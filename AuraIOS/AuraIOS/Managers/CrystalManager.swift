import Foundation

class CrystalManager {
    static let shared = CrystalManager()
    
    private let userDefaults = UserDefaults.standard
    private let balanceKey = "crystalBalance"
    private let lastLoginKey = "lastLoginDate"
    private let genderSelectionBonusKey = "genderSelectionBonusGiven"
    
    private init() {}
    
    var currentBalance: Int {
        get {
            return userDefaults.integer(forKey: balanceKey)
        }
        set {
            userDefaults.set(newValue, forKey: balanceKey)
            NotificationCenter.default.post(name: .crystalBalanceChanged, object: newValue)
        }
    }
    
    // MARK: - Daily Login System
    
    func checkDailyLogin() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let lastLogin = userDefaults.object(forKey: lastLoginKey) as? Date ?? Date.distantPast
        let lastLoginDay = Calendar.current.startOfDay(for: lastLogin)
        
        if today > lastLoginDay {
            // New day, award login bonus
            userDefaults.set(today, forKey: lastLoginKey)
            let bonus = 10
            awardCrystals(bonus, reason: "Günlük giriş bonusu")
            return bonus
        }
        
        return 0
    }
    
    // MARK: - Gender Selection Bonus
    
    func completeGenderSelection() {
        if !userDefaults.bool(forKey: genderSelectionBonusKey) {
            awardCrystals(50, reason: "Hoş geldin bonusu")
            userDefaults.set(true, forKey: genderSelectionBonusKey)
        }
        
        // Also check daily login
        let _ = checkDailyLogin()
    }
    
    // MARK: - Crystal Operations
    
    func awardCrystals(_ amount: Int, reason: String) {
        currentBalance += amount
        print("💎 Awarded \(amount) crystals: \(reason)")
        
        // Show notification
        showCrystalNotification(amount: amount, reason: reason)
    }
    
    func spendCrystals(_ amount: Int, for item: String) -> Bool {
        guard currentBalance >= amount else {
            print("❌ Insufficient crystals for \(item)")
            return false
        }
        
        currentBalance -= amount
        print("💎 Spent \(amount) crystals on \(item)")
        return true
    }
    
    // MARK: - Achievement Rewards
    
    func awardFirstMatch() {
        awardCrystals(25, reason: "İlk eşleşme")
    }
    
    func awardFirstMessage() {
        awardCrystals(15, reason: "İlk mesaj")
    }
    
    func awardVenueCheckin() {
        awardCrystals(20, reason: "Mekan check-in")
    }
    
    func awardGroupChatParticipation() {
        awardCrystals(5, reason: "Grup sohbeti")
    }
    
    func awardQRScan() {
        awardCrystals(10, reason: "QR kod tarama")
    }
    
    // MARK: - Premium Features
    
    func purchaseAuraBoost() -> Bool {
        return spendCrystals(100, for: "Aura Boost (24 saat)")
    }
    
    func purchaseInstantPulse() -> Bool {
        return spendCrystals(50, for: "Instant Pulse (1 saat)")
    }
    
    func purchaseMoodSignal() -> Bool {
        return spendCrystals(75, for: "Mood Signal (12 saat)")
    }
    
    func purchaseGoldenHour() -> Bool {
        return spendCrystals(150, for: "Golden Hour (2 saat)")
    }
    
    func purchasePremiumTheme() -> Bool {
        return spendCrystals(200, for: "Premium Theme")
    }
    
    func purchaseRadarEffect() -> Bool {
        return spendCrystals(300, for: "Radar Effect")
    }
    
    // MARK: - Notifications
    
    private func showCrystalNotification(amount: Int, reason: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .crystalAwarded,
                object: nil,
                userInfo: ["amount": amount, "reason": reason]
            )
        }
    }
    
    // MARK: - Statistics
    
    func getTotalEarned() -> Int {
        return userDefaults.integer(forKey: "totalCrystalsEarned")
    }
    
    func getTotalSpent() -> Int {
        return userDefaults.integer(forKey: "totalCrystalsSpent")
    }
    
    private func updateTotalEarned(_ amount: Int) {
        let current = getTotalEarned()
        userDefaults.set(current + amount, forKey: "totalCrystalsEarned")
    }
    
    private func updateTotalSpent(_ amount: Int) {
        let current = getTotalSpent()
        userDefaults.set(current + amount, forKey: "totalCrystalsSpent")
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let crystalBalanceChanged = Notification.Name("crystalBalanceChanged")
    static let crystalAwarded = Notification.Name("crystalAwarded")
}