import UIKit

class GenderSelectionViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let maleButton = UIButton()
    private let femaleButton = UIButton()
    private let continueButton = UIButton()
    
    private var selectedGender: Gender?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.043, green: 0.059, blue: 0.078, alpha: 1) // #0B0F14
        
        // Title
        titleLabel.text = "Cinsiyetini Seç"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Subtitle
        subtitleLabel.text = "Bu seçim özel özelliklerini belirler"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        // Male Button
        setupGenderButton(maleButton, gender: .male)
        
        // Female Button
        setupGenderButton(femaleButton, gender: .female)
        
        // Continue Button
        continueButton.setTitle("Devam Et", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        continueButton.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        continueButton.setTitleColor(.black, for: .normal)
        continueButton.layer.cornerRadius = 25
        continueButton.alpha = 0.5
        continueButton.isEnabled = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(continueButton)
        
        // Layout
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            maleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            maleButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 60),
            maleButton.widthAnchor.constraint(equalToConstant: 280),
            maleButton.heightAnchor.constraint(equalToConstant: 80),
            
            femaleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            femaleButton.topAnchor.constraint(equalTo: maleButton.bottomAnchor, constant: 20),
            femaleButton.widthAnchor.constraint(equalToConstant: 280),
            femaleButton.heightAnchor.constraint(equalToConstant: 80),
            
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            continueButton.widthAnchor.constraint(equalToConstant: 200),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupGenderButton(_ button: UIButton, gender: Gender) {
        button.setTitle("\(gender.emoji) \(gender.displayName)", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = gender.backgroundColor
        button.setTitleColor(gender.primaryColor, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.clear.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = gender == .male ? 0 : 1
        view.addSubview(button)
    }
    
    private func setupActions() {
        maleButton.addTarget(self, action: #selector(genderButtonTapped(_:)), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(genderButtonTapped(_:)), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    @objc private func genderButtonTapped(_ sender: UIButton) {
        let gender: Gender = sender.tag == 0 ? .male : .female
        selectedGender = gender
        
        // Update UI
        updateGenderSelection(selectedGender: gender)
        
        // Enable continue button
        continueButton.alpha = 1.0
        continueButton.isEnabled = true
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func updateGenderSelection(selectedGender: Gender) {
        // Reset both buttons
        maleButton.layer.borderColor = UIColor.clear.cgColor
        femaleButton.layer.borderColor = UIColor.clear.cgColor
        
        // Highlight selected button
        let selectedButton = selectedGender == .male ? maleButton : femaleButton
        selectedButton.layer.borderColor = selectedGender.primaryColor.cgColor
        
        // Add pulse animation
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.2
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.05
        pulseAnimation.autoreverses = true
        selectedButton.layer.add(pulseAnimation, forKey: "pulse")
    }
    
    @objc private func continueButtonTapped() {
        guard let gender = selectedGender else { return }
        
        // Save gender selection
        UserPreferences.shared.gender = gender
        UserPreferences.shared.hasCompletedGenderSelection = true
        UserPreferences.shared.isVisibilityEnabled = true
        
        // Initialize Crystal Manager with bonus
        CrystalManager.shared.completeGenderSelection()
        
        // Navigate to main app
        let mainTabBarController = MainTabBarController()
        mainTabBarController.modalPresentationStyle = .fullScreen
        present(mainTabBarController, animated: true) {
            // Show welcome message
            self.showWelcomeMessage(gender: gender)
        }
    }
    
    private func showWelcomeMessage(gender: Gender) {
        let message = gender == .male ? 
            "🎉 Hoş geldin! Günlük 5 DM hakkın aktif." :
            "🎉 Hoş geldin! %50 daha fazla tarama gücün aktif."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let alert = UIAlertController(title: "Aura'ya Hoş Geldin!", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Başlayalım!", style: .default))
            
            if let topVC = UIApplication.shared.windows.first?.rootViewController {
                topVC.present(alert, animated: true)
            }
        }
    }
}