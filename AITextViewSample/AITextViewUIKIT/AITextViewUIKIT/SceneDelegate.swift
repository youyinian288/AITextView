//
//  SceneDelegate.swift
//  AITextViewUIKIT
//
//  Created by yunning you on 2025/10/7.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // 创建主ViewController
        let mainViewController = ViewController()
        mainViewController.title = "AITextView 编辑器"
        
        // 创建AI测试ViewController
        let aiTestViewController = AIStreamTestViewController()
        aiTestViewController.title = "AI流式输出测试"
        
        // 创建TabBarController
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: mainViewController),
            UINavigationController(rootViewController: aiTestViewController)
        ]
        
        // 设置TabBar图标和标题
        if let mainNav = tabBarController.viewControllers?[0] as? UINavigationController {
            mainNav.tabBarItem = UITabBarItem(title: "编辑器", image: UIImage(systemName: "doc.text"), tag: 0)
        }
        
        if let aiNav = tabBarController.viewControllers?[1] as? UINavigationController {
            aiNav.tabBarItem = UITabBarItem(title: "AI测试", image: UIImage(systemName: "brain.head.profile"), tag: 1)
        }
        
        // 设置window的根视图控制器
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

