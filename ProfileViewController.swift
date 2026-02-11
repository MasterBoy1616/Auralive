import UIKit
import Combine

class ProfileViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    // UI Elements
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "PROFILE"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let visibilitySwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = UIColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private let visibilityLabel: UILabel = {
        let label = UILabel()
        label.text = "Visibility"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Status: OFF"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let changeGenderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Gender", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let changeNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Name", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Photo", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let bottomTabBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let discoverButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔍 Discover", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let matchesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("💕 Matches", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("👤 Profile", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        
        setupUI()
        setupActions()
        loadProfile()
        
        // Add BLE listener
        BLEManager.shared.addListener(self)
        
        print("👤 ProfileViewController: Loaded")
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(genderLabel)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(visibilityLabel)
        contentView.addSubview(visibilitySwitch)
        contentView.addSubview(statusLabel)
        contentView.addSubview(changeGenderButton)
        contentView.addSubview(changeNameButton)
        contentView.addSubview(changePhotoButton)
        
        view.addSubview(bottomTabBar)
        bottomTabBar.addSubview(discoverButton)
        bottomTabBar.addSubview(matchesButton)
        bottomTabBar.addSubview(profileButton)
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomTabBar.topAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Profile Image
            profileImageView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 30),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Gender Label
            genderLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 30),
            genderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            genderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            // UserName Label
            userNameLabel.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 15),
            userNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            // Visibility Label
            visibilityLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 30),
            visibilityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            
            // Visibility Switch
            visibilitySwitch.centerYAnchor.constraint(equalTo: visibilityLabel.centerYAnchor),
            visibilitySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            // Status Label
            statusLabel.topAnchor.constraint(equalTo: visibilityLabel.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            // Change Gender Button
            changeGenderButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30),
            changeGenderButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            changeGenderButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            changeGenderButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Change Name Button
            changeNameButton.topAnchor.constraint(equalTo: changeGenderButton.bottomAnchor, constant: 15),
            changeNameButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            changeNameButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            changeNameButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Change Photo Button
            changePhotoButton.topAnchor.constraint(equalTo: changeNameButton.bottomAnchor, constant: 15),
            changePhotoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            changePhotoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            changePhotoButton.heightAnchor.constraint(equalToConstant: 50),
            changePhotoButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            // Bottom Tab Bar
            bottomTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomTabBar.heightAnchor.constraint(equalToConstant: 80),
            
            // Tab Buttons
            discoverButton.leadingAnchor.constraint(equalTo: bottomTabBar.leadingAnchor, constant: 20),
            discoverButton.centerYAnchor.constraint(equalTo: bottomTabBar.centerYAnchor, constant: -10),
            discoverButton.widthAnchor.constraint(equalToConstant: 100),
            
            matchesButton.centerXAnchor.constraint(equalTo: bottomTabBar.centerXAnchor),
            matchesButton.centerYAnchor.constraint(equalTo: bottomTabBar.centerYAnchor, constant: -10),
            matchesButton.widthAnchor.constraint(equalToConstant: 100),
            
            profileButton.trailingAnchor.constraint(equalTo: bottomTabBar.trailingAnchor, constant: -20),
            profileButton.centerYAnchor.constraint(equalTo: bottomTabBar.centerYAnchor, constant: -10),
            profileButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupActions() {
        visibilitySwitch.addTarget(self, action: #selector(visibilityChanged), for: .valueChanged)
        changeGenderButton.addTarget(self, action: #selector(changeGenderTapped), for: .touchUpInside)
        changeNameButton.addTarget(self, action: #selector(changeNameTapped), for: .touchUpInside)
        changePhotoButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        
        discoverButton.addTarget(self, action: #selector(discoverTapped), for: .touchUpInside)
        matchesButton.addTarget(self, action: #selector(matchesTapped), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
    }
    
    private func loadProfile() {
        let userPrefs = UserPreferences.shared
        
        // Load gender
        if let gender = userPrefs.getGender() {
            let genderText = gender == .male ? "Male" : "Female"
            genderLabel.text = "Gender: \(genderText)"
        }
        
        // Load username
        let userName = userPrefs.getUserName()
        userNameLabel.text = "Name: \(userName)"
        
        // Load visibility
        let isVisible = userPrefs.getVisibilityEnabled()
        visibilitySwitch.isOn = isVisible
        updateStatus()
        
        // Load profile photo (placeholder for now)
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .lightGray
        
        print("👤 ProfileViewController: Profile loaded")
    }
    
    private func updateStatus() {
        let isAdvertising = BLEManager.shared.isAdvertisingActive()
        let isVisible = visibilitySwitch.isOn
        
        if isVisible && isAdvertising {
            statusLabel.text = "Status: Broadcasting ON"
            statusLabel.textColor = UIColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 1.0)
        } else if isVisible {
            statusLabel.text = "Status: Starting..."
            statusLabel.textColor = .orange
        } else {
            statusLabel.text = "Status: Broadcasting OFF"
            statusLabel.textColor = .lightGray
        }
    }
    
    @objc private func visibilityChanged() {
        let isEnabled = visibilitySwitch.isOn
        UserPreferences.shared.setVisibilityEnabled(isEnabled)
        
        if isEnabled {
            BLEManager.shared.startAdvertising()
            showToast("📡 Broadcasting ON")
        } else {
            BLEManager.shared.stopAdvertising()
            showToast("📡 Broadcasting OFF")
        }
        
        updateStatus()
    }
    
    @objc private func changeGenderTapped() {
        let alert = UIAlertController(title: "Change Gender", message: "Select your gender", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Male", style: .default) { [weak self] _ in
            UserPreferences.shared.setGender(.male)
            self?.loadProfile()
            self?.restartAdvertising()
            self?.showToast("Gender updated to Male")
        })
        
        alert.addAction(UIAlertAction(title: "Female", style: .default) { [weak self] _ in
            UserPreferences.shared.setGender(.female)
            self?.loadProfile()
            self?.restartAdvertising()
            self?.showToast("Gender updated to Female")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func changeNameTapped() {
        let alert = UIAlertController(title: "Change Name", message: "Enter your new name", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.text = UserPreferences.shared.getUserName()
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let newName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newName.isEmpty,
                  newName.count <= 20 else {
                self?.showToast("Invalid name")
                return
            }
            
            UserPreferences.shared.setUserName(newName)
            self?.loadProfile()
            self?.restartAdvertising()
            self?.showToast("Name updated to \(newName)")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func changePhotoTapped() {
        showToast("Photo upload coming soon!")
    }
    
    private func restartAdvertising() {
        if UserPreferences.shared.getVisibilityEnabled() {
            BLEManager.shared.stopAdvertising()
            
            // Update current user in BLE Manager
            let userId = UserPreferences.shared.getUserId()
            BLEManager.shared.setCurrentUser(userId)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                BLEManager.shared.startAdvertising()
                print("📡 ProfileViewController: Advertising restarted with new data")
            }
        }
    }
    
    @objc private func discoverTapped() {
        dismiss(animated: true)
    }
    
    @objc private func matchesTapped() {
        let matchesVC = MatchesViewController()
        matchesVC.modalPresentationStyle = .fullScreen
        present(matchesVC, animated: true)
    }
    
    @objc private func profileTapped() {
        // Already on profile
    }
    
    private func showToast(_ message: String) {
        let toast = UILabel()
        toast.text = message
        toast.textColor = .white
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toast.textAlignment = .center
        toast.font = UIFont.systemFont(ofSize: 14)
        toast.layer.cornerRadius = 10
        toast.clipsToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toast)
        
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            toast.widthAnchor.constraint(equalToConstant: 200),
            toast.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
            toast.alpha = 0
        }) { _ in
            toast.removeFromSuperview()
        }
    }
    
    deinit {
        BLEManager.shared.removeListener(self)
    }
}

// MARK: - BLEManagerListener
extension ProfileViewController: BLEManager.BLEManagerListener {
    func onIncomingMatchRequest(senderHash: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Match Request", message: "Someone wants to match with you!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Accept", style: .default) { _ in
                BLEManager.shared.acceptMatchRequest(from: senderHash)
                self?.showToast("✅ Match Accepted!")
            })
            
            alert.addAction(UIAlertAction(title: "Reject", style: .cancel) { _ in
                BLEManager.shared.rejectMatchRequest(from: senderHash)
            })
            
            self?.present(alert, animated: true)
        }
    }
    
    func onMatchAccepted(senderHash: String) {
        DispatchQueue.main.async { [weak self] in
            self?.showToast("✅ Match Accepted!")
        }
    }
    
    func onMatchRejected(senderHash: String) {
        DispatchQueue.main.async { [weak self] in
            self?.showToast("❌ Match Rejected")
        }
    }
    
    func onChatMessage(senderHash: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.showToast("💬 New message")
        }
    }
    
    func onPhotoReceived(senderHash: String, photoBase64: String) {}
    func onPhotoRequested(senderHash: String) {}
    func onUnmatchReceived(senderHash: String) {}
    func onBlockReceived(senderHash: String) {}
}
