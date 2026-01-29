import UIKit
import CoreLocation

class DiscoverViewController: UIViewController {
    
    // UI Components
    private let headerView = UIView()
    private let logoLabel = UILabel()
    private let crystalBalanceView = UIView()
    private let crystalLabel = UILabel()
    private let statusLabel = UILabel()
    private let radarView = UIView()
    private let scanButton = UIButton()
    private let groupChatButton = UIButton()
    private let tableView = UITableView()
    
    // Managers
    private var nearbyUsers: [NearbyUser] = []
    private var isScanning = false
    
    // Location
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBLE()
        setupLocation()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCrystalBalance()
        startScanning()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.043, green: 0.059, blue: 0.078, alpha: 1)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Header View
        headerView.backgroundColor = UIColor.clear
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        // Logo
        logoLabel.text = "AURA"
        logoLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        logoLabel.textColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        logoLabel.textAlignment = .center
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(logoLabel)
        
        // Crystal Balance
        crystalBalanceView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        crystalBalanceView.layer.cornerRadius = 15
        crystalBalanceView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(crystalBalanceView)
        
        crystalLabel.text = "💎 0"
        crystalLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        crystalLabel.textColor = .white
        crystalLabel.translatesAutoresizingMaskIntoConstraints = false
        crystalBalanceView.addSubview(crystalLabel)
        
        // Status Label
        statusLabel.text = "Yakındaki kullanıcıları arıyor..."
        statusLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        statusLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // Radar View
        radarView.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 0.1)
        radarView.layer.cornerRadius = 80
        radarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(radarView)
        
        // Scan Button
        scanButton.setTitle("🔍 TARA", for: .normal)
        scanButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        scanButton.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        scanButton.setTitleColor(.black, for: .normal)
        scanButton.layer.cornerRadius = 30
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        view.addSubview(scanButton)
        
        // Group Chat Button
        groupChatButton.setTitle("🏢 Grup Sohbeti", for: .normal)
        groupChatButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        groupChatButton.backgroundColor = UIColor(red: 0.302, green: 0.102, blue: 0.180, alpha: 1)
        groupChatButton.setTitleColor(.white, for: .normal)
        groupChatButton.layer.cornerRadius = 20
        groupChatButton.translatesAutoresizingMaskIntoConstraints = false
        groupChatButton.addTarget(self, action: #selector(groupChatButtonTapped), for: .touchUpInside)
        view.addSubview(groupChatButton)
        
        // Table View
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Layout
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            logoLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            logoLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            crystalBalanceView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            crystalBalanceView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            crystalBalanceView.widthAnchor.constraint(equalToConstant: 80),
            crystalBalanceView.heightAnchor.constraint(equalToConstant: 30),
            
            crystalLabel.centerXAnchor.constraint(equalTo: crystalBalanceView.centerXAnchor),
            crystalLabel.centerYAnchor.constraint(equalTo: crystalBalanceView.centerYAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            radarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            radarView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            radarView.widthAnchor.constraint(equalToConstant: 160),
            radarView.heightAnchor.constraint(equalToConstant: 160),
            
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanButton.centerYAnchor.constraint(equalTo: radarView.centerYAnchor),
            scanButton.widthAnchor.constraint(equalToConstant: 120),
            scanButton.heightAnchor.constraint(equalToConstant: 60),
            
            groupChatButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            groupChatButton.topAnchor.constraint(equalTo: radarView.bottomAnchor, constant: 20),
            groupChatButton.widthAnchor.constraint(equalToConstant: 160),
            groupChatButton.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: groupChatButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Add tap gesture to crystal balance
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(crystalBalanceTapped))
        crystalBalanceView.addGestureRecognizer(tapGesture)
        crystalBalanceView.isUserInteractionEnabled = true
    }
    
    private func setupBLE() {
        BLEManager.shared.addDelegate(self)
    }
    
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NearbyUserCell.self, forCellReuseIdentifier: "NearbyUserCell")
    }
    
    private func startScanning() {
        guard !isScanning else { return }
        
        isScanning = true
        BLEManager.shared.startScanning()
        
        // Update UI
        statusLabel.text = "Yakındaki kullanıcıları arıyor..."
        startRadarAnimation()
        
        // Update scan button
        scanButton.setTitle("🛑 DURDUR", for: .normal)
        scanButton.backgroundColor = UIColor.red.withAlphaComponent(0.8)
    }
    
    private func stopScanning() {
        guard isScanning else { return }
        
        isScanning = false
        BLEManager.shared.stopScanning()
        
        // Update UI
        statusLabel.text = "Tarama durduruldu"
        stopRadarAnimation()
        
        // Update scan button
        scanButton.setTitle("🔍 TARA", for: .normal)
        scanButton.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
    }
    
    private func startRadarAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 2.0
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.3
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        radarView.layer.add(pulseAnimation, forKey: "pulse")
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = 2.0
        opacityAnimation.fromValue = 0.1
        opacityAnimation.toValue = 0.3
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        
        radarView.layer.add(opacityAnimation, forKey: "opacity")
    }
    
    private func stopRadarAnimation() {
        radarView.layer.removeAllAnimations()
    }
    
    private func updateCrystalBalance() {
        let balance = CrystalManager.shared.currentBalance
        crystalLabel.text = "💎 \(balance)"
    }
    
    @objc private func scanButtonTapped() {
        if isScanning {
            stopScanning()
        } else {
            startScanning()
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    @objc private func groupChatButtonTapped() {
        showGroupChatOptions()
    }
    
    @objc private func crystalBalanceTapped() {
        // Navigate to Crystal Store
        let crystalStoreVC = CrystalStoreViewController()
        navigationController?.pushViewController(crystalStoreVC, animated: true)
    }
    
    private func showGroupChatOptions() {
        let alert = UIAlertController(title: "Grup Sohbeti", message: "Yakındaki bir mekanın grup sohbetine katıl", preferredStyle: .actionSheet)
        
        // Mock hotspots for demo
        let hotspots = [
            ("🍺 The Local Bar", "150m"),
            ("🍕 Pizza Palace", "300m"),
            ("☕ Coffee House", "500m")
        ]
        
        for (name, distance) in hotspots {
            alert.addAction(UIAlertAction(title: "\(name) - \(distance)", style: .default) { _ in
                self.joinGroupChat(venueName: name)
            })
        }
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = groupChatButton
            popover.sourceRect = groupChatButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func joinGroupChat(venueName: String) {
        let groupChatVC = VenueGroupChatViewController()
        groupChatVC.venueName = venueName
        navigationController?.pushViewController(groupChatVC, animated: true)
    }
    
    private func showMatchRequestDialog(from userHash: String, gender: String) {
        guard let user = nearbyUsers.first(where: { $0.userHash == userHash }) else { return }
        
        let genderEmoji = gender == "M" ? "👨" : "👩"
        let title = "💕 Eşleşme İsteği"
        let message = "\(genderEmoji) \(user.userName) seninle eşleşmek istiyor!"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "❌ Reddet", style: .cancel) { _ in
            BLEManager.shared.sendMatchResponse(to: userHash, accepted: false)
        })
        
        alert.addAction(UIAlertAction(title: "💕 Kabul Et", style: .default) { _ in
            BLEManager.shared.sendMatchResponse(to: userHash, accepted: true)
            self.showMatchSuccessMessage(userName: user.userName)
        })
        
        present(alert, animated: true)
    }
    
    private func showMatchSuccessMessage(userName: String) {
        let alert = UIAlertController(title: "🎉 Eşleştiniz!", message: "\(userName) ile eşleştiniz! Artık sohbet edebilirsiniz.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Harika!", style: .default))
        present(alert, animated: true)
        
        // Award crystals for match
        CrystalManager.shared.awardCrystals(25, reason: "İlk eşleşme")
        updateCrystalBalance()
    }
}

