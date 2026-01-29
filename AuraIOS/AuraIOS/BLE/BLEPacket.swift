import Foundation

enum BLEPacketType: UInt8 {
    case presence = 0x01
    case matchRequest = 0x02
    case matchAccept = 0x03
    case matchReject = 0x04
    case chatMessage = 0x05
    case unmatch = 0x06
    case block = 0x07
    case photoRequest = 0x08
    case photo = 0x09
}

struct BLEPacket {
    static let companyId: UInt16 = 0xFFFF
    static let maxPayloadSize = 16 // BLE advertising limit
    
    let type: BLEPacketType
    let senderHash: Data
    let targetHash: Data
    let msgId: UInt16
    let chunkIndex: UInt8
    let chunkTotal: UInt8
    let chunkData: Data
    
    // Computed properties
    var isComplete: Bool {
        return chunkTotal == 1 || (chunkIndex == chunkTotal - 1)
    }
    
    var completeMessage: String? {
        if chunkTotal == 1 {
            return String(data: chunkData, encoding: .utf8)
        }
        return nil
    }
    
    // MARK: - Encoding
    
    func encode() -> Data {
        var data = Data()
        
        // Header (1 byte)
        data.append(type.rawValue)
        
        // Sender hash (4 bytes)
        data.append(senderHash.prefix(4))
        
        // Target hash (4 bytes)
        data.append(targetHash.prefix(4))
        
        // Message ID (2 bytes)
        data.append(contentsOf: withUnsafeBytes(of: msgId.bigEndian) { Array($0) })
        
        // Chunk info (2 bytes)
        data.append(chunkIndex)
        data.append(chunkTotal)
        
        // Payload (remaining bytes, max 3 for 16-byte limit)
        let remainingSpace = maxPayloadSize - data.count
        let payload = chunkData.prefix(remainingSpace)
        data.append(payload)
        
        return data
    }
    
    // MARK: - Decoding
    
    static func decode(from data: Data) -> BLEPacket? {
        guard data.count >= 13 else { return nil } // Minimum packet size
        
        var offset = 0
        
        // Type
        guard let type = BLEPacketType(rawValue: data[offset]) else { return nil }
        offset += 1
        
        // Sender hash
        let senderHash = data.subdata(in: offset..<offset+4)
        offset += 4
        
        // Target hash
        let targetHash = data.subdata(in: offset..<offset+4)
        offset += 4
        
        // Message ID
        let msgIdData = data.subdata(in: offset..<offset+2)
        let msgId = msgIdData.withUnsafeBytes { $0.load(as: UInt16.self).bigEndian }
        offset += 2
        
        // Chunk info
        let chunkIndex = data[offset]
        offset += 1
        let chunkTotal = data[offset]
        offset += 1
        
        // Payload
        let chunkData = data.subdata(in: offset..<data.count)
        
        return BLEPacket(
            type: type,
            senderHash: senderHash,
            targetHash: targetHash,
            msgId: msgId,
            chunkIndex: chunkIndex,
            chunkTotal: chunkTotal,
            chunkData: chunkData
        )
    }
    
    // MARK: - Factory Methods
    
    static func createPresenceWithNameAndGender(from senderHash: String, userName: String, gender: Gender) -> [BLEPacket] {
        let senderHashData = Data(senderHash.prefix(8).hexadecimal ?? [])
        let targetHashData = Data(repeating: 0, count: 4) // Broadcast
        
        // Create payload: gender byte + username
        var payload = Data()
        payload.append(gender == .male ? 0x01 : 0x02)
        if let nameData = userName.data(using: .utf8) {
            payload.append(nameData)
        }
        
        return createMultiChunkPackets(
            type: .presence,
            senderHash: senderHashData,
            targetHash: targetHashData,
            payload: payload
        )
    }
    
    static func createMatchRequest(from senderHash: String, to targetHash: String, senderGender: String) -> BLEPacket {
        let senderHashData = Data(senderHash.prefix(8).hexadecimal ?? [])
        let targetHashData = Data(targetHash.prefix(8).hexadecimal ?? [])
        
        var payload = Data()
        payload.append(senderGender == "M" ? 0x01 : 0x02)
        
        return BLEPacket(
            type: .matchRequest,
            senderHash: senderHashData,
            targetHash: targetHashData,
            msgId: UInt16.random(in: 1...65535),
            chunkIndex: 0,
            chunkTotal: 1,
            chunkData: payload
        )
    }
    
