import Foundation
import CommonCrypto

/// BLE-only packet framing and chunking for manufacturer data
/// Max payload: 24 bytes after companyId (0xFFFF)
///
/// Packet format - EXACTLY matching Android:
/// Byte0: version (0x01)
/// Byte1: type (0x01=PRESENCE, 0x02=MATCH_REQ, 0x03=MATCH_ACC, 0x04=MATCH_REJ, 0x05=CHAT)
/// Byte2..5: senderHash (4 bytes)
/// Byte6..9: targetHash (4 bytes) (0x00000000 if broadcast/presence)
/// Byte10: msgId (0..255 rolling)
/// Byte11: chunkIndex
/// Byte12: chunkTotal
/// Byte13..(end): chunkData (UTF-8 bytes for chat OR reserved for match)

class BLEPacket {
    
    // Company ID for manufacturer data
    static let COMPANY_ID: UInt16 = 0xFFFF
    
    // Protocol version
    private static let VERSION: UInt8 = 0x01
    
    // Packet types
    static let TYPE_PRESENCE: UInt8 = 0x01
    static let TYPE_MATCH_REQ: UInt8 = 0x02
    static let TYPE_MATCH_ACC: UInt8 = 0x03
    static let TYPE_MATCH_REJ: UInt8 = 0x04
    static let TYPE_CHAT: UInt8 = 0x05
    static let TYPE_UNMATCH: UInt8 = 0x06
    static let TYPE_BLOCK: UInt8 = 0x07
    static let TYPE_PHOTO: UInt8 = 0x08
    static let TYPE_PHOTO_REQUEST: UInt8 = 0x09
    
    // Packet structure constants
    private static let HEADER_SIZE = 13
    private static let MAX_PAYLOAD_SIZE = 24
    private static let MAX_CHUNK_DATA = MAX_PAYLOAD_SIZE - HEADER_SIZE // 11 bytes per chunk
    
    // Reassembly cache
    private static var reassemblyCache: [String: ChunkCollector] = [:]
    private static let REASSEMBLY_TIMEOUT_MS: TimeInterval = 10.0
    
    struct DecodedFrame {
        let type: UInt8
        let senderHash: Data
        let targetHash: Data
        let msgId: Int
        let chunkIndex: Int
        let chunkTotal: Int
        let chunkData: Data
        let isComplete: Bool
        let completeMessage: String?
    }
    
    private struct ChunkCollector {
        var chunks: [Int: Data] = [:]
        let totalChunks: Int
        let timestamp: Date = Date()
    }
    
    /// Hash userId to stable 4-byte hash - EXACTLY matching Android
    static func hashUserIdTo4Bytes(_ userId: String) -> Data {
        guard let data = userId.data(using: .utf8) else {
            return Data(repeating: 0, count: 4)
        }
        
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        
        return Data(hash.prefix(4))
    }
    
    /// Encode presence broadcast - EXACTLY matching Android
    static func encodePresence(senderHash: Data) -> Data {
        assert(senderHash.count == 4, "senderHash must be 4 bytes")
        
        var packet = Data(count: 13)
        packet[0] = VERSION
        packet[1] = TYPE_PRESENCE
        packet.replaceSubrange(2..<6, with: senderHash)
        // targetHash = 0x00000000 for broadcast
        packet[10] = 0 // msgId
        packet[11] = 0 // chunkIndex
        packet[12] = 1 // chunkTotal
        
        return packet
    }
    
    /// Encode presence with name and gender - EXACTLY matching Android
    static func encodePresenceWithNameAndGender(senderHash: Data, userName: String, gender: UInt8) -> [Data] {
        assert(senderHash.count == 4, "senderHash must be 4 bytes")
        
        // Combine gender and userName: [gender][userName]
        var genderAndNameData = Data([gender])
        if let nameData = userName.data(using: .utf8) {
            genderAndNameData.append(nameData)
        }
        
        let msgId = UInt8(Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 256))
        
