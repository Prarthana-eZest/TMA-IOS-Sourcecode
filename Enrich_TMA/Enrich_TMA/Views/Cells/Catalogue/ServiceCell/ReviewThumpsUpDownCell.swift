//
//  ReviewThumpsUpDownCell.swift
//  EnrichSalon
//
//  Created by Apple on 28/06/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class ReviewThumpsUpDownCell: UITableViewCell {

    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblCustomerComments: UILabel!
    @IBOutlet weak var lblcustomerName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: ReviewModel) {
        lblRating.text = "\(model.rating)/5"
        lblCustomerComments.text = model.comment
        lblcustomerName.text = model.cutomerName
    }

}

struct ReviewModel {
    let cutomerName: String
    let comment: String
    let rating: String

}
