//
//  InvoiceHeaderCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 12/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class InvoiceHeaderCell: UITableViewCell {
    
    @IBOutlet weak private var lblRatings: UILabel!
    @IBOutlet weak private var profilePicture: UIImageView!
    @IBOutlet weak private var lblUserName: UILabel!
    @IBOutlet weak private var lblBookedBy: UILabel!
    @IBOutlet weak private var lblBookedFor: UILabel!
    
    @IBOutlet weak private var membershipIcon: UIImageView!
    @IBOutlet weak private var lblMembershipType: UILabel!
    
    @IBOutlet weak private var highSpendingIcon: UIImageView!
    @IBOutlet weak private var lblLastVisit: UILabel!
    
    @IBOutlet weak private var dividerView: UIView!
    @IBOutlet weak private var stackViewMemAndHighS: UIStackView!
    @IBOutlet weak private var addOnStackView: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(model: Schedule.GetAppointnents.Data) {
        
        // Add On Flow
        if model.booked_by_id == model.booked_for_id {
            lblUserName.isHidden = false
            addOnStackView.isHidden = true
            lblUserName.text = model.booked_by ?? ""
        }else {
            lblUserName.isHidden = true
            addOnStackView.isHidden = false
            lblBookedBy.text = model.booked_by ?? ""
            lblBookedFor.text = model.booked_for ?? ""
        }
        
        lblLastVisit.text = model.last_visit ?? ""
        
        let ratingText = model.avg_rating ?? 0
        let rating = ratingText.cleanForRating
        lblRatings.text = "\(rating)/5"
        
        profilePicture.layer.cornerRadius = profilePicture.frame.size.height * 0.5
        profilePicture.kf.indicatorType = .activity
        
        let defaultImage = UIImage(named: "defaultProfile")
        if let url = model.profile_picture,
            let imageurl = URL(string: url) {
            profilePicture.kf.setImage(with: imageurl, placeholder: defaultImage, options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            profilePicture.image = defaultImage
        }
        
        // Memebership
        
        var isMember = false
        dividerView.isHidden = true
        stackViewMemAndHighS.isHidden = false
        
        if let membership = model.membership, !membership.isEmpty,
            let iconImage = model.membership_default_image, !iconImage.isEmpty,
                let imageurl = URL(string: iconImage) {
                isMember = true
                membershipIcon.kf.setImage(with: imageurl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
            lblMembershipType.text = model.membership ?? ""
        }
        
        membershipIcon.isHidden = !isMember
        lblMembershipType.isHidden = !isMember
        
        if let highSpending = model.high_expensive, highSpending == true {
            highSpendingIcon.isHidden = false
        }
        else {
            highSpendingIcon.isHidden = true
            if !isMember {
                stackViewMemAndHighS.isHidden = true
            }
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
