//
//  UIFactory.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 13/02/20.
//  Copyright © 2020 e-zest. All rights reserved.
//

import UIKit

class UIFactory {

    static let shared = UIFactory()

    func navigationbackButtonBehaviour() {
        let attributes = [NSAttributedString.Key.font: UIFont(name: FontName.FuturaPTMedium.rawValue,
                                                              size: is_iPAD ? 26.0 : 20.0) ?? UIFont.systemFont(ofSize: is_iPAD ? 26.0 : 20.0), NSAttributedString.Key.foregroundColor: UIColor.black]
        let barButtonItemAppearance = UIBarButtonItem.appearance()

        barButtonItemAppearance.setTitleTextAttributes(attributes, for: .normal)
        barButtonItemAppearance.setTitleTextAttributes(attributes, for: .highlighted)

        // Sets Navigation bar Title Color and Font

        let attrs = [

            NSAttributedString.Key.foregroundColor: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: FontName.FuturaPTMedium.rawValue, size: is_iPAD ? 26.0 : 20.0) ?? UIFont.systemFont(ofSize: is_iPAD ? 26.0 : 20.0)
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

    func tabBarAppearace() {
        UITabBarItem.appearance()
            .setTitleTextAttributes(
                [NSAttributedString.Key.font: UIFont(name: FontName.FuturaPTMedium.rawValue, size: 13) ?? UIFont.systemFont(ofSize: 13)],
                for: .normal)
        UITabBarItem.appearance()
            .setTitleTextAttributes(
                [NSAttributedString.Key.font: UIFont(name: FontName.FuturaPTMedium.rawValue, size: 13) ?? UIFont.systemFont(ofSize: 13)],
                for: .selected)
    }

}
