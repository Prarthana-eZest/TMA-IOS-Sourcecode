//
//  HairTreatmentCell.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 08/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit
import Cosmos
protocol HairTreatmentCellDelegate: class {
    func addAction(indexPath: IndexPath)
    func viewDetails(indexPath: Int)
    func moveToCart(indexPath: Int)
    func addOns(indexPath: Int)
    func wishList(indexPath: IndexPath)
    func optionsBeTheFirstToReview(indexPath: IndexPath)
}

class HairTreatmentCell: UITableViewCell {

    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var viewDetailsButton: UIButton!
    @IBOutlet weak var addServiceButton: UIButton!
    @IBOutlet weak var countButton: UIButton!
    @IBOutlet weak var btnMoveToCart: UIButton!

    @IBOutlet weak var countLabel: LabelButton!

    @IBOutlet weak var lblShowType: UILabel!
    @IBOutlet weak var prodDerviceTypeShow: UIView!
    @IBOutlet weak var memberOfferView: UIView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblReviews: LabelButton!
    @IBOutlet weak var viewUnderline: UIView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblOldPrice: UILabel!

    @IBOutlet weak var btnWishList: UIButton!
    @IBOutlet weak var lblServiceHours: UILabel!

    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var corverView: UIView!
    @IBOutlet weak var imgView_Product: UIImageView!

    @IBOutlet weak var lblNewCustomerOffer: UILabel!

    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var countLableView: UIView!

    // Stack Views
    @IBOutlet weak var ratingAndReviewStackView: UIStackView!
    @IBOutlet weak var dropDownStackView: UIStackView!
    @IBOutlet weak var serviceTimeStackView: UIStackView!

    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var lblDiscount: UILabel!

    weak var delegate: HairTreatmentCellDelegate?

    var indexPath = IndexPath(row: 0, section: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.imgView_Product.setGradientToImageView()
        }

        self.resetOfferAmount(text: "New customers of Enrich get 20%OFF their hair service", rangeText: "20%OFF")
        self.countLabel.onClick = {
            // TODO
           self.countAction(self.countButton)
        }
        self.lblReviews.onClick = {
            if (self.lblReviews.text?.containsIgnoringCase(find: noReviewsMessage))! {
                self.delegate?.optionsBeTheFirstToReview(indexPath: self.indexPath)
            }
        }

        btnMoveToCart.isHidden = true
        btnWishList.isHidden = true
        addServiceButton.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) {
        let radius: CGFloat = is_iPAD ? 8 : 5
        self.viewDetailsButton.layer.borderColor = UIColor.red.cgColor
        self.viewDetailsButton.layer.borderWidth = 1
        self.viewDetailsButton.layer.cornerRadius = radius
        self.btnMoveToCart.layer.borderColor = UIColor.red.cgColor
        self.btnMoveToCart.layer.borderWidth = 1
        self.btnMoveToCart.layer.cornerRadius = radius

        //self.addServiceButton.layer.cornerRadius = radius
        self.countLableView.layer.borderColor = UIColor.lightGray.cgColor

        self.countLableView.layer.borderWidth = 1
        self.countLableView.layer.cornerRadius = radius
        self.btnWishList.tag = indexPath.row
        self.addServiceButton.tag = indexPath.row
        self.countButton.tag = indexPath.row
        self.viewDetailsButton.tag = indexPath.row
        self.btnMoveToCart.tag = indexPath.row

        //self.adView.isHidden = false
        self.resetOfferAmount(text: "New customers of Enrich get 20%OFF their hair service", rangeText: "20%OFF")
        self.indexPath = indexPath
        self.adView.isHidden = true
        self.viewUnderline.isHidden = true

        if (lblShowType.text ?? "").isEmpty {
            prodDerviceTypeShow.isHidden = true
        }
    }

    @IBAction func addAction(_ sender: UIButton) {
        //sender.isSelected = !sender.isSelected

        if sender.isSelected {

            print(sender.isSelected)
        }
        else {

            print(sender.isSelected)
        }
        delegate?.addAction(indexPath: self.indexPath)
    }
    @IBAction func clickWishList(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if sender.isSelected {

            print(sender.isSelected)
        }
        else {

            print(sender.isSelected)
        }

        delegate?.wishList(indexPath: self.indexPath )

    }
    @IBAction func viewDetailsAction(_ sender: UIButton) {
        delegate?.viewDetails(indexPath: sender.tag)

    }
    @IBAction func moveToCartAction(_ sender: UIButton) {
        delegate?.moveToCart(indexPath: sender.tag)

    }
    @IBAction func countAction(_ sender: UIButton) {
        delegate?.addOns(indexPath: sender.tag)
    }
    func resetOfferAmount(text: String, rangeText: String) {
        let range = (text as NSString).range(of: rangeText)
        let attribute = NSMutableAttributedString(string: text)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: range)
        attribute.addAttribute(NSAttributedString.Key.font, value: UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 24.0 : 16.0)!, range: range)
        self.lblNewCustomerOffer.attributedText = attribute

    }

}
