//
//  TermsAndConditionsVC.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 17/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class TermsAndConditionsVC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.addCustomBackButton(title: "Enrich Terms & Conditions")
    }
    
    
    @IBAction func actionAccept(_ sender: Any) {
        self.navigationController?.popViewController(animated:true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
