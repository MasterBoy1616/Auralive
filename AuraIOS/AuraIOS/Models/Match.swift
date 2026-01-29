import Foundation

struct Match: Codable {
    let id: String
    let userHash: String
    let userName: String
    let gender: String
    let matchedAt: Date
    let lastMessageAt: Date?
    let isActive: Bool
    
    init(userHash: String, userName: String, gender: String) {
        self.id = UUID().uuidString
        self.userHash = userHash
        self.userName = userName
        self.gender = gender
        self.matchedAt = Date()
        self.lastMessageAt = nil
        self.isActive = true
    }
    
    var genderEmoji: String {
        return gender == "M" ? "👨" : "👩"
    }
    
    var displayName: String {
        return "\(genderEmoji) \(userName)"
    }
}

class MatchStore {
    static let shared = MatchStore()
    
    private let userDefaults = UserDefaults.standard
    private let matchesKey = "storedMatches"
    
    private init() {}
    
    func storeMatch(_ match: Match) {
        var matches = getMatches()
        
        // Check if match already exists
        if !matches.contains(where: { $0.userHash == match.userHash }) {
            matches.append(match)
            saveMatches(matches)
            
            // Award crystals for first match
            CrystalManager.shared.awardFirstMatch()
            
            print("✅ Match stored: \(match.userName)")
        }
    }
    
    func getMatches() -> [Match] {
        guard let data = userDefaults.data(forKey: matchesKey),
              let matches = try? JSONDecoder().decode([Match].self, from: data) else {
            return []
        }
        return matches.sorted { $0.matchedAt > $1.matchedAt }
    }
    
    func removeMatch(userHash: String) {
        var matches = getMatches()
        matches.removeAll { $0.userHash == userHash }
        saveMatches(matches)
    }
    
    func updateLastMessage(userHash: String) {
        var matches = getMatches()
        if let index = matches.firstIndex(where: { $0.userHash == userHash }) {
            var match = matches[index]
            match = Match(
                id: match.id,
                userHash: match.userHash,
                userName: match.userName,
                gender: match.gender,
                matchedAt: match.matchedAt,
                lastMessageAt: Date(),
                isActive: match.isActive
            )
            matches[index] = match
            saveMatches(matches)
        }
    }
    
    func isMatched(with userHash: String) -> Bool {
        return getMatches().contains { $0.userHash == userHash && $0.isActive }
    }
    
    private func saveMatches(_ matches: [Match]) {
        if let data = try? JSONEncoder().encode(matches) {
            userDefaults.set(data, forKey: matchesKey)
        }
    }
}

// MARK: - Match Extensions
extension Match {
    init(id: String, userHash: String, userName: String, gender: String, matchedAt: Date, lastMessageAt: Date?, isActive: Bool) {
        self.id = id
        self.userHash = userHash
        self.userName = userName
        self.gender = gender
        self.matchedAt = matchedAt
        self.lastMessageAt = lastMessageAt
        self.isActive = isActive
    }
}