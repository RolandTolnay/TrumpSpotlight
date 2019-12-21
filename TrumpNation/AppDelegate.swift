//
//  AppDelegate.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/5/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
   
   var window: UIWindow?
   let gcmMessageIDKey = "gcm.message_id"
   
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      
      // Firebase
      FIRApp.configure()
      
      // Notifications
      registerNotifications(for: application)
      
      // Crashlytics
      Fabric.with([Crashlytics.self])
      
      UIApplication.shared.statusBarStyle = .lightContent
      
      return true
   }
   
   func applicationWillResignActive(_ application: UIApplication) {
      // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
      // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
   }
   
   func applicationDidEnterBackground(_ application: UIApplication) {
      FIRMessaging.messaging().disconnect()
   }
   
   func applicationWillEnterForeground(_ application: UIApplication) {
      // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
      
      SubscriptionManager().validateSubscription() { _ in }
   }
   
   func applicationDidBecomeActive(_ application: UIApplication) {
      connectToFcm()
   }
   
   func applicationWillTerminate(_ application: UIApplication) {
      // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   }
   
   // iOS 9
   func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      
      guard let userInfo = userInfo as? [String:Any] else {
         completionHandler(UIBackgroundFetchResult.newData)
         return
      }
      let manager = NotificationManager()
      manager.showNotification(from: userInfo)
      
      completionHandler(UIBackgroundFetchResult.newData)
   }
   
   func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Unable to register for remote notifications: \(error.localizedDescription)")
   }
   
   private func registerNotifications(for application: UIApplication) {
      if #available(iOS 10.0, *) {
         UNUserNotificationCenter.current().delegate = self
         
         let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
         UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
         
         FIRMessaging.messaging().remoteMessageDelegate = self
      } else {
         let notificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
         let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
         application.registerUserNotificationSettings(pushNotificationSettings)
      }
      
      application.registerForRemoteNotifications()
      
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(self.tokenRefreshNotification),
                                             name: .firInstanceIDTokenRefresh,
                                             object: nil)
   }
   
   func tokenRefreshNotification(_ notification: Notification) {
      if let refreshedToken = FIRInstanceID.instanceID().token() {
         print("InstanceID token: \(refreshedToken)")
      }
      
      // Connect to FCM since connection may have failed when attempted before having a token.
      connectToFcm()
   }
   
   func connectToFcm() {
      guard FIRInstanceID.instanceID().token() != nil else {
         return
      }
      
      FIRMessaging.messaging().disconnect()
      FIRMessaging.messaging().connect { (error) in
         if error != nil {
            print("Unable to connect with FCM. \(error?.localizedDescription ?? "")")
         } else {
            print("Connected to FCM.")
         }
      }
   }
   
   private func printFonts() {
      for name in UIFont.familyNames {
         print("# Family Name: \(name)")
         print("Font Names: \(UIFont.fontNames(forFamilyName: name))")
      }
   }
   
   var orientationLock = UIInterfaceOrientationMask.all
   
   func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
      return self.orientationLock
   }
}

extension AppDelegate: FIRMessagingDelegate {
   
   func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
      print(remoteMessage.appData)
   }
}

// Receive displayed notifications for iOS 10 devices.
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
   
   // Called when in foreground
   func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      
      guard let userInfo = notification.request.content.userInfo as? [String:Any] else {
         completionHandler([])
         return
      }
      let manager = NotificationManager()
      manager.showNotification(from: userInfo)
      
      completionHandler([])
   }
   
   // Callen when in background and opened
   func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
      
      guard let userInfo = response.notification.request.content.userInfo as? [String:Any] else {
         completionHandler()
         return
      }
      let manager = NotificationManager()
      manager.showNotification(from: userInfo)
      
      completionHandler()
   }
}

