//
//  RevenueCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 11/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class RevenueCell: UITableViewCell {

    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblSubTitle: UILabel!
    @IBOutlet weak private var lblValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: RevenueCellModel) {
        lblTitle.text = model.title
        lblSubTitle.text = model.subTitle
        lblValue.text = model.value
        lblValue.isHidden = model.value.isEmpty
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

struct RevenueCellModel {
    let title: String
    let subTitle: String
    let value: String
}
