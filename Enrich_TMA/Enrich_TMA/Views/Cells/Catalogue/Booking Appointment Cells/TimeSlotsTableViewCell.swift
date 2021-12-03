//
//  TimeSlotsTableViewCell.swift
//  EnrichSalon
//
//  Created by Apple on 05/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

struct TimeSlotsTableViewCellModel {
    var isTimeSelected: Bool
    var timeSlots: String
    var startTime: String
    var endTime: String
}

class TimeSlotsTableViewCell: UITableViewCell {
    @IBOutlet weak private var lblTimeSlot: UILabel!
    @IBOutlet weak private var selectionView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureCell(model: TimeSlotsTableViewCellModel) {
        lblTimeSlot.text = model.timeSlots
        isSelected(status: model.isTimeSelected)

    }
    func isSelected(status: Bool) {
        if status {
            lblTimeSlot.textColor = .white
            selectionView.backgroundColor = UIColor.red
            lblTimeSlot.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 24.0 : 16.0)!

        }
        else {
            lblTimeSlot.textColor = UIColor(red: 39 / 255, green: 37 / 255, blue: 37 / 255, alpha: 1)
            selectionView.backgroundColor = .white
            lblTimeSlot.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 24.0 : 16.0)!
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
