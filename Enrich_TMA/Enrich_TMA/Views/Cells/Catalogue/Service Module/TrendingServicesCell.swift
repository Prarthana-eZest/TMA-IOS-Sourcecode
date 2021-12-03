//
//  TrendingServicesCell.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 12/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit

struct  TrendingService {
    let serviceName: String
    let serviceImageURL: String
    let id: String
    let sku: String
    let imgMaleFemale: String
}

class TrendingServicesCell: UICollectionViewCell {

    @IBOutlet weak private var cornerView: UIView!
    @IBOutlet weak private var backgroundImageView: UIImageView!
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblDescription: UILabel!
    @IBOutlet weak private var imgViewMaleFemale: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.backgroundImageView.setGradientToImageView()
        }

    }

    func configureCell(serviceDetails: TrendingService) {
        self.cornerView.isUserInteractionEnabled = false
        self.lblTitle.text = serviceDetails.serviceName
        self.lblDescription.text = "Get the Look"
        self.imgViewMaleFemale.image = UIImage(named: serviceDetails.imgMaleFemale)
        self.backgroundImageView.kf.indicatorType = .activity
        self.backgroundImageView.image = UIImage(named: "trendingservicesdefault")
        if !serviceDetails.serviceImageURL.isEmpty {
            let url = URL(string: serviceDetails.serviceImageURL)
            self.backgroundImageView.kf.setImage(with: url, placeholder: UIImage(named: "trendingservicesdefault"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }

}
