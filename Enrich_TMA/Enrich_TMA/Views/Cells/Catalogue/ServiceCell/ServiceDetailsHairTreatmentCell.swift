//
//  HairTreatmentCell.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 08/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit
import Cosmos
protocol ServiceDetailsHairTreatmentCellDelegate: class {
    func addAction(indexPath: IndexPath)
    func addOnsServiceDetailsHairTreatmentCell(indexPath: IndexPath)
    func optionsBeTheFirstToReview(indexPath: IndexPath)

}

class ServiceDetailsHairTreatmentCell: UITableViewCell {

    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var addServiceButton: UIButton!
    @IBOutlet weak var countButton: UIButton!

    @IBOutlet weak var countLabel: LabelButton!

    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblReviews: LabelButton!
    @IBOutlet weak var viewUnderline: UIView!

    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblServiceHours: UILabel!
    @IBOutlet weak var lblOldPrice: UILabel!

    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var corverView: UIView!

    @IBOutlet weak var lblNewCustomerOffer: UILabel!

    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var countLableView: UIView!
    @IBOutlet weak var stackViewConstraintCountLabel: UIStackView!

    @IBOutlet weak var memberOfferView: UIView!
    @IBOutlet weak var lblDiscount: UILabel!

    weak var delegate: ServiceDetailsHairTreatmentCellDelegate?

    var indexPath = IndexPath(row: 0, section: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.resetOfferAmount(text: "New customers of Enrich get 20%OFF their hair service", rangeText: "20%OFF")

        self.countLabel.onClick = {
            // TODO
           self.countAction(self.countButton)
        }
        self.lblReviews.onClick = {
//            if (self.lblReviews.text?.containsIgnoringCase(find: noReviewsMessage))!{
//                self.delegate?.optionsBeTheFirstToReview(indexPath: self.indexPath)
//            }
            self.delegate?.optionsBeTheFirstToReview(indexPath: self.indexPath)

        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) {
        let radius: CGFloat = is_iPAD ? 8 : 5
        self.countLableView.layer.borderColor = UIColor.lightGray.cgColor

        self.countLableView.layer.borderWidth = 1
        self.countLableView.layer.cornerRadius = radius
        self.addServiceButton.tag = indexPath.row
        self.countButton.tag = indexPath.row
        //self.adView.isHidden = false

        self.resetOfferAmount(text: "New customers of Enrich get 20%OFF their hair service", rangeText: "20%OFF")
        self.indexPath = indexPath
        self.adView.isHidden = true

       // self.corverView.layer.borderWidth = 1
       // self.corverView.layer.borderColor = UIColor.gray.cgColor

//        if index == 0{
//            self.adView.isHidden = false
//            self.viewDetailsTopConstraint.constant = is_iPAD ? 145 : 90
//        }else{
//            self.adView.isHidden = true
//            self.viewDetailsTopConstraint.constant = is_iPAD ? 30 : 20
//        }
    }

    @IBAction func addAction(_ sender: UIButton) {
//        sender.isSelected = !sender.isSelected
//
//        if sender.isSelected {
//
//            print(sender.isSelected)
//        } else {
//
//            print(sender.isSelected)
//        }
        delegate?.addAction(indexPath: self.indexPath)
    }

    @IBAction func viewDetailsAction(_ sender: UIButton) {
     //   delegate?.viewDetails(indexPath: sender.tag)

    }
    @IBAction func countAction(_ sender: UIButton) {
        delegate?.addOnsServiceDetailsHairTreatmentCell(indexPath: self.indexPath)
    }
    func resetOfferAmount(text: String, rangeText: String) {
        let range = (text as NSString).range(of: rangeText)
        let attribute = NSMutableAttributedString(string: text)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: range)
        attribute.addAttribute(NSAttributedString.Key.font, value: UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 24.0 : 16.0)!, range: range)
        self.lblNewCustomerOffer.attributedText = attribute

    }

}
