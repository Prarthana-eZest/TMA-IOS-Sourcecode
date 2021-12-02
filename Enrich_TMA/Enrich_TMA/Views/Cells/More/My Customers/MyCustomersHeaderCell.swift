//
//  MyCustomersHeaderCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 16/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class MyCustomersHeaderCell: UITableViewCell {

    @IBOutlet weak var btnName: UIButton!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var btnMobileNo: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        btnName.setTitle("Name \u{2304}", for: .normal)
        btnName.setTitle("Name \u{2303}", for: .selected)
        
        btnLocation.setTitle("Location \u{2304}", for: .normal)
        btnLocation.setTitle("Location \u{2303}", for: .selected)
        
        btnMobileNo.setTitle("Mobile Number \u{2304}", for: .normal)
        btnMobileNo.setTitle("Mobile Number \u{2303}", for: .selected)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func actionName(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func actionLocation(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnMobileNumber(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
}
