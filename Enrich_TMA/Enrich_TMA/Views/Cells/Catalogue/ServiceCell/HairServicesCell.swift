//
//  HairServicesCell.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 09/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit

class HairServicesCell: UICollectionViewCell {

    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    var selectedMenuCell = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configueView(model: SelectedCellModel) {
        selectionView.isHidden = model.indexSelected ? false : true
        titleLabel.text = model.title.withoutHtml

        if model.indexSelected {
            titleLabel.font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: is_iPAD ? 24.0 : 16.0)!
            titleLabel.textColor = .white
        }
        else {
            titleLabel.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 24.0 : 16.0)!
            titleLabel.textColor = .white
        }
    }
}
