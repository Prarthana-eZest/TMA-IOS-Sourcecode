//
//  CustomerReviewCell.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 10/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit

class CustomerReviewCell: UICollectionViewCell {

    @IBOutlet weak private var reviewText: UITextView!
    @IBOutlet weak private var customerName: UILabel!
    @IBOutlet weak private var profilePicture: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureCell(customerReviewModel: CustomerReviewCellModel) {
        customerName.text = customerReviewModel.customerName
        reviewText.text = customerReviewModel.customerComments
        let url = URL(string: customerReviewModel.customerImage ?? "" )
        profilePicture.kf.indicatorType = .activity
        if let imageurl = customerReviewModel.customerImage, !imageurl.isEmpty {
        profilePicture.kf.setImage(with: url, placeholder: UIImage(named: "reviewAavatarImg"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
        profilePicture.image = UIImage(named: "reviewAavatarImg")
        }
    }
}
struct  CustomerReviewCellModel {
    let customerName: String?
    let customerImage: String?
    let customerComments: String?
    let id: String
}
