//
//  HairTreatment swift
//  EnrichPOC
//
//  Created by Harshal Patil on 08/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit
import Cosmos

protocol CombosCellDelegate: class {
    func addComboAction(indexPath: IndexPath)
    func wishListCombo(indexPath: IndexPath)
    func optionsBeTheFirstToReviewCombo(indexPath: IndexPath)

}
class CombosCell: UITableViewCell {

    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var addServiceButton: UIButton!
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var corverView: UIView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblOldPrice: UILabel!

    @IBOutlet weak var btnWishList: UIButton!
    @IBOutlet weak var lblServiceHours: UILabel!
    @IBOutlet weak var lblReviews: LabelButton!
    @IBOutlet weak var viewUnderline: UIView!
    @IBOutlet weak var imgView_Product: UIImageView!
    @IBOutlet weak private var lblDiscount: UILabel!
    @IBOutlet weak var memberOfferView: UIView!

    weak var delegate: CombosCellDelegate?
    var indexPath = IndexPath(row: 0, section: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
     DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.imgView_Product.setGradientToImageView()
     }
        self.lblReviews.onClick = {
            if (self.lblReviews.text?.containsIgnoringCase(find: noReviewsMessage))! {
                self.delegate?.optionsBeTheFirstToReviewCombo(indexPath: self.indexPath)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, model: HairTreatmentModule.Something.Items, isuserLoggedIn: Bool) {
        var offerPercentage: Double = 0

        let radius: CGFloat = is_iPAD ? 8 : 5
         addServiceButton.layer.cornerRadius = radius
         addServiceButton.tag = indexPath.row
         btnWishList.tag = indexPath.row
         self.indexPath = indexPath
         adView.isHidden = true
         viewUnderline.isHidden = true
         lblOldPrice.isHidden = true
        memberOfferView.isHidden = true

         lblHeading.text = model.name
         lblPrice.text = String(format: " ₹ %@", model.price?.cleanForPrice ?? " ₹ 0")

        let specialPriceObj = checkSpecialPriceSimpleProduct(element: model)

        let strPrice = String(format: " ₹ %@", model.price?.cleanForPrice ?? "0")
        let strSpecialPrice = String(format: " ₹ %@", specialPriceObj.specialPrice.cleanForPrice)
        let attributeString = NSMutableAttributedString(string: "")
        attributeString.append(strPrice.strikeThrough())
        lblOldPrice.attributedText = attributeString

        lblOldPrice.isHidden = specialPriceObj.specialPrice == model.price ? true : specialPriceObj.specialPrice > 0 ? false : true

        lblPrice.text = specialPriceObj.isHavingSpecialPrice ? strSpecialPrice :  strPrice
        if  !lblOldPrice.isHidden {
            offerPercentage = specialPriceObj.specialPrice.getPercent(price: model.price ?? 0)
            lblDiscount.text = "\(offerPercentage.rounded(toPlaces: 1))" + "%"
            memberOfferView.isHidden = false

        }

         if let reviewCount = model.extension_attributes?.total_reviews, reviewCount > 0 {
            lblReviews.text = String(format: " %@ reviews", reviewCount.cleanForPrice )
         }
         else {
            lblReviews.text = "\(noReviewsMessage)"
            viewUnderline.isHidden = false
         }

         selectionStyle = .none

        /*** Rating And Reviews Condition ***/

         ratingView.rating = 0
        if let rating = model.extension_attributes?.rating_percentage, rating > 0 {
             ratingView.rating = ((rating) / 100 * 5)
        }

        // if let shortDescription = model?.custom_attributes?.filter({ $0.attribute_code == "short_description"})
        if let shortDescription = model.custom_attributes?.first(where: { $0.attribute_code == "description"}) {
            let responseObject = shortDescription.value.description
            var data = responseObject.components(separatedBy: "\r\n")
            let unicode = "\\u2022".unescapingUnicodeCharacters
            data = data.map { "\(unicode) \($0)" }
             lblDescription.text = data.joined(separator: "\n")
        }

        if let serviceTime = model.custom_attributes?.first(where: { $0.attribute_code == "service_time"}) {
            let responseObject = serviceTime.value.description
            let doubleVal: Double = (responseObject.toDouble() ?? 0 ) * 60
            let stringValue = String(format: "%@", doubleVal.asString(style: .brief))
             lblServiceHours.text = stringValue
        }

        /*** Add Button Condition ***/
         addServiceButton.isSelected = false

        if model.isItemSelected == true {
             addServiceButton.isSelected = true
        }
        else {
             addServiceButton.isSelected = false
        }
         addServiceButton.isUserInteractionEnabled = addServiceButton.isSelected ? false : true

        /*** WhishList Button Condition ***/

         btnWishList.isSelected = false

        if model.extension_attributes?.wishlist_flag == true || model.isWishSelected == true {
            if isuserLoggedIn {
                 btnWishList.isSelected = true
            }
        }

        /*** Image Set ***/
        //        var imagePath:String = ""
        //
        //        if let imageUrl = model?.custom_attributes?.filter({ $0.attribute_code == "image" })
        //        {
        //            imagePath = imageUrl.first?.value.description ?? ""
        //        }

         imgView_Product.kf.indicatorType = .activity
        if  !(model.extension_attributes?.media_url ?? "").isEmpty &&  !(model.media_gallery_entries?.first?.file ?? "").isEmpty {

            let url = URL(string: String(format: "%@%@", model.extension_attributes?.media_url ?? "", (model.media_gallery_entries?.first?.file)! ))

             imgView_Product.kf.setImage(with: url, placeholder: UIImage(named: "Servicelisting-card-default"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
             imgView_Product.image = UIImage(named: "Servicelisting-card-default")
        }
//        if indexPath.row == 0{
//             adView.isHidden = false
//             viewDetailsTopConstraint.constant = is_iPAD ? 145 : 90
//        }else{
//             adView.isHidden = true
//             viewDetailsTopConstraint.constant = is_iPAD ? 30 : 20
//        }

    }

    func checkSpecialPriceSimpleProduct(element: HairTreatmentModule.Something.Items) -> (isHavingSpecialPrice: Bool, specialPrice: Double, offerPercentage: Double ) {

        // ****** Check for special price
        var isSpecialDateInbetweenTo = false
        var specialPrice: Double = 0.0
        var offerPercentage: Double = 0

        if let specialFrom = element.custom_attributes?.filter({ $0.attribute_code == "special_from_date" }), let strDateFrom = specialFrom.first?.value.description, !strDateFrom.isEmpty, !strDateFrom.containsIgnoringCase(find: "null") {
            let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
            let fromDateInt: Int = Int(strDateFrom.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

            if currentDateInt >= fromDateInt {
                isSpecialDateInbetweenTo = true
                if let specialTo = element.custom_attributes?.filter({ $0.attribute_code == "special_to_date" }), let strDateTo = specialTo.first?.value.description, !strDateTo.isEmpty, !strDateTo.containsIgnoringCase(find: "null") {
                    let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
                    let toDateInt: Int = Int(strDateTo.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

                    if currentDateInt <= toDateInt {
                        isSpecialDateInbetweenTo = true
                    }
                    else {
                        isSpecialDateInbetweenTo = false
                    }
                }
            }
            else {
                isSpecialDateInbetweenTo = false
            }
        }

        if isSpecialDateInbetweenTo {
            if let specialPriceValue = element.custom_attributes?.first(where: { $0.attribute_code == "special_price"}) {
                let responseObject = specialPriceValue.value.description
                specialPrice = responseObject.toDouble() ?? 0.0
            }
        }

        if  specialPrice != 0 {
            offerPercentage = specialPrice.getPercent(price: element.price ?? 0)
        }
        else {
            specialPrice = element.price ?? 0
        }

        return (isSpecialDateInbetweenTo, specialPrice, offerPercentage.rounded(toPlaces: 1))
    }

    @IBAction func addAction(_ sender: UIButton) {
        //sender.isSelected = !sender.isSelected

        if sender.isSelected {

            print(sender.isSelected)
        }
        else {

            print(sender.isSelected)
        }
        delegate?.addComboAction(indexPath: indexPath)

    }

    @IBAction func clickWishList(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if sender.isSelected {

            print(sender.isSelected)
        }
        else {

            print(sender.isSelected)
        }

        delegate?.wishListCombo(indexPath: indexPath )

    }

}
