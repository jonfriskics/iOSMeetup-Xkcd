//
//  AppDelegate.swift
//  XkcdSwift
//
//  Created by Jon Friskics on 9/27/14.
//  Copyright (c) 2014 Code School. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    // MARK: ------ Property declarations

    var window: UIWindow?

    // MARK: ------ App delegate methods

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let comicsTVC = ComicsTableViewController(style: UITableViewStyle.Grouped)
        
        let navController = UINavigationController(rootViewController: comicsTVC)
        
        window!.rootViewController = navController
        window!.makeKeyAndVisible()
        
        return true
    }
}