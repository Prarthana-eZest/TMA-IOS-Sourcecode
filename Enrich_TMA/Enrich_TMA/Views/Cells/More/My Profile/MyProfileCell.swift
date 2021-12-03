//
//  MyProfileCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 16/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class MyProfileCell: UITableViewCell {

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

    func configureCell(model: MyProfileModel) {
        lblTitle.text = model.title
        lblValue.text = model.value.isEmpty ? "-" : model.value
    }

}

struct MyProfileSection {
    let title: String
    var data: [MyProfileModel]
}

struct MyProfileModel {
    let title: String
    let value: String
    let isMultiOption: Bool
}
