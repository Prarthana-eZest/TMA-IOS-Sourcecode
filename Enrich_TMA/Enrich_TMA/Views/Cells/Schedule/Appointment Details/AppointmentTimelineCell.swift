//
//  AppointmentTimelineCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 07/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class AppointmentTimelineCell: UITableViewCell {

    @IBOutlet weak private var lblTime: UILabel!
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblSubTitle: UILabel!
    @IBOutlet weak private var roundView: UIView!
    @IBOutlet weak private var endView: UIView!
    @IBOutlet weak private var lineView: UIView!
    @IBOutlet weak private var lblCustomerName: UILabel!
    @IBOutlet weak private var customerNameStackView: UIStackView!
    @IBOutlet weak private var dependentIcon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: AppointmentTimelineModel, isEndCell: Bool) {
        lblTime.text = model.time
        lblTitle.text = model.title
        lblSubTitle.text = model.subTitle
        if !isEndCell {
            self.contentView.alpha = model.selfService ? 1 : 0.5
            self.endView.isHidden = true
            self.roundView.isHidden = false
            self.lineView.backgroundColor = .lightGray
        }
        else {
            self.contentView.alpha = 1
            self.roundView.isHidden = true
            self.endView.isHidden = false
            self.lineView.backgroundColor = .clear
        }
        lblCustomerName.text = model.customerName
        customerNameStackView.isHidden = isEndCell
        dependentIcon.isHidden = !model.isDepedentService
    }

}

struct AppointmentTimelineModel {
    let time: String
    let title: String
    let subTitle: String
    let selfService: Bool
    let customerName: String
    let isDepedentService: Bool
}
