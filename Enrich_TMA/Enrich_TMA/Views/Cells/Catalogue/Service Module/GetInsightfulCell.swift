//
//  GetInsightfulCell.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 12/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit

class GetInsightfulCell: UICollectionViewCell {

    @IBOutlet weak private var cornerView: UIView!
    @IBOutlet weak private var backgroundImageView: UIImageView!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: GetInsightFulDetails) {
        let fullDate = String(format: "%@%@ %@ %@", model.date.getFormattedDate().dayDateName, model.date.getFormattedDate().daySuffix(), model.date.getFormattedDate().monthName, model.date.getFormattedDate().OnlyYear)
        dateLabel.text = fullDate
        titleLabel.text = model.titleString
        self.backgroundImageView.image = UIImage(named: "trendingservicesdefault")
        if !model.imageURL.isEmpty {
            let url = URL(string: model.imageURL)
            self.backgroundImageView.kf.setImage(with: url, placeholder: UIImage(named: "trendingservicesdefault"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
}

struct GetInsightFulDetails: Codable {
    let titleString: String
    let date: String
    let imageURL: String
    let blogId: String
}
