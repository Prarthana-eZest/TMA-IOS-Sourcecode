//
//  MyProfileHeaderCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 16/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class MyProfileHeaderCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblSpeciality: UILabel!
    @IBOutlet weak var lblDateOfJoining: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(model:MyProfileHeaderModel){
        lblUserName.text = model.userName
        lblSpeciality.text = model.speciality
        lblDateOfJoining.text = model.dateOfJoining
    }
    
}

struct MyProfileHeaderModel{
    let profilePictureURL: String
    let userName: String
    let speciality: String
    let dateOfJoining: String
}
