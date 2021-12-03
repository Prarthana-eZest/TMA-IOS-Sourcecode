//
//  IrresistibleOffersCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 26/06/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class IrresistibleOffersCell: UICollectionViewCell {

    @IBOutlet weak private var backgroundImageView: UIImageView!
//    @IBOutlet weak private var lblTopTitle: UILabel!
//    @IBOutlet weak private var lblTitle: UILabel!
//    @IBOutlet weak private var lblDiscountText: UILabel!
//    @IBOutlet weak private var lblSubTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: Offers.Something.ResponseCoupons) {
        //        self.lblTopTitle.text = model.topTitle
        //        self.lblTitle.text = model.title
        //        self.lblSubTitle.text = model.offerDescription
        //        self.lblDiscountText.text = model.offerDescription
        backgroundImageView?.kf.indicatorType = .activity
        if let imagepath = model.cma_banner_image, !imagepath.isEmpty {
            if let dict = GenericClass.sharedInstance.convertToDictionary(text: imagepath),
                let urlString = dict["url"] as? String,
                let url = URL(string: urlString) {
                backgroundImageView?.kf.setImage(with: url, placeholder: UIImage(named: "OfferImage"), options: nil, progressBlock: nil, completionHandler: nil)
            }
        }

    }

}

struct IrresistibleOfferModel: Codable {

    let title: String
    let topTitle: String
    let offerDiscount: String
    let offerDescription: String
    let imageUrl: String
}
