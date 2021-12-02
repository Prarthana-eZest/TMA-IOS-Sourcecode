//
//  ProductCatalogHeaderCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 25/06/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class ProductCatalogHeaderCell: UICollectionViewCell {

    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblDescription: UILabel!
    @IBOutlet weak private var backgroundImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: BannerModel) {

        self.lblTitle.text = model.title
        self.lblDescription.text = model.bannerDesciption

        if !model.imageUrl.isEmpty {
            self.backgroundImageView.kf.setImage(with: URL(string: model.imageUrl), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
}

struct BannerModel: Codable {
    let title: String
    let bannerDesciption: String
    let imageUrl: String
}
