//
//  AppDelegate.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/11/16.
//  Copyright © 2016 Oracle. All rights reserved.
//

import UIKit

import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var isRunningInBG:Bool?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        isRunningInBG = false;
        
        registerLocalNotifications()
        
        application.beginBackgroundTask(withName:"showNotification", expirationHandler: nil)

        let tabBar:UITabBarController = self.window?.rootViewController as! UITabBarController
        if( UserDefaults.standard.object(forKey: kBaseURL) == nil ){
            tabBar.selectedIndex = 1;
        }
        
        setDefaults()

        return true
    }
    
    func registerLocalNotifications () -> Void {
        
        let center = UNUserNotificationCenter.current()
        
        let txtAction = UNTextInputNotificationAction.init(identifier: "inputNotif", title: "Reply here", options: UNNotificationActionOptions.destructive, textInputButtonTitle: "Reply", textInputPlaceholder: "Type here");
        
        let category = UNNotificationCategory.init(identifier: "InputTxtCategory", actions: [txtAction], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([category])
        
        let options: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Failied to authorize for local notification.")
            }
        }
        
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                print("Local notifications are no more authorized by user.")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Local notification recieved.")
    }
    
    var orientationLock = UIInterfaceOrientationMask.all
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        isRunningInBG = true;
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func setDefaults() -> Void {
        
        if( UserDefaults.standard.object(forKey: kBaseURL) == nil ){
            UserDefaults.standard.set("http://e5e2d296.ngrok.io", forKey: kBaseURL)
            UserDefaults.standard.set(true, forKey: kIsBotsSpeakerON)
        }

        if( UserDefaults.standard.object(forKey: kWebhookChannelID) == nil ){
            UserDefaults.standard.set("79B208CC-6567-400D-9BE3-ABF0F883B0A8", forKey: kWebhookChannelID)
        }
        if( UserDefaults.standard.object(forKey: kBotName) == nil ){
            UserDefaults.standard.set("My bot", forKey: kBotName)
        }
        
        UserDefaults.standard.synchronize()
    }

    func establishWSConnection() -> Void {
        
        // This username is for WebSocket connection only, could be anything.
        var _username = CBManager.sharedInstance.randomString(length: 4)
        
        var host = "";
        
        if( UserDefaults.standard.object(forKey: kBaseURL) != nil ){
            host = UserDefaults.standard.object(forKey: kBaseURL) as! String
            if( host.range(of: "://")?.isEmpty == false ){
                host = host.substring(from: (host.range(of: "://")?.upperBound)!)
            }
        }
        
        if( host.range(of: "://")?.isEmpty == false ){
            host = host.substring(from: (host.range(of: "://")?.upperBound)!)
        }
        
        if( UserDefaults.standard.object(forKey: "username") != nil ){
            _username = UserDefaults.standard.object(forKey: "username") as! String
        }
        
        CBManager.sharedInstance.establishConnection( host: host, userName: _username )
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        isRunningInBG = false;
        
        establishWSConnection();
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        CBManager.sharedInstance.disconnectWS()
    }
}

