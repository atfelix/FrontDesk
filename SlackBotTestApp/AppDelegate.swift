//
//  AppDelegate.swift
//  SlackBotTestApp
//
//  Created by atfelix on 2017-07-31.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit
import SKWebAPI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.setupAppearance()
        let navController = self.window?.rootViewController as! UINavigationController
        let decisionVC = navController.topViewController as! DecisionViewController
        decisionVC.channelStore = ChannelStore(token: SLACK_API_KEY)
        return true
    }

    private func setupAppearance() {
        self.window?.tintColor = .black
        UISearchBar.appearance().barTintColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchController.self]).textColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchController.self]).backgroundColor = .black
        UISwitch.appearance().tintColor = .black
        UISwitch.appearance().onTintColor = .black
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: .normal)
    }
}
