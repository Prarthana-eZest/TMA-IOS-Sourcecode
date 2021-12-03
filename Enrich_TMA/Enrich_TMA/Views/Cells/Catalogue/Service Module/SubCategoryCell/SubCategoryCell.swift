//
//  SubCategoryCell.swift
//  EnrichSalon
//
//  Created by Apple on 06/12/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class SubCategoryCell: UITableViewCell {

    @IBOutlet weak var lblCategoryName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(productModel: SubCategoryCellModel) {
        lblCategoryName.text = productModel.categoryName
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

struct SubCategoryCellModel {
    let categoryName: String
}
