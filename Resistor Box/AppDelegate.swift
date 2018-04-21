//
//  AppDelegate.swift
//  Resistor Box
//
//  Created by Michael Griebling on 2018-02-15.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import UIKit
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static var currentCloudToken : (NSCoding & NSCopying & NSObjectProtocol)?
    static var firstLaunchWithiCloudAvailable = false
    static var useiCloud = false
    static var myContainer : URL?
    
    var paymentHandler = Purchase()
    
    enum Key {
        static let ubiquityName = "com.c-inspirations.Resistor-Box.UbiquityIdentityToken"
    }
    
    func getiCloudToken() -> (NSCoding & NSCopying & NSObjectProtocol)? {
        let fileManager = FileManager.default
        let currentCloudToken = fileManager.ubiquityIdentityToken
        if let currentToken = currentCloudToken {
            let newTokenData = NSKeyedArchiver.archivedData(withRootObject: currentToken)
            UserDefaults.standard.set(newTokenData, forKey: Key.ubiquityName)
        } else {
            UserDefaults.standard.removeObject(forKey: Key.ubiquityName)
        }
        return currentCloudToken
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        let previousCloud = UserDefaults.standard.data(forKey: Key.ubiquityName)
//        let currentCloudToken = getiCloudToken()
//        if previousCloud == nil, let _ = currentCloudToken {
//            AppDelegate.firstLaunchWithiCloudAvailable = true
//        }
//        AppDelegate.currentCloudToken = currentCloudToken
//        
//        // Register to be notified of iCloud availability changes
////        NotificationCenter.default.addObserver(self, selector: #selector(iCloudAvailabilityChanged(_:)), name: NSNotification.Name.NSUbiquityIdentityDidChange, object: nil)
//        
//        // Ask user if (s)he wants to use iCloud
//        if let _ = AppDelegate.currentCloudToken, AppDelegate.firstLaunchWithiCloudAvailable {
//            let alert = UIAlertController(title: "Choose Storage Option", message: "Should documents be stored in iCloud and available on all your devices?", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Local Only", style: .cancel, handler: { action in
//                AppDelegate.useiCloud = false
//            }))
//            alert.addAction(UIAlertAction(title: "Use iCloud", style: .default, handler: { action in
//                AppDelegate.useiCloud = true
//                // get the iCloud container to be used
//                self.updateContainer()
//            }))
//            
//            DispatchQueue.main.async {
//                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
//            }
//            
//            AppDelegate.firstLaunchWithiCloudAvailable = false
//        }
        if AppDelegate.myContainer == nil {
            setUpLocalContainer()
        }
        print("Active container = \(AppDelegate.myContainer!)")
        
        // register for external payment notifications
        SKPaymentQueue.default().add(paymentHandler)
        
        return true
    }
    
    func setUpLocalContainer() {
        if let container = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            AppDelegate.myContainer = container
        }
    }
    
    func updateContainer() {
        DispatchQueue.global().async {
            AppDelegate.myContainer = FileManager.default.url(forUbiquityContainerIdentifier: nil)
            if AppDelegate.myContainer == nil {
                self.setUpLocalContainer()
            }
            print("Container = \(AppDelegate.myContainer!.absoluteString)")
        }
    }
    
    @objc func iCloudAvailabilityChanged(_ arg : Any) {
        let currentToken = AppDelegate.currentCloudToken
        let newToken = getiCloudToken()
        print("iCloud availability changed...")
        if let current = currentToken, let new = newToken, !current.isEqual(new) {
            // discard changes because old account is gone
            updateContainer()
        } else if newToken == nil {
            setUpLocalContainer()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        Resistors.cancelCalculations = true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        SKPaymentQueue.default().remove(paymentHandler)
    }
    
    //********************************************************************************
    /**
     Called by an external App to open a Solinst XLE file.  We examine the XLE
     file to see if it already exists in the database, and if it does, we show
     the current file contents on a plot.  If the data doesnt' exist, it is
     imported to the database and then displayed.
     
     - Author:   Michael Griebling
     - Date:     7 Dec 2017
     
     ******************************************************************************** */
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // Ensure the URL is a file URL
        guard url.isFileURL else { return false }
        
        // Reveal / import the document at the URL
        //        guard let documentBrowserViewController = window?.rootViewController as? DocumentBrowserViewController else { return false }
        //
        //        documentBrowserViewController.revealDocument(at: url, importIfNeeded: true) { (revealedDocumentURL, error) in
        //            if let error = error {
        //                // Handle the error appropriately
        //                print("Failed to reveal the document at URL \(url) with error: '\(error)'")
        //                return
        //            }
        //
        //            // Present the Document View Controller for the revealed URL
        //            documentBrowserViewController.presentDocument(at: revealedDocumentURL!)
        //        }
        return true
    }


}