// MARK: - BLEManagerDelegate
extension DiscoverViewController: BLEManagerDelegate {
    func didReceiveMatchRequest(from userHash: String, gender: String) {
        DispatchQueue.main.async {
            self.showMatchRequestDialog(from: userHash, gender: gender)
        }
    }
    
    func didReceiveMatchResponse(from userHash: String, accepted: Bool) {
        DispatchQueue.main.async {
            if accepted {
                if let user = self.nearbyUsers.first(where: { $0.userHash == userHash }) {
                    self.showMatchSuccessMessage(userName: user.userName)
                }
            }
        }
    }
    
    func didReceiveChatMessage(from userHash: String, message: String) {
        // Handle in ChatViewController
    }
    
    func didReceiveUnmatch(from userHash: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "💔 Eşleşme İptal", message: "Bir kullanıcı eşleşmeyi iptal etti.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func didReceiveBlock(from userHash: String) {
        // Handle blocking
    }
    
    func didDiscoverNearbyUser(_ user: NearbyUser) {
        DispatchQueue.main.async {
            if !self.nearbyUsers.contains(where: { $0.userHash == user.userHash }) {
                self.nearbyUsers.append(user)
                self.tableView.reloadData()
                self.statusLabel.text = "\(self.nearbyUsers.count) kullanıcı bulundu"
            }
        }
    }
    
