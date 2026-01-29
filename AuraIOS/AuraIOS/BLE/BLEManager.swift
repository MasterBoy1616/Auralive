import Foundation
import CoreBluetooth
import UIKit

protocol BLEManagerDelegate: AnyObject {
    func didReceiveMatchRequest(from userHash: String, gender: String)
    func didReceiveMatchResponse(from userHash: String, accepted: Bool)
    func didReceiveChatMessage(from userHash: String, message: String)
    func didReceiveUnmatch(from userHash: String)
    func didReceiveBlock(from userHash: String)
    func didDiscoverNearbyUser(_ user: NearbyUser)
    func didLoseNearbyUser(userHash: String)
}

struct NearbyUser {
    let userHash: String
    let userName: String
    let gender: String
    let rssi: Int
    let lastSeen: Date
    let deviceAddress: String
}

class BLEManager: NSObject {
    static let shared = BLEManager()
    
    // Core Bluetooth
    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    
    // State
    private var isScanning = false
    private var isAdvertising = false
    private var nearbyUsers: [String: NearbyUser] = [:]
    private var messageQueue: [BLEPacket] = []
    private var currentFrameIndex = 0
    
    // Delegates - Fixed memory leak with weak references
    weak var delegate: BLEManagerDelegate?
    private var delegates: [WeakBLEManagerDelegate] = []
    
    private struct WeakBLEManagerDelegate {
        weak var delegate: BLEManagerDelegate?
    }
    
    // Timers
    private var advertisingTimer: Timer?
    private var cleanupTimer: Timer?
    
    // Message reassembly cache
    private var reassemblyCache: [String: ChunkCollector] = [:]
    private let reassemblyTimeout: TimeInterval = 10.0
    
    private struct ChunkCollector {
        var chunks: [Int: Data] = [:]
        let totalChunks: Int
        let timestamp: Date = Date()
    }
    
    // Constants
    private let advertisingRotationInterval: TimeInterval = 0.3
    private let nearbyUserTimeout: TimeInterval = 60.0
    
    private override init() {
        super.init()
    }
    
    func initialize() {
        print("🔍 BLE Manager initializing...")
        print("📱 Device: \(UIDevice.current.model)")
        print("📱 iOS version: \(UIDevice.current.systemVersion)")
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        // Start cleanup timer
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            self.cleanupNearbyUsers()
        }
        
