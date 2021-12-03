//
//  PersonalDetailsFilledCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 01/10/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class PersonalDetailsFilledCell: UITableViewCell {

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblMobileNumber: UILabel!
    @IBOutlet weak var lblEmailAddress: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblTitleAddress: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: PersonalDetailsModel) {
        lblUserName.text = model.userName
        lblMobileNumber.text = model.mobileNumber
        lblEmailAddress.text = model.email
        lblAddress.text = model.address
    }

}

struct PersonalDetailsModel {
    let userName: String
    let mobileNumber: String
    let email: String
    let address: String
    let gender: Int
}
