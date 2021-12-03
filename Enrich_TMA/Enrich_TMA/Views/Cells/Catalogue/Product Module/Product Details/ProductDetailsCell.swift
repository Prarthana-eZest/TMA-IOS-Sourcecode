//
//  ProductDetailsCell.swift
//  EnrichSalon
//
//  Created by Harshal on 28/06/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit
import Cosmos

class ProductDetailsCell: UITableViewCell {

    @IBOutlet weak private var pageControl: UIPageControl!
    @IBOutlet weak private var imageCollectionView: UICollectionView!

    @IBOutlet weak private var offerView: UIView!
    @IBOutlet weak private var lblReviews: LabelButton!
    @IBOutlet weak private var viewUnderline: UIView!
    @IBOutlet weak private var lblNewPrice: UILabel!
    @IBOutlet weak private var lblOldPrice: UILabel!
    @IBOutlet weak private var lblProductTitle: UILabel!
    @IBOutlet weak private var lblProductDescription: UILabel!
    @IBOutlet weak private var ratingsView: CosmosView!
    var dataForCollectionView =  [String]()

    @IBOutlet weak private var lblDiscount: UILabel!

    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIStackView!
    @IBOutlet weak var stackOutOfStock: UIStackView!

    @IBOutlet weak var quantityCollectionView: UICollectionView!
    @IBOutlet weak var qunatityPickerView: UIStackView!

    @IBOutlet weak var lblDropHeading: UILabel!

    weak var delegate: ProductDelegates?
    var indexPath: IndexPath?

    var selectedQuantity = 0
    var selectedColor = 0

    var colors = [ProductConfigurableColorQuanity]()
    var quantity = [ProductConfigurableColorQuanity]()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageCollectionView.register(UINib(nibName: CellIdentifier.imageViewCollectionCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.imageViewCollectionCell)

        quantityCollectionView.register(UINib(nibName: CellIdentifier.timeSlotCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.timeSlotCell)

        colorCollectionView.register(UINib(nibName: CellIdentifier.colorCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.colorCell)
        self.lblReviews.onClick = {
//            if (self.lblReviews.text?.isEqual(noReviewsMessage))!{
//            self.delegate?.optionsBeTheFirstToReview()
//            }
            self.delegate?.optionsBeTheFirstToReview()

        }

        imageCollectionView.isPagingEnabled = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: ProductDetailsModel) {

        self.lblProductTitle.text = model.productName
        self.ratingsView.rating = model.ratingPercentage
        if model.reviewCount.isEmpty {
            self.lblReviews.text = "0 reviews"
        }
        else {
            self.lblReviews.text = model.reviewCount
        }
        self.viewUnderline.isHidden = model.reviewCount.isEmpty
        self.lblProductDescription.text = model.productDescription
        self.lblProductDescription.isHidden = model.productDescription.isEmpty
        let strPrice = model.price
        let strSpecialPrice = model.specialPrice
        self.lblOldPrice.text = strPrice
        self.lblOldPrice.isHidden = model.specialPriceDouble == model.priceDouble ? true : model.specialPriceDouble > 0 ? false : true    // Old Code (model.specialPrice == model.price)
        let attributeString = NSMutableAttributedString(string: "")
        attributeString.append(strPrice.strikeThrough())
        self.lblOldPrice.attributedText = attributeString

        self.lblNewPrice.text = model.specialPriceDouble == model.priceDouble ?  strPrice : model.specialPriceDouble > 0 ? strSpecialPrice :  strPrice   //Old Code strSpecialPrice

        self.offerView.isHidden = (model.offerPercentage.isEmpty || model.offerPercentage == "0" || model.offerPercentage == "0.0" || model.offerPercentage == "0%" || model.offerPercentage.starts(with: "-"))
        self.lblDiscount.text = model.offerPercentage
        self.dataForCollectionView = model.imageUrls
        self.pageControl.numberOfPages = model.imageUrls.count > 1 ? model.imageUrls.count : 0
        self.pageControl.currentPage = 0
        self.colors.removeAll()
        self.quantity.removeAll()
        self.colors.append(contentsOf: model.uniqueColors)
        self.quantity.append(contentsOf: model.uniqueQuantities)
        reloadCollectionView()
        self.colorPickerView.isHidden = model.uniqueColors.isEmpty
        self.qunatityPickerView.isHidden = model.uniqueQuantities.isEmpty
//        self.viewUnderline.isHidden = true
//        if (self.lblReviews.text?.isEqual(noReviewsMessage))!{
//            self.viewUnderline.isHidden = false
//        }

        self.stackOutOfStock.isHidden = model.isOutOfStock == 1 ? true : false

    }

    func reloadCollectionView() {
        self.colorCollectionView.reloadData()
        self.quantityCollectionView.reloadData()
    }

}

struct ProductDetailsModel {
    let imageUrls: [String]
    let productId: Int64
    let productName: String
    let sku: String
    let productDescription: String
    var price: String
    var specialPrice: String
    var priceDouble: Double
    var specialPriceDouble: Double
    let reviewCount: String
    let ratingPercentage: Double
    let offerPercentage: String
    let productURL: String
    var isWishListSelected: Bool
    var isProductSelected: Bool
    var isOutOfStock: Int64 = 1 // 1 Stock is Available and 0 OutOfStock
    var type_id: String
    var uniqueColors: [ProductConfigurableColorQuanity]
    var uniqueQuantities: [ProductConfigurableColorQuanity]
    var allColors: [ProductConfigurableColorQuanity]
    var allQuantities: [ProductConfigurableColorQuanity]

}
struct ProductConfigurableColorQuanity {
    let productId: Int64
    let value_index: Int64
    let attribute_id: Int64
    let productColorOrQty: String?
    let sku: String
    let price: Double?
    let specialPrice: Double?
    var isProductSelected: Bool = false
    var isUserSelectionEnable: Bool = false
    let attribute_code: String?

}

extension ProductDetailsCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imageCollectionView {
            return self.dataForCollectionView.isEmpty ? 1 : self.dataForCollectionView.count
        }
        else if collectionView == colorCollectionView {
            return colors.count
        }
        else if collectionView == quantityCollectionView {
            return quantity.count
        }
        else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == imageCollectionView {

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.imageViewCollectionCell, for: indexPath) as? ImageViewCollectionCell else {
                return UICollectionViewCell()
            }
            cell.backgroundImageView.contentMode = .scaleAspectFit
            cell.backgroundImageView.kf.indicatorType = .activity

            cell.backgroundImageView.image = UIImage(named: "productDefault")

            if !self.dataForCollectionView.isEmpty && !self.dataForCollectionView[indexPath.row].isEmpty {
                let url = URL(string: self.dataForCollectionView[indexPath.row])

                cell.backgroundImageView.kf.setImage(with: url, placeholder: UIImage(named: "productDefault"), options: nil, progressBlock: nil, completionHandler: nil)
            }

            return cell

        }
        else if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.colorCell, for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            let model = colors[indexPath.row]
            cell.configureCell(color: model.productColorOrQty ?? "", isSelected: model.isProductSelected)
            cell.imgViewUnAvailable.isHidden = model.isUserSelectionEnable ? true : false

//            if selectedColor != 0, (selectedColor - 1) == indexPath.row {
//                cell.configureCell(color: colors[indexPath.row].productColorOrQty ?? "", isSelected: true)
//            } else {
//                cell.configureCell(color: colors[indexPath.row].productColorOrQty ?? "", isSelected: false)
//            }

