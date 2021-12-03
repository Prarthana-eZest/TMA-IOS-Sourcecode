//
//  TimeSlotCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 24/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class TimeSlotCell: UICollectionViewCell {

    @IBOutlet weak private var lblTimeSlot: UILabel!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var imgViewUnAvailable: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(text: String) {
        lblTimeSlot.text = text
    }

    func isSelected(status: Bool) {
        if status {
            lblTimeSlot.textColor = .white
            selectionView.backgroundColor = UIColor(red: 39 / 255, green: 37 / 255, blue: 37 / 255, alpha: 1)
        }
        else {
            lblTimeSlot.textColor = UIColor(red: 39 / 255, green: 37 / 255, blue: 37 / 255, alpha: 1)
            selectionView.backgroundColor = .white
        }
    }
}
