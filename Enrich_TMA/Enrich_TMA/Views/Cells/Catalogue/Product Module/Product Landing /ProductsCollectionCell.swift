//
//  ProductsCollectionCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 25/06/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

enum SalonServicesSections: Int {
    case titleImageSection = 0
    case categorySection
    case infoSection
    case testimonialsSection
    
    var heightOfCell: CGFloat {
        switch self {
        case .titleImageSection:
            return is_iPAD ? 400 : 250
        case .categorySection:
            return is_iPAD ? 120 : 80
        case .infoSection:
            return is_iPAD ? 500 : 400
        case .testimonialsSection:
            return is_iPAD ? 500 : 400
        }
    }
}

protocol ProductSelectionDelegate {
    func selectedItem(indexpath: IndexPath, identifier: SectionIdentifier)
    func wishlistStatus(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier)
    func checkBoxSelection(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier)
    func actionQunatity(quantity: Int, indexPath: IndexPath)
}

extension ProductSelectionDelegate {
    func checkBoxSelection(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {}
    func actionQunatity(quantity: Int, indexPath: IndexPath) {}
    func wishlistStatus(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {}
}

protocol AddressCellDelegate: class {
    func leftButtonAction(cellType: CellType, indexPath: IndexPath)
    func rightButtonAction(cellType: CellType, indexPath: IndexPath)
}

enum CellType {
    case confirmation
    case manageAddress
}

class ProductsCollectionCell: UITableViewCell {
    
    @IBOutlet weak var productCollectionView: UICollectionView!
    
    var tableViewIndexPath: IndexPath!
    var pageControl: UIPageControl?
    var selectionDelegate: ProductSelectionDelegate?
    weak var addressDelegate: AddressCellDelegate?
    
    var configuration: SectionConfiguration!
    var hideCheckBox = true
    var selectedMenuCell = 0
    var addSectionSpacing: CGFloat = is_iPAD ? 25 : 15
    
    lazy var whyEnrichView = WhyEnrich()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        productCollectionView.register(UINib(nibName: "GetInsightfulCell", bundle: nil), forCellWithReuseIdentifier: "GetInsightfulCell")
        productCollectionView.register(UINib(nibName: "TrendingProductsCell", bundle: nil), forCellWithReuseIdentifier: "TrendingProductsCell")
        productCollectionView.register(UINib(nibName: "IrresistibleOffersCell", bundle: nil), forCellWithReuseIdentifier: "IrresistibleOffersCell")
        productCollectionView.register(UINib(nibName: "PopularBrandsCell", bundle: nil), forCellWithReuseIdentifier: "PopularBrandsCell")
        productCollectionView.register(UINib(nibName: "ProductCell", bundle: nil), forCellWithReuseIdentifier: "ProductCell")
        productCollectionView.register(UINib(nibName: "PointsTitleCell", bundle: nil), forCellWithReuseIdentifier: "PointsTitleCell")
        productCollectionView.register(UINib(nibName: "TrendingServicesCell", bundle: nil), forCellWithReuseIdentifier: "TrendingServicesCell")
        productCollectionView.register(UINib(nibName: "HairstylesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HairstylesCollectionViewCell")
        productCollectionView.register(UINib(nibName: "ServiceCell", bundle: nil), forCellWithReuseIdentifier: "ServiceCell")
        productCollectionView.register(UINib(nibName: "CartProductCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CartProductCollectionCell")
        productCollectionView.register(UINib(nibName: "CartProductConfirmationCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CartProductConfirmationCollectionCell")
        productCollectionView.register(UINib(nibName: "AddressCollectionCell", bundle: nil), forCellWithReuseIdentifier: "AddressCollectionCell")
        productCollectionView.register(UINib(nibName: "FirstTimeClientCell", bundle: nil), forCellWithReuseIdentifier: "FirstTimeClientCell")
        productCollectionView.register(UINib(nibName: "OurProductsCell", bundle: nil), forCellWithReuseIdentifier: "OurProductsCell")
        productCollectionView.register(UINib(nibName: "AlwaysAtYourServiceCell", bundle: nil), forCellWithReuseIdentifier: "AlwaysAtYourServiceCell")
        productCollectionView.register(UINib(nibName: "HorizontalListingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HorizontalListingCollectionViewCell1")
        productCollectionView.register(UINib(nibName: "CustomerReviewCell", bundle: nil), forCellWithReuseIdentifier: "CustomerReviewCell")
        productCollectionView.register(UINib(nibName: "WeddingSeasonCell", bundle: nil), forCellWithReuseIdentifier: "WeddingSeasonCell")
        productCollectionView.register(UINib(nibName: "ServiceCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ServiceCollectionCell")
        productCollectionView.register(UINib(nibName: "ServiceWithoutStylistCell", bundle: nil), forCellWithReuseIdentifier: "ServiceWithoutStylistCell")
        
        productCollectionView.register(UINib(nibName: "TimeSlotCell", bundle: nil), forCellWithReuseIdentifier: "TimeSlotCell")
        productCollectionView.register(UINib(nibName: "FeaturedVideosCell", bundle: nil), forCellWithReuseIdentifier: "FeaturedVideosCell")
        productCollectionView.register(UINib(nibName: "HairServicesCell", bundle: nil), forCellWithReuseIdentifier: "HairServicesCell")
        productCollectionView.register(UINib(nibName: "MyPreferredTopicCell", bundle: nil), forCellWithReuseIdentifier: "MyPreferredTopicCell")
        
        productCollectionView.register(UINib(nibName: "GiftCardCell", bundle: nil), forCellWithReuseIdentifier: "GiftCardCell")
        
        productCollectionView.register(UINib(nibName: "SavedCardCell", bundle: nil), forCellWithReuseIdentifier: "SavedCardCell")
        
        productCollectionView.register(UINib(nibName: "PreferredStylistCollectionCell", bundle: nil), forCellWithReuseIdentifier: "PreferredStylistCollectionCell")
        
        productCollectionView.register(UINib(nibName: "AvailableCouponCell", bundle: nil), forCellWithReuseIdentifier: "AvailableCouponCell")
        
        productCollectionView.register(UINib(nibName: "PopularCityCell", bundle: nil), forCellWithReuseIdentifier: "PopularCityCell")
        
        whyEnrichView = WhyEnrich(frame: CGRect.zero).loadNib() as! WhyEnrich
        
    }
    
    func configureCollectionView(configuration: SectionConfiguration, scrollDirection: UICollectionView.ScrollDirection) {
        self.configuration = configuration
        
        DispatchQueue.main.async {
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: configuration.leftMargin, bottom: 10, right: configuration.rightMarging)
            layout.scrollDirection = scrollDirection
            layout.itemSize = CGSize(width: configuration.cellWidth, height: configuration.cellHeight)
            self.productCollectionView.collectionViewLayout = layout
            if configuration.identifier != .additionalDetails && (configuration.data as AnyObject).count > 0 {
                self.productCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .right, animated: false)
            }
        }
        
        productCollectionView.backgroundColor = UIColor.white
        productCollectionView.dataSource = self
        productCollectionView.delegate = self
        productCollectionView.isPagingEnabled = configuration.isPagingEnabled
        productCollectionView.allowsSelection = true
        productCollectionView.showsVerticalScrollIndicator = false
        productCollectionView.showsHorizontalScrollIndicator = false
        
        self.productCollectionView.reloadData()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //    func updateWishlistCellStatus(statusForWish:Bool,statusForAddToCart:Bool,index:Int)
    //    {
    //        let indexPath = IndexPath(item: index, section: 0)
    //        if let cell = productCollectionView.cellForItem(at: indexPath) as? TrendingProductsCell
    //        {
    //            cell.btnCheckBox.isSelected = statusForAddToCart
    //            cell.btnWishList.isSelected = statusForWish
    //
    //        }
    //    }
    
}

extension ProductsCollectionCell: ProductActionDelegate {
    
    func actionQunatity(quantity: Int, indexPath: IndexPath) {
        self.selectionDelegate?.actionQunatity(quantity: quantity, indexPath: IndexPath(row: indexPath.row, section: tableViewIndexPath.section))
    }
    
    func wishlistStatus(status: Bool, indexPath: IndexPath) {
        self.selectionDelegate?.wishlistStatus(status: status, indexpath: IndexPath(row: indexPath.row, section: tableViewIndexPath.section), identifier: configuration.identifier)
    }
    
    func checkboxStatus(status: Bool, indexPath: IndexPath) {
        self.selectionDelegate?.checkBoxSelection(status: status, indexpath: IndexPath(row: indexPath.row, section: tableViewIndexPath.section), identifier: configuration.identifier)
    }
    
}

extension ProductsCollectionCell: AddressCellDelegate {
    
    func leftButtonAction(cellType: CellType, indexPath: IndexPath) {
        self.addressDelegate?.leftButtonAction(cellType: cellType, indexPath: IndexPath(row: indexPath.row, section: tableViewIndexPath.section))
    }
    
    func rightButtonAction(cellType: CellType, indexPath: IndexPath) {
        self.addressDelegate?.rightButtonAction(cellType: cellType, indexPath: IndexPath(row: indexPath.row, section: tableViewIndexPath.section))
    }
}

extension ProductsCollectionCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.configuration.items
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        print("Current Section: \(configuration.identifier)")
        switch configuration.identifier {
            
        case .shop_by_hairtype:
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HairstylesCollectionViewCell", for: indexPath) as? HairstylesCollectionViewCell else {
                return UICollectionViewCell()
            } // ,,249
            collectionView.backgroundColor = UIColor(red: (251 / 255), green: (249 / 255), blue: (249 / 255), alpha: 1)
            if let model = self.configuration.data as? [HairstylesModel], !model.isEmpty {
                cell.configureCell(model: model[indexPath.row])
            }
            return cell
            
        case .advetisement:
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCatalogHeaderCell", for: indexPath) as? ProductCatalogHeaderCell else {
                return UICollectionViewCell()
            }
            if let model = self.configuration.data as? [BannerModel], !model.isEmpty {
                cell.configureCell(model: model[indexPath.row])
            }
            return cell
            
        case .irresistible:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IrresistibleOffersCell", for: indexPath) as? IrresistibleOffersCell else {
                return UICollectionViewCell()
            }
            if let model = self.configuration.data as? [IrresistibleOfferModel], !model.isEmpty {
                cell.configureCell(model: model[indexPath.row])
            }
            return cell
            
        case .popular:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularBrandsCell", for: indexPath) as? PopularBrandsCell  else {
                return UICollectionViewCell()
            }
            if let model = self.configuration.data as? [PopularBranchModel], !model.isEmpty {
                cell.configureCell(model: model[indexPath.row])
            }
            return cell
            
        case .new_arrivals,
             .recently_viewed,
             .trending,
             .frequently_bought,
             .customers_also_bought:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingProductsCell", for: indexPath) as? TrendingProductsCell else {
                return UICollectionViewCell()
            }
            cell.btnCheckBox.isHidden = hideCheckBox
            cell.indexPath = indexPath
            cell.delegate = self
            if let model = self.configuration.data as? [ProductModel], !model.isEmpty {
                cell.configureCell(model: model[indexPath.row])
            }
            return cell
            
