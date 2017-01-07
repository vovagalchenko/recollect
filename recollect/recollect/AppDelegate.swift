//
//  AppDelegate.swift
//  recollect
//
//  Created by Vova Galchenko on 10/19/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Analytics.sharedInstance().logEvent(withName: "launch", type: AnalyticsEventTypeAppLifecycle, attributes: nil)
        
        let _ = ReviewElicitor.instance // <-- Arm the ReviewElicitor
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = BaseViewController()
        self.window = window
        self.window!.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        Analytics.sharedInstance().logEvent(withName: "resign_active", type: AnalyticsEventTypeAppLifecycle, attributes: nil)
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Analytics.sharedInstance().logEvent(withName: "enter_background", type: AnalyticsEventTypeAppLifecycle, attributes: nil)
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Analytics.sharedInstance().logEvent(withName: "enter_foreground", type: AnalyticsEventTypeAppLifecycle, attributes: nil)
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Analytics.sharedInstance().logEvent(withName: "become_active", type: AnalyticsEventTypeAppLifecycle, attributes: nil)
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        Analytics.sharedInstance().logEvent(withName: "terminate", type: AnalyticsEventTypeAppLifecycle, attributes: nil)
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

