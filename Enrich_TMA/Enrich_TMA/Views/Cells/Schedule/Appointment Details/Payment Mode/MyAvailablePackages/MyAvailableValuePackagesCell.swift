//
//  ValuePackagesCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 22/08/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class MyAvailableValuePackagesCell: UITableViewCell {

    @IBOutlet weak private var lblValuePackageName: UILabel!
    @IBOutlet weak private var lblValuePackageBalance: UILabel!
    @IBOutlet weak private var lblValuePackageValidityDate: UILabel!
    @IBOutlet weak private var lblValuePackagePrice: UILabel!
    @IBOutlet weak private var lblPackageValue: UILabel!
    @IBOutlet weak private var btnRadio: UIButton!
    @IBOutlet weak private var btnClose: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell (model: PaymentMode.MyWalletRewardPointsPackages.Value, indexPath: IndexPath) {
        lblValuePackageName.text = model.product_name
        lblValuePackageBalance.text = String(format: "₹ %@", model.discount_price?.cleanForPrice ?? "0")
        lblValuePackageValidityDate.text = model.expiry_at
        lblValuePackagePrice.text = String(format: "₹ %@", model.package_price?.cleanForPrice ?? "0")
        lblPackageValue.text = String(format: "₹ %@", model.package_price?.cleanForPrice ?? "0")
        btnRadio.isSelected = model.isSelected ?? false
    }

}
