//
//  EarningCategoryFilterCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 17/08/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

class EarningCategoryFilterCell: UITableViewCell {
    
    @IBOutlet weak private var lblCategory: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: EarningsCatgoryFilterModel, showUpperCorner: Bool, showLowerCorner: Bool) {
        lblCategory.text = model.category
        if model.isSelected {
            contentView.backgroundColor = UIColor.white
            lblCategory.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: 14)
        }
        else {
            contentView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
            lblCategory.font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 14)
        }
        
        contentView.layer.cornerRadius = 0

        if showUpperCorner {
            contentView.layer.cornerRadius = 9
            contentView.layer.maskedCorners = [.layerMaxXMinYCorner]
        }
        if showLowerCorner {
            contentView.layer.cornerRadius = 8
            contentView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        }
    }
    
}

class EarningsCatgoryFilterModel {
    let category: String
    var isSelected: Bool
    var subCategories: [EarningsSubCatgoryFilterModel]?
    
    init(category: String, isSelected: Bool, subCategories: [EarningsSubCatgoryFilterModel]) {
        self.category = category
        self.isSelected = isSelected
        self.subCategories = subCategories
    }
}

class EarningsSubCatgoryFilterModel {
    let subCategory: String
    var isSelected: Bool
    
    init(subCategory: String, isSelected: Bool) {
        self.subCategory = subCategory
        self.isSelected = isSelected
    }
}

