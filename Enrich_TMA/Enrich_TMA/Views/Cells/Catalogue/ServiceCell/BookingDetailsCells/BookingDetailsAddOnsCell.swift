//
//  BookingDetailsAddOnsCell.swift
//  EnrichSalon
//
//  Created by Apple on 23/08/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class BookingDetailsAddOnsCell: UITableViewCell {
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblPrice: UILabel!
    @IBOutlet weak var sepratorLine: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(model: BookingDetailsAddOnsModel) {
        lblTitle.text = String(format: "%@%@", "\\u2022".unescapingUnicodeCharacters, model.title)
        lblPrice.text =  ""//model.price
    }
}
struct BookingDetailsAddOnsModel {
    let title: String
    let price: String
    let sku: String
    let id: Int64
    let parent_product_id: Int64
    let selection_id: Int64
    let serviceTime: Double
}
