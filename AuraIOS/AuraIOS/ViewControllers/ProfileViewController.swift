import UIKit

class ProfileViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Profile Section
    private let profileSection = UIView()
    private let avatarView = UIView()
    private let genderLabel = UILabel()
    private let nameLabel = UILabel()
    private let hashLabel = UILabel()
    private let editButton = UIButton()
    
    // Crystal Section
    private let crystalSection = UIView()
    private let crystalTitleLabel = UILabel()
    private let crystalBalanceLabel = UILabel()
    private let crystalStoreButton = UIButton()
    
    // Settings Section
    private let settingsSection = UIView()
    private let visibilitySwitch = UISwitch()
    private let languageButton = UIButton()
    
    // Premium Section
    private let premiumSection = UIView()
    private let premiumTitleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCrystalBalance()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.043, green: 0.059, blue: 0.078, alpha: 1)
        title = "Profil"
        
        // Navigation bar styling
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.tintColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        
        setupScrollView()
        setupProfileSection()
        setupCrystalSection()
        setupSettingsSection()
        setupPremiumSection()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupProfileSection() {
        profileSection.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        profileSection.layer.cornerRadius = 15
        profileSection.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(profileSection)
        
        // Avatar
        avatarView.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 0.3)
        avatarView.layer.cornerRadius = 40
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        profileSection.addSubview(avatarView)
        
        genderLabel.font = UIFont.systemFont(ofSize: 40)
        genderLabel.textAlignment = .center
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(genderLabel)
        
        // Name
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        profileSection.addSubview(nameLabel)
        
        // Hash
        hashLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        hashLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        hashLabel.textAlignment = .center
        hashLabel.translatesAutoresizingMaskIntoConstraints = false
        profileSection.addSubview(hashLabel)
        
        // Edit button
        editButton.setTitle("✏️ Düzenle", for: .normal)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        editButton.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 0.2)
        editButton.setTitleColor(UIColor(red: 0, green: 0.898, blue: 1, alpha: 1), for: .normal)
        editButton.layer.cornerRadius = 20
        editButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        profileSection.addSubview(editButton)
        
        NSLayoutConstraint.activate([
            profileSection.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            profileSection.heightAnchor.constraint(equalToConstant: 200),
            
            avatarView.centerXAnchor.constraint(equalTo: profileSection.centerXAnchor),
            avatarView.topAnchor.constraint(equalTo: profileSection.topAnchor, constant: 20),
            avatarView.widthAnchor.constraint(equalToConstant: 80),
            avatarView.heightAnchor.constraint(equalToConstant: 80),
            
            genderLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            genderLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            nameLabel.centerXAnchor.constraint(equalTo: profileSection.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 12),
            
            hashLabel.centerXAnchor.constraint(equalTo: profileSection.centerXAnchor),
            hashLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            
            editButton.centerXAnchor.constraint(equalTo: profileSection.centerXAnchor),
            editButton.bottomAnchor.constraint(equalTo: profileSection.bottomAnchor, constant: -16),
            editButton.widthAnchor.constraint(equalToConstant: 120),
            editButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupCrystalSection() {
        crystalSection.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        crystalSection.layer.cornerRadius = 15
        crystalSection.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(crystalSection)
        
        crystalTitleLabel.text = "💎 Aura Kristalleri"
        crystalTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        crystalTitleLabel.textColor = .white
        crystalTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        crystalSection.addSubview(crystalTitleLabel)
        
        crystalBalanceLabel.text = "0"
        crystalBalanceLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        crystalBalanceLabel.textColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        crystalBalanceLabel.textAlignment = .center
        crystalBalanceLabel.translatesAutoresizingMaskIntoConstraints = false
        crystalSection.addSubview(crystalBalanceLabel)
        
        crystalStoreButton.setTitle("🛍️ Kristal Mağazası", for: .normal)
        crystalStoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        crystalStoreButton.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        crystalStoreButton.setTitleColor(.black, for: .normal)
        crystalStoreButton.layer.cornerRadius = 20
        crystalStoreButton.addTarget(self, action: #selector(crystalStoreTapped), for: .touchUpInside)
        crystalStoreButton.translatesAutoresizingMaskIntoConstraints = false
        crystalSection.addSubview(crystalStoreButton)
        
        NSLayoutConstraint.activate([
            crystalSection.topAnchor.constraint(equalTo: profileSection.bottomAnchor, constant: 20),
            crystalSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            crystalSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            crystalSection.heightAnchor.constraint(equalToConstant: 120),
            
            crystalTitleLabel.topAnchor.constraint(equalTo: crystalSection.topAnchor, constant: 16),
            crystalTitleLabel.leadingAnchor.constraint(equalTo: crystalSection.leadingAnchor, constant: 16),
            
            crystalBalanceLabel.centerYAnchor.constraint(equalTo: crystalSection.centerYAnchor),
            crystalBalanceLabel.leadingAnchor.constraint(equalTo: crystalSection.leadingAnchor, constant: 16),
            
            crystalStoreButton.centerYAnchor.constraint(equalTo: crystalSection.centerYAnchor),
            crystalStoreButton.trailingAnchor.constraint(equalTo: crystalSection.trailingAnchor, constant: -16),
            crystalStoreButton.widthAnchor.constraint(equalToConstant: 160),
            crystalStoreButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupSettingsSection() {
        settingsSection.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        settingsSection.layer.cornerRadius = 15
        settingsSection.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(settingsSection)
        
        // Visibility setting
        let visibilityLabel = UILabel()
        visibilityLabel.text = "👁️ Görünürlük"
        visibilityLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        visibilityLabel.textColor = .white
        visibilityLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsSection.addSubview(visibilityLabel)
        
        visibilitySwitch.isOn = UserPreferences.shared.isVisibilityEnabled
        visibilitySwitch.onTintColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        visibilitySwitch.addTarget(self, action: #selector(visibilitySwitchChanged), for: .valueChanged)
        visibilitySwitch.translatesAutoresizingMaskIntoConstraints = false
        settingsSection.addSubview(visibilitySwitch)
        
        // Language setting
        let languageLabel = UILabel()
        languageLabel.text = "🌍 Dil"
        languageLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        languageLabel.textColor = .white
        languageLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsSection.addSubview(languageLabel)
        
        languageButton.setTitle("Türkçe", for: .normal)
        languageButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        languageButton.setTitleColor(UIColor(red: 0, green: 0.898, blue: 1, alpha: 1), for: .normal)
        languageButton.addTarget(self, action: #selector(languageButtonTapped), for: .touchUpInside)
        languageButton.translatesAutoresizingMaskIntoConstraints = false
        settingsSection.addSubview(languageButton)
        
        NSLayoutConstraint.activate([
            settingsSection.topAnchor.constraint(equalTo: crystalSection.bottomAnchor, constant: 20),
            settingsSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            settingsSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            settingsSection.heightAnchor.constraint(equalToConstant: 120),
            
            visibilityLabel.topAnchor.constraint(equalTo: settingsSection.topAnchor, constant: 16),
            visibilityLabel.leadingAnchor.constraint(equalTo: settingsSection.leadingAnchor, constant: 16),
            
            visibilitySwitch.centerYAnchor.constraint(equalTo: visibilityLabel.centerYAnchor),
            visibilitySwitch.trailingAnchor.constraint(equalTo: settingsSection.trailingAnchor, constant: -16),
            
            languageLabel.topAnchor.constraint(equalTo: visibilityLabel.bottomAnchor, constant: 20),
            languageLabel.leadingAnchor.constraint(equalTo: settingsSection.leadingAnchor, constant: 16),
            
            languageButton.centerYAnchor.constraint(equalTo: languageLabel.centerYAnchor),
            languageButton.trailingAnchor.constraint(equalTo: settingsSection.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupPremiumSection() {
        premiumSection.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        premiumSection.layer.cornerRadius = 15
        premiumSection.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(premiumSection)
        
        premiumTitleLabel.text = "⭐ Premium Özellikler"
        premiumTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        premiumTitleLabel.textColor = .white
        premiumTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        premiumSection.addSubview(premiumTitleLabel)
        
        let premiumDescLabel = UILabel()
        premiumDescLabel.text = "Kristal harcayarak premium özellikleri aktif edebilirsin"
        premiumDescLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        premiumDescLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        premiumDescLabel.numberOfLines = 0
        premiumDescLabel.translatesAutoresizingMaskIntoConstraints = false
        premiumSection.addSubview(premiumDescLabel)
        
        NSLayoutConstraint.activate([
            premiumSection.topAnchor.constraint(equalTo: settingsSection.bottomAnchor, constant: 20),
            premiumSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            premiumSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            premiumSection.heightAnchor.constraint(equalToConstant: 80),
            premiumSection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            premiumTitleLabel.topAnchor.constraint(equalTo: premiumSection.topAnchor, constant: 16),
            premiumTitleLabel.leadingAnchor.constraint(equalTo: premiumSection.leadingAnchor, constant: 16),
            
            premiumDescLabel.topAnchor.constraint(equalTo: premiumTitleLabel.bottomAnchor, constant: 8),
            premiumDescLabel.leadingAnchor.constraint(equalTo: premiumSection.leadingAnchor, constant: 16),
            premiumDescLabel.trailingAnchor.constraint(equalTo: premiumSection.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(crystalBalanceChanged),
            name: .crystalBalanceChanged,
            object: nil
        )
    }
    
    private func loadUserData() {
        let userPrefs = UserPreferences.shared
        
        nameLabel.text = userPrefs.userName
        hashLabel.text = "ID: \(userPrefs.userHash)"
        
        if let gender = userPrefs.gender {
            genderLabel.text = gender.emoji
            avatarView.backgroundColor = gender.primaryColor.withAlphaComponent(0.3)
        }
        
        visibilitySwitch.isOn = userPrefs.isVisibilityEnabled
    }
    
    private func updateCrystalBalance() {
        crystalBalanceLabel.text = "\(CrystalManager.shared.currentBalance)"
    }
    
    @objc private func editProfileTapped() {
        let alert = UIAlertController(title: "Profili Düzenle", message: "Kullanıcı adını değiştir", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Yeni kullanıcı adı"
            textField.text = UserPreferences.shared.userName
        }
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Kaydet", style: .default) { _ in
            if let newName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
               !newName.isEmpty {
                UserPreferences.shared.userName = newName
                self.nameLabel.text = newName
                
                // Restart advertising with new name
                BLEManager.shared.stopAdvertising()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    BLEManager.shared.startAdvertising()
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    @objc private func crystalStoreTapped() {
        let crystalStoreVC = CrystalStoreViewController()
        navigationController?.pushViewController(crystalStoreVC, animated: true)
    }
    
    @objc private func visibilitySwitchChanged() {
        UserPreferences.shared.isVisibilityEnabled = visibilitySwitch.isOn
        
        if visibilitySwitch.isOn {
            BLEManager.shared.startAdvertising()
        } else {
            BLEManager.shared.stopAdvertising()
        }
    }
    
    @objc private func languageButtonTapped() {
        let alert = UIAlertController(title: "Dil Seçimi", message: "Uygulama dilini seç", preferredStyle: .actionSheet)
        
        let languages = [
            ("🇹🇷", "Türkçe"),
            ("🇺🇸", "English"),
            ("🇩🇪", "Deutsch"),
            ("🇪🇸", "Español"),
            ("🇫🇷", "Français")
        ]
        
        for (flag, name) in languages {
            alert.addAction(UIAlertAction(title: "\(flag) \(name)", style: .default) { _ in
                self.languageButton.setTitle(name, for: .normal)
                // Language change would require app restart in a real implementation
            })
        }
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = languageButton
            popover.sourceRect = languageButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    @objc private func crystalBalanceChanged() {
        DispatchQueue.main.async {
            self.updateCrystalBalance()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - CrystalStoreViewController
class CrystalStoreViewController: UIViewController {
    
    private let tableView = UITableView()
    private let balanceLabel = UILabel()
    
    private let premiumFeatures = [
        ("🔥 Aura Boost", "24 saat daha güçlü yayın", 100),
        ("⚡ Instant Pulse", "1 saat hızlı tarama", 50),
        ("😊 Mood Signal", "12 saat ruh hali yayını", 75),
        ("🌅 Golden Hour", "2 saat öncelik modu", 150),
        ("🎨 Premium Theme", "Özel tema (kalıcı)", 200),
        ("🌀 Radar Effect", "Özel radar efekti (kalıcı)", 300)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBalance()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.043, green: 0.059, blue: 0.078, alpha: 1)
        title = "💎 Kristal Mağazası"
        
        // Navigation bar styling
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.tintColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        
        // Balance header
        let headerView = UIView()
        headerView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        let titleLabel = UILabel()
        titleLabel.text = "Mevcut Bakiye"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        balanceLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        balanceLabel.textColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        balanceLabel.textAlignment = .center
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(balanceLabel)
        
        // Table view
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            balanceLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            balanceLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PremiumFeatureCell.self, forCellReuseIdentifier: "PremiumFeatureCell")
    }
    
    private func updateBalance() {
        balanceLabel.text = "💎 \(CrystalManager.shared.currentBalance)"
    }
    
    private func purchaseFeature(at index: Int) {
        let feature = premiumFeatures[index]
        let cost = feature.2
        
        let alert = UIAlertController(
            title: feature.0,
            message: "\(feature.1)\n\nFiyat: \(cost) kristal",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Satın Al", style: .default) { _ in
            let success: Bool
            
            switch index {
            case 0: success = CrystalManager.shared.purchaseAuraBoost()
            case 1: success = CrystalManager.shared.purchaseInstantPulse()
            case 2: success = CrystalManager.shared.purchaseMoodSignal()
            case 3: success = CrystalManager.shared.purchaseGoldenHour()
            case 4: success = CrystalManager.shared.purchasePremiumTheme()
            case 5: success = CrystalManager.shared.purchaseRadarEffect()
            default: success = false
            }
            
            if success {
                self.updateBalance()
                let successAlert = UIAlertController(title: "✅ Satın Alındı!", message: "\(feature.0) başarıyla aktif edildi!", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "Harika!", style: .default))
                self.present(successAlert, animated: true)
            } else {
                let failAlert = UIAlertController(title: "❌ Yetersiz Kristal", message: "Bu özelliği satın almak için yeterli kristalin yok.", preferredStyle: .alert)
                failAlert.addAction(UIAlertAction(title: "Tamam", style: .default))
                self.present(failAlert, animated: true)
            }
        })
        
        present(alert, animated: true)
    }
}

// MARK: - CrystalStoreViewController Table View
extension CrystalStoreViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return premiumFeatures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumFeatureCell", for: indexPath) as! PremiumFeatureCell
        let feature = premiumFeatures[indexPath.row]
        cell.configure(title: feature.0, description: feature.1, cost: feature.2)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        purchaseFeature(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - PremiumFeatureCell
class PremiumFeatureCell: UITableViewCell {
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let costLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        costLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        costLabel.textColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        costLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(costLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: costLabel.leadingAnchor, constant: -8),
            
            costLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            costLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(title: String, description: String, cost: Int) {
        titleLabel.text = title
        descriptionLabel.text = description
        costLabel.text = "💎 \(cost)"
    }
}