//
//  MonthCollectionViewCell.swift
//  EnrichSalon
//
//  Created by Apple on 26/06/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class MonthCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lblWeek: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    var indexPath = IndexPath(row: 0, section: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(week: String, date: String) {
        lblWeek.text = week
        lblDate.text = date
    }

}
