import UIKit

struct ChatMessage {
    let id: String
    let content: String
    let isFromMe: Bool
    let timestamp: Date
    let status: MessageStatus
    
    enum MessageStatus {
        case sending
        case sent
        case delivered
        case failed
    }
}

class ChatViewController: UIViewController {
    
    var match: Match!
    
    private let tableView = UITableView()
    private let inputContainer = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton()
    
    private var messages: [ChatMessage] = []
    private var inputContainerBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupInputContainer()
        setupKeyboardObservers()
        setupBLE()
        loadMessages()
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
        title = match.displayName
        
        // Navigation bar styling
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.tintColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        
        // Add info button
        let infoButton = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(showUserInfo))
        navigationItem.rightBarButtonItem = infoButton
    }
    
    private func setupTableView() {
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
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
        messageTextField.placeholder = "Mesajını yaz..."
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
    
    private func setupBLE() {
        BLEManager.shared.addDelegate(self)
    }
    
    private func loadMessages() {
        // Load messages from local storage
        messages = ChatStore.shared.getMessages(for: match.userHash)
        tableView.reloadData()
        scrollToBottom(animated: false)
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
    
    @objc private func showUserInfo() {
        let alert = UIAlertController(title: match.displayName, message: "Eşleşme Tarihi: \(DateFormatter.localizedString(from: match.matchedAt, dateStyle: .medium, timeStyle: .short))", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "💔 Eşleşmeyi İptal Et", style: .destructive) { _ in
            self.confirmUnmatch()
        })
        
        alert.addAction(UIAlertAction(title: "Kapat", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func confirmUnmatch() {
        let alert = UIAlertController(
            title: "Eşleşmeyi İptal Et",
            message: "\(match.userName) ile eşleşmeyi iptal etmek istediğinden emin misin?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Evet, İptal Et", style: .destructive) { _ in
            // Send unmatch message via BLE
            BLEManager.shared.sendUnmatch(to: self.match.userHash)
            
            // Remove from local storage
            MatchStore.shared.removeMatch(userHash: self.match.userHash)
            
            // Go back
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func sendMessage() {
        guard let text = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        
        // Clear input
        messageTextField.text = ""
        
        // Create message
        let message = ChatMessage(
            id: UUID().uuidString,
            content: text,
            isFromMe: true,
            timestamp: Date(),
            status: .sending
        )
        
        // Add to UI
        messages.append(message)
        tableView.reloadData()
        scrollToBottom(animated: true)
        
        // Store locally
        ChatStore.shared.storeMessage(message, for: match.userHash)
        
        // Send via BLE
        BLEManager.shared.sendChatMessage(to: match.userHash, message: text)
        
        // Update message status after delay (simulate sending)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let index = self.messages.firstIndex(where: { $0.id == message.id }) {
                var updatedMessage = self.messages[index]
                updatedMessage = ChatMessage(
                    id: updatedMessage.id,
                    content: updatedMessage.content,
                    isFromMe: updatedMessage.isFromMe,
                    timestamp: updatedMessage.timestamp,
                    status: .sent
                )
                self.messages[index] = updatedMessage
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
        
        // Award crystals for first message
        if messages.filter({ $0.isFromMe }).count == 1 {
            CrystalManager.shared.awardFirstMessage()
        }
        
        // Update match last message time
        MatchStore.shared.updateLastMessage(userHash: match.userHash)
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
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageCell
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

// MARK: - BLEManagerDelegate
extension ChatViewController: BLEManagerDelegate {
    func didReceiveMatchRequest(from userHash: String, gender: String) {
        // Handle in DiscoverViewController
    }
    
    func didReceiveMatchResponse(from userHash: String, accepted: Bool) {
        // Handle in DiscoverViewController
    }
    
    func didReceiveChatMessage(from userHash: String, message: String) {
        guard userHash == match.userHash else { return }
        
        DispatchQueue.main.async {
            let chatMessage = ChatMessage(
                id: UUID().uuidString,
                content: message,
                isFromMe: false,
                timestamp: Date(),
                status: .delivered
            )
            
            self.messages.append(chatMessage)
            self.tableView.reloadData()
            self.scrollToBottom(animated: true)
            
            // Store locally
            ChatStore.shared.storeMessage(chatMessage, for: self.match.userHash)
            
            // Update match last message time
            MatchStore.shared.updateLastMessage(userHash: self.match.userHash)
        }
    }
    
    func didReceiveUnmatch(from userHash: String) {
        guard userHash == match.userHash else { return }
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "💔 Eşleşme İptal Edildi", message: "\(self.match.userName) eşleşmeyi iptal etti.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            })
            self.present(alert, animated: true)
            
            // Remove from local storage
            MatchStore.shared.removeMatch(userHash: userHash)
        }
    }
    
    func didReceiveBlock(from userHash: String) {
        // Handle blocking
    }
    
    func didDiscoverNearbyUser(_ user: NearbyUser) {
        // Handle in DiscoverViewController
    }
    
    func didLoseNearbyUser(userHash: String) {
        // Handle in DiscoverViewController
    }
}

// MARK: - ChatMessageCell
class ChatMessageCell: UITableViewCell {
    private let messageContainer = UIView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let statusLabel = UILabel()
    
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
        
        // Message container
        messageContainer.layer.cornerRadius = 16
        messageContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageContainer)
        
        // Message label
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageContainer.addSubview(messageLabel)
        
        // Time label
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timeLabel)
        
        // Status label
        statusLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)
        
        // Layout constraints will be set in configure method
    }
    
    func configure(with message: ChatMessage) {
        messageLabel.text = message.content
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: message.timestamp)
        
        // Configure status
        switch message.status {
        case .sending:
            statusLabel.text = "⏳"
            statusLabel.textColor = UIColor.yellow
        case .sent:
            statusLabel.text = "✓"
            statusLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        case .delivered:
            statusLabel.text = "✓✓"
            statusLabel.textColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        case .failed:
            statusLabel.text = "❌"
            statusLabel.textColor = UIColor.red
        }
        
        // Remove existing constraints
        messageContainer.removeFromSuperview()
        timeLabel.removeFromSuperview()
        statusLabel.removeFromSuperview()
        
        contentView.addSubview(messageContainer)
        contentView.addSubview(timeLabel)
        contentView.addSubview(statusLabel)
        
        messageContainer.addSubview(messageLabel)
        
        if message.isFromMe {
            // My message - right aligned, blue
            messageContainer.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
            messageLabel.textColor = .black
            
            NSLayoutConstraint.activate([
                messageContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                messageContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                messageContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
                
                messageLabel.topAnchor.constraint(equalTo: messageContainer.topAnchor, constant: 12),
                messageLabel.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: 12),
                messageLabel.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor, constant: -12),
                messageLabel.bottomAnchor.constraint(equalTo: messageContainer.bottomAnchor, constant: -12),
                
                timeLabel.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor),
                timeLabel.topAnchor.constraint(equalTo: messageContainer.bottomAnchor, constant: 4),
                timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
                
                statusLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -4),
                statusLabel.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor)
            ])
        } else {
            // Their message - left aligned, gray
            messageContainer.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            messageLabel.textColor = .white
            
            NSLayoutConstraint.activate([
                messageContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                messageContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                messageContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
                
                messageLabel.topAnchor.constraint(equalTo: messageContainer.topAnchor, constant: 12),
                messageLabel.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: 12),
                messageLabel.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor, constant: -12),
                messageLabel.bottomAnchor.constraint(equalTo: messageContainer.bottomAnchor, constant: -12),
                
                timeLabel.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor),
                timeLabel.topAnchor.constraint(equalTo: messageContainer.bottomAnchor, constant: 4),
                timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])
            
            statusLabel.isHidden = true
        }
    }
}

