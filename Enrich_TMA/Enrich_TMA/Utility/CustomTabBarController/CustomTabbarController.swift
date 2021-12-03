//
//  CustomTabbarController.swift
//  YouTubeEmebeded
//
//  Created by Aman Gupta on 2/6/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class CustomTabbarController: UITabBarController, UITabBarControllerDelegate {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers?.forEach {_ = $0.children[0].view}
    }

    func tabBarControllerSupportedInterfaceOrientations(_ tabBarController: UITabBarController) -> UIInterfaceOrientationMask {
//        if tabBarController.selectedViewController is YouTubePlayerViewController {
//            return .allButUpsideDown
//        } else if let navController = tabBarController.selectedViewController as? UINavigationController, navController.topViewController is YouTubePlayerViewController {
//            return .allButUpsideDown
//        } else {
            //Lock view that should not be able to rotate
            return .portrait
       // }

    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        if viewController is YouTubePlayerViewController {
//            AppDelegate.OrientationLock.lock(to: .allButUpsideDown)
//        } else if let navController = viewController as? UINavigationController, navController.topViewController is YouTubePlayerViewController {
//            AppDelegate.OrientationLock.lock(to: .allButUpsideDown)
//        } else {
            //Lock orientation and rotate to desired orientation
            AppDelegate.OrientationLock.lock(to: .portrait, andRotateTo: .portrait)
       // }
        return true
    }
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Selected view controller")
//         if let navController = viewController as? UINavigationController, navController.topViewController is CartModuleVC {
//            let cntrl = navController.topViewController as? CartModuleVC
//            if let backButton = cntrl?.btnBack {backButton.isHidden = true}
//        }

    }
}
// How to use
//self.tabBarController?.increaseBadge(indexOfTab: 3, num: "34")
extension UITabBarController {
    func increaseBadge(indexOfTab: Int, num: String) {
        let tabItem = tabBar.items?[indexOfTab]
        tabItem?.badgeValue = num
    }
    func nilBadge(indexOfTab: Int) {
        let tabItem = tabBar.items?[indexOfTab]
        tabItem?.badgeValue = nil
    }
}
