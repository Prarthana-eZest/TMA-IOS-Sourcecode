//
//  AchievementCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 19/02/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

class AchievementCell: UICollectionViewCell {

    @IBOutlet weak private var gradientView: UIView!
    @IBOutlet weak private var iconImage: UIImageView!
    @IBOutlet weak private var lblAmount: UILabel!
    
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell() {
        gradientView.backgroundColor = .clear
        gradientView.backgroundColor = UIColor.fromGradientWithDirection(GradientLayer.getGradientForIndex(indexPath?.row ?? 0), frame: gradientView.frame, cornerRadius: 6, direction: .topToBottom)
        lblAmount.text = "\(indexPath?.row  ?? 0)K"
        if ((indexPath?.row ?? 0) % 2 == 0) {
            iconImage.image = UIImage(named: "BestPerformer")
        }
        else {
            iconImage.image = UIImage(named: "SpecialRecognition")
        }
    }

}