// MARK: - ChatStore
class ChatStore {
    static let shared = ChatStore()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    func storeMessage(_ message: ChatMessage, for userHash: String) {
        let key = "messages_\(userHash)"
        var messages = getMessages(for: userHash)
        messages.append(message)
        
        if let data = try? JSONEncoder().encode(messages) {
            userDefaults.set(data, forKey: key)
        }
    }
    
    func getMessages(for userHash: String) -> [ChatMessage] {
        let key = "messages_\(userHash)"
        guard let data = userDefaults.data(forKey: key),
              let messages = try? JSONDecoder().decode([ChatMessage].self, from: data) else {
            return []
        }
        return messages.sorted { $0.timestamp < $1.timestamp }
    }
}

// MARK: - ChatMessage Codable
extension ChatMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case id, content, isFromMe, timestamp, status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        isFromMe = try container.decode(Bool.self, forKey: .isFromMe)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        
        let statusString = try container.decode(String.self, forKey: .status)
        switch statusString {
        case "sending": status = .sending
        case "sent": status = .sent
        case "delivered": status = .delivered
        case "failed": status = .failed
        default: status = .sent
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(isFromMe, forKey: .isFromMe)
        try container.encode(timestamp, forKey: .timestamp)
        
        let statusString: String
        switch status {
        case .sending: statusString = "sending"
        case .sent: statusString = "sent"
        case .delivered: statusString = "delivered"
        case .failed: statusString = "failed"
        }
        try container.encode(statusString, forKey: .status)
    }
}