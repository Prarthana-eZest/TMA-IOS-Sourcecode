//
//  ApplicationFactory.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 13/02/20.
//  Copyright © 2020 e-zest. All rights reserved.
//

import UIKit

class ApplicationFactory {

    static let shared = ApplicationFactory()

    let customTabbarController = CustomTabbarController.instantiate(fromAppStoryboard: .HomeLanding)

    func openGoogleMaps(lat: Double, long: Double) {

        if let UrlNavigation = URL(string: "comgooglemaps://") {
            if UIApplication.shared.canOpenURL(UrlNavigation) {
                if let urlDestination = URL(string: "comgooglemaps://?saddr=&daddr=\(lat),\(long)&directionsmode=driving") {
                    //UIApplication.shared.openURL(urlDestination)
                    UIApplication.shared.open(urlDestination, options: [:])
                }
            }
            else {
                NSLog("Can't use comgooglemaps://")
                if let urlDestination = URL(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(lat),\(long)&directionsmode=driving") {
                    UIApplication.shared.open(urlDestination, options: [:])
                }

            }
        }
        else {
            NSLog("Can't use comgooglemaps://")
            if let urlDestination = URL(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(lat),\(long)&directionsmode=driving") {
                UIApplication.shared.open(urlDestination, options: [:])
            }
        }

    }

    func showAppUpdate() {
        if UIApplication.shared.keyWindow?.rootViewController == customTabbarController {
            let selectedIndex = customTabbarController.selectedIndex
            if selectedIndex == 0 {

                if let viewC = customTabbarController.viewControllers?[0] {
                    if let navController = viewC as? UINavigationController, navController.topViewController is DashboardVC {
                        let cntrl = navController.topViewController as? DashboardVC
                        cntrl?.showAppUpdateAlert()
                    }

                }

            }
        }
    }

    func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }

    func moveToMaintenanceScreen(message: String) {
        EZLoadingActivity.hide()
        let vc = ServerUnderMaintenanceModuleVC.instantiate(fromAppStoryboard: .HomeLanding)
        if let topController = ApplicationFactory.shared.topViewController() {
            if (topController.navigationController?.topViewController as? ServerUnderMaintenanceModuleVC) != nil {
            }
            else {
                topController.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

}
