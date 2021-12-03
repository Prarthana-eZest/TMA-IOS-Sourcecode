//
//  AppDelegate.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 17/09/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseMessaging

enum ServiceType: String {
    case salonService = "salon"
    case belitaService = "belita"
    case homeService = "home"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var orientationLock = UIInterfaceOrientationMask.all

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Override point for customization after application launch.
        LocationManager.sharedInstance.initialiseLocationManager()

        Messaging.messaging().delegate = self
        FirebaseApp.configure()
        self.registerForPushNotification()

        // ********* App Flow Functions *******
        UIFactory.shared.navigationbackButtonBehaviour()
        UIFactory.shared.tabBarAppearace()
        // self.biometricAuthentication()
        onBoardingScreen()

        return true
    }

    func onBoardingScreen() {
        // authentication successful

        if GenericClass.sharedInstance.isuserLoggedIn().status {
            moveToLandingScreen()
        }
        else {
            let navigationC = LoginNavigtionController.instantiate(fromAppStoryboard: .Login)
            self.window?.rootViewController = navigationC
            self.window?.makeKeyAndVisible()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        ApplicationFactory.shared.showAppUpdate()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UserFactory.shared.checkForSignOut()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate.
        // Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Enrich_TMA")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                //You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    struct OrientationLock {

        static func lock(to orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }

        static func lock(to orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation) {
            self.lock(to: orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
    }

}
