//
//  ServiceCell.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 09/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit

class ServiceCell: UICollectionViewCell {

    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(productDetails: ServiceModel ) {
        self.serviceNameLabel.text = productDetails.name
        self.backgroundImageView.image = UIImage(named: "imgCategoryProd")

        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
            let imageURL: String = (userSelectionForService.gender == PersonType.male ? productDetails.male_img : productDetails.female_img)
            if !imageURL.isEmpty {
                let url = URL(string: imageURL )
                self.backgroundImageView.kf.setImage(with: url, placeholder: UIImage(named: "imgCategoryProd"), options: nil, progressBlock: nil, completionHandler: nil)
            }
        }

//        if !productDetails.female_img.isEmpty {
//            let url = URL(string:productDetails.female_img)
//            self.backgroundImageView.kf.setImage(with: url, placeholder: UIImage(named: "categoryPlaceholderImg"), options: nil, progressBlock: nil, completionHandler: nil)
//        }
    }
}

struct ServiceModel {
    var name = ""
    var female_img = ""
    var male_img = ""
    var id = ""
}
