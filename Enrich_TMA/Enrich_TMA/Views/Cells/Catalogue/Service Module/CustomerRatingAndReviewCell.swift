//
//  CustomerRatingAndReviewCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 01/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol CustomerRatingReviewCellDelegate: class {
    func actionToRateProductOrService()
}

class CustomerRatingAndReviewCell: UITableViewCell {

    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblRatingAndReviews: UILabel!
    @IBOutlet weak var progressViewFifth: UIProgressView!
    @IBOutlet weak var progressViewFourth: UIProgressView!
    @IBOutlet weak var progressViewThird: UIProgressView!
    @IBOutlet weak var progressViewSecond: UIProgressView!
    @IBOutlet weak var progressViewFirst: UIProgressView!
    @IBOutlet weak var btnRateService: UIButton!
    weak  var delegate: CustomerRatingReviewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func actionRateService(_ sender: UIButton) {
        delegate?.actionToRateProductOrService()
    }

}
