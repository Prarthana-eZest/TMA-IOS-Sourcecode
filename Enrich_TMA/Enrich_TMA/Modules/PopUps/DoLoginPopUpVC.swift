//
//  DoLoginPopUpVC.swift
//  EnrichSalon
//
//  Created by Mugdha Mundhe on 4/24/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

struct Status {

}
protocol LoginRegisterDelegate: class {
    func doLoginRegister()
}

class DoLoginPopUpVC: UIViewController {
    @IBOutlet weak private var imgLogo: UIImageView!
    @IBOutlet weak private var lblDescription: UILabel!
    @IBOutlet weak private var btnLogin: UIButton!

    var onDoneBlock: ((Bool) -> Void)?
    weak var delegate: LoginRegisterDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Navigation

    @IBAction func actionBtnLogin(_ sender: Any) {
        onDoneBlock?(true)
        delegate?.doLoginRegister()
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func clickToClose(_ sender: Any) {
        onDoneBlock?(true)
        self.dismiss(animated: false, completion: nil)
    }
}
