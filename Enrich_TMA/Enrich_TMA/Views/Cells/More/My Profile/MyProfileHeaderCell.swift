//
//  MyProfileHeaderCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 16/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class MyProfileHeaderCell: UITableViewCell {

    @IBOutlet weak private var profilePicture: UIImageView!
    @IBOutlet weak private var lblUserName: UILabel!
    @IBOutlet weak private var lblSpeciality: UILabel!
    @IBOutlet weak private var lblDateOfJoining: UILabel!
    @IBOutlet weak private var lblRatings: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: MyProfileHeaderModel) {

        lblUserName.text = model.userName.capitalized
        lblSpeciality.text = model.speciality.capitalized

        let dateString = model.dateOfJoining
        if let date = dateString.getDateFromString() {
            lblDateOfJoining.text = date.monthYearDate
        }
        else {
            lblDateOfJoining.text = dateString
        }

        let rating = Double(model.ratings)?.cleanForRating
        lblRatings.text = "\(rating ?? "0")/5"

        profilePicture.layer.cornerRadius = profilePicture.frame.size.height * 0.5
        profilePicture.kf.indicatorType = .activity
        let defaultImage = UIImage(named: "defaultProfile")

        if !model.profilePictureURL.isEmpty,
            let imageurl = URL(string: model.profilePictureURL) {
            profilePicture.kf.setImage(with: imageurl, placeholder: defaultImage, options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            profilePicture.image = defaultImage
        }
    }

}

struct MyProfileHeaderModel {
    let profilePictureURL: String
    let userName: String
    let speciality: String
    let dateOfJoining: String
    let ratings: String
    let gender: String
}
