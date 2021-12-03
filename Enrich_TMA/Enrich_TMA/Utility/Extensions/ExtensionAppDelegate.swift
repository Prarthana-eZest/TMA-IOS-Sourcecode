//
//  ExtensionAppDelegate.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 13/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

extension AppDelegate: UNUserNotificationCenterDelegate {

    // MARK: Move To Landing Screen
    func moveToLandingScreen() {
        // authentication successful
        self.window?.rootViewController = ApplicationFactory.shared.customTabbarController
        self.window?.makeKeyAndVisible()
    }

    /// Register for push notifications
    func registerForPushNotification() {

        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (_, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
        else {

            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {

    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("Remote instance ID token: \(Messaging.messaging().fcmToken ?? "")")
        let deviceTokenKey = Messaging.messaging().fcmToken ?? ""
        UserDefaults.standard.set(deviceTokenKey, forKey: UserDefauiltsKeys.k_key_FCM_PushNotification)

        //        InstanceID.instanceID().instanceID { (result, error) in
        //            if let error = error {
        //                print("Error fetching remote instange ID: \(error)")
        //            } else if let result = result {
        //                print("Remote instance ID token: \(result.token)")
        //            }
        //        }

    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

    }

}

extension AppDelegate: MessagingDelegate {

    func application(received remoteMessage: MessagingRemoteMessage) {
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("FCM Token \(fcmToken)")
    }
}
