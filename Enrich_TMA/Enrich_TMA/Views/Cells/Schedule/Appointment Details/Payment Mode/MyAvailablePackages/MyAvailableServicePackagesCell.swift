//
//  ServicePackagesCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 22/08/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class MyAvailableServicePackagesCell: UITableViewCell {

    @IBOutlet weak private var lblServicePackageName: UILabel!
    @IBOutlet weak private var lblServicePackagePrice: UILabel!
    @IBOutlet weak private var lblServicePackageValidityDate: UILabel!
    @IBOutlet weak private var lblServicePackageIncludes: UILabel!
    @IBOutlet weak private var btnRadio: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell (model: PaymentMode.MyWalletRewardPointsPackages.Service, indexPath: IndexPath) {
        lblServicePackageName.text = model.product_name
        lblServicePackageValidityDate.text = model.expiry_at
        lblServicePackagePrice.text = String(format: "₹ %@", model.discount_price?.cleanForPrice ?? "0")

        var stringServiceIncludes: String = ""
        var data = [String]()

        if let serviceIncludes = model.remaining_service_cma {
            serviceIncludes.forEach {
                stringServiceIncludes.append(String(format: "%@ (%d),", $0.name ?? "", $0.qty ?? ""))
            }
            stringServiceIncludes = String(stringServiceIncludes.dropLast())
            data = stringServiceIncludes.components(separatedBy: ",")

            let unicode = "\\u2022".unescapingUnicodeCharacters
            data = data.map { "\(unicode) \($0)" }
            lblServicePackageIncludes.text = data.joined(separator: "\n")

        }

        btnRadio.isSelected = model.isSelected ?? false

    }

}
