//
//  PopularBrandsCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 26/06/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class PopularBrandsCell: UICollectionViewCell {

    @IBOutlet weak private var productImageView: UIImageView!
    @IBOutlet weak private var lblTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: PopularBranchModel) {
        self.lblTitle.text = model.title
        self.productImageView.image = UIImage(named: "productDefault")
        if !model.imageUrl.isEmpty {
            let url = URL(string: model.imageUrl)
            self.productImageView.kf.setImage(with: url, placeholder: UIImage(named: "productDefault"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
}

struct PopularBranchModel: Codable {
    let value: String
    let title: String
    let imageUrl: String
}
