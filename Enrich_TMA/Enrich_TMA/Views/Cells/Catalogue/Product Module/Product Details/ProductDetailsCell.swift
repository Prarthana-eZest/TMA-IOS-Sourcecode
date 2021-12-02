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
        imageCollectionView.register(UINib(nibName: "ImageViewCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ImageViewCollectionCell")
        
        quantityCollectionView.register(UINib(nibName: "TimeSlotCell", bundle: nil), forCellWithReuseIdentifier: "TimeSlotCell")
        
        colorCollectionView.register(UINib(nibName: "ColorCell", bundle: nil), forCellWithReuseIdentifier: "ColorCell")
        self.lblReviews.onClick = {
            if (self.lblReviews.text?.isEqual(noReviewsMessage))!{
            self.delegate?.optionsBeTheFirstToReview()
            }
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(model: ProductDetailsModel) {
        
        self.lblProductTitle.text = model.productName
        self.ratingsView.rating = ((model.ratingPercentage) / 100 * 5)
        self.lblReviews.text = model.reviewCount
        self.lblProductDescription.text = model.productDescription
        self.lblProductDescription.isHidden = model.productDescription.isEmpty
        let strPrice = model.price
        let strSpecialPrice = model.specialPrice
        self.lblOldPrice.text = strPrice
        self.lblOldPrice.isHidden = (model.specialPrice == model.price)
        let attributeString = NSMutableAttributedString(string: "")
        attributeString.append(strPrice.strikeThrough())
        self.lblOldPrice.attributedText = attributeString
        
        self.lblNewPrice.text = strSpecialPrice
        self.offerView.isHidden = (model.offerPercentage.isEmpty || model.offerPercentage == "0" || model.offerPercentage == "0.0" || model.offerPercentage.starts(with: "-"))
        self.lblDiscount.text = model.offerPercentage
        self.dataForCollectionView = model.imageUrls
        self.pageControl.numberOfPages = model.imageUrls.count > 1 ? model.imageUrls.count : 0
        self.colors.removeAll()
        self.quantity.removeAll()
        self.colors.append(contentsOf: model.colors)
        self.quantity.append(contentsOf: model.quantities)
        reloadCollectionView()
        self.colorPickerView.isHidden = model.colors.isEmpty
        self.qunatityPickerView.isHidden = model.quantities.isEmpty
        self.viewUnderline.isHidden = true
        if (self.lblReviews.text?.isEqual(noReviewsMessage))!{
            self.viewUnderline.isHidden = false
        }
        self.stackOutOfStock.isHidden = false


    }
    
    func reloadCollectionView(){
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
    let price: String
    let specialPrice: String
    let reviewCount: String
    let ratingPercentage: Double
    let offerPercentage: String
    let productURL: String
    var isWishListSelected: Bool
    var isProductSelected: Bool
    var type_id: String
    var colors: [ProductConfigurableColorQuanity]
    var quantities:[ProductConfigurableColorQuanity]
    
}
struct ProductConfigurableColorQuanity{
    let productId: Int64
    let productColorOrQty: String?
    let sku: String
    let price: Double?
    let specialPrice: Double?
    var isProductSelected: Bool = false

}

extension ProductDetailsCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imageCollectionView{
            return self.dataForCollectionView.count
        }else if collectionView == colorCollectionView{
            return colors.count
        }else if collectionView == quantityCollectionView{
            return quantity.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == imageCollectionView{
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCollectionCell", for: indexPath) as? ImageViewCollectionCell else {
                return UICollectionViewCell()
            }
            cell.backgroundImageView.image = UIImage(named: "product")
            cell.backgroundImageView.contentMode = .scaleAspectFit
            cell.backgroundImageView.kf.indicatorType = .activity
            
            if !self.dataForCollectionView[indexPath.row].isEmpty {
                let url = URL(string: self.dataForCollectionView[indexPath.row])
                
                cell.backgroundImageView.kf.setImage(with: url, placeholder: UIImage(named: "product"), options: nil, progressBlock: nil, completionHandler: nil)
            } else {
                cell.backgroundImageView.image = UIImage(named: "product")
            }
            
            return cell
            
        }else if collectionView == colorCollectionView{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            if selectedColor != 0, (selectedColor - 1) == indexPath.row {
                cell.configureCell(color: colors[indexPath.row].productColorOrQty ?? "", isSelected: true)
            } else {
                cell.configureCell(color: colors[indexPath.row].productColorOrQty ?? "", isSelected: false)
            }
            return cell
        }else if collectionView == quantityCollectionView{
            
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeSlotCell", for: indexPath) as? TimeSlotCell else {
//                return UICollectionViewCell()
//            }
//
//            cell.configureCell(text:quantity[indexPath.row].productColorOrQty ?? "")
//
//            if selectedQuantity != 0, (selectedQuantity - 1) == indexPath.row {
//                cell.isSelected(status: true)
//            } else {
//                cell.isSelected(status: false)
//            }
//            return cell
            return UICollectionViewCell()

            
        }else{
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == imageCollectionView{
            self.pageControl.currentPage = indexPath.row
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == colorCollectionView{
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else {
                return
            }
            selectedColor = indexPath.row + 1
            cell.configureCell(color: colors[indexPath.row].productColorOrQty ?? "", isSelected: true)
            collectionView.reloadData()
            delegate?.actionColorSelection(indexPath: indexPath, color: colors[indexPath.row])
            
        }
//        else if collectionView == quantityCollectionView{
//
//            guard let cell = collectionView.cellForItem(at: indexPath) as? TimeSlotCell else {
//                return
//            }
//            selectedQuantity = indexPath.row + 1
//            cell.isSelected(status: true)
//            collectionView.reloadData()
//            delegate?.actionQuantitySelection(indexPath: indexPath, quantity: quantity[indexPath.row])
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == imageCollectionView{
            
            let height: CGFloat = collectionView.frame.size.height
            let width: CGFloat = is_iPAD ?(collectionView.frame.size.width - 50) : (collectionView.frame.size.width - 30)
            return CGSize(width: width, height: height)
        }
        return CGSize(width: is_iPAD ? 90 : 70, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return is_iPAD ? 25 : 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
