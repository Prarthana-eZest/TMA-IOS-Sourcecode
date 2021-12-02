//
//  CartProductCollectionCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 15/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class CartProductCollectionCell: UICollectionViewCell {

    @IBOutlet weak private var productImage: UIImageView!
    @IBOutlet weak private var lblPeopleBought: UILabel!
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblProductType: UILabel!
    @IBOutlet weak private var lblPrice: UILabel!
    @IBOutlet weak private var lblOldPrice: UILabel!
    @IBOutlet weak private var lblProductCount: UILabel!
    @IBOutlet weak private var btnMinus: UIButton!
    @IBOutlet weak private var btnPlus: UIButton!
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak private var btnMoveToWishListOrNewAddress: UIButton!
    @IBOutlet weak private var btnRemoveOrEditChangeAddress: UIButton!

    @IBOutlet weak var peopleBoughtTop: NSLayoutConstraint!

    weak var productActionDelegate: ProductActionDelegate?
    weak var addressActionDelegate: AddressCellDelegate?

    var indexPath: IndexPath!

    var showCheckBox = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnMinus.setImage(UIImage(named: "minus-disabled"), for: .normal)
        self.lblOldPrice.attributedText = self.lblOldPrice.text?.strikeThrough()

    }

    func configureCell(model: CartProductCellModel) {

        self.lblPeopleBought.text = model.peopleBought
        self.lblTitle.text = model.title
        self.lblProductType.text = "Product type: " + model.productType
        self.lblPrice.text = model.specialPrice
        self.lblOldPrice.attributedText = model.oldPrice.strikeThrough()
        self.lblProductCount.text = model.productCount
        self.lblOldPrice.isHidden = model.specialPrice == model.oldPrice

        if !model.productImageURL.isEmpty {
            let url = URL(string: model.productImageURL)

            self.productImage.kf.setImage(with: url, placeholder: UIImage(named: "productDefault"), options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            self.productImage.image = UIImage(named: "productDefault")
        }
        if let value = self.lblProductCount.text,
            let count = Int(value),
            count > 1 {
            self.btnMinus.setImage(UIImage(named: "minus"), for: .normal)
        } else {
            self.btnMinus.setImage(UIImage(named: "minus-disabled"), for: .normal)
        }

        self.peopleBoughtTop.constant = showCheckBox ? 30 : 10
        self.btnCheckBox.isHidden = !showCheckBox
        self.btnCheckBox.isSelected = model.isSelected
    }

    @IBAction func actionRemove(_ sender: UIButton) {
        if let indexPath = indexPath {
            addressActionDelegate?.leftButtonAction(cellType: .confirmation, indexPath: indexPath)
        }
    }

    @IBAction func actionMoveToWishList(_ sender: UIButton) {
        if let indexPath = indexPath {
            addressActionDelegate?.rightButtonAction(cellType: .confirmation, indexPath: indexPath)
        }
    }

    @IBAction func actionCheckBox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let indexPath = indexPath {
            productActionDelegate?.checkboxStatus(status: sender.isSelected, indexPath: indexPath)
        }
    }

    @IBAction func actionCountPlus(_ sender: UIButton) {
        if let value = lblProductCount.text, let count = Int(value) {
            lblProductCount.text = "\(count + 1)"
            btnMinus.setImage(UIImage(named: "minus"), for: .normal)
            if let indexPath = indexPath {
                productActionDelegate?.actionQunatity(quantity: count + 1, indexPath: indexPath )
            }
        }
    }

    @IBAction func actionCountMinus(_ sender: UIButton) {
        if let value = lblProductCount.text,
            let count = Int(value),
            count > 1 {
            let newValue = count - 1
            lblProductCount.text = "\(newValue)"
            if newValue > 1 {
                sender.setImage(UIImage(named: "minus"), for: .normal)
            } else {
                sender.setImage(UIImage(named: "minus-disabled"), for: .normal)
            }
            if let indexPath = indexPath {
                productActionDelegate?.actionQunatity(quantity: newValue, indexPath: indexPath)
            }
        } else {
            sender.setImage(UIImage(named: "minus-disabled"), for: .normal)
        }
    }

}

struct CartProductCellModel {
    let peopleBought: String?
    let title: String
    let productType: String
    let specialPrice: String
    let oldPrice: String
    let productCount: String
    let deliveryDate: String
    let productImageURL: String
    let isSelected: Bool
    let item_id: Int64
    let sku: String

}
