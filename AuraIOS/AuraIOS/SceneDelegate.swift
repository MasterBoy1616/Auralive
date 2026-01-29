import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Check if user has completed gender selection
        let userDefaults = UserDefaults.standard
        let hasCompletedGenderSelection = userDefaults.bool(forKey: "hasCompletedGenderSelection")
        
        let rootViewController: UIViewController
        
        if hasCompletedGenderSelection {
            // Show main app
            rootViewController = MainTabBarController()
        } else {
            // Show splash and gender selection
            rootViewController = SplashViewController()
        }
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        // Initialize BLE Manager
        BLEManager.shared.initialize()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Resume full BLE functionality
        BLEManager.shared.enterForeground()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Keep BLE scanning active in background
        BLEManager.shared.enterBackground()
    }
}