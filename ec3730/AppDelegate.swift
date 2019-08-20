//
//  AppDelegate.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/22/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import SwiftyStoreKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        #if DEBUG
            // https://docs.fastlane.tools/actions/snapshot/#speed-up-snapshots
            if ProcessInfo().arguments.contains("SKIP_ANIMATIONS") {
                UIView.setAnimationsEnabled(false)
            }
        #endif

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.black

        let tabViewController = SRCTabBarController()
        tabViewController.delegate = tabViewController

//        let splitViewController = SRCSplitViewController()
//        splitViewController.delegate = splitViewController
//        let masterViewController = UINavigationController.init(rootViewController: MasterViewController())
//
//        let detailViewController = UINavigationController.init(rootViewController: DetailViewController())
//
//        splitViewController.viewControllers = [masterViewController, detailViewController]
//
//        splitViewController.preferredDisplayMode = .allVisible

        window!.rootViewController = tabViewController

        window!.makeKeyAndVisible()

        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                default:
                    break // do nothing
                }
            }
        }

//        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
//        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        return true
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state.
        // This can occur for certain types of temporary interruptions (such as an incoming
        // phone call or SMS message) or when the user quits the application and it begins
        // the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics
        // rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and
        // store enough application state information to restore your application to its
        // current state in case it is terminated later.
        // If your application supports background execution, this method is called instead
        // of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state;
        // here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application
        // was inactive. If the application was previously in the background, optionally
        // refresh the user interface.
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
