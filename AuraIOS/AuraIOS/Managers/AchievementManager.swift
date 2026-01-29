import Foundation

enum AchievementType: String, CaseIterable {
    case firstMatch = "first_match"
    case firstMessage = "first_message"
    case firstGroupChat = "first_group_chat"
    case firstVenueVisit = "first_venue_visit"
    case socialButterfly = "social_butterfly" // 10 matches
    case conversationalist = "conversationalist" // 100 messages
    case partyAnimal = "party_animal" // 20 group chats
    case explorer = "explorer" // 5 different venues
    case earlyAdopter = "early_adopter"
    case streakMaster = "streak_master" // 7 day streak
    case crystalCollector = "crystal_collector" // 1000 crystals earned
    case nightOwl = "night_owl" // Active after midnight
    case weekendWarrior = "weekend_warrior" // Active on weekends
    
    var title: String {
        switch self {
        case .firstMatch: return "💕 İlk Eşleşme"
        case .firstMessage: return "💬 İlk Mesaj"
        case .firstGroupChat: return "👥 Grup Sohbeti"
        case .firstVenueVisit: return "🏢 İlk Mekan"
        case .socialButterfly: return "🦋 Sosyal Kelebek"
        case .conversationalist: return "🗣️ Konuşkan"
        case .partyAnimal: return "🎉 Parti Hayvanı"
        case .explorer: return "🗺️ Kaşif"
        case .earlyAdopter: return "🚀 Erken Kullanıcı"
        case .streakMaster: return "🔥 Seri Ustası"
        case .crystalCollector: return "💎 Kristal Koleksiyoncusu"
        case .nightOwl: return "🦉 Gece Kuşu"
        case .weekendWarrior: return "🎊 Hafta Sonu Savaşçısı"
        }
    }
    
    var description: String {
        switch self {
        case .firstMatch: return "İlk eşleşmeni yap"
        case .firstMessage: return "İlk mesajını gönder"
        case .firstGroupChat: return "İlk grup sohbetine katıl"
        case .firstVenueVisit: return "İlk mekanını ziyaret et"
        case .socialButterfly: return "10 farklı kişiyle eşleş"
        case .conversationalist: return "100 mesaj gönder"
        case .partyAnimal: return "20 grup sohbetine katıl"
        case .explorer: return "5 farklı mekan ziyaret et"
        case .earlyAdopter: return "Aura'nın erken kullanıcısı ol"
        case .streakMaster: return "7 gün üst üste aktif ol"
        case .crystalCollector: return "1000 kristal kazan"
        case .nightOwl: return "Gece yarısından sonra aktif ol"
        case .weekendWarrior: return "Hafta sonu aktif ol"
        }
    }
    
    var crystalReward: Int {
        switch self {
        case .firstMatch, .firstMessage, .firstGroupChat, .firstVenueVisit: return 25
        case .socialButterfly, .conversationalist: return 100
        case .partyAnimal, .explorer: return 150
        case .earlyAdopter: return 50
        case .streakMaster: return 200
        case .crystalCollector: return 500
        case .nightOwl, .weekendWarrior: return 75
        }
    }
    
    var targetValue: Int {
        switch self {
        case .firstMatch, .firstMessage, .firstGroupChat, .firstVenueVisit, .earlyAdopter: return 1
        case .socialButterfly: return 10
        case .conversationalist: return 100
        case .partyAnimal: return 20
        case .explorer: return 5
        case .streakMaster: return 7
        case .crystalCollector: return 1000
        case .nightOwl, .weekendWarrior: return 1
        }
    }
}

struct Achievement {
    let type: AchievementType
    let unlockedAt: Date
    let progress: Int
    let isUnlocked: Bool
    
    var progressPercentage: Double {
        return min(Double(progress) / Double(type.targetValue), 1.0) * 100
    }
}

class AchievementManager {
    static let shared = AchievementManager()
    
    private let userDefaults = UserDefaults.standard
    private let achievementsKey = "achievements"
    private let progressKey = "achievement_progress"
    
    private init() {}
    
    // MARK: - Achievement Tracking
    
    func recordFirstMatch() {
        recordProgress(for: .firstMatch, increment: 1)
    }
    
    func recordFirstMessage() {
        recordProgress(for: .firstMessage, increment: 1)
    }
    
    func recordGroupChatParticipation() {
        recordProgress(for: .firstGroupChat, increment: 1)
        recordProgress(for: .partyAnimal, increment: 1)
    }
    
    func recordVenueVisit() {
        recordProgress(for: .firstVenueVisit, increment: 1)
        recordProgress(for: .explorer, increment: 1)
    }
    
    func recordMatch() {
        recordProgress(for: .socialButterfly, increment: 1)
    }
    
    func recordMessage() {
        recordProgress(for: .conversationalist, increment: 1)
    }
    
    func recordEarlyAdopter() {
        recordProgress(for: .earlyAdopter, increment: 1)
    }
    
    func recordStreak(days: Int) {
        setProgress(for: .streakMaster, value: days)
    }
    
    func recordCrystalEarned(total: Int) {
        setProgress(for: .crystalCollector, value: total)
    }
    