        checkDeviceCompatibility()
    }
    
    private func checkDeviceCompatibility() {
        let deviceModel = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        
        print("🏭 DEVICE_CHECK: \(deviceModel) iOS \(systemVersion)")
        
        if #available(iOS 13.0, *) {
            print("✅ iOS version compatible")
        } else {
            print("⚠️ iOS version may have limitations")
        }
    }
    
    // MARK: - Public Methods
    
    func addDelegate(_ delegate: BLEManagerDelegate) {
        delegates.append(WeakBLEManagerDelegate(delegate: delegate))
        cleanupDelegates()
    }
    
    func removeDelegate(_ delegate: BLEManagerDelegate) {
        delegates.removeAll { $0.delegate === delegate }
    }
    
    private func cleanupDelegates() {
        delegates.removeAll { $0.delegate == nil }
    }
    
    private func notifyDelegates(_ action: (BLEManagerDelegate) -> Void) {
        cleanupDelegates()
        delegates.compactMap { $0.delegate }.forEach(action)
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("❌ Bluetooth not powered on")
            return
        }
        
        if isScanning {
            print("🔍 Already scanning")
            return
        }
        
        print("🔍 Starting BLE scan...")
        
        // Scan for devices with manufacturer data
        let scanOptions: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: true
        ]
        
        centralManager.scanForPeripherals(withServices: nil, options: scanOptions)
        isScanning = true
    }
    
    func stopScanning() {
        guard isScanning else { return }
        
        print("🛑 Stopping BLE scan")
        centralManager.stopScan()
        isScanning = false
    }
    
    func startAdvertising() {
        guard peripheralManager.state == .poweredOn else {
            print("❌ Peripheral manager not powered on")
            return
        }
        
        if isAdvertising {
            print("📡 Already advertising")
            return
        }
        
        print("📡 Starting BLE advertising...")
        
        let userPrefs = UserPreferences.shared
        guard let gender = userPrefs.gender else {
            print("❌ No gender set, cannot advertise")
            return
        }
        
        // Start with presence frames with user name and gender
        messageQueue.removeAll()
        let presencePackets = BLEPacket.createPresenceWithNameAndGender(
            from: userPrefs.userHash,
            userName: userPrefs.userName,
            gender: gender
        )
        messageQueue.append(contentsOf: presencePackets)
        currentFrameIndex = 0
        
        startAdvertisingRotation()
        isAdvertising = true
        
        print("✅ BLE advertising started with user hash: \(userPrefs.userHash)")
    }
    
    func stopAdvertising() {
        guard isAdvertising else { return }
        
        print("📡 Stopping BLE advertising")
        peripheralManager.stopAdvertising()
        isAdvertising = false
        
        advertisingTimer?.invalidate()
        advertisingTimer = nil
        messageQueue.removeAll()
    }
    
    // MARK: - Message Sending
    
    func sendMatchRequest(to userHash: String) {
        let packet = BLEPacket.createMatchRequest(
            from: UserPreferences.shared.userHash,
            to: userHash,
            senderGender: UserPreferences.shared.gender?.rawValue ?? "U"
        )
        enqueueMessage(packet)
    }
    
    func sendMatchResponse(to userHash: String, accepted: Bool) {
        let packet = BLEPacket.createMatchResponse(
            from: UserPreferences.shared.userHash,
            to: userHash,
            accepted: accepted,
            responderGender: UserPreferences.shared.gender?.rawValue ?? "U"
        )
        enqueueMessage(packet)
    }
    
    func sendChatMessage(to userHash: String, message: String) {
        let packets = BLEPacket.createChatMessage(
            from: UserPreferences.shared.userHash,
            to: userHash,
            message: message
        )
        
        // Send multiple times for reliability
        for _ in 0..<3 {
            packets.forEach { enqueueMessage($0) }
        }
    }
    
    func sendUnmatch(to userHash: String) {
        let packet = BLEPacket.createUnmatch(
            from: UserPreferences.shared.userHash,
            to: userHash
        )
        
        // Send multiple times for reliability
        for _ in 0..<3 {
            enqueueMessage(packet)
        }
    }
    
    func sendBlock(to userHash: String) {
        let packet = BLEPacket.createBlock(
            from: UserPreferences.shared.userHash,
            to: userHash
        )
        
        // Send multiple times for reliability
        for _ in 0..<3 {
            enqueueMessage(packet)
        }
    }
    
    private func enqueueMessage(_ packet: BLEPacket) {
        messageQueue.append(packet)
        
        // Start advertising if not already
        if !isAdvertising {
            startAdvertising()
        }
    }
    
    private func startAdvertisingRotation() {
        advertisingTimer?.invalidate()
        
        advertisingTimer = Timer.scheduledTimer(withTimeInterval: advertisingRotationInterval, repeats: true) { _ in
            self.rotateAdvertisingData()
        }
    }
    
    private func rotateAdvertisingData() {
        guard isAdvertising && !messageQueue.isEmpty else { return }
        
        let packet = messageQueue[currentFrameIndex % messageQueue.count]
        currentFrameIndex += 1
        
        // Update advertising data with packet
        updateAdvertisingData(with: packet)
        
        // Clean up old messages after cycling through them multiple times
        if currentFrameIndex >= messageQueue.count * 3 {
            // Keep only presence packets and recent messages
            let userPrefs = UserPreferences.shared
            if let gender = userPrefs.gender {
                let presencePackets = BLEPacket.createPresenceWithNameAndGender(
                    from: userPrefs.userHash,
                    userName: userPrefs.userName,
                    gender: gender
                )
                messageQueue = presencePackets
                currentFrameIndex = 0
            }
        }
    }
    
    private func updateAdvertisingData(with packet: BLEPacket) {
        peripheralManager.stopAdvertising()
        
        let packetData = packet.encode()
        let advertisementData: [String: Any] = [
            CBAdvertisementDataManufacturerDataKey: [BLEPacket.companyId: packetData]
        ]
        
        peripheralManager.startAdvertising(advertisementData)
    }
    
    // MARK: - Background Support
    
    func enterBackground() {
        print("📱 Entering background mode")
        // Keep scanning for incoming messages
        if !isScanning {
            startScanning()
        }
    }
    
    func enterForeground() {
        print("📱 Entering foreground mode")
        // Resume full functionality
        if UserPreferences.shared.isVisibilityEnabled && !isAdvertising {
            startAdvertising()
        }
    }
    
    // MARK: - Cleanup
    
    private func cleanupNearbyUsers() {
        let now = Date()
        
        nearbyUsers = nearbyUsers.filter { _, user in
            let isRecent = now.timeIntervalSince(user.lastSeen) < nearbyUserTimeout
            if !isRecent {
                delegates.forEach { $0.didLoseNearbyUser(userHash: user.userHash) }
            }
            return isRecent
        }
        
        // Clean up reassembly cache
        let iterator = reassemblyCache.filter { _, collector in
            now.timeIntervalSince(collector.timestamp) < reassemblyTimeout
        }
        reassemblyCache = iterator
    }
    
    // MARK: - Public Properties
    
    var isAdvertisingActive: Bool {
        return isAdvertising
    }
    
    var isScanningActive: Bool {
        return isScanning
    }
}

