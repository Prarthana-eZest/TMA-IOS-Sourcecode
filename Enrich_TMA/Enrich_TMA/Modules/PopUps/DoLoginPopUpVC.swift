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
protocol LoginRegisterDelegate {
    func doLoginRegister()
}

class DoLoginPopUpVC: UIViewController {
    var delegate: LoginRegisterDelegate?
    @IBOutlet weak private var imgLogo: UIImageView!
    @IBOutlet weak private var lblDescription: UILabel!
    @IBOutlet weak private var btnLogin: UIButton!

    var onDoneBlock: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func actionBtnLogin(_ sender: Any) {
        onDoneBlock!(true)
        delegate?.doLoginRegister()
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func clickToClose(_ sender: Any) {
        onDoneBlock!(true)
        self.dismiss(animated: false, completion: nil)
    }
}
