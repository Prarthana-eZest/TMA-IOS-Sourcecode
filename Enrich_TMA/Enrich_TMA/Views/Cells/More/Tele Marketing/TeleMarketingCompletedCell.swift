//
//  TeleMarketingCompletedCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 14/05/20.
//  Copyright © 2020 e-zest. All rights reserved.
//

import UIKit

class TeleMarketingCompletedCell: UITableViewCell {

    @IBOutlet weak private var lblDateTime: UILabel!
    @IBOutlet weak private var lblCustomerName: UILabel!
    @IBOutlet weak private var lblNotes: UILabel!
    @IBOutlet weak private var lblEmployee: UILabel!
    @IBOutlet weak private var lblAction: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: TeleMarketingModel) {
        lblCustomerName.text = model.customerName
        lblEmployee.text = model.employee
        lblDateTime.text = model.date
        lblNotes.text = model.noteText
        lblAction.text = model.status_label
    }

}
