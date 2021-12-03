//
//  IncentiveDetailsHeaderCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 24/02/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

class IncentiveDetailsHeaderCell: UITableViewCell {
    
    @IBOutlet weak private var btnDropDown: UIButton!
    
    @IBOutlet weak private var lblDate: UILabel!
    @IBOutlet weak private var lblShift: UILabel!
    @IBOutlet weak private var lblPunchIn: UILabel!
    @IBOutlet weak private var lblPunchOut: UILabel!

    @IBOutlet weak private var gradientView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell() {
        gradientView.backgroundColor = UIColor.fromGradientWithDirection(.blue, frame: gradientView.frame, cornerRadius: 4, direction: .leftToRight)
    }

    @IBAction func actionDropDown(_ sender: UIButton) {
    }
    
}
