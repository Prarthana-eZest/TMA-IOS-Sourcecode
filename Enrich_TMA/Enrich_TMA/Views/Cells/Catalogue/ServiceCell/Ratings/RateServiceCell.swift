//
//  RateServiceCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 25/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit
import Cosmos

class RateServiceCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!

    @IBOutlet weak var lblStylistName: UILabel!
    @IBOutlet weak var lblStylistLevel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
