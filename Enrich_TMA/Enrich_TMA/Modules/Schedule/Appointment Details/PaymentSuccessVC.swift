//
//  PaymentSuccessVC.swift
//  Enrich_TMA
//
//  Created by Harshal on 20/01/20.
//  Copyright © 2020 e-zest. All rights reserved.
//

import UIKit

class PaymentSuccessVC: UIViewController {

    @IBOutlet weak private var lblOrderId: UILabel!

    var orderId = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblOrderId.text = "Order Id - \(orderId)"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait,
                                         andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    @IBAction func actionGoBackHome(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }

}
