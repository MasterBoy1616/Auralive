import UIKit

class GenderSelectViewController: UIViewController {
    
    private var selectedGender: Gender?
    
    // UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Your Gender"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let maleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("♂️ Male", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.clear.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let femaleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("♀️ Female", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        button.backgroundColor = UIColor.systemPink.withAlphaComponent(0.2)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.clear.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = UIColor.systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.isEnabled = false
        button.alpha = 0.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        
        setupUI()
        setupActions()
        
        print("🎨 GenderSelectViewController: Loaded")
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(maleButton)
        view.addSubview(femaleButton)
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            // Title
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Male Button
            maleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            maleButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            maleButton.widthAnchor.constraint(equalToConstant: 200),
            maleButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Female Button
            femaleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            femaleButton.topAnchor.constraint(equalTo: maleButton.bottomAnchor, constant: 20),
            femaleButton.widthAnchor.constraint(equalToConstant: 200),
            femaleButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Continue Button
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            continueButton.widthAnchor.constraint(equalToConstant: 250),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        maleButton.addTarget(self, action: #selector(maleButtonTapped), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(femaleButtonTapped), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    @objc private func maleButtonTapped() {
        selectedGender = .male
        updateButtonStates()
        print("👨 GenderSelectViewController: Male selected")
    }
    
    @objc private func femaleButtonTapped() {
        selectedGender = .female
        updateButtonStates()
        print("👩 GenderSelectViewController: Female selected")
    }
    
    private func updateButtonStates() {
        // Reset both buttons
        maleButton.layer.borderColor = UIColor.clear.cgColor
        femaleButton.layer.borderColor = UIColor.clear.cgColor
        
        // Highlight selected
        if selectedGender == .male {
            maleButton.layer.borderColor = UIColor.systemBlue.cgColor
        } else if selectedGender == .female {
            femaleButton.layer.borderColor = UIColor.systemPink.cgColor
        }
        
        // Enable continue button
        continueButton.isEnabled = selectedGender != nil
        continueButton.alpha = selectedGender != nil ? 1.0 : 0.5
    }
    
    @objc private func continueButtonTapped() {
        guard let gender = selectedGender else { return }
        
        print("✅ GenderSelectViewController: Saving gender: \(gender.rawValue)")
        
        // Save gender
        UserPreferences.shared.setGender(gender)
        UserPreferences.shared.hasCompletedGenderSelection = true
        UserPreferences.shared.save()
        
        // Update BLE Manager
        BLEManager.shared.setCurrentUser(UserPreferences.shared.getUserId())
        
        // Navigate to main app
        let mainVC = MainViewController()
        mainVC.modalPresentationStyle = .fullScreen
        present(mainVC, animated: true)
        
        print("🚀 GenderSelectViewController: Navigating to main app")
    }
}