    static func createMatchResponse(from senderHash: String, to targetHash: String, accepted: Bool, responderGender: String) -> BLEPacket {
        let senderHashData = Data(senderHash.prefix(8).hexadecimal ?? [])
        let targetHashData = Data(targetHash.prefix(8).hexadecimal ?? [])
        
        var payload = Data()
        payload.append(responderGender == "M" ? 0x01 : 0x02)
        
        return BLEPacket(
            type: accepted ? .matchAccept : .matchReject,
            senderHash: senderHashData,
            targetHash: targetHashData,
            msgId: UInt16.random(in: 1...65535),
            chunkIndex: 0,
            chunkTotal: 1,
            chunkData: payload
        )
    }
    
    static func createChatMessage(from senderHash: String, to targetHash: String, message: String) -> [BLEPacket] {
        let senderHashData = Data(senderHash.prefix(8).hexadecimal ?? [])
        let targetHashData = Data(targetHash.prefix(8).hexadecimal ?? [])
        
        guard let messageData = message.data(using: .utf8) else { return [] }
        
        return createMultiChunkPackets(
            type: .chatMessage,
            senderHash: senderHashData,
            targetHash: targetHashData,
            payload: messageData
        )
    }
    
    static func createUnmatch(from senderHash: String, to targetHash: String) -> BLEPacket {
        let senderHashData = Data(senderHash.prefix(8).hexadecimal ?? [])
        let targetHashData = Data(targetHash.prefix(8).hexadecimal ?? [])
        
        return BLEPacket(
            type: .unmatch,
            senderHash: senderHashData,
            targetHash: targetHashData,
            msgId: UInt16.random(in: 1...65535),
            chunkIndex: 0,
            chunkTotal: 1,
            chunkData: Data()
        )
    }
    
    static func createBlock(from senderHash: String, to targetHash: String) -> BLEPacket {
        let senderHashData = Data(senderHash.prefix(8).hexadecimal ?? [])
        let targetHashData = Data(targetHash.prefix(8).hexadecimal ?? [])
        
        return BLEPacket(
            type: .block,
            senderHash: senderHashData,
            targetHash: targetHashData,
            msgId: UInt16.random(in: 1...65535),
            chunkIndex: 0,
            chunkTotal: 1,
            chunkData: Data()
        )
    }
    
    // MARK: - Multi-chunk Support
    
    private static func createMultiChunkPackets(type: BLEPacketType, senderHash: Data, targetHash: Data, payload: Data) -> [BLEPacket] {
        let maxChunkSize = 3 // Remaining space after headers
        let msgId = UInt16.random(in: 1...65535)
        
        if payload.count <= maxChunkSize {
            // Single chunk
            return [BLEPacket(
                type: type,
                senderHash: senderHash,
                targetHash: targetHash,
                msgId: msgId,
                chunkIndex: 0,
                chunkTotal: 1,
                chunkData: payload
            )]
        }
        
        // Multiple chunks
        var packets: [BLEPacket] = []
        let totalChunks = UInt8((payload.count + maxChunkSize - 1) / maxChunkSize)
        
        for chunkIndex in 0..<totalChunks {
            let startIndex = Int(chunkIndex) * maxChunkSize
            let endIndex = min(startIndex + maxChunkSize, payload.count)
            let chunkData = payload.subdata(in: startIndex..<endIndex)
            
            let packet = BLEPacket(
                type: type,
                senderHash: senderHash,
                targetHash: targetHash,
                msgId: msgId,
                chunkIndex: chunkIndex,
                chunkTotal: totalChunks,
                chunkData: chunkData
            )
            
            packets.append(packet)
        }
        
        return packets
    }
}

// MARK: - Data Extensions
extension Data {
    var hexString: String {
        return map { String(format: "%02x", $0) }.joined()
    }
}

extension String {
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        return data
    }
}