            return cell
        }
        else if collectionView == quantityCollectionView {

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.timeSlotCell, for: indexPath) as? TimeSlotCell else {
                return UICollectionViewCell()
            }

            let model = quantity[indexPath.row]
            cell.configureCell(text: model.productColorOrQty ?? "")
            cell.isSelected(status: model.isProductSelected)
            cell.imgViewUnAvailable.isHidden = model.isUserSelectionEnable ? true : false

//            if selectedQuantity != 0, (selectedQuantity - 1) == indexPath.row {
//                cell.isSelected(status: true)
//            } else {
//                cell.isSelected(status: false)
//            }
            return cell

        }
        else {
            return UICollectionViewCell()
        }
    }

//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if collectionView == imageCollectionView{
//            self.pageControl.currentPage = indexPath.row
//        }
//    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if collectionView == imageCollectionView ,
            let cell = collectionView.visibleCells.last,
            let visibleIndex = collectionView.indexPath(for: cell) {
            self.pageControl.currentPage = visibleIndex.row
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()

        visibleRect.origin = imageCollectionView.contentOffset
        visibleRect.size = imageCollectionView.bounds.size

        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

        guard let indexPath = imageCollectionView.indexPathForItem(at: visiblePoint) else { return }

        print(indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if collectionView == colorCollectionView {

            guard (collectionView.cellForItem(at: indexPath) as? ColorCell) != nil else {
                return
            }
            let model = colors[indexPath.row]
            if model.isUserSelectionEnable {
                delegate?.actionColorSelection(indexPath: indexPath, color: colors[indexPath.row])

            }

        }
        else if collectionView == quantityCollectionView {

            guard (collectionView.cellForItem(at: indexPath) as? TimeSlotCell) != nil else {
                return
            }
            let model = quantity[indexPath.row]
            if model.isUserSelectionEnable {
            delegate?.actionQuantitySelection(indexPath: indexPath, quantity: quantity[indexPath.row])
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == imageCollectionView {

            let height: CGFloat = collectionView.frame.size.height
            let width: CGFloat = is_iPAD ?(collectionView.frame.size.width) : (collectionView.frame.size.width)
            return CGSize(width: width, height: height)
        }
        return CGSize(width: is_iPAD ? 90 : 70, height: collectionView.frame.size.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == imageCollectionView {
            return 0
        }
        return is_iPAD ? 25 : 15
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
