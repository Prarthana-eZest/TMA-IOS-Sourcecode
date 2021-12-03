//
//  RecommendedForCell.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 15/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit

class RecommendedForCell: UICollectionViewCell {

    @IBOutlet weak private var cornerView: UIView!
    @IBOutlet weak private var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell() {
        self.cornerView.layer.borderWidth = 1
        self.cornerView.layer.borderColor = UIColor.lightGray.cgColor
    }

}
