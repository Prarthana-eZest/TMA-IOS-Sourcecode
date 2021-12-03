//
//  PackageFilterCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 16/08/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

class PackageFilterCell: UITableViewCell {

    @IBOutlet weak private var radioView: UIView!
    @IBOutlet weak private var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: PackageFilterModel) {
        radioView.isHidden = !model.isSelected
        lblTitle.text = model.title
        if model.isSelected {
            lblTitle.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: 14)
        }
        else {
            lblTitle.font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 14)
        }
    }
    
    func configureCell(model: EarningsSubCatgoryFilterModel) {
        radioView.isHidden = !model.isSelected
        lblTitle.text = model.subCategory
        if model.isSelected {
            lblTitle.font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 14)
        }
        else {
            lblTitle.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 14)
        }
    }
}

class PackageFilterModel {
    let title: String
    var isSelected: Bool
    var fromDate: Date?
    var toDate: Date?
    var sku: String
    
    init(title: String, isSelected: Bool, fromDate: Date?, toDate: Date?, sku: String?) {
        self.title = title
        self.isSelected = isSelected
        self.fromDate = fromDate
        self.toDate = toDate
        self.sku = sku ?? ""
    }
}
