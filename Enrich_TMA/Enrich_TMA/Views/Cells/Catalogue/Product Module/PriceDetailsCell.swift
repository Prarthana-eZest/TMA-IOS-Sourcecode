//
//  PriceDetailsCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 12/08/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit
struct ProductCartAddOnsModel {
    let productName: String
    let price: String
}

class PriceDetailsCell: UITableViewCell {

    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureCell(productModel: ProductCartAddOnsModel) {
        self.lblProductName.text = productModel.productName
        self.lblPrice.text = productModel.price
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
