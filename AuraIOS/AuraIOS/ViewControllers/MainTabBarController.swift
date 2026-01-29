import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    private func setupTabBar() {
        // Tab bar appearance
        tabBar.backgroundColor = UIColor(red: 0.043, green: 0.059, blue: 0.078, alpha: 0.95)
        tabBar.tintColor = UIColor(red: 0, green: 0.898, blue: 1, alpha: 1) // Neon Blue
        tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.6)
        tabBar.isTranslucent = true
        
        // Add subtle border
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
    }
    
    private func setupViewControllers() {
        let discoverVC = DiscoverViewController()
        let discoverNav = UINavigationController(rootViewController: discoverVC)
        discoverNav.tabBarItem = UITabBarItem(
            title: "Keşfet",
            image: UIImage(systemName: "radar"),
            selectedImage: UIImage(systemName: "radar.fill")
        )
        
        let matchesVC = MatchesViewController()
        let matchesNav = UINavigationController(rootViewController: matchesVC)
        matchesNav.tabBarItem = UITabBarItem(
            title: "Eşleşmeler",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )
        
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: "Profil",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        viewControllers = [discoverNav, matchesNav, profileNav]
        
        // Set initial tab
        selectedIndex = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start BLE services
        BLEManager.shared.startScanning()
        
        if UserPreferences.shared.isVisibilityEnabled {
            BLEManager.shared.startAdvertising()
        }
    }
}