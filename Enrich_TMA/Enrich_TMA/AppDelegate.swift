//
//  AppDelegate.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 17/09/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics

enum ServiceType:Int{
    case Salon = 1
    case Belita = 2
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var orientationLock = UIInterfaceOrientationMask.all
    
    var window: UIWindow?
    let customTabbarController = CustomTabbarController.instantiate(fromAppStoryboard: .HomeLanding)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        Fabric.with([Crashlytics.self]) // My personal aman.gupta@e-zest.in CrashAnalaytic key added
        
        // ********* App Flow Functions *******
        navigationbackButtonBehaviour()
        tabBarAppearace()
        // self.biometricAuthentication()
        onBoardingScreen()
        
        return true
    }
    
    func onBoardingScreen() {
        // authentication successful
        
        if UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_Key_LoginUser) == nil {
            let navigationC = LoginNavigtionController.instantiate(fromAppStoryboard: .Login)
            self.window?.rootViewController = navigationC
            self.window?.makeKeyAndVisible()
            UserDefaults.standard.setValue(true, forKey: UserDefauiltsKeys.k_Key_LoginUser)
        } else {
            moveToLandingScreen()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
        
        if let lastDate = UserDefaults.standard.value(forKey: UserDefauiltsKeys.lastLoginDate) as? String {
            if self.needToLogoutFromapp(lastDate: lastDate) {
                self.signOutUserFromApp()
                UserDefaults.standard.set(self.getCurrentDate(), forKey: UserDefauiltsKeys.lastLoginDate)
            }
        } else {
            UserDefaults.standard.set(self.getCurrentDate(), forKey: UserDefauiltsKeys.lastLoginDate)
        }
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
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
            } catch {
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

extension AppDelegate {
    
    private func navigationbackButtonBehaviour() {
        let attributes = [NSAttributedString.Key.font: UIFont(name: FontName.FuturaPTMedium.rawValue, size: is_iPAD ? 26.0 : 20.0)!, NSAttributedString.Key.foregroundColor: UIColor.black]
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        
        barButtonItemAppearance.setTitleTextAttributes(attributes, for: .normal)
        barButtonItemAppearance.setTitleTextAttributes(attributes, for: .highlighted)
        
        // Sets Navigation bar Title Color and Font
        
        let attrs = [
            
            NSAttributedString.Key.foregroundColor: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: FontName.FuturaPTMedium.rawValue, size: is_iPAD ? 26.0 : 20.0)!
        ]
        UINavigationBar.appearance().titleTextAttributes = attrs
        
        // Sets Navigation Back Button Color
        UINavigationBar.appearance().tintColor = .black
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = .clear
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
        
    }
    
    private func tabBarAppearace() {
        UITabBarItem.appearance()
            .setTitleTextAttributes(
                [NSAttributedString.Key.font: UIFont(name: FontName.FuturaPTMedium.rawValue, size: 13)!],
                for: .normal)
        UITabBarItem.appearance()
            .setTitleTextAttributes(
                [NSAttributedString.Key.font: UIFont(name: FontName.FuturaPTMedium.rawValue, size: 13)!],
                for: .selected)
    }
    // MARK: Move To Landing Screen
    func moveToLandingScreen() {
        // authentication successful
        
        self.window?.rootViewController = customTabbarController
        self.window?.makeKeyAndVisible()
    }
    
}

extension AppDelegate{
    
    // Logout Flow
    
    func signOutUserFromApp() {
        UserDefaults.standard.removeObject(forKey: UserDefauiltsKeys.k_Key_LoginUserSignIn)
        UserDefaults.standard.removeObject(forKey: UserDefauiltsKeys.k_Key_LoginUser)
        UserDefaults.standard.removeObject(forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart)
        UserDefaults.standard.removeObject(forKey: UserDefauiltsKeys.k_key_ServiceType)
        
        let navigationC = LoginNavigtionController.instantiate(fromAppStoryboard: .Login)
        self.window?.rootViewController = navigationC
    }
    
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: Date())
    }
    
    func needToLogoutFromapp(lastDate : String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        // Today date with time 00:00:00
        let todayDateStr =  dateFormatter.string(from: Date())
//        todayDateStr = todayDateStr.components(separatedBy: " ").first ?? ""
//        todayDateStr = todayDateStr + " 00:00:00"
        
        // Last saved date
        if let todayDate =  dateFormatter.date(from: todayDateStr), let dateLastEnter =  dateFormatter.date(from: lastDate){
            // today date is greater than last saved date app gets logout
            if todayDate != dateLastEnter {
                return true
            }
        }
        
        return false
    }
}



