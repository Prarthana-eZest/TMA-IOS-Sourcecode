//
//  AddNewPettyCash.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 11/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class AddNewPettyCash: UIViewController {
    
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var txtfPurpose: UITextField!
    @IBOutlet weak var txtfAmount: UITextField!
    @IBOutlet weak var btnAttchement: UIButton!
    
    var viewDismissBlock: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        viewDismissBlock?(true)
    }
    
    @IBAction func actionAttachment(_ sender: UIButton) {
    }
    
    @IBAction func actionSubmit(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        viewDismissBlock?(true)
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
