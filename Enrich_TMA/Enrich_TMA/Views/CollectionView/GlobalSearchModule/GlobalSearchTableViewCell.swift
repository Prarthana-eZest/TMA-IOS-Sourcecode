//
//  GlobalSearchTableViewCell.swift
//  EnrichSalon
//
//  Created by Mugdha Mundhe on 21/10/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class GlobalSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imageObj: UIImageView!
    @IBOutlet weak var btnType: UIButton!
    @IBOutlet weak var constraintTopConstant: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
