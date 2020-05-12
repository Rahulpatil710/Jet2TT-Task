//
//  AppDelegate.swift
//  Jet2TT
//
//  Created by Rahul Patil on 11/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        let pendingOperations = PendingOperations()
        let blogsAPI = BlogsAPI()
        let articlesViewModel = ArticlesViewModel(blogsAPI, and: pendingOperations)
        let articlesViewController = ArticlesViewController(articlesViewModel)
        articlesViewModel.output = articlesViewController
        let navigationViewController = UINavigationController(rootViewController: articlesViewController)
        window?.rootViewController = navigationViewController

        return true
    }
}
