//
//  ViewController.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 17/09/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class ServiceSelectionVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserFactory.shared.checkForSignOut()
        self.navigationController?.navigationBar.isHidden = true
    }

    @IBAction func actionSalonTechnician(_ sender: UIButton) {
        let vc = CustomTabbarController.instantiate(fromAppStoryboard: .HomeLanding)
        UIApplication.shared.keyWindow?.rootViewController = vc
    }

    @IBAction func actionBelitaTechnician(_ sender: UIButton) {
        let vc = CustomTabbarController.instantiate(fromAppStoryboard: .HomeLanding)
        UIApplication.shared.keyWindow?.rootViewController = vc
    }

}
