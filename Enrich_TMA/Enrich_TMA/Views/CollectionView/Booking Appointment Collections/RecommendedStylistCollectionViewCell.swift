//
//  RecommendedStylistCollectionViewCell.swift
//  EnrichSalon
//
//  Created by Apple on 03/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class RecommendedStylistCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var lblTimings: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
