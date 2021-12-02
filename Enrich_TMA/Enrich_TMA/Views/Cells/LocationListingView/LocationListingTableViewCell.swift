//
//  LocationListingTableViewCell.swift
//  EnrichSalon
//
//  Created by Mugdha Mundhe on 4/5/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

enum LocationTypes: String {
    case locPreferredSalons = "Preferred Salons"
    case locOtherSalons = "Other Salons"
    case locNearestSalons = "Nearest Salons"

    var locationIdentifier: Int {
        switch self {
        case .locPreferredSalons:
            return 0
        case .locOtherSalons:
            return 1
        case .locNearestSalons:
            return 2
        }
    }
}

protocol StarLocationStatusDelegation {
    func statusOfStarAddressLocation(btnPlaceTag: Int, isSelected: Bool)
}

class LocationListingTableViewCell: UITableViewCell {

    var delegate: StarLocationStatusDelegation?

    @IBOutlet weak var lblPlaceNickName: UILabel!
    @IBOutlet weak var lblPlaceTitle: UILabel!
    @IBOutlet weak var lblPlaceAddress: UILabel!
    @IBOutlet weak var lblPlaceDistance: UILabel!
    @IBOutlet weak var imgPlaceTypeIcon: UIImageView!
    @IBOutlet weak var btnStar: UIButton!
    @IBOutlet weak var viewBackBorder: UIView!
    @IBOutlet weak var imgBackground: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func actionBtnStar(_ sender: UIButton) {
        delegate?.statusOfStarAddressLocation(btnPlaceTag: sender.tag, isSelected: false)
    }

}
