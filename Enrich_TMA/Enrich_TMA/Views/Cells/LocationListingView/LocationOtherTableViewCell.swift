//
//  LocationOtherTableViewCell.swift
//  EnrichSalon
//
//  Created by Mugdha Mundhe on 4/5/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol StarLocOtherStatusDelegation {
    func statusOfStarAddrOtherLocation(btnPlaceTag: Int, isSelected: Bool)
}

class LocationOtherTableViewCell: UITableViewCell {

    var delegate: StarLocOtherStatusDelegation?

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
        delegate?.statusOfStarAddrOtherLocation(btnPlaceTag: sender.tag, isSelected: true)
    }

}
