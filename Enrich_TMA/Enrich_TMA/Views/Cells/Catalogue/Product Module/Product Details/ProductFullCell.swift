//
//  ProductFullCell.swift
//  EnrichSalon
//
//  Created by Harshal on 28/06/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class ProductFullCell: UITableViewCell {

    @IBOutlet weak private var productImageView: UIImageView!
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblPrice: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: ProductFullModel) {
        self.lblTitle.text = model.productName
        self.lblPrice.text = model.productPrice
        if !model.imageUrl.isEmpty {
                let url = URL(string: model.imageUrl)

                productImageView.kf.setImage(with: url, placeholder: UIImage(named: "productDefault"), options: nil, progressBlock: nil, completionHandler: nil)
            }
            else {
            productImageView.image = UIImage(named: "productDefault")
        }
        }

}

struct ProductFullModel {
    let productName: String
    let productPrice: String
    let imageUrl: String
}