        case .additionalDetails:
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PointsTitleCell", for: indexPath) as? PointsTitleCell  else {
                return UICollectionViewCell()
            }
            cell.selectionView.isHidden = indexPath.row == selectedMenuCell ? false : true
            if let model = self.configuration.data as? [PointsCellData], !model.isEmpty {
                cell.titleLabel.text = model[indexPath.row].title
                
            }
            
            if indexPath.row == selectedMenuCell {
                cell.titleLabel.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 25.5 : 17.0)
                cell.titleLabel.textColor = .white
            } else {
                cell.titleLabel.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 25.5 : 17.0)
                cell.titleLabel.textColor = .gray
            }
            return cell
            
        case .get_insightful:
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GetInsightfulCell", for: indexPath) as? GetInsightfulCell  else {
                return UICollectionViewCell()
            }
            if let model = self.configuration.data as? [GetInsightFulDetails], model.count > 0 {
                cell.configureCell(model: model[indexPath.row])
            }
            return cell
            
        case .frequently_availed_services:
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingServicesCell", for: indexPath) as? TrendingServicesCell  else {
                return UICollectionViewCell()
            }
            if let trendingService: [TrendingService] = self.configuration?.data as? [TrendingService], trendingService.count > 0 {
                cell.configureCell(serviceDetails: trendingService[indexPath.row])
            }
            return cell
            
        case .recommended_products:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as? ProductCell  else {
                return UICollectionViewCell()
            }
            if let recommendedProducts: [RecommendedProduct] = self.configuration?.data as? [RecommendedProduct], recommendedProducts.count > 0 {
                cell.configureCell(productDetails: recommendedProducts[indexPath.row] )
            }
            return cell
            
        case .cart_Product:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CartProductCollectionCell", for: indexPath) as? CartProductCollectionCell  else {
                return UICollectionViewCell()
            }
            cell.showCheckBox = !hideCheckBox
            cell.productActionDelegate = self
            cell.addressActionDelegate = self
            cell.indexPath = indexPath
            cell.peopleBoughtTop.constant = !hideCheckBox ? 30 : 10
            cell.btnCheckBox.isHidden = hideCheckBox
            if let arrcartProductCell: [CartProductCellModel] = self.configuration?.data as? [CartProductCellModel], !arrcartProductCell.isEmpty {
                cell.configureCell(model: arrcartProductCell[indexPath.row])
            }
            
            return cell
            
        case .cart_Product_Confirmation:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CartProductConfirmationCollectionCell", for: indexPath) as? CartProductConfirmationCollectionCell else {
                return UICollectionViewCell()
            }
            if let arrcartProductCell: [CartProductCellModel] = self.configuration?.data as? [CartProductCellModel], !arrcartProductCell.isEmpty {
                cell.configureCell(model: arrcartProductCell[indexPath.row])
            }
            return cell
            
        case .why_Enrich:
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalListingCollectionViewCell1", for: indexPath) as? HorizontalListingCollectionViewCell  else {
                return UICollectionViewCell()
            }
            cell.addSubview(whyEnrichView)
            whyEnrichView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: SalonServicesSections.infoSection.heightOfCell)
            if let whyEnrichData = self.configuration?.data as? [SalonServiceModule.Something.WhyEnrichModel], !whyEnrichData.isEmpty {
                whyEnrichView.setupUIInit(model: whyEnrichData.first!)
                
            }
            
            return cell
            
            
        case .customer_Feedback:
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomerReviewCell", for: indexPath) as? CustomerReviewCell  else {
                return UICollectionViewCell()
            }
            if let customerReviewCellModel: [CustomerReviewCellModel] = self.configuration?.data as? [CustomerReviewCellModel], !customerReviewCellModel.isEmpty {
                cell.configureCell(customerReviewModel: customerReviewCellModel[indexPath.row])
            }
            return cell
            
            
        case .availableCoupons:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvailableCouponCell", for: indexPath) as? AvailableCouponCell else {
                return UICollectionViewCell()
            }
            return cell
            
            
        default:
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if configuration.identifier == .additionalDetails {
            
            var width: CGFloat = 0
            
            let font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 25.0 : 17.0)
            
            if let model = self.configuration.data as? [PointsCellData], model.count > 0 {
                model.forEach {
                    width = $0.title.width(withConstrainedHeight: configuration.cellHeight, font: font!) > width ? $0.title.width(withConstrainedHeight: configuration.cellHeight, font: font!) : width
                }
            }
            
            return CGSize(width: width + 30, height: configuration.cellHeight)
        } else {
            return CGSize(width: configuration.cellWidth, height: configuration.cellHeight)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (self.configuration.identifier == .advetisement ||
            self.configuration.identifier == .customer_Feedback), pageControl != nil {
            self.pageControl?.currentPage = indexPath.row
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.configuration.identifier == .additionalDetails {
            selectedMenuCell = indexPath.row
            
            collectionView.visibleCells.forEach {
                if let allCells = $0 as? PointsTitleCell {
                    allCells.titleLabel.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 25.5 : 17.0)
                    allCells.titleLabel.textColor = .gray
                    allCells.selectionView.isHidden = true
                }
            }
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? PointsTitleCell else{
                return
            }
            cell.titleLabel.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 25.5 : 17.0)
            cell.titleLabel.textColor = .white
            cell.selectionView.isHidden = false
            productCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            
        }
        self.selectionDelegate?.selectedItem(indexpath: indexPath, identifier: self.configuration.identifier)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return addSectionSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
