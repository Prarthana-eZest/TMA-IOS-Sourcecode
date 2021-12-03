//
//  MembershipStatusCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 11/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class MembershipStatusCell: UITableViewCell {
    
    @IBOutlet weak private var membershipIcon: UIImageView!
    @IBOutlet weak private var lblMemberType: UILabel!
    @IBOutlet weak private var lblValidUpTo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(model: MembershipStatusModel?) {
        
        if let model = model {
            
            lblMemberType.text = model.type
            
            // Validity
            let validity: String
            let dateString = model.validity
            if let date = dateString.getDateFromShortString() {
                validity = date.monthCommaYearDate
            }
            else {
                validity = model.validity
            }
            
            lblValidUpTo.text = "Valid up to \(validity)"
            lblValidUpTo.isHidden = true
            membershipIcon.isHidden = true
            
            if let membership = model.type, !membership.isEmpty,
                let iconImage = model.icon, !iconImage.isEmpty,
                let imageurl = URL(string: iconImage) {
                lblValidUpTo.isHidden = false
                membershipIcon.isHidden = false
                    membershipIcon.kf.setImage(with: imageurl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
            }
            
        }
        else {
            
            lblMemberType.text = "No active membership"
            lblValidUpTo.isHidden = true
            membershipIcon.isHidden = true
        }
    }
}

struct MembershipStatusModel {
    let type: String?
    let icon: String?
    let validity: String
    let rewardPoints: String
}
