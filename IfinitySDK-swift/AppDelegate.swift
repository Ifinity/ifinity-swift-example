//
//  AppDelegate.swift
//  IfinitySDK-swift
//
//  Created by Ifinity on 10.12.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

import UIKit
import ifinitySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        IFBluetoothManager.sharedManager().setOutsideBeaconName("GEOS_OUT")
        IFDataManager.sharedManager().setClientID("43_8jqmibuoltkwkkogsws4ogkkwg4swos0g8ko84k44s4o848o8", secret: "2b1my6quzs748440gcwcww04os0kw0s480o4cskg488488gc8w")
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: [])
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPush:", name: IFPushManagerNotificationPushAreaBackgroundAdd, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPush:", name: IFPushManagerNotificationPushVenueBackgroundAdd, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPush:", name: IFPushManagerNotificationPushRemoteBackgroundAdd, object: nil)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    //MARK: - Notifications
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
}

