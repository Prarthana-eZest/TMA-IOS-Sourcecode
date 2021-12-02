//
//  HairstylesCollectionViewCell.swift
//  EnrichSalon
//
//  Created by Mugdha Mundhe on 7/8/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class HairstylesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak private var lblName: UILabel!
    @IBOutlet weak private var imgHairStyle: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: HairstylesModel) {
        self.lblName.text = model.strName
        self.imgHairStyle.image = UIImage(named: "female-selected")
        if !model.imgURL.isEmpty {
            //female-selected
            self.imgHairStyle.kf.setImage(with: URL(string: model.imgURL), placeholder: UIImage(named: "female-selected"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
}

struct HairstylesModel {
    var strName = ""
    var imgURL = ""
    var value = ""
    var categoryType = ""
}
