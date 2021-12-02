//
//  CartProductConfirmationCollectionCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 15/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class CartProductConfirmationCollectionCell: UICollectionViewCell {

    @IBOutlet weak private var productImage: UIImageView!
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblProductType: UILabel!
    @IBOutlet weak private var lblPrice: UILabel!
    @IBOutlet weak private var lblOldPrice: UILabel!
    @IBOutlet weak private var lblDeliveryDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lblOldPrice.attributedText = self.lblOldPrice.text?.strikeThrough()
    }

    func configureCell(model: CartProductCellModel) {
        DispatchQueue.main.async {
            self.lblTitle.text = model.peopleBought
            self.lblProductType.text = "Product type: " + model.productType
            self.lblPrice.text = model.specialPrice
            self.lblOldPrice.attributedText = model.oldPrice.strikeThrough()
            self.lblDeliveryDate.text = model.deliveryDate
            self.lblOldPrice.isHidden = model.specialPrice == model.oldPrice

            if !model.productImageURL.isEmpty {
                let url = URL(string: model.productImageURL)

                self.productImage.kf.setImage(with: url, placeholder: UIImage(named: "productDefault"), options: nil, progressBlock: nil, completionHandler: nil)
            } else {
                self.productImage.image = UIImage(named: "productDefault")
            }
        }
    }

}