        // If data fits in single packet
        if genderAndNameData.count <= MAX_CHUNK_DATA {
            var packet = Data(count: HEADER_SIZE + genderAndNameData.count)
            packet[0] = VERSION
            packet[1] = TYPE_PRESENCE
            packet.replaceSubrange(2..<6, with: senderHash)
            // targetHash = 0x00000000 for broadcast
            packet[10] = msgId
            packet[11] = 0 // chunkIndex
            packet[12] = 1 // chunkTotal
            packet.replaceSubrange(HEADER_SIZE..<(HEADER_SIZE + genderAndNameData.count), with: genderAndNameData)
            
            return [packet]
        } else {
            // Multi-chunk (unlikely but handle it)
            let totalChunks = (genderAndNameData.count + MAX_CHUNK_DATA - 1) / MAX_CHUNK_DATA
            var chunks: [Data] = []
            
            for chunkIndex in 0..<totalChunks {
                let startOffset = chunkIndex * MAX_CHUNK_DATA
                let endOffset = min(startOffset + MAX_CHUNK_DATA, genderAndNameData.count)
                let chunkData = genderAndNameData.subdata(in: startOffset..<endOffset)
                
                var packet = Data(count: HEADER_SIZE + chunkData.count)
                packet[0] = VERSION
                packet[1] = TYPE_PRESENCE
                packet.replaceSubrange(2..<6, with: senderHash)
                // targetHash = 0x00000000
                packet[10] = msgId
                packet[11] = UInt8(chunkIndex)
                packet[12] = UInt8(totalChunks)
                packet.replaceSubrange(HEADER_SIZE..<(HEADER_SIZE + chunkData.count), with: chunkData)
                
                chunks.append(packet)
            }
            
            return chunks
        }
    }
    
    /// Encode match request - EXACTLY matching Android
    /// PROTOCOL: Request payload contains SENDER identity, targetHash only for routing
    static func encodeMatchReq(senderHash: Data, senderGender: UInt8, targetHash: Data) -> Data {
        assert(senderHash.count == 4, "senderHash must be 4 bytes")
        assert(targetHash.count == 4, "targetHash must be 4 bytes")
        
        var packet = Data(count: 14)
        packet[0] = VERSION
        packet[1] = TYPE_MATCH_REQ
        packet.replaceSubrange(2..<6, with: senderHash)
        packet[6] = senderGender // SENDER gender in payload
        packet.replaceSubrange(7..<11, with: targetHash)
        packet[11] = UInt8(Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 256))
        packet[12] = 0 // chunkIndex
        packet[13] = 1 // chunkTotal
        
        return packet
    }
    
    /// Encode match response - EXACTLY matching Android
    static func encodeMatchResp(type: UInt8, responderHash: Data, responderGender: UInt8, targetHash: Data) -> Data {
        assert(type == TYPE_MATCH_ACC || type == TYPE_MATCH_REJ, "Invalid response type")
        assert(responderHash.count == 4, "responderHash must be 4 bytes")
        assert(targetHash.count == 4, "targetHash must be 4 bytes")
        
        var packet = Data(count: 14)
        packet[0] = VERSION
        packet[1] = type
        packet.replaceSubrange(2..<6, with: responderHash)
        packet[6] = responderGender // RESPONDER gender in payload
        packet.replaceSubrange(7..<11, with: targetHash)
        packet[11] = UInt8(Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 256))
        packet[12] = 0 // chunkIndex
        packet[13] = 1 // chunkTotal
        
        return packet
    }
    
    /// Encode chat message - EXACTLY matching Android
    static func encodeChat(senderHash: Data, targetHash: Data, message: String) -> [Data] {
        assert(senderHash.count == 4, "senderHash must be 4 bytes")
        assert(targetHash.count == 4, "targetHash must be 4 bytes")
        
        guard let messageData = message.data(using: .utf8) else {
            return []
        }
        
        let msgId = UInt8(Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 256))
        let totalChunks = (messageData.count + MAX_CHUNK_DATA - 1) / MAX_CHUNK_DATA
        var chunks: [Data] = []
        
        for chunkIndex in 0..<totalChunks {
            let startOffset = chunkIndex * MAX_CHUNK_DATA
            let endOffset = min(startOffset + MAX_CHUNK_DATA, messageData.count)
            let chunkData = messageData.subdata(in: startOffset..<endOffset)
            
            var packet = Data(count: HEADER_SIZE + chunkData.count)
            packet[0] = VERSION
            packet[1] = TYPE_CHAT
            packet.replaceSubrange(2..<6, with: senderHash)
            packet.replaceSubrange(6..<10, with: targetHash)
            packet[10] = msgId
            packet[11] = UInt8(chunkIndex)
            packet[12] = UInt8(totalChunks)
            packet.replaceSubrange(HEADER_SIZE..<(HEADER_SIZE + chunkData.count), with: chunkData)
            
            chunks.append(packet)
        }
        
        print("📦 BLEPacket: Encoded chat message: \(message.count) chars -> \(chunks.count) chunks")
        return chunks
    }
    
    /// Encode unmatch - EXACTLY matching Android
    static func encodeUnmatch(senderHash: Data, targetHash: Data) -> [Data] {
        assert(senderHash.count == 4, "senderHash must be 4 bytes")
        assert(targetHash.count == 4, "targetHash must be 4 bytes")
        
        let msgId = UInt8(Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 256))
        
        var packet = Data(count: HEADER_SIZE)
        packet[0] = VERSION
        packet[1] = TYPE_UNMATCH
        packet.replaceSubrange(2..<6, with: senderHash)
        packet.replaceSubrange(6..<10, with: targetHash)
        packet[10] = msgId
        packet[11] = 0
        packet[12] = 1
        
        return [packet]
    }
    
    /// Encode block - EXACTLY matching Android
    static func encodeBlock(senderHash: Data, targetHash: Data) -> [Data] {
        assert(senderHash.count == 4, "senderHash must be 4 bytes")
        assert(targetHash.count == 4, "targetHash must be 4 bytes")
        
        let msgId = UInt8(Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 256))
        
        var packet = Data(count: HEADER_SIZE)
        packet[0] = VERSION
        packet[1] = TYPE_BLOCK
        packet.replaceSubrange(2..<6, with: senderHash)
        packet.replaceSubrange(6..<10, with: targetHash)
        packet[10] = msgId
        packet[11] = 0
        packet[12] = 1
        
        return [packet]
    }
    
    /// Decode packet - EXACTLY matching Android
    static func decode(_ data: Data) -> DecodedFrame? {
        // Minimum size check
        let minSize = (data.count >= 2 && (data[1] == TYPE_MATCH_REQ || data[1] == TYPE_MATCH_ACC || data[1] == TYPE_MATCH_REJ)) ? 14 : 13
        
        guard data.count >= minSize else {
            print("⚠️ BLEPacket: Packet too small: \(data.count) bytes, expected: \(minSize)")
            return nil
        }
        
        // Check version
        guard data[0] == VERSION else {
            print("⚠️ BLEPacket: Unknown version: \(data[0])")
            return nil
        }
        
        let type = data[1]
        
        // Parse based on packet type
        let (senderHash, targetHash, msgId, chunkIndex, chunkTotal, chunkData): (Data, Data, Int, Int, Int, Data)
        
        if type == TYPE_MATCH_REQ || type == TYPE_MATCH_ACC || type == TYPE_MATCH_REJ {
            // New format with gender byte
            senderHash = data.subdata(in: 2..<6)
            let senderGender = data[6]
            targetHash = data.subdata(in: 7..<11)
            msgId = Int(data[11])
            chunkIndex = Int(data[12])
            chunkTotal = Int(data[13])
            chunkData = Data([senderGender]) // Store gender as chunk data
        } else {
            // Old format
            senderHash = data.subdata(in: 2..<6)
            targetHash = data.subdata(in: 6..<10)
            msgId = Int(data[10])
            chunkIndex = Int(data[11])
            chunkTotal = Int(data[12])
            chunkData = data.count > 13 ? data.subdata(in: 13..<data.count) : Data()
        }
        
        print("📦 BLEPacket: rx type=\(String(format: "%02x", type)) sender=\(senderHash.hexString) target=\(targetHash.hexString) msgId=\(msgId) chunk \(chunkIndex)/\(chunkTotal)")
        
        // Handle single-chunk messages
        if chunkTotal == 1 {
            let completeMessage = (type == TYPE_CHAT) ? String(data: chunkData, encoding: .utf8) : nil
            return DecodedFrame(type: type, senderHash: senderHash, targetHash: targetHash, msgId: msgId, chunkIndex: chunkIndex, chunkTotal: chunkTotal, chunkData: chunkData, isComplete: true, completeMessage: completeMessage)
        }
        
        // Handle multi-chunk messages (chat only)
        if type == TYPE_CHAT {
            let cacheKey = "\(senderHash.hexString)-\(targetHash.hexString)-\(msgId)"
            
            cleanupReassemblyCache()
            
            if reassemblyCache[cacheKey] == nil {
                reassemblyCache[cacheKey] = ChunkCollector(totalChunks: chunkTotal)
            }
            
            reassemblyCache[cacheKey]?.chunks[chunkIndex] = chunkData
            
            if let collector = reassemblyCache[cacheKey], collector.chunks.count == chunkTotal {
                // Reassemble
                var completeData = Data()
                for i in 0..<chunkTotal {
                    if let chunk = collector.chunks[i] {
                        completeData.append(chunk)
                    }
                }
                
                let completeMessage = String(data: completeData, encoding: .utf8)
                reassemblyCache.removeValue(forKey: cacheKey)
                
                print("📦 BLEPacket: CHAT reassembled complete message from \(senderHash.hexString)")
                return DecodedFrame(type: type, senderHash: senderHash, targetHash: targetHash, msgId: msgId, chunkIndex: chunkIndex, chunkTotal: chunkTotal, chunkData: chunkData, isComplete: true, completeMessage: completeMessage)
            } else {
                print("📦 BLEPacket: CHAT partial chunk from \(senderHash.hexString)")
                return DecodedFrame(type: type, senderHash: senderHash, targetHash: targetHash, msgId: msgId, chunkIndex: chunkIndex, chunkTotal: chunkTotal, chunkData: chunkData, isComplete: false, completeMessage: nil)
            }
        }
        
        return DecodedFrame(type: type, senderHash: senderHash, targetHash: targetHash, msgId: msgId, chunkIndex: chunkIndex, chunkTotal: chunkTotal, chunkData: chunkData, isComplete: false, completeMessage: nil)
    }
    
    private static func cleanupReassemblyCache() {
        let now = Date()
        reassemblyCache = reassemblyCache.filter { now.timeIntervalSince($0.value.timestamp) < REASSEMBLY_TIMEOUT_MS }
    }
}

// MARK: - Data Extension
extension Data {
    var hexString: String {
        return map { String(format: "%02x", $0) }.joined()
    }
}
