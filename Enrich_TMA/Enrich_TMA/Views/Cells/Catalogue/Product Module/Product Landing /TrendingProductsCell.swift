//
//  TrendingProductsCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 25/06/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit
import Cosmos

protocol ProductActionDelegate: class {
    func wishlistStatus(status: Bool, indexPath: IndexPath)
    func checkboxStatus(status: Bool, indexPath: IndexPath)
    func actionQunatity(quantity: Int, indexPath: IndexPath)
    func actionAddOnCart(indexPath: IndexPath)
    func moveToCart(indexPath: IndexPath)

}

class TrendingProductsCell: UICollectionViewCell {

    @IBOutlet weak private var offerView: UIView!
    @IBOutlet weak private var cardImageView: UIImageView!
    @IBOutlet weak private var lblProductTitle: UILabel!
    @IBOutlet weak private var ratingsView: CosmosView!
    @IBOutlet weak private var lblReviews: UILabel!
    @IBOutlet weak private var lblNewPrice: UILabel!
    @IBOutlet weak private var lblOldPrice: UILabel!
    @IBOutlet weak var btnWishList: UIButton!
    @IBOutlet weak private var lblDiscount: UILabel!
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var btnMoveToCart: UIButton!

    weak var delegate: ProductActionDelegate?
    var indexPath = IndexPath(row: 0, section: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func actionWishlist(_ sender: UIButton) {
       // sender.isSelected = !sender.isSelected
        delegate?.wishlistStatus(status: sender.isSelected, indexPath: indexPath)
    }
    @IBAction func moveToCartAction(_ sender: UIButton) {
        delegate?.moveToCart(indexPath: indexPath)

    }

    @IBAction func actionCheckBox(_ sender: UIButton) {
        //sender.isSelected = !sender.isSelected
        delegate?.checkboxStatus(status: sender.isSelected, indexPath: indexPath)
    }

    func configureCell(model: ProductModel) {

        self.lblProductTitle.text = model.productName
        self.ratingsView.rating = model.ratingPercentage
        self.lblReviews.text = model.reviewCount.starts(with: "0") || model.reviewCount.starts(with: " 0")  ? " \(noReviewsMessage)" : model.reviewCount + " reviews"

        let strPrice = String(format: "%@", model.price.cleanForPrice )
        let strSpecialPrice = String(format: "₹%@", model.specialPrice.cleanForPrice)

        let attributeString = NSMutableAttributedString(string: "₹")
        attributeString.append(strPrice.strikeThrough())
        self.lblOldPrice.attributedText = attributeString

        self.lblOldPrice.isHidden = (model.price == model.specialPrice) || model.offerPercentage.starts(with: "-") ? true : false
        self.lblNewPrice.text = strSpecialPrice
        self.btnCheckBox.isHidden = !model.showCheckBox
        self.offerView.isHidden = (model.offerPercentage.isEmpty || model.offerPercentage == "0" || model.offerPercentage == "0.0" || model.offerPercentage.starts(with: "-"))
        self.lblDiscount.text = model.offerPercentage + "%"
        self.btnWishList.isSelected = model.isFavourite
        self.btnCheckBox.isSelected = model.isProductSelected

//        
//        self.btnWishList.setBackgroundImage(UIImage(named: "addressNotSelected"), for: .normal)
//        if (model.isFavourite){
//            self.btnWishList.setBackgroundImage(UIImage(named: "wishlist-selected"), for: .normal)
//        }

        self.cardImageView.image = UIImage(named: "productDefault")
        if !model.strImage.isEmpty {
            self.cardImageView.kf.setImage(with: URL(string: model.strImage), placeholder: UIImage(named: "productDefault"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
}

struct ProductModel: Codable {
    var productId: Int64
    var productName: String
    var price: Double
    var specialPrice: Double
    var reviewCount: String
    var ratingPercentage: Double
    var showCheckBox: Bool
    var offerPercentage: String
    var isFavourite: Bool
    var strImage: String
    var sku: String
    var isProductSelected: Bool
    var type_id: String
    var type_of_service: String
}
