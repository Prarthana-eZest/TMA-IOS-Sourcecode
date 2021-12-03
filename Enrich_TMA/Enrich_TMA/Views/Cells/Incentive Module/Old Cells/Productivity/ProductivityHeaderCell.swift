//
//  ProductivityHeaderCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 16/02/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

class ProductivityHeaderCell: UITableViewCell {
    
    @IBOutlet weak private var rankView: UIView!
    @IBOutlet weak private var revenueMultiplierView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell() {
        rankView.backgroundColor = UIColor.fromGradientWithDirection(.green, frame: rankView.frame, cornerRadius: 4, direction: .leftToRight)
        revenueMultiplierView.backgroundColor = UIColor.fromGradientWithDirection(.purple, frame: revenueMultiplierView.frame, cornerRadius: 4, direction: .leftToRight)
    }
    
}
