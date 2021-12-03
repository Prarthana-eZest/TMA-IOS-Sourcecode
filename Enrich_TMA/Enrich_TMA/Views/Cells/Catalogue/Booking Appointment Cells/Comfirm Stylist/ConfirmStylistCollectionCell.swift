//
//  ConfirmStylistCollectionCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 29/11/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class ConfirmStylistCollectionCell: UICollectionViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var selectionView: UIView!

    let selectedTextColoe = UIColor(red: 37 / 255, green: 37 / 255, blue: 37 / 255, alpha: 1)
    let unSelectedTextColor = UIColor(red: 116 / 255, green: 116 / 255, blue: 116 / 255, alpha: 1)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(title: String, subTitle: String) {
        lblTitle.text = title
        lblSubTitle.text = subTitle
    }

    func isSelected(status: Bool) {

        selectionView.isHidden = !status
        if let fontSelected = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 24 : 16 ), let fontUnSelected = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 24 : 16 ) {
            lblTitle.font = status ? fontSelected : fontUnSelected
            lblTitle.textColor = status ? selectedTextColoe : unSelectedTextColor
        }
    }

}
