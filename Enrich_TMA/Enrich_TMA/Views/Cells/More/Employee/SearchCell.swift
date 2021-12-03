//
//  SearchCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 25/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak private var btnCheckbox: UIButton!
    @IBOutlet weak private var lblUserName: UILabel!
    @IBOutlet weak private var lblEmailAddress: UILabel!
    @IBOutlet weak private var lblContactNo: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: MyCustomers.GetCustomers.Customer, isSelected: Bool) {
        btnCheckbox.isSelected = isSelected
        let name = "\(model.firstname) \(model.lastname)"
        lblUserName.text = name
        lblEmailAddress.text = model.email
        lblContactNo.text = model.mobile_number.masked(6)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

struct SearchCellModel {
    let userName: String
    let contactNo: String
    let email: String
    var isSelected: Bool = false
}