    func recordNightActivity() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 0 && hour <= 6 { // Midnight to 6 AM
            recordProgress(for: .nightOwl, increment: 1)
        }
    }
    
    func recordWeekendActivity() {
        let weekday = Calendar.current.component(.weekday, from: Date())
        if weekday == 1 || weekday == 7 { // Sunday or Saturday
            recordProgress(for: .weekendWarrior, increment: 1)
        }
    }
    
    // MARK: - Progress Management
    
    private func recordProgress(for type: AchievementType, increment: Int) {
        let currentProgress = getProgress(for: type)
        let newProgress = currentProgress + increment
        setProgress(for: type, value: newProgress)
    }
    
    private func setProgress(for type: AchievementType, value: Int) {
        var progress = getProgressData()
        progress[type.rawValue] = value
        saveProgressData(progress)
        
        // Check if achievement should be unlocked
        if value >= type.targetValue && !isUnlocked(type) {
            unlockAchievement(type)
        }
    }
    
    private func getProgress(for type: AchievementType) -> Int {
        let progress = getProgressData()
        return progress[type.rawValue] ?? 0
    }
    
    private func getProgressData() -> [String: Int] {
        return userDefaults.dictionary(forKey: progressKey) as? [String: Int] ?? [:]
    }
    
    private func saveProgressData(_ data: [String: Int]) {
        userDefaults.set(data, forKey: progressKey)
    }
    
    // MARK: - Achievement Unlocking
    
    private func unlockAchievement(_ type: AchievementType) {
        var unlockedAchievements = getUnlockedAchievements()
        
        if !unlockedAchievements.contains(type.rawValue) {
            unlockedAchievements.append(type.rawValue)
            saveUnlockedAchievements(unlockedAchievements)
            
            // Award crystals
            CrystalManager.shared.awardCrystals(type.crystalReward, reason: "Başarım: \(type.title)")
            
            // Show notification
            showAchievementNotification(type)
            
            print("🏆 Achievement unlocked: \(type.title)")
        }
    }
    
    private func showAchievementNotification(_ type: AchievementType) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .achievementUnlocked,
                object: type,
                userInfo: [
                    "title": type.title,
                    "description": type.description,
                    "crystalReward": type.crystalReward
                ]
            )
        }
    }
    
    // MARK: - Data Persistence
    
    private func getUnlockedAchievements() -> [String] {
        return userDefaults.stringArray(forKey: achievementsKey) ?? []
    }
    
    private func saveUnlockedAchievements(_ achievements: [String]) {
        userDefaults.set(achievements, forKey: achievementsKey)
    }
    
    // MARK: - Public Interface
    
    func isUnlocked(_ type: AchievementType) -> Bool {
        return getUnlockedAchievements().contains(type.rawValue)
    }
    
    func getAllAchievements() -> [Achievement] {
        let unlockedTypes = getUnlockedAchievements()
        let progressData = getProgressData()
        
        return AchievementType.allCases.map { type in
            Achievement(
                type: type,
                unlockedAt: Date(), // In a real app, store actual unlock dates
                progress: progressData[type.rawValue] ?? 0,
                isUnlocked: unlockedTypes.contains(type.rawValue)
            )
        }
    }
    
    func getUnlockedAchievementsList() -> [Achievement] {
        return getAllAchievements().filter { $0.isUnlocked }
    }
    
    func getInProgressAchievements() -> [Achievement] {
        return getAllAchievements().filter { !$0.isUnlocked && $0.progress > 0 }
    }
    
    func getAchievementProgress(for type: AchievementType) -> Achievement {
        let progress = getProgress(for: type)
        let isUnlocked = isUnlocked(type)
        
        return Achievement(
            type: type,
            unlockedAt: Date(),
            progress: progress,
            isUnlocked: isUnlocked
        )
    }
    
    // MARK: - Statistics
    
    func getTotalUnlockedCount() -> Int {
        return getUnlockedAchievements().count
    }
    
    func getTotalAchievementCount() -> Int {
        return AchievementType.allCases.count
    }
    
    func getCompletionPercentage() -> Double {
        let unlocked = Double(getTotalUnlockedCount())
        let total = Double(getTotalAchievementCount())
        return (unlocked / total) * 100
    }
    
    func getTotalCrystalsEarned() -> Int {
        let unlockedTypes = getUnlockedAchievements()
        return AchievementType.allCases
            .filter { unlockedTypes.contains($0.rawValue) }
            .reduce(0) { $0 + $1.crystalReward }
    }
    
    // MARK: - Debug Helpers
    
    func resetAllAchievements() {
        userDefaults.removeObject(forKey: achievementsKey)
        userDefaults.removeObject(forKey: progressKey)
        print("🔄 All achievements reset")
    }
    
    func unlockAllAchievements() {
        let allTypes = AchievementType.allCases.map { $0.rawValue }
        saveUnlockedAchievements(allTypes)
        
        var progressData: [String: Int] = [:]
        for type in AchievementType.allCases {
            progressData[type.rawValue] = type.targetValue
        }
        saveProgressData(progressData)
        
        print("🏆 All achievements unlocked (debug)")
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let achievementUnlocked = Notification.Name("achievementUnlocked")
    static let achievementProgressUpdated = Notification.Name("achievementProgressUpdated")
}