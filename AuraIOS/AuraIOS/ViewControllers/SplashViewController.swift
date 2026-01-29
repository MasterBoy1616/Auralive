import UIKit

class SplashViewController: UIViewController {
    
    private let logoLabel = UILabel()
    private let taglineLabel = UILabel()
    private let pulseView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Auto-transition to gender selection after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.navigateToGenderSelection()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.043, green: 0.059, blue: 0.078, alpha: 1) // #0B0F14
        
        // Logo
        logoLabel.text = "AURA"
        logoLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        logoLabel.textColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1) // Neon Blue
        logoLabel.textAlignment = .center
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoLabel)
        
        // Tagline
        taglineLabel.text = "Yakınındaki insanları keşfet"
        taglineLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        taglineLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        taglineLabel.textAlignment = .center
        taglineLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taglineLabel)
        
        // Pulse animation view
        pulseView.backgroundColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 0.3)
        pulseView.layer.cornerRadius = 50
        pulseView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pulseView)
        
        // Layout
        NSLayoutConstraint.activate([
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            
            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            taglineLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 16),
            
            pulseView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pulseView.centerYAnchor.constraint(equalTo: logoLabel.centerYAnchor),
            pulseView.widthAnchor.constraint(equalToConstant: 100),
            pulseView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupAnimation() {
        // Pulse animation
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.5
        pulseAnimation.fromValue = 0.8
        pulseAnimation.toValue = 1.2
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        
        pulseView.layer.add(pulseAnimation, forKey: "pulse")
        
        // Fade in animation
        logoLabel.alpha = 0
        taglineLabel.alpha = 0
        
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseInOut) {
            self.logoLabel.alpha = 1
            self.taglineLabel.alpha = 1
        }
    }
    
    private func navigateToGenderSelection() {
        let genderSelectionVC = GenderSelectionViewController()
        genderSelectionVC.modalPresentationStyle = .fullScreen
        present(genderSelectionVC, animated: true)
    }
}