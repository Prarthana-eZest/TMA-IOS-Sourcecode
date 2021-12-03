//
//  MonthCollectionCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 23/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class MonthCollectionCell: UICollectionViewCell {

    @IBOutlet weak private var lblWeek: UILabel!
    @IBOutlet weak private var lblDate: UILabel!
    @IBOutlet weak private var selectionView: UIView!
    @IBOutlet weak private var cornerDotView: UIView!

    var indexPath = IndexPath(row: 0, section: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: SelectAppointment, indexPath: IndexPath) {

        let date: String = model.dateobj.dayDateName
        let weekName: String = model.dateobj.weekdayName
        lblWeek.text = weekName
        lblDate.text = date
        self.indexPath = indexPath
        lblDate.backgroundColor = .white
        lblDate.textColor = UIColor.darkGray
        lblDate.layer.borderColor = model.isSelected ? UIColor.red.cgColor : UIColor.clear.cgColor
        selectionView.isHidden = true
        lblDate.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 17)

        //cornerDotView.isHidden = !model.isRosterCreated

        cornerDotView.backgroundColor = !model.isRosterCreated ? UIColor.white : model.appointmentPresent ?
            UIColor(red: 70 / 255, green: 196 / 255, blue: 91 / 255, alpha: 1) :
            UIColor(red: 232 / 255, green: 34 / 255, blue: 25 / 255, alpha: 1)

        lblDate.textColor = (model.isLeaveOrHoliday ? UIColor(red: 232 / 255, green: 34 / 255, blue: 25 / 255, alpha: 1) : UIColor(red: 35 / 255, green: 35 / 255, blue: 35 / 255, alpha: 1))

        if model.isSelected {
            selectionView.isHidden = false
            lblDate.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: 17)
        }
        else {
            selectionView.isHidden = true
            lblDate.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 17)
        }

    }

}
