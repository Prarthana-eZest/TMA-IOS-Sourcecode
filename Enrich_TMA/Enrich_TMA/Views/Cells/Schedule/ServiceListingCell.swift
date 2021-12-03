//
//  ServiceListingCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 11/12/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class ServiceListingCell: UITableViewCell {

    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: ServiceListingModel) {
        lblTitle.text = model.name
        lblValue.text = "₹\(model.price)"
    }

}

struct ServiceListingModel {
    let name: String
    let price: String
}
