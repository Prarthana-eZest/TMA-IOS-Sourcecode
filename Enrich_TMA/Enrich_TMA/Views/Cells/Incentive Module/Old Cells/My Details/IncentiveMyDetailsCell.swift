//
//  IncentiveMyDetailsCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 18/02/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

class IncentiveMyDetailsCell: UITableViewCell {
    
    @IBOutlet weak private var gradientView: UIView!
    @IBOutlet weak private var lblCurrentMonthAttendance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(showGradientView: Bool, showCurrentMonthLabel: Bool) {
        if showGradientView {
            gradientView.backgroundColor = UIColor.fromGradientWithDirection(.purple, frame: gradientView.frame, cornerRadius: 4, direction: .leftToRight)
        }
        gradientView.isHidden = !showGradientView
        lblCurrentMonthAttendance.isHidden = !showCurrentMonthLabel
    }
    
}
