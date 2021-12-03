//
//  StylistNameCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 24/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit
import Cosmos

class StylistNameCell: UITableViewCell {

    @IBOutlet weak private var lblCovidTechStatus: UILabel!
    @IBOutlet weak private var profilePicture: UIImageView!
    @IBOutlet weak private var lblUserName: UILabel!
    @IBOutlet weak private var ratingView: CosmosView!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var lblPrice: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ratingView.isUserInteractionEnabled = false
        ratingView.settings.fillMode = .half
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configureCell(model: StylistNameCellModel) {
        lblUserName.text = model.userName
        ratingView.rating = model.rating
        btnChange.isHidden = model.btnChangeIsHidden
        lblPrice.isHidden = true
        profilePicture.image = UIImage(named: model.profilePictureURL)
        lblCovidTechStatus.isHidden = true
    }

    func isAvailable(status: Bool = true) {
        self.alpha = status ? 1 : 0.5
        lblUserName.alpha = status ? 1 : 0.5
//        ratingView.alpha = status ? 1 : 0.5
//        btnChange.alpha = status ? 1 : 0.5
        profilePicture.alpha = status ? 1 : 0.5
//
        if status {
            lblCovidTechStatus.textColor = UIColor.black
            lblPrice.textColor = UIColor.black
        }
        else {
            lblCovidTechStatus.textColor = UIColor.lightGray
            lblPrice.textColor = UIColor.lightGray
        }

    }

    @IBAction func actionChange(_ sender: UIButton) {
    }

}

struct StylistNameCellModel {
    let profilePictureURL: String
    let userName: String
    let rating: Double
    let btnChangeIsHidden: Bool
    let rate: Double
    
    let employee_health_status : String?
    let employee_last_screening : String?
}
