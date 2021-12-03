//
//  EarningListViewCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 29/01/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

class EarningListViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var lblTitle: UILabel!
    @IBOutlet private weak var lblPrice: UILabel!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 8
        backView.layer.masksToBounds = false
        backView.layer.shadowRadius = 8
        backView.layer.shadowOpacity = 0.10
        backView.layer.shadowOffset = CGSize(width: 0, height: 6)
        backView.layer.shadowColor = UIColor.gray.cgColor
    }
    
    func configureCell(details: EarningsHeaderDataModel) {
        lblPrice.text = details.roundedValue
        lblTitle.text = details.earningsType.menuTitle
        icon.image = details.earningsType.menuIcon
        lblPrice.textColor = details.earningsType.valueColor
    }

}
