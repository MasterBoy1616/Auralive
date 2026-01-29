import UIKit

class MatchesViewController: UIViewController {
    
    private let tableView = UITableView()
    private let emptyStateView = UIView()
    private let emptyStateLabel = UILabel()
    
    private var matches: [Match] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupEmptyState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMatches()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.043, green: 0.059, blue: 0.078, alpha: 1)
        title = "Eşleşmeler"
        
        // Navigation bar styling
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.043, green: 0.059, blue: 0.078, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
    }
    
    private func setupTableView() {
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MatchCell.self, forCellReuseIdentifier: "MatchCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupEmptyState() {
        emptyStateView.backgroundColor = UIColor.clear
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        
        emptyStateLabel.text = "💕\n\nHenüz eşleşmen yok\nYakındaki kullanıcıları keşfet!"
        emptyStateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyStateLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor)
        ])
        
        emptyStateView.isHidden = true
    }
    
    private func loadMatches() {
        matches = MatchStore.shared.getMatches()
        tableView.reloadData()
        
        emptyStateView.isHidden = !matches.isEmpty
        tableView.isHidden = matches.isEmpty
    }
    
    private func openChat(with match: Match) {
        let chatVC = ChatViewController()
        chatVC.match = match
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    private func showMatchOptions(for match: Match) {
        let alert = UIAlertController(title: match.displayName, message: "Ne yapmak istiyorsun?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "💬 Sohbet Et", style: .default) { _ in
            self.openChat(with: match)
        })
        
        alert.addAction(UIAlertAction(title: "💔 Eşleşmeyi İptal Et", style: .destructive) { _ in
            self.confirmUnmatch(match)
        })
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(alert, animated: true)
    }
    
    private func confirmUnmatch(_ match: Match) {
        let alert = UIAlertController(
            title: "Eşleşmeyi İptal Et",
            message: "\(match.userName) ile eşleşmeyi iptal etmek istediğinden emin misin?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Evet, İptal Et", style: .destructive) { _ in
            // Send unmatch message via BLE
            BLEManager.shared.sendUnmatch(to: match.userHash)
            
            // Remove from local storage
            MatchStore.shared.removeMatch(userHash: match.userHash)
            
            // Reload data
            self.loadMatches()
            
            // Show confirmation
            let successAlert = UIAlertController(title: "✅ Eşleşme İptal Edildi", message: "Eşleşme başarıyla iptal edildi.", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "Tamam", style: .default))
            self.present(successAlert, animated: true)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension MatchesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath) as! MatchCell
        cell.configure(with: matches[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showMatchOptions(for: matches[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - MatchCell
class MatchCell: UITableViewCell {
    private let containerView = UIView()
    private let avatarView = UIView()
    private let genderLabel = UILabel()
    private let nameLabel = UILabel()
    private let timeLabel = UILabel()
    private let statusLabel = UILabel()
    private let chatButton = UIButton()
    
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
        containerView.layer.cornerRadius = 15
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Avatar
        avatarView.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 0.3)
        avatarView.layer.cornerRadius = 25
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(avatarView)
        
        // Gender emoji
        genderLabel.font = UIFont.systemFont(ofSize: 24)
        genderLabel.textAlignment = .center
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(genderLabel)
        
        // Name
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        // Time
        timeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(timeLabel)
        
        // Status
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        statusLabel.textColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(statusLabel)
        
        // Chat button
        chatButton.setTitle("💬", for: .normal)
        chatButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        chatButton.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 0.2)
        chatButton.layer.cornerRadius = 20
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(chatButton)
        
        // Layout
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            avatarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            avatarView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),
            
            genderLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            genderLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            
            timeLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            timeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            
            statusLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            statusLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            chatButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            chatButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chatButton.widthAnchor.constraint(equalToConstant: 40),
            chatButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with match: Match) {
        genderLabel.text = match.genderEmoji
        nameLabel.text = match.userName
        
        // Format time
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        timeLabel.text = formatter.localizedString(for: match.matchedAt, relativeTo: Date())
        
        // Status
        if let lastMessage = match.lastMessageAt {
            statusLabel.text = "Son mesaj: \(formatter.localizedString(for: lastMessage, relativeTo: Date()))"
        } else {
            statusLabel.text = "Henüz mesaj yok"
        }
        
        // Avatar color based on gender
        if match.gender == "M" {
            avatarView.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 0.3)
        } else {
            avatarView.backgroundColor = UIColor(red: 1, green: 0.078, blue: 0.576, alpha: 0.3)
        }
    }
}