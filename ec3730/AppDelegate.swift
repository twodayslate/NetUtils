//
//  AppDelegate.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/22/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import CloudKit
import CoreData
import SimpleCommon
import SKVersion
import SwiftUI
import UIKit
import Version

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let services = WhoisXml.current.services + GoogleWebRisk.current.services

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
            if ProcessInfo().arguments.contains("SKIP_ANIMATIONS") {
                UIView.setAnimationsEnabled(false)
            }

            handleUITests()
        #endif

        SimpleAppIcon.allIcons.insert(.dark)
        SimpleAppIcon.allIcons.insert(.light)
        SimpleAppIcon.allIcons.insert(.legacy)

        UIDevice.current.isBatteryMonitoringEnabled = true

        print(Bundle.main.bundleIdentifier?.description ?? "NO BUNDLE IDENTIFIER")

        Bundle.main.storeVersion?.update { canUpdate, version, error in
            guard error == nil else {
                print("An error has occured! \(error!.localizedDescription)")
                return
            }

            guard let version = version else {
                print("Unable to get new version")
                return
            }

            if canUpdate {
                DispatchQueue.main.async {
                    self.window?.rootViewController?.showError("Update Available!", message: "An update to \(String(describing: version)) is available in the App Store")
                }
            }
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.black

        let tabViewController = UIHostingController(rootView: ContentView())
        window!.rootViewController = tabViewController
        window!.makeKeyAndVisible()

        return true
    }

    func handleUITests() {
        if ProcessInfo.processInfo.arguments.contains("UI-Testing") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.dictionaryRepresentation().keys.forEach(UserDefaults.standard.removeObject(forKey:))
            UserDefaults.standard.synchronize()
        }
    }

    static var persistantStore: NSPersistentCloudKitContainer? = {
        let container = NSPersistentCloudKitContainer(name: "NetUtilsCoreData")
        container.loadPersistentStores { _, error in
            guard error == nil else {
                return
            }
        }
        return container
    }()

    func applicationWillResignActive(_: UIApplication) {}

    func applicationDidEnterBackground(_: UIApplication) {}

    func applicationWillEnterForeground(_: UIApplication) {}

    func applicationDidBecomeActive(_: UIApplication) {}

    func applicationWillTerminate(_: UIApplication) {}
}
