//
//  PackageDetailTableViewCell.swift
//  EnrichSalon
//
//  Created by Mugdha Mundhe on 07/11/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol PackageDetailDelegate: class {
    func openOfferStores()
}

class PackageDetailTableViewCell: UITableViewCell {
    @IBOutlet weak private var lblName: UILabel!
    @IBOutlet weak private var lblShortDescription: UILabel!
    @IBOutlet weak private var lblServicePackagePrice: UILabel!
    @IBOutlet weak private var lblStores: UILabel!
    @IBOutlet weak private var btnStores: UIButton!
    @IBOutlet weak private var lblDescription: UILabel!
    @IBOutlet weak private var lblOfferDescTitle: UILabel!
    @IBOutlet weak private var imgShowOffer: UIImageView!
    @IBOutlet weak private var lblServicPackageIncludesLabel: UILabel!
    @IBOutlet weak private var lblServicPackageIncludesData: UILabel!
    @IBOutlet weak private var lblValuePackageDetail: UILabel!
    @IBOutlet weak private var lblPackageValidity: UILabel!

    weak var delegate: PackageDetailDelegate?

    @IBAction func actionOpenStores(_ sender: Any) {
        delegate?.openOfferStores()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configureCell(hideAndShowServiceIncludes: Bool = false, model: PackageListing.OffersValuePackages.Package_listValues ) {
        lblServicPackageIncludesLabel.isHidden = hideAndShowServiceIncludes
        lblServicPackageIncludesData.isHidden = hideAndShowServiceIncludes
        lblServicePackagePrice.isHidden = hideAndShowServiceIncludes
        lblServicePackagePrice.text = model.price ?? ""
        lblValuePackageDetail.isHidden = hideAndShowServiceIncludes ? false : true
        lblName.text = model.name
        lblName.text = lblName.text?.capitalized
        imgShowOffer.image = UIImage(named: "packagesDefault")
        lblShortDescription.text = model.short_description ?? ""
        lblDescription.text = model.description ?? ""
        self.lblOfferDescTitle.isHidden = (model.description ?? "").isEmpty ?  true : false

        let strLink = !(model.swatch_image ?? "").isEmpty ?  (model.swatch_image ?? "") :  (model.image ?? "")
        if !strLink.isEmpty {
            let url = URL(string: strLink)
            imgShowOffer.kf.setImage(with: url, placeholder: UIImage(named: "packagesDefault"), options: nil, progressBlock: nil, completionHandler: nil)
        }

        if let serviceInclude = model.data {
            var data = [String]()
            serviceInclude.forEach({data.append(String(format: "%@ [%@]", $0.name ?? "", "\($0.qty ?? "")"))})
            let unicode = "\\u2022".unescapingUnicodeCharacters
            data = data.map { "\(unicode) \($0)" }
            lblServicPackageIncludesData.text = data.joined(separator: "\n")
        }
        lblPackageValidity.text = String(format: "%d %@ from the date of purchase", model.validity ?? 0, model.validity ?? 0 > 1 ? "day(s)" : "day")
        lblValuePackageDetail.text = String(format: "Get ₹ %@ by purchasing value package of ₹ %@", model.offer_price_cma?.cleanForPrice ?? "0", model.price_cma?.cleanForPrice ?? "0")

        if let salon_data = model.salon_data, !salon_data.isEmpty {
            btnStores.isHidden = false
            lblStores.text = AlertMessagesToAsk.packageApplicableForSelected
        }
        else {
            lblStores.text = AlertMessagesToAsk.packageApplicable
            btnStores.isHidden = true

        }

    }

}
