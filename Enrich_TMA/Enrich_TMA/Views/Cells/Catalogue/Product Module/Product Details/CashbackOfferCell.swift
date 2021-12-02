//
//  CashbackOfferCell.swift
//  EnrichSalon
//
//  Created by Harshal on 28/06/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class CashbackOfferCell: UITableViewCell {

    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblSubTitile: UILabel!
    @IBOutlet weak private var lblPercentage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: CashbackOfferModel) {
        self.lblTitle.text = model.title
        self.lblSubTitile.text = model.subTitle
        self.lblPercentage.text = model.offerPercentage
    }

}

struct CashbackOfferModel {

    let title: String
    let subTitle: String
    let offerPercentage: String
}