// MARK: - CBCentralManagerDelegate

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("📡 Central manager state: \(central.state.rawValue)")
        
        switch central.state {
        case .poweredOn:
            print("✅ Bluetooth powered on")
            if UserPreferences.shared.isVisibilityEnabled {
                startScanning()
            }
        case .poweredOff:
            print("❌ Bluetooth powered off")
            stopScanning()
        case .unauthorized:
            print("❌ Bluetooth unauthorized")
        case .unsupported:
            print("❌ Bluetooth unsupported")
        default:
            print("⚠️ Bluetooth state unknown")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // Parse packet data from manufacturer data
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? [NSNumber: Data] {
            for (companyId, data) in manufacturerData {
                if companyId.uint16Value == BLEPacket.companyId {
                    parsePacketData(data, from: peripheral.identifier.uuidString, rssi: RSSI.intValue)
                }
            }
        }
    }
    
    private func parsePacketData(_ data: Data, from deviceAddress: String, rssi: Int) {
        guard let packet = BLEPacket.decode(from: data) else { return }
        
        let senderHashHex = packet.senderHash.hexString
        let targetHashHex = packet.targetHash.hexString
        let myHashHex = UserPreferences.shared.userHash.lowercased()
        
        print("🔍 PACKET_DECODED: type=\(String(format: "%02x", packet.type.rawValue)), sender=\(senderHashHex), target=\(targetHashHex), me=\(myHashHex)")
        
        // Update nearby users for presence and other frames
        if packet.type == .presence || senderHashHex != myHashHex {
            var userName = "User\(senderHashHex.prefix(4).uppercased())"
            var gender = "U"
            
            if packet.type == .presence && packet.isComplete && packet.completeMessage != nil {
                // Multi-chunk presence - completeMessage contains gender+name
                if let data = packet.completeMessage?.data(using: .utf8), !data.isEmpty {
                    gender = data[0] == 0x01 ? "M" : (data[0] == 0x02 ? "F" : "U")
                    if data.count > 1 {
                        userName = String(data: data.dropFirst(), encoding: .utf8) ?? userName
                    }
                }
            } else if packet.type == .presence && !packet.chunkData.isEmpty {
                // Single chunk presence with gender+name
                let data = packet.chunkData
                if !data.isEmpty {
                    gender = data[0] == 0x01 ? "M" : (data[0] == 0x02 ? "F" : "U")
                    if data.count > 1 {
                        userName = String(data: data.dropFirst(), encoding: .utf8) ?? userName
                    }
                }
            }
            
            updateNearbyUser(userHash: senderHashHex, deviceAddress: deviceAddress, rssi: rssi, userName: userName, gender: gender)
        }
        
        // Skip our own frames
        if senderHashHex == myHashHex {
            print("🔍 SKIP_OWN: Skipping own frame")
            return
        }
        
        // Handle targeted frames
        switch packet.type {
        case .matchRequest:
            print("🎯 MATCH_REQ: Processing match request from \(senderHashHex) to \(targetHashHex)")
            
            if targetHashHex == myHashHex {
                let senderGender = !packet.chunkData.isEmpty ? (packet.chunkData[0] == 0x01 ? "M" : (packet.chunkData[0] == 0x02 ? "F" : "U")) : "U"
                print("✅ MATCH_REQ: This is for ME! From \(senderHashHex) (gender: \(senderGender))")
                notifyDelegates { $0.didReceiveMatchRequest(from: senderHashHex, gender: senderGender) }
            }
            
        case .matchAccept:
            print("🎯 MATCH_ACC: Processing match accept from \(senderHashHex) to \(targetHashHex)")
            
            if targetHashHex == myHashHex {
                let responderGender = !packet.chunkData.isEmpty ? (packet.chunkData[0] == 0x01 ? "M" : (packet.chunkData[0] == 0x02 ? "F" : "U")) : "U"
                print("✅ MATCH_ACCEPT: This is for ME! From \(senderHashHex) (gender: \(responderGender))")
                
                // Store match
                storeMatch(userHash: senderHashHex, gender: responderGender)
                
                notifyDelegates { $0.didReceiveMatchResponse(from: senderHashHex, accepted: true) }
            }
            
        case .matchReject:
            if targetHashHex == myHashHex {
                print("MATCH: rejected from \(senderHashHex)")
                delegates.forEach { $0.didReceiveMatchResponse(from: senderHashHex, accepted: false) }
            }
            
        case .chatMessage:
            print("💬 CHAT packet received from \(senderHashHex) to \(targetHashHex)")
            
            if targetHashHex == myHashHex {
                if packet.isComplete, let message = packet.completeMessage {
                    print("💬 CHAT: Processing complete message from \(senderHashHex)")
                    delegates.forEach { $0.didReceiveChatMessage(from: senderHashHex, message: message) }
                } else {
                    // Handle multi-chunk message reassembly
                    handleMultiChunkMessage(packet)
                }
            }
            
        case .unmatch:
            print("💔 UNMATCH packet received from \(senderHashHex) to \(targetHashHex)")
            
            if targetHashHex == myHashHex {
                print("💔 UNMATCH: Processing unmatch from \(senderHashHex)")
                delegates.forEach { $0.didReceiveUnmatch(from: senderHashHex) }
            }
            
        case .block:
            print("🚫 BLOCK packet received from \(senderHashHex) to \(targetHashHex)")
            
            if targetHashHex == myHashHex {
                print("🚫 BLOCK: Processing block from \(senderHashHex)")
                delegates.forEach { $0.didReceiveBlock(from: senderHashHex) }
            }
            
        default:
            break
        }
    }
    
    private func handleMultiChunkMessage(_ packet: BLEPacket) {
        let cacheKey = "\(packet.senderHash.hexString)-\(packet.targetHash.hexString)-\(packet.msgId)"
        
        if reassemblyCache[cacheKey] == nil {
            reassemblyCache[cacheKey] = ChunkCollector(totalChunks: Int(packet.chunkTotal))
        }
        
        guard var collector = reassemblyCache[cacheKey] else { return }
        
        // Add chunk
        collector.chunks[Int(packet.chunkIndex)] = packet.chunkData
        reassemblyCache[cacheKey] = collector
        
        // Check if complete
        if collector.chunks.count == collector.totalChunks {
            // Reassemble message
            var completeData = Data()
            for i in 0..<collector.totalChunks {
                if let chunk = collector.chunks[i] {
                    completeData.append(chunk)
                }
            }
            
            if let completeMessage = String(data: completeData, encoding: .utf8) {
                print("💬 CHAT: Reassembled complete message from \(packet.senderHash.hexString)")
                delegates.forEach { $0.didReceiveChatMessage(from: packet.senderHash.hexString, message: completeMessage) }
            }
            
            reassemblyCache.removeValue(forKey: cacheKey)
        }
    }
    
    private func updateNearbyUser(userHash: String, deviceAddress: String, rssi: Int, userName: String, gender: String) {
        let user = NearbyUser(
            userHash: userHash,
            userName: userName,
            gender: gender,
            rssi: rssi,
            lastSeen: Date(),
            deviceAddress: deviceAddress
        )
        
        let isNewUser = nearbyUsers[userHash] == nil
        nearbyUsers[userHash] = user
        
        if isNewUser {
            notifyDelegates { $0.didDiscoverNearbyUser(user) }
        }
    }
    
    private func storeMatch(userHash: String, gender: String) {
        let userName = nearbyUsers[userHash]?.userName ?? "User\(userHash.prefix(4).uppercased())"
        let match = Match(userHash: userHash, userName: userName, gender: gender)
        MatchStore.shared.storeMatch(match)
        print("✅ STORE_MATCH: Successfully stored match with \(userHash)")
    }
}

// MARK: - CBPeripheralManagerDelegate

extension BLEManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("📡 Peripheral manager state: \(peripheral.state.rawValue)")
        
        switch peripheral.state {
        case .poweredOn:
            print("✅ Peripheral powered on")
            if UserPreferences.shared.isVisibilityEnabled {
                startAdvertising()
            }
        case .poweredOff:
            print("❌ Peripheral powered off")
            stopAdvertising()
        case .unauthorized:
            print("❌ Peripheral unauthorized")
        case .unsupported:
            print("❌ Peripheral unsupported")
        default:
            print("⚠️ Peripheral state unknown")
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("❌ Advertising failed: \(error.localizedDescription)")
            isAdvertising = false
        } else {
            print("✅ Advertising started successfully")
        }
    }
}