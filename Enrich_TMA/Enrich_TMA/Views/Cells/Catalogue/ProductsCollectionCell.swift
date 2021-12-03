//
//  ProductsCollectionCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 25/06/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol ProductSelectionDelegate: class {
    func selectedItem(indexpath: IndexPath, identifier: SectionIdentifier)
    func wishlistStatus(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier)
    func checkBoxSelection(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier)
    func actionQunatity(quantity: Int, indexPath: IndexPath)
    func actionAddOnsBundle(indexPath: IndexPath)
    func moveToCart(indexPath: IndexPath)
}

extension ProductSelectionDelegate {
    func checkBoxSelection(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {}
    func actionQunatity(quantity: Int, indexPath: IndexPath) {}
    func wishlistStatus(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {}
}

protocol ConfirmStylistDelegate: class {
    func selectedTimeSlot(stylistId: String, indexpath: IndexPath)
}

class ProductsCollectionCell: UITableViewCell {

    @IBOutlet weak var productCollectionView: UICollectionView!

    var tableViewIndexPath: IndexPath!
    var pageControl: UIPageControl?
    weak var selectionDelegate: ProductSelectionDelegate?
    weak var addressDelegate: AddressCellDelegate?
    weak var serviceDelegate: ServiceActionDelegate?
    weak var confirmStylistDelegate: ConfirmStylistDelegate?
    weak var appointmentDelegate: AppointmentDelegate?

    var configuration: SectionConfiguration!
    var hideCheckBox = true
    var isDeleteShow = true
    var selectedMenuCell = -1
    var addSectionSpacing: CGFloat = is_iPAD ? 25 : 15

    lazy var whyEnrichView = WhyEnrich()

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
        productCollectionView.register(UINib(nibName: CellIdentifier.getInsightfulCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.getInsightfulCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.trendingProductsCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.trendingProductsCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.popularBrandsCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.popularBrandsCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.productCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.productCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.pointsTitleCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.pointsTitleCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.trendingServicesCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.trendingServicesCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.hairstylesCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.hairstylesCollectionViewCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.serviceCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.serviceCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.cartProductCollectionCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.cartProductCollectionCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.cartProductConfirmationCollectionCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.cartProductConfirmationCollectionCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.addressCollectionCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.addressCollectionCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.firstTimeClientCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.firstTimeClientCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.ourProductsCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.ourProductsCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.alwaysAtYourServiceCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.alwaysAtYourServiceCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.horizontalListingCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: "HorizontalListingCollectionViewCell1")
        productCollectionView.register(UINib(nibName: CellIdentifier.customerReviewCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.customerReviewCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.weddingSeasonCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.weddingSeasonCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.serviceCollectionCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.serviceCollectionCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.serviceWithoutStylistCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.serviceWithoutStylistCell)

        productCollectionView.register(UINib(nibName: CellIdentifier.timeSlotCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.timeSlotCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.featuredVideosCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.featuredVideosCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.hairServicesCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.hairServicesCell)
        productCollectionView.register(UINib(nibName: CellIdentifier.myPreferredTopicCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.myPreferredTopicCell)

        productCollectionView.register(UINib(nibName: CellIdentifier.giftCardCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.giftCardCell)

        productCollectionView.register(UINib(nibName: CellIdentifier.valuePackagesCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.valuePackagesCell)

        productCollectionView.register(UINib(nibName: CellIdentifier.popularBrandsCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.popularBrandsCell)
        
        productCollectionView.register(UINib(nibName: CellIdentifier.achievementCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.achievementCell)

        
        if let view = WhyEnrich(frame: CGRect.zero).loadNib() as? WhyEnrich {
            whyEnrichView = view
        }

        productCollectionView.register(UINib(nibName: CellIdentifier.appoinmentCollectionCell, bundle: nil),
                                       forCellWithReuseIdentifier: CellIdentifier.appoinmentCollectionCell)

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
        self.selectedMenuCell = configuration.selectedIndex
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
    func moveToCart(indexPath: IndexPath) {
        print("moveToCart \(indexPath)")
        self.selectionDelegate?.moveToCart(indexPath: indexPath)

    }
    func actionAddOnCart(indexPath: IndexPath) {
        self.selectionDelegate?.actionAddOnsBundle(indexPath: indexPath)
    }

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

extension ProductsCollectionCell: AppointmentDelegate {

    func appointmentAction(actionType: AppointmentAction, indexPath: IndexPath) {
        self.appointmentDelegate?.appointmentAction(actionType: actionType, indexPath: indexPath)
    }

    func actionViewAllAppointments() {
        self.appointmentDelegate?.actionViewAllAppointments()
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

extension ProductsCollectionCell: ServiceActionDelegate {

    func actionAddOn(indexPath: IndexPath) {
        self.serviceDelegate?.actionAddOn(indexPath: IndexPath(row: indexPath.row, section: tableViewIndexPath.section))
    }

    func actionDelete(indexPath: IndexPath) {
        self.serviceDelegate?.actionDelete(indexPath: IndexPath(row: indexPath.row, section: tableViewIndexPath.section))
    }

    func actionChangeStylist(indexPath: IndexPath) {
        self.serviceDelegate?.actionChangeStylist(indexPath: IndexPath(row: indexPath.row, section: tableViewIndexPath.section))
    }

    func openImportantTipsOrAfterTips(indexPath: IndexPath) {
        self.serviceDelegate?.openImportantTipsOrAfterTips(indexPath: indexPath)
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

            case .check_Available_TimeSlot:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.timeSlotCell, for: indexPath) as? TimeSlotCell else {
                    return UICollectionViewCell()
                }
                if let models = self.configuration.data as? [StylistDetailsCellModel] {
                    cell.configureCell(text: models[0].availableTimeSlots[indexPath.row])
                }
                if selectedMenuCell > 0, (selectedMenuCell - 1) == indexPath.row {
                    cell.isSelected(status: true)
                }
                else {
                    cell.isSelected(status: false)
                }
                return cell

        case .serviceCell :
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.serviceCell, for: indexPath) as? ServiceCell else {
                return UICollectionViewCell()
            }
            if let model = self.configuration.data as? [ServiceModel], !model.isEmpty {
                cell.configureCell(productDetails: model[indexPath.row])
            }
            return cell

        case .shop_by_hairtype:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.hairstylesCollectionViewCell, for: indexPath) as? HairstylesCollectionViewCell else {
                return UICollectionViewCell()
            } // ,,249
            collectionView.backgroundColor = UIColor(red: (251 / 255), green: (249 / 255), blue: (249 / 255), alpha: 1)
            if let model = self.configuration.data as? [HairstylesModel], !model.isEmpty {
                cell.configureCell(model: model[indexPath.row], index: indexPath.row)
            }
            return cell

        case .advetisement:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.productCatalogHeaderCell, for: indexPath) as? ProductCatalogHeaderCell else {
                return UICollectionViewCell()
            }
            if let model = self.configuration.data as? [BannerModel], !model.isEmpty {
                cell.configureCell(model: model[indexPath.row])
            }
            return cell

        case .popular:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.popularBrandsCell, for: indexPath) as? PopularBrandsCell  else {
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

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.trendingProductsCell, for: indexPath) as? TrendingProductsCell else {
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

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.pointsTitleCell, for: indexPath) as? PointsTitleCell  else {
                return UICollectionViewCell()
            }
            cell.selectionView.isHidden = indexPath.row == selectedMenuCell ? false : true
            if let model = self.configuration.data as? [PointsCellData], !model.isEmpty {
                cell.titleLabel.text = model[indexPath.row].title

            }

            if indexPath.row == selectedMenuCell {
                cell.titleLabel.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 25.5 : 17.0)
                cell.titleLabel.textColor = .white
            }
            else {
                cell.titleLabel.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 25.5 : 17.0)
                cell.titleLabel.textColor = .gray
            }
            return cell

        case .get_insightful:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.getInsightfulCell, for: indexPath) as? GetInsightfulCell  else {
                return UICollectionViewCell()
            }
            if let model = self.configuration.data as? [GetInsightFulDetails], !model.isEmpty {
                cell.configureCell(model: model[indexPath.row])
            }
            return cell

        case .frequently_availed_services:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.trendingServicesCell, for: indexPath) as? TrendingServicesCell  else {
                return UICollectionViewCell()
            }
            if let trendingService = self.configuration?.data as? [TrendingService], !trendingService.isEmpty {
                cell.configureCell(serviceDetails: trendingService[indexPath.row])
            }
            return cell

        case .recommended_products:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.productCell, for: indexPath) as? ProductCell  else {
                return UICollectionViewCell()
            }
            if let recommendedProducts: [RecommendedProduct] = self.configuration?.data as? [RecommendedProduct], !recommendedProducts.isEmpty {
                cell.configureCell(productDetails: recommendedProducts[indexPath.row] )
            }
            return cell

        case .address:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.addressCollectionCell, for: indexPath) as? AddressCollectionCell  else {
                return UICollectionViewCell()
            }

            cell.delegate = self
            if let address = self.configuration?.data as? [AddressCellModel], !address.isEmpty {
                cell.configureCell(model: address.first!, cellType: .manageAddress, indexPath: indexPath)

            }

            return cell

        case .bookedServiceDetails:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.serviceCollectionCell, for: indexPath) as? ServiceCollectionCell else {
                return UICollectionViewCell()
            }
            cell.indexPath = indexPath
            cell.delegate = self
            cell.showAddOnView(status: true)
            cell.showImportantTips(status: false)
            cell.showChangeButton(status: true)
            return cell

        case .selectedServices:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.serviceCollectionCell, for: indexPath) as? ServiceCollectionCell else {
                return UICollectionViewCell()
            }
            cell.indexPath = indexPath
            cell.delegate = self
            cell.showAddOnView(status: false)
            cell.showImportantTips(status: true)
            cell.showChangeButton(status: false)
            cell.setDeleteCellView(show: isDeleteShow)

            if let bookedServiceModel = self.configuration?.data as? [BookedServiceModel], !bookedServiceModel.isEmpty {
                cell.configureCell(model: bookedServiceModel[indexPath.row])
            }

            collectionView.backgroundColor = UIColor(red: (251 / 255), green: (249 / 255), blue: (249 / 255), alpha: 1)
            return cell

        case .bookedServiceDetailsWithoutStylist:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.serviceWithoutStylistCell, for: indexPath) as? ServiceWithoutStylistCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            cell.indexPath = indexPath
            cell.showAddOnView(status: false)
            if let bookingDetailModel = self.configuration?.data as? [BookedServiceModel], !bookingDetailModel.isEmpty {
                cell.showAddOnView(status: bookingDetailModel[indexPath.row].arrayOfAddons?.isEmpty ?? false  ? false : true)

                cell.configureCell(model: bookingDetailModel[indexPath.row])
            }

