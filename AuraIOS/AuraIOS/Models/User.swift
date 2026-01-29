import Foundation
import CommonCrypto

enum Gender: String, CaseIterable {
    case male = "M"
    case female = "F"
    
    var displayName: String {
        switch self {
        case .male:
            return "Erkek"
        case .female:
            return "Kadın"
        }
    }
    
    var emoji: String {
        switch self {
        case .male:
            return "👨"
        case .female:
            return "👩"
        }
    }
    
    var primaryColor: UIColor {
        switch self {
        case .male:
            return UIColor(red: 0, green: 0.898, blue: 1, alpha: 1) // Neon Blue
        case .female:
            return UIColor(red: 1, green: 0.078, blue: 0.576, alpha: 1) // Neon Pink
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .male:
            return UIColor(red: 0, green: 0.122, blue: 0.247, alpha: 1) // Dark Blue
        case .female:
            return UIColor(red: 0.302, green: 0.102, blue: 0.180, alpha: 1) // Dark Pink
        }
    }
}

class UserPreferences {
    static let shared = UserPreferences()
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    var userId: String {
        get {
            if let id = userDefaults.string(forKey: "userId") {
                return id
            } else {
                let newId = UUID().uuidString
                userDefaults.set(newId, forKey: "userId")
                return newId
            }
        }
    }
    
    var userHash: String {
        return userId.sha256.prefix(8).uppercased()
    }
    
    var userName: String {
        get {
            return userDefaults.string(forKey: "userName") ?? "User\(userHash.prefix(4))"
        }
        set {
            userDefaults.set(newValue, forKey: "userName")
        }
    }
    
    var gender: Gender? {
        get {
            if let genderString = userDefaults.string(forKey: "gender") {
                return Gender(rawValue: genderString)
            }
            return nil
        }
        set {
            if let gender = newValue {
                userDefaults.set(gender.rawValue, forKey: "gender")
            } else {
                userDefaults.removeObject(forKey: "gender")
            }
        }
    }
    
    var isVisibilityEnabled: Bool {
        get {
            return userDefaults.bool(forKey: "isVisibilityEnabled")
        }
        set {
            userDefaults.set(newValue, forKey: "isVisibilityEnabled")
        }
    }
    
    var hasCompletedGenderSelection: Bool {
        get {
            return userDefaults.bool(forKey: "hasCompletedGenderSelection")
        }
        set {
            userDefaults.set(newValue, forKey: "hasCompletedGenderSelection")
        }
    }
}

// MARK: - String Extension for SHA256
extension String {
    var sha256: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { bytes in
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256(bytes.bindMemory(to: UInt8.self).baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}