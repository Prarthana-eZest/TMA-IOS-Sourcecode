//
//  ExtensionNavigationController.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 4/4/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    /// Given the kind of a (UIViewController subclass),
    /// removes any matching instances from self's
    /// viewControllers array.

    func removeAnyViewControllers(ofKind kind: AnyClass) {
        self.viewControllers = self.viewControllers.filter { !$0.isKind(of: kind)}
    }

    /// Given the kind of a (UIViewController subclass),
    /// returns true if self's viewControllers array contains at
    /// least one matching instance.

    func containsViewController(ofKind kind: AnyClass) -> Bool {
        return self.viewControllers.contains(where: { $0.isKind(of: kind) })
    }
}
extension UINavigationController {
    func addCustomBackButton(title: String = "") {

        var backButtonTitle: String = ""
        if title.count <= navigationBarTitleTrimTo {
            backButtonTitle = title
        }
        else {
            backButtonTitle = String(title.prefix(navigationBarTitleTrimTo)) + "..."
        }

        // let shortString = String(title.prefix(navigationBarTitleTrimTo))
        let imgBackArrow = UIImage(named: "navigationBackButton")

        navigationController?.navigationBar.backIndicatorImage = imgBackArrow
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = imgBackArrow

        navigationItem.leftItemsSupplementBackButton = true
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: .plain, target: self, action: nil)
    }
}