            return cell

        case .our_Products:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.ourProductsCell, for: indexPath) as? OurProductsCell  else {
                return UICollectionViewCell()
            }
            cell.configureCell(model: OurProductsCellModel(
                title: "Our products", subTitle: "We package the products with love and care for our customers",
                buttonTitle: "EXPLORE PRODUCTS",
                defaultImage: UIImage(named: "ourProductsDefault")))
            return cell

        case .our_Services:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.ourProductsCell, for: indexPath) as? OurProductsCell  else {
                return UICollectionViewCell()
            }
            cell.configureCell(model: OurProductsCellModel(
                title: "Our services", subTitle: "We serve the services with love and care for our customers",
                buttonTitle: "EXPLORE SERVICES",
                defaultImage: UIImage(named: "ourServicesDefault")))
            return cell

        case .our_Packages:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.ourProductsCell, for: indexPath) as? OurProductsCell  else {
                return UICollectionViewCell()
            }
            cell.configureCell(model: OurProductsCellModel(
                title: "Our packages", subTitle: "We provide packages with love and care for our customers",
                buttonTitle: "EXPLORE PACKAGES",
                defaultImage: UIImage(named: "ourPackageDefault")))
            return cell

        case .blog_Topics:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.hairServicesCell, for: indexPath) as? HairServicesCell else {
                return UICollectionViewCell()
            }
            if let whyEnrichData = self.configuration?.data as? [SelectedCellModel], !whyEnrichData.isEmpty {
                cell.configueView(model: whyEnrichData[indexPath.row])
            }

            return cell

        case .giftCard_Topics:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.hairServicesCell, for: indexPath) as? HairServicesCell else {
                return UICollectionViewCell()
            }

            return cell

        case .appointmentCollection:

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.appoinmentCollectionCell, for: indexPath) as? AppointmentCollectionCell else {
                return UICollectionViewCell()
            }
            if let appointmentData = self.configuration?.data as? [Schedule.GetAppointnents.Data], !appointmentData.isEmpty {
                cell.configureCell1(model: appointmentData[indexPath.row])
            }
            productCollectionView.backgroundColor = UIColor(red: 244/256, green: 246/256, blue: 251/256, alpha: 1)
            cell.indexPath = indexPath
            cell.delegate = self
            return cell

        case .achievement:
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.achievementCell, for: indexPath) as? AchievementCell else {
                return UICollectionViewCell()
            }
            cell.indexPath = indexPath
            cell.configureCell()
            productCollectionView.backgroundColor = UIColor.clear
            return cell

        default:
            return UICollectionViewCell()
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if configuration.identifier == .additionalDetails {

            var width: CGFloat = 0
            var totalLabelsWidth: CGFloat = 0
            var numberOfItem: Int = 0
            let font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 25.0 : 17.0)

            if let model = self.configuration.data as? [PointsCellData], !model.isEmpty {
                model.forEach {
                    width = $0.title.width(withConstrainedHeight: configuration.cellHeight, font: font!) > width ? $0.title.width(withConstrainedHeight: configuration.cellHeight, font: font!) : width
                    totalLabelsWidth += width
                    numberOfItem += 1
                }
            }

            if totalLabelsWidth < configuration.cellWidth {
                let newWidth: Int = Int(configuration.cellWidth) / numberOfItem
                width = CGFloat(newWidth)
               return CGSize(width: width + 15, height: configuration.cellHeight)
            }

            return CGSize(width: width + 30, height: configuration.cellHeight)

        }
        else {
            return CGSize(width: configuration.cellWidth, height: configuration.cellHeight)
        }

    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if (self.configuration.identifier == .advetisement ||
            self.configuration.identifier == .customer_Feedback), pageControl != nil ,
            let cell = collectionView.visibleCells.last,
            let visibleIndex = collectionView.indexPath(for: cell) {
            self.pageControl?.currentPage = visibleIndex.row
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

            guard let cell = collectionView.cellForItem(at: indexPath) as? PointsTitleCell else {
                return
            }
            cell.titleLabel.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 25.5 : 17.0)
            cell.titleLabel.textColor = .white
            cell.selectionView.isHidden = false
            productCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)

        }
        else if self.configuration.identifier == .blog_Topics {

            selectedMenuCell = indexPath.row

            collectionView.visibleCells.forEach {
                if let allCells = $0 as? HairServicesCell {
                    allCells.titleLabel.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 25.5 : 17.0)
                    allCells.titleLabel.textColor = .white
                    allCells.selectionView.isHidden = true
                }
            }

            guard let cell = collectionView.cellForItem(at: indexPath) as? HairServicesCell else {
                return
            }
            cell.titleLabel.font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: is_iPAD ? 25.5 : 17.0)
            cell.titleLabel.textColor = .white
            cell.selectionView.isHidden = false
            productCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)

        }
        else if self.configuration.identifier == .check_Available_TimeSlot {
            guard let cell = collectionView.cellForItem(at: indexPath) as? TimeSlotCell else {
                return
            }
            if selectedMenuCell != indexPath.row + 1 {
                selectedMenuCell = indexPath.row + 1
                cell.isSelected(status: true)
            } else {
                selectedMenuCell = -1
                cell.isSelected(status: false)
            }
            if let models = self.configuration.data as? [StylistDetailsCellModel] {
                confirmStylistDelegate?.selectedTimeSlot(stylistId: "\(models[0].id)", indexpath: indexPath)
            }
            collectionView.reloadData()
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
