//
//  AvailableCouponCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 05/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class AvailableCouponCell: UICollectionViewCell {

    @IBOutlet weak private var lblCouponCode: UILabel!
    @IBOutlet weak private var lblExpiryCode: UILabel!
    @IBOutlet weak private var lblDescription: UILabel!
    @IBOutlet weak private var lblDiscount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: AvailableCouponCellModel) {
        lblCouponCode.text = model.couponCode
        lblDescription.text = model.descriptionText
        lblExpiryCode.text = model.expiryDate
        lblDiscount.text = "\(model.discount)%"
    }

    @IBAction func actionApply(_ sender: UIButton) {
    }

}

struct AvailableCouponCellModel {
    let discount: String
    let descriptionText: String
    let couponCode: String
    let expiryDate: String
}
