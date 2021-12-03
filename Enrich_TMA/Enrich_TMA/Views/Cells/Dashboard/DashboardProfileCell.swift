//
//  DashboardProfileCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 15/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

protocol DashboardHeaderCellDelegate: class {
    func locationUpdateAction()
    func locationDetailViewUpdate()
    func actionCustomerCount()
}

class DashboardProfileCell: UITableViewCell {

    @IBOutlet weak private var btnSelectALocation: UIButton!
    @IBOutlet weak private var locationNameView: UIStackView!
    @IBOutlet weak private var lblUserName: UILabel!
    @IBOutlet weak private var lblDesignation: UILabel!
    @IBOutlet weak var btnCustomerCount: UIButton!
    @IBOutlet weak private var profilePicture: UIImageView!
    @IBOutlet weak private var lblRating: UILabel!
    @IBOutlet weak private var btnSOS: UIButton!

    weak var delegate: DashboardHeaderCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell() {

        if let userData = UserDefaults.standard.value(MyProfile.GetUserProfile.UserData.self, forKey: UserDefauiltsKeys.k_Key_LoginUser) {
            lblUserName.text = ("\(userData.firstname ?? "") \(userData.lastname ?? "")").capitalized
            lblDesignation.text = userData.designation ?? ""
            btnSelectALocation.setTitle(userData.base_salon_name ?? "", for: .normal)

            let ratingTest = userData.rating?.description ?? "0"
            let rating = Double(ratingTest)?.cleanForRating
            lblRating.text = "\(rating ?? "0")/5"

            let count = userData.customer_count ?? "0"

            btnCustomerCount.setTitle("\(count.isEmpty ? "0" : count) Customers", for: .normal)
            btnSOS.isHidden = !showSOS

            profilePicture.layer.cornerRadius = profilePicture.frame.size.height * 0.5
            profilePicture.kf.indicatorType = .activity

            let defaultImage = UIImage(named: "defaultProfile")
            if let url = userData.profile_pic,
                let imageurl = URL(string: url) {
                profilePicture.kf.setImage(with: imageurl, placeholder: defaultImage, options: nil, progressBlock: nil, completionHandler: nil)
            } else {
                profilePicture.image = defaultImage
            }
        }
        contentView.layer.cornerRadius = 15
        contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    @IBAction func actionSOS(_ sender: UIButton) {
        SOSFactory.shared.raiseSOSRequest()
    }
    
    @IBAction func actionCustomerCount(_ sender: UIButton) {
        delegate?.actionCustomerCount()
    }
    

}

struct DashboardProfileCellModel {
    let userName: String
    let location: String
    let profilePictureURL: String
    let rating: Double
    let customerCount: Int
}
