//  EnrichSalon
//  Created by Aman Gupta on 3/4/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit

enum AppStoryboard: String {

    case Main, HomeLanding, Login, Dashboard, Revenue, Schedule, Catalogue, More, Location, Products, Services, Blog, BookAppointment, Incentive, Earnings

    var instance: UIStoryboard {

        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }

    func viewController<T: UIViewController>(viewControllerClass: T.Type) -> T {

        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard")
        }

        return scene
    }

    func initialViewController() -> UIViewController? {

        return instance.instantiateInitialViewController()
    }
}

extension UIViewController {

    // Not using static as it wont be possible to override to provide custom storyboardID then
    class var storyboardID: String {

        return "\(self)"

    }

    static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {

        return appStoryboard.viewController(viewControllerClass: self)
    }

}
