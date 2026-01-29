import UIKit

class VenueGroupChatViewController: UIViewController {
    
    var venueName: String = ""
    
    private let tableView = UITableView()
    private let inputContainer = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton()
    private let participantsButton = UIButton()
    
    private var messages: [GroupMessage] = []
    private var participants: [GroupParticipant] = []
    private var inputContainerBottomConstraint: NSLayoutConstraint!
    
    // Mock data for demo
    private let mockMessages = [
        GroupMessage(id: "1", content: "Hey everyone! 🎉", senderNickname: "NeonWave42", timestamp: Date().addingTimeInterval(-300), isSystem: false),
        GroupMessage(id: "2", content: "Great music tonight! 🎵", senderNickname: "CrystalStar88", timestamp: Date().addingTimeInterval(-240), isSystem: false),
        GroupMessage(id: "3", content: "Anyone up for dancing? 💃", senderNickname: "ElectricDream", timestamp: Date().addingTimeInterval(-180), isSystem: false),
        GroupMessage(id: "4", content: "The vibe is amazing! ✨", senderNickname: "AuraGlow", timestamp: Date().addingTimeInterval(-120), isSystem: false)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupInputContainer()
        setupKeyboardObservers()
        loadMockData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollToBottom(animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.043, green: 0.059, blue: 0.078, alpha: 1)
        title = venueName
        
        // Navigation bar styling
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.tintColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        
        // Add participants button
        participantsButton.setTitle("👥 5", for: .normal)
        participantsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        participantsButton.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 0.2)
        participantsButton.setTitleColor(UIColor(red: 0, green: 0.898, blue: 1, alpha: 1), for: .normal)
        participantsButton.layer.cornerRadius = 12
        participantsButton.addTarget(self, action: #selector(showParticipants), for: .touchUpInside)
        
        let participantsBarButton = UIBarButtonItem(customView: participantsButton)
        navigationItem.rightBarButtonItem = participantsBarButton
    }
    
    private func setupTableView() {
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GroupMessageCell.self, forCellReuseIdentifier: "GroupMessageCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableView.addGestureRecognizer(tapGesture)
    }
    
    private func setupInputContainer() {
        inputContainer.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputContainer)
        
        // Message text field
        messageTextField.placeholder = "Grup mesajı yaz..."
        messageTextField.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        messageTextField.textColor = .white
        messageTextField.layer.cornerRadius = 20
        messageTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        messageTextField.leftViewMode = .always
        messageTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        messageTextField.rightViewMode = .always
        messageTextField.delegate = self
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(messageTextField)
        
        // Send button
        sendButton.setTitle("📤", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        sendButton.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        sendButton.layer.cornerRadius = 20
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(sendButton)
        
        // Layout
        inputContainerBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor),
            
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerBottomConstraint,
            inputContainer.heightAnchor.constraint(equalToConstant: 60),
            
            messageTextField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            messageTextField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func loadMockData() {
        messages = mockMessages
        tableView.reloadData()
        
        // Award crystals for group chat participation
        CrystalManager.shared.awardGroupChatParticipation()
    }
    
    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    @objc private func sendButtonTapped() {
        sendMessage()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func showParticipants() {
        let alert = UIAlertController(title: "👥 Katılımcılar", message: "Aktif kullanıcılar", preferredStyle: .actionSheet)
        
        let mockParticipants = [
            "🌟 NeonWave42",
            "💎 CrystalStar88", 
            "⚡ ElectricDream",
            "✨ AuraGlow",
            "🎵 MusicLover"
        ]
        
        for participant in mockParticipants {
            alert.addAction(UIAlertAction(title: participant, style: .default) { _ in
                // In a real app, this would show user profile or start DM
                let dmAlert = UIAlertController(title: "💬 Özel Mesaj", message: "Bu kullanıcıyla özel mesajlaşmak için 2+ etkileşim gerekli", preferredStyle: .alert)
                dmAlert.addAction(UIAlertAction(title: "Tamam", style: .default))
                self.present(dmAlert, animated: true)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Kapat", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = participantsButton
            popover.sourceRect = participantsButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func sendMessage() {
        guard let text = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        
        // Clear input
        messageTextField.text = ""
        
        // Create message with random nickname
        let nicknames = ["NeonWave42", "CrystalStar88", "ElectricDream", "AuraGlow", "MusicLover"]
        let myNickname = nicknames.randomElement() ?? "AuraUser"
        
        let message = GroupMessage(
            id: UUID().uuidString,
            content: text,
            senderNickname: myNickname,
            timestamp: Date(),
            isSystem: false
        )
        
        // Add to UI
        messages.append(message)
        tableView.reloadData()
        scrollToBottom(animated: true)
        
        // Award crystals for group participation
        CrystalManager.shared.awardGroupChatParticipation()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        inputContainerBottomConstraint.constant = -keyboardFrame.height + view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        
        scrollToBottom(animated: true)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        inputContainerBottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension VenueGroupChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMessageCell", for: indexPath) as! GroupMessageCell
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension VenueGroupChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

// MARK: - GroupMessage Model
struct GroupMessage {
    let id: String
    let content: String
    let senderNickname: String
    let timestamp: Date
    let isSystem: Bool
    
    init(id: String, content: String, senderNickname: String, timestamp: Date, isSystem: Bool) {
        self.id = id
        self.content = content
        self.senderNickname = senderNickname
        self.timestamp = timestamp
        self.isSystem = isSystem
    }
}

// MARK: - GroupParticipant Model
struct GroupParticipant {
    let id: String
    let nickname: String
    let auraColor: String
    let isVerified: Bool
    let joinedAt: Date
}

// MARK: - GroupMessageCell
class GroupMessageCell: UITableViewCell {
    private let containerView = UIView()
    private let nicknameLabel = UILabel()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let auraIndicator = UIView()
    
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
        
        // Aura indicator
        auraIndicator.layer.cornerRadius = 6
        auraIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(auraIndicator)
        
        // Nickname
        nicknameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nicknameLabel)
        
        // Message
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(messageLabel)
        
        // Time
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(timeLabel)
        
        // Layout
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            auraIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            auraIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            auraIndicator.widthAnchor.constraint(equalToConstant: 12),
            auraIndicator.heightAnchor.constraint(equalToConstant: 12),
            
            nicknameLabel.leadingAnchor.constraint(equalTo: auraIndicator.trailingAnchor, constant: 8),
            nicknameLabel.centerYAnchor.constraint(equalTo: auraIndicator.centerYAnchor),
            
            timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            timeLabel.centerYAnchor.constraint(equalTo: auraIndicator.centerYAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with message: GroupMessage) {
        nicknameLabel.text = message.senderNickname
        messageLabel.text = message.content
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: message.timestamp)
        
        // Random aura colors for demo
        let auraColors = [
            UIColor(red: 0, green: 0.898, blue: 1, alpha: 1), // Neon Blue
            UIColor(red: 1, green: 0.078, blue: 0.576, alpha: 1), // Neon Pink
            UIColor(red: 0.5, green: 0, blue: 1, alpha: 1), // Purple
            UIColor(red: 0, green: 1, blue: 0.5, alpha: 1), // Green
            UIColor(red: 1, green: 0.5, blue: 0, alpha: 1) // Orange
        ]
        
        auraIndicator.backgroundColor = auraColors.randomElement()
        nicknameLabel.textColor = auraIndicator.backgroundColor
        
        if message.isSystem {
            nicknameLabel.text = "System"
            nicknameLabel.textColor = UIColor.white.withAlphaComponent(0.7)
            auraIndicator.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        }
    }
}