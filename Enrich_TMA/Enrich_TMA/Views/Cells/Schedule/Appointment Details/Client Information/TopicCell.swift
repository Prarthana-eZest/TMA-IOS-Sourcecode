//
//  HairServicesCell.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 09/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit

class TopicCell: UICollectionViewCell {

    @IBOutlet weak private var selectionView: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    var selectedMenuCell = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if let font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 16.0) {
            titleLabel.font = font
        }
        titleLabel.textColor = .white
    }

    func configueView(model: SelectedCellModel) {
        selectionView.isHidden = model.indexSelected ? false : true
        titleLabel.text = model.title.withoutHtml
        titleLabel.textColor = .white

        if model.indexSelected {
            if let font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 16.0) {
                titleLabel.font = font
            }
        }
        else {
            if let font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 16.0) {
                titleLabel.font = font
            }
        }
    }
}

struct SelectedCellModel {
    var title: String = ""
    var indexSelected: Bool = false
    var id: String = ""
}