    func didLoseNearbyUser(userHash: String) {
        DispatchQueue.main.async {
            self.nearbyUsers.removeAll { $0.userHash == userHash }
            self.tableView.reloadData()
            self.statusLabel.text = self.nearbyUsers.isEmpty ? "Kullanıcı bulunamadı" : "\(self.nearbyUsers.count) kullanıcı bulundu"
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension DiscoverViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyUserCell", for: indexPath) as! NearbyUserCell
        cell.configure(with: nearbyUsers[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = nearbyUsers[indexPath.row]
        showUserActionSheet(for: user)
    }
    
    private func showUserActionSheet(for user: NearbyUser) {
        let genderEmoji = user.gender == "M" ? "👨" : "👩"
        let alert = UIAlertController(title: "\(genderEmoji) \(user.userName)", message: "Ne yapmak istiyorsun?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "💕 Eşleşme İsteği Gönder", style: .default) { _ in
            BLEManager.shared.sendMatchRequest(to: user.userHash)
            
            let successAlert = UIAlertController(title: "✅ İstek Gönderildi", message: "\(user.userName) kullanıcısına eşleşme isteği gönderildi!", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "Tamam", style: .default))
            self.present(successAlert, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = tableView.rectForRow(at: IndexPath(row: nearbyUsers.firstIndex(where: { $0.userHash == user.userHash }) ?? 0, section: 0))
        }
        
        present(alert, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension DiscoverViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

// MARK: - NearbyUserCell
class NearbyUserCell: UITableViewCell {
    private let containerView = UIView()
    private let avatarView = UIView()
    private let nameLabel = UILabel()
    private let distanceLabel = UILabel()
    private let genderLabel = UILabel()
    
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
        
        // Container
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Avatar
        avatarView.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 0.3)
        avatarView.layer.cornerRadius = 20
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(avatarView)
        
        // Name
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        // Distance
        distanceLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        distanceLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(distanceLabel)
        
        // Gender
        genderLabel.font = UIFont.systemFont(ofSize: 20)
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(genderLabel)
        
        // Layout
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.heightAnchor.constraint(equalToConstant: 60),
            
            avatarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            avatarView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),
            
            genderLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            genderLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            
            distanceLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            distanceLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with user: NearbyUser) {
        nameLabel.text = user.userName
        genderLabel.text = user.gender == "M" ? "👨" : "👩"
        
        // Calculate distance from RSSI (rough approximation)
        let distance = rssiToDistance(user.rssi)
        distanceLabel.text = distance
        
        // Update avatar color based on gender
        if user.gender == "M" {
            avatarView.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 0.3)
        } else {
            avatarView.backgroundColor = UIColor(red: 1, green: 0.078, blue: 0.576, alpha: 0.3)
        }
    }
    
    private func rssiToDistance(_ rssi: Int) -> String {
        let distance = pow(10.0, (Double(-rssi) - 40.0) / 20.0)
        
        if distance < 2 {
            return "Çok Yakın"
        } else if distance < 5 {
            return "Yakın"
        } else if distance < 10 {
            return "Orta"
        } else {
            return "Uzak"
        }
    }
}