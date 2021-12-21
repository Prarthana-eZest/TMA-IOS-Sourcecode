//
//  EarningTotalHeaderCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 20/12/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

class EarningTotalHeaderCell: UITableViewCell {

    @IBOutlet weak private var iconImage: UIImageView!
    @IBOutlet weak private var lblValue: UILabel!
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var gradientView: Gradient!
    
    var model: EarningsHeaderDataModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientView.clipsToBounds = true
        gradientView.layer.cornerRadius = 8
        gradientView.layer.masksToBounds = false
        gradientView.layer.shadowRadius = 8
        gradientView.layer.shadowOpacity = 0.20
        gradientView.layer.shadowOffset = CGSize(width: 0, height: 10)
        gradientView.layer.shadowColor = UIColor.gray.cgColor
        
    }
    
    func configureCell(model: EarningsHeaderDataModel, data: [GraphDataEntry]) {
        self.model = model
        gradientView.startColor = UIColor(red: 0.23, green: 0.89, blue: 0.76, alpha: 1.00)//rgba(58, 226, 195, 1)//model.earningsType.headerGradientColors.first ?? .white
        gradientView.endColor = UIColor(red: 0.04, green: 0.44, blue: 0.78, alpha: 1.00)//rgba(9, 111, 200, 1)
        gradientView.startLocation = 0.0
        gradientView.endLocation = 1.0
        gradientView.horizontalMode = true
        iconImage.image = UIImage(named: "TotalEarningsHeader")
        //lblTitle.text = model.earningsType.headerTitle
        lblValue.text = model.value?.roundedStringValue() ?? ""
    }
    
}
