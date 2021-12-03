//
//  EmployeeCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 21/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit
import Cosmos

class EmployeeCell: UITableViewCell {

    @IBOutlet weak private var lblEmplyeeName: UILabel!
    @IBOutlet weak private var statusView: UIView!
    @IBOutlet weak private var lblLevel: UILabel!
    @IBOutlet weak private var ratingsView: CosmosView!
    @IBOutlet weak private var lblStatus: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ratingsView.isUserInteractionEnabled = false
        ratingsView.settings.fillMode = .precise
    }

    func configureCell(model: EmployeeModel) {
        lblEmplyeeName.text = model.name.capitalized
        lblLevel.text = model.level.capitalized
        ratingsView.rating = model.ratings
        //lblStatus.text = model.statusText
        //statusView.backgroundColor = model.statusType.color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

struct EmployeeModel {
    let name: String
    let level: String
    let ratings: Double
    let statusType: AvailableStatusColor
    let statusText: String
    let employeeId: Int64?
}
