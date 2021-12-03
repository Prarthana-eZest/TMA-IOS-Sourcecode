//
//  ProductDetailsModuleViewController.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit
protocol ProductDetailsModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
}

class ProductDetailsModuleVC: UIViewController, ProductDetailsModuleDisplayLogic {
    @IBOutlet weak private var productDetailsTableView: UITableView!
    @IBOutlet weak private var btnAddToCart: UIButton!

    @IBOutlet weak private var totalPriceView: UIView!
    @IBOutlet weak private var btnTotalPrice: UIButton!

    private var interactor: ProductDetailsModuleBusinessLogic?

    // Multi Web Service Calls Handle Dispatch
    private let dispatchGroup = DispatchGroup()
    private let dispatchGroupDataFeeding = DispatchGroup()

    // Variables To Get Value From Calling Controllers
    var objProductSKU: String?
    var objProductId: Int64?

    // Local Variables
    private var selectedAdditionalDetailsCell = 0
    private var sections = [SectionConfiguration]()
    private var serverDataProductDetails: ServiceDetailModule.ServiceDetails.Response? // Product Details Service Data
    private var arrFrequentlyBoughtTogetherData = [ProductModel]() // FrequentlyBoughtTogether
    private var modelTopHeaderData: ProductDetailsModel?
    //private var arrayOfSpecificationData = [ProductSpecificationModel]()
    private var serverDataProductReviews: ServiceDetailModule.ServiceDetails.ProductReviewResponse? // ProductReviewResponse
    private var arrCustomerAlsoBought = [ProductModel]() // Customer Also Bought
    private var arrRecentlyViewedData: [ProductModel] = [] // RecentlyViewedProducts
    private var afterTipsData = [PointsCellData]()// After Tips And Details

    private var identifierLocal: SectionIdentifier = .parentVC
    private var selectedIndexWishList = IndexPath(row: 0, section: 0)

    //** Cart API Variables
    private var serverDataForAllCartItemsGuest: [ProductDetailsModule.GetAllCartsItemGuest.Response]?
    private var serverDataForAllCartItemsCustomer: [ProductDetailsModule.GetAllCartsItemCustomer.Response]?
    private var arrayOFSelectedFrequentlyBought = [ProductModel]()
    private var countOfAddProductRequestGuestOrCustomer: Int = 0
    //** Cart API Variables

    // MARK: Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: Setup
    private func setup() {
        let viewController = self
        let interactor = ProductDetailsModuleInteractor()
        let presenter = ProductDetailsModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
        // showNavigationBarRigtButtons()
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCells()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.setHidesBackButton(false, animated: false)
        self.navigationController?.addCustomBackButton(title: "")
        showNavigationBarRigtButtons()
        //updatedFevouriteData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshView()
    }

    // MARK: initialSetUp
    func initializeCells() {
        self.productDetailsTableView.register(UINib(nibName: CellIdentifier.productDetailsCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.productDetailsCell)
        self.productDetailsTableView.register(UINib(nibName: CellIdentifier.cashbackOfferCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.cashbackOfferCell)
        self.productDetailsTableView.register(UINib(nibName: CellIdentifier.productQuantityCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.productQuantityCell)
        self.productDetailsTableView.register(UINib(nibName: CellIdentifier.productFullCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.productFullCell)
        self.productDetailsTableView.register(UINib(nibName: CellIdentifier.productSpcificationCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.productSpcificationCell)
        self.productDetailsTableView.register(UINib(nibName: CellIdentifier.customerRatingAndReviewCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.customerRatingAndReviewCell)
        self.productDetailsTableView.register(UINib(nibName: CellIdentifier.addServiceInYourCartCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.addServiceInYourCartCell)
        self.productDetailsTableView.register(UINib(nibName: CellIdentifier.reviewThumpsUpDownCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.reviewThumpsUpDownCell)

        self.productDetailsTableView.register(UINib(nibName: CellIdentifier.headerViewWithTitleCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.headerViewWithTitleCell)
        self.productDetailsTableView.register(UINib(nibName: CellIdentifier.headerViewWithSubTitleCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.headerViewWithSubTitleCell)
    }
    func refreshView() {
        arrRecentlyViewedData.removeAll()
        arrCustomerAlsoBought.removeAll()
        arrFrequentlyBoughtTogetherData.removeAll()
        arrayOFSelectedFrequentlyBought.removeAll()
        serverDataForAllCartItemsCustomer?.removeAll()
        totalPriceView.isHidden = !arrayOFSelectedFrequentlyBought.isEmpty ? false : true
        afterTipsData.removeAll()

        callProductDetailsAPI()
        callProductReviewsAPI()

        dispatchGroup.notify(queue: .main) {[unowned self] in
            print("dispatchGroup")
            self.configureSections()
            self.dispatchGroupDataFeeding.notify(queue: .main) {[unowned self] in
                print("dispatchGroupDataFeeding")
                EZLoadingActivity.hide()
                self.productDetailsTableView.reloadData()
            }
        }
    }

    // MARK: updateCartBadgeNumber
    func updateCartBadgeNumber(badgeCount: Int) {
        badgeCount > 0 ? self.navigationItem.rightBarButtonItems?.first(where: { $0.tag == 0})?.addBadge(number: badgeCount) : self.navigationItem.rightBarButtonItems?.first(where: { $0.tag == 0})?.removeBadge()
        badgeCount > 0 ? ApplicationFactory.shared.customTabbarController.increaseBadge(indexOfTab: 3,
                                                                                        num: String(format: "%d", badgeCount)) : ApplicationFactory.shared.customTabbarController.nilBadge(indexOfTab: 3)

    }

    // MARK: updateBottomAddToCartButton
    func updateBottomAddToCartButton(isStatus: Bool) {
        var buttonTitle: String = "ADD TO CART"
        buttonTitle = isStatus == true ? "GO TO CART" : "ADD TO CART"
        self.btnAddToCart.setTitle(buttonTitle, for: .normal)
    }

    // MARK: optionsToOpenAllReviews
    func optionsToOpenAllReviewsForTopHeader() {
        let vc = AllReviewsVC.instantiate(fromAppStoryboard: .Products)
        vc.productId = String(format: "%d", objProductId ?? 0)
        self.navigationController?.pushViewController(vc, animated: true)

    }

    // MARK: Top Navigation Bar And  Actions

    func showNavigationBarRigtButtons() {

        guard let shareButtonImg = UIImage(named: "navigationBarshare"),
            let sosImg = UIImage(named: "SOS") else {
                return
        }

        let shareButton = UIBarButtonItem(image: shareButtonImg, style: .plain, target: self, action: #selector(didTapShareButton))
        shareButton.tintColor = UIColor.black
        shareButton.tag = 1

        let sosButton = UIBarButtonItem(image: sosImg, style: .plain, target: self, action: #selector(didTapSOSButton))
        sosButton.tintColor = UIColor.black

        if showSOS {
            navigationItem.rightBarButtonItems = [shareButton, sosButton]
        }
        else {
            navigationItem.rightBarButtonItems = [shareButton]
        }
    }

    @objc func didTapSOSButton() {
        SOSFactory.shared.raiseSOSRequest()
    }

    @objc func didTapShareButton() {

        if let productUrl = modelTopHeaderData?.productURL, !productUrl.isEmpty {
            var shareAll = [URL]()
            if let  url = URL(string: productUrl) {
                shareAll.append(url)
                if !shareAll.isEmpty {
                    let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = self.view
                    self.present(activityViewController, animated: true, completion: nil)
                }
            }
        }

    }

    // MARK: OpenLoginWindow
    func openLoginWindow() {

        //DoLoginPopUpVC
        let vc = DoLoginPopUpVC.instantiate(fromAppStoryboard: .Location)
        vc.delegate = self
        self.view.alpha = screenPopUpAlpha
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
        vc.onDoneBlock = { [unowned self] result in
            // Do something
            if result {}
else {}
            self.view.alpha = 1.0

        }
    }

    // MARK: createDataForConfigurableProductColorQuantity
    func createDataForConfigurableProductColorQuantity() -> (uniqueColor: [ProductConfigurableColorQuanity], uniqueQuantity: [ProductConfigurableColorQuanity], allColors: [ProductConfigurableColorQuanity], allQuantity: [ProductConfigurableColorQuanity]) {

        var arrUniqueColors = [ProductConfigurableColorQuanity]()
        var arrUniqueQuantity = [ProductConfigurableColorQuanity]()
        var arrAllColors = [ProductConfigurableColorQuanity]()
        var arrAllQuantity = [ProductConfigurableColorQuanity]()

        if let model = self.serverDataProductDetails {
            if let arrayOfData = model.extension_attributes?.configurable_subproduct_options {
                for (_, element) in arrayOfData.enumerated() {

                    // ****** Check for special price
                    var specialPrice = 0.0
                    var isSpecialDateInbetweenTo = false

                    if let strDateFrom = element.special_from_date {

                        let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
                        let fromDateInt: Int = Int(strDateFrom.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

                        if currentDateInt >= fromDateInt {
                            isSpecialDateInbetweenTo = true
                            if let strDateTo = element.special_to_date {
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
                        if let specialPriceValue = element.special_price {
                            specialPrice = specialPriceValue
                        }
                    }

                    specialPrice = (specialPrice != 0) ?  specialPrice :  element.price ?? 0

                    if (element.attribute_code?.equalsIgnoreCase(string: ProductConfigurableDetailType.color))! {
                        let dataModel = ProductConfigurableColorQuanity(productId: Int64(element.product_id ?? "0") ?? 0, value_index: Int64(element.value_index ?? "0") ?? 0, attribute_id: Int64(element.attribute_id ?? "0") ?? 0, productColorOrQty: element.swatch_option_value ?? "", sku: element.sku ?? "", price: element.price ?? 0, specialPrice: specialPrice, isProductSelected: false, isUserSelectionEnable: true, attribute_code: element.attribute_code)
                        arrUniqueColors.append(dataModel)
                        arrAllColors.append(dataModel)
                    }
                    else if (element.attribute_code?.equalsIgnoreCase(string: ProductConfigurableDetailType.quantity))! {
                        let dataModel = ProductConfigurableColorQuanity(productId: Int64(element.product_id ?? "0") ?? 0, value_index: Int64(element.value_index ?? "0") ?? 0, attribute_id: Int64(element.attribute_id ?? "0") ?? 0, productColorOrQty: element.swatch_option_value ?? "", sku: element.sku ?? "", price: element.price ?? 0, specialPrice: specialPrice, isProductSelected: false, isUserSelectionEnable: true, attribute_code: element.attribute_code)
                        arrUniqueQuantity.append(dataModel)
                        arrAllQuantity.append(dataModel)

                    }

                }
            }
        }
        if !arrUniqueColors.isEmpty {
            let uniqueData = arrUniqueColors.unique {$0.value_index}
            arrUniqueColors = uniqueData
        }

        if !arrUniqueQuantity.isEmpty {
            let uniqueData = arrUniqueQuantity.unique {$0.value_index}
            arrUniqueQuantity = uniqueData
        }
        return (arrUniqueColors, arrUniqueQuantity, arrAllColors, arrAllQuantity)
    }

    // MARK: UpdateWishListButtonOnNavigationBar
    func updateWishListButtonOnNavigationBar() {

        var isWishListSelected: Bool = false

        if let isSelected = modelTopHeaderData?.isWishListSelected {
            isWishListSelected = isSelected
        }
        let element = self.navigationItem.rightBarButtonItems?.first(where: { $0.tag == 2})
        element?.image = isWishListSelected == true ? UIImage(named: "navigationBarwishlistSelected")! : UIImage(named: "navigationBarwishlistUnSelected")!
        element?.tintColor = isWishListSelected == true ? .red : .black
    }

    // MARK: IBActions
    @IBAction func actionAddToCart(_ sender: UIButton) {
    }
    @IBAction func actionTotalPrice(_ sender: UIButton) {

        //        let vc = PriceDetailsViewController.instantiate(fromAppStoryboard: .Products)
        //        self.view.alpha = screenPopUpAlpha
        //        vc.arrData = createDataForBottomMoreItemsWithProduct().0
        //        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
        //        vc.onDoneBlock = { [unowned self] result in
        //            // Do something
        //            if result {}
        //else {}
        //            self.view.alpha = 1.0
        //
        //        }
    }

    // MARK: CheckForConfigurableProductOption
    func checkAtLeastOneOptionSelectedInConfigurableProduct() -> (isColor: Bool, isQuanity: Bool) {

        var isColorSelected: Bool = false
        var isQuantitySelected: Bool = false

        if let dataColorObj = modelTopHeaderData?.uniqueColors, !dataColorObj.isEmpty {
            if ((modelTopHeaderData?.uniqueColors.first(where: {$0.isProductSelected})) != nil) {
                isColorSelected = true
            }

        }
        else {
            isColorSelected = true
        }

        if let dataQuantitiesObj = modelTopHeaderData?.uniqueQuantities, !dataQuantitiesObj.isEmpty {
            if ((modelTopHeaderData?.uniqueQuantities.first(where: {$0.isProductSelected})) != nil) {
                isQuantitySelected = true
            }

        }
        else {
            isQuantitySelected = true
        }

        return (isColorSelected, isQuantitySelected)

    }

    func createServerRequestConfigurableProductModelForAddToCartMine() {

    }
    func createServerRequestConfigurableProductModelForAddToCartGuest() {

    }

    // MARK: checkWhichColorQuantityIsAvailable
    func checkWhichColorQuantityIsAvailable(value_Index: Int64, allColor: [ProductConfigurableColorQuanity], allQuantity: [ProductConfigurableColorQuanity]) -> (priceDouble: Double, specialPriceDouble: Double) {
        var arrOfSelectedColorCombinations = [ProductConfigurableColorQuanity]()
        var arrOfAvailableQuantity = [ProductConfigurableColorQuanity]()

        arrOfSelectedColorCombinations.append(contentsOf: allColor.filter({$0.value_index == value_Index}))

        for (_, element) in arrOfSelectedColorCombinations.enumerated() {

            if let matchedObject = allQuantity.first(where: {$0.productId == element.productId}) {
                arrOfAvailableQuantity.append(matchedObject)

            }
        }

        for (index, _) in (self.modelTopHeaderData?.uniqueQuantities.enumerated())! {

            self.modelTopHeaderData?.uniqueQuantities[index].isUserSelectionEnable = false
        }

        for (_, elementQty) in arrOfAvailableQuantity.enumerated() {

            if let matchedObject = self.modelTopHeaderData?.uniqueQuantities.firstIndex(where: {$0.value_index == elementQty.value_index}) {
                self.modelTopHeaderData?.uniqueQuantities[matchedObject].isUserSelectionEnable = true
            }

        }
        var priceRDouble: Double = 0.0
        var specialRPriceDouble: Double = 0.0

        if !allQuantity.isEmpty { // Form Price from both array combinations

            let isSelectedQuantity = self.modelTopHeaderData?.uniqueQuantities.first(where: {$0.isProductSelected == true})
            var arrOfSelectedQuanitityCombinations = [ProductConfigurableColorQuanity]()
            arrOfSelectedQuanitityCombinations.append(contentsOf: allQuantity.filter({$0.value_index == isSelectedQuantity?.value_index}))

            for (_, element) in (arrOfSelectedQuanitityCombinations.enumerated()) {
                if let isSelectedColor = arrOfSelectedColorCombinations.first(where: {$0.productId == element.productId}) {
                    priceRDouble = isSelectedColor.price ?? 0
                    specialRPriceDouble = isSelectedColor.specialPrice ?? 0
                    break
                }

            }

        }
        else // Only from Unique Color Array
        {

            if let isSelectedColor = arrOfSelectedColorCombinations.first(where: {$0.value_index == value_Index}) {
                priceRDouble = isSelectedColor.price ?? 0
                specialRPriceDouble = isSelectedColor.specialPrice ?? 0
            }

        }

        return (priceRDouble, specialRPriceDouble)
    }
    // MARK: checkWhichQuantityColorIsAvailable
    func checkWhichQuantityColorIsAvailable(value_Index: Int64, allColor: [ProductConfigurableColorQuanity], allQuantity: [ProductConfigurableColorQuanity]) -> (priceDouble: Double, specialPriceDouble: Double) {
        var arrOfSelectedQuanitityCombinations = [ProductConfigurableColorQuanity]()
        var arrOfAvailableColors = [ProductConfigurableColorQuanity]()

        arrOfSelectedQuanitityCombinations.append(contentsOf: allQuantity.filter({$0.value_index == value_Index}))

        arrOfSelectedQuanitityCombinations.forEach { element in
            if let matchedObject = allColor.first(where: {$0.productId == element.productId}) {
                arrOfAvailableColors.append(matchedObject)
            }
        }

        for (index, _) in (self.modelTopHeaderData?.uniqueColors.enumerated())! {

            self.modelTopHeaderData?.uniqueColors[index].isUserSelectionEnable = false
        }

        for (_, elementColor) in arrOfAvailableColors.enumerated() {

            if let matchedObject = self.modelTopHeaderData?.uniqueColors.firstIndex(where: {$0.value_index == elementColor.value_index}) {
                self.modelTopHeaderData?.uniqueColors[matchedObject].isUserSelectionEnable = true
            }

        }
        var priceRDouble: Double = 0.0
        var specialRPriceDouble: Double = 0.0

        if !allColor.isEmpty { // Form Price from both array combinations

            let isSelectedColor = self.modelTopHeaderData?.uniqueColors.first(where: {$0.isProductSelected == true})

            var arrOfSelectedColorCombinations = [ProductConfigurableColorQuanity]()
            arrOfSelectedColorCombinations.append(contentsOf: allColor.filter({$0.value_index == isSelectedColor?.value_index}))
            for (_, element) in (arrOfSelectedColorCombinations.enumerated()) {
                if let isSelectedColor = arrOfSelectedQuanitityCombinations.first(where: {$0.productId == element.productId}) {
                    priceRDouble = isSelectedColor.price ?? 0
                    specialRPriceDouble = isSelectedColor.specialPrice ?? 0
                    break
                }

            }

        }
        else // Only from Unique Color Array
        {

            if let isSelectedColor = arrOfSelectedQuanitityCombinations.first(where: {$0.value_index == value_Index}) {
                priceRDouble = isSelectedColor.price ?? 0
                specialRPriceDouble = isSelectedColor.specialPrice ?? 0
            }

        }

        return (priceRDouble, specialRPriceDouble)

    }

    // MARK: setPriceForConfigurableProductColorSelection
    func setPriceForConfigurableProductColorOrQuantitySelection (price: String, priceDouble: Double, specialPrice: String, specialPriceDoble: Double) {
        self.modelTopHeaderData?.price = price
        self.modelTopHeaderData?.priceDouble = priceDouble

        self.modelTopHeaderData?.specialPrice = specialPrice
        self.modelTopHeaderData?.specialPriceDouble = specialPriceDoble

    }

    // MARK: Configure Sections
    func configureSections() {

        // configureSections
        sections.removeAll()
        createDataForProductDetailsTopHeader()

        // sections.append(configureSection(idetifier: .cashbackOffer, items: 2, data: []))
        // sections.append(configureSection(idetifier: .quntity,items: 1, data: []))
        // createDataForSpecifications()
        createDataForAfterTips()

        createDataForFrequentlyBoughtTogether()

        if let productReview = serverDataProductReviews?.data?.all_star_rating, !productReview.isEmpty {
            sections.append(configureSection(idetifier: .customer_rating_review, items: 1, data: []))
        }

        if let productReview = serverDataProductReviews?.data?.review_items, !productReview.isEmpty {
            sections.append(configureSection(idetifier: .feedbackDetails, items: productReview.count, data: []))
        }
        createDataForCustomerAlsoBought()
        if GenericClass.sharedInstance.isuserLoggedIn().status {
            createDataForRecentlyViewedProduct()
        }
        self.productDetailsTableView.separatorColor = .clear

    }

    // MARK: createDataForAfterTips
    func createDataForProductDetailsTopHeader() {
        dispatchGroupDataFeeding.enter()

        var arrayOfImages = [String]()
        var productDescription: String = ""
        var specialPrice: Double = 0.0
        var offerPercentage: Double = 0
        var ratingPercentage = 0.0

        if let model = self.serverDataProductDetails {
            specialPrice = model.price ?? 0
            for(_, element)in (model.media_gallery_entries?.enumerated())! {
                arrayOfImages.append(String(format: "%@%@", model.extension_attributes?.media_url ?? "", element.file ?? ""))
            }

            if let descriptionData = model.custom_attributes?.first(where: { $0.attribute_code == "description"}) {
                var responseObject = descriptionData.value.description.withoutHtml
                responseObject = responseObject.trim()
                productDescription = responseObject
            }

            // ****** Check for special price
            var isSpecialDateInbetweenTo = false

            if let specialFrom = model.custom_attributes?.filter({ $0.attribute_code == "special_from_date" }), let strDateFrom = specialFrom.first?.value.description, !strDateFrom.isEmpty, !strDateFrom.containsIgnoringCase(find: "null") {
                let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
                let fromDateInt: Int = Int(strDateFrom.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

                if currentDateInt >= fromDateInt {
                    isSpecialDateInbetweenTo = true
                    if let specialTo = model.custom_attributes?.filter({ $0.attribute_code == "special_to_date" }), let strDateTo = specialTo.first?.value.description, !strDateTo.isEmpty, !strDateTo.containsIgnoringCase(find: "null") {
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
                if let specialPriceValue = model.custom_attributes?.first(where: { $0.attribute_code == "special_price"}) {
                    let responseObject = specialPriceValue.value.description
                    specialPrice = responseObject.toDouble() ?? 0.0
                }
            }

            if  specialPrice != 0 {
                offerPercentage = specialPrice.getPercent(price: model.price ?? 0)
            }
            else {
                specialPrice = model.price ?? 0
            }
            //  specialPrice = (specialPrice != 0) ?  specialPrice :  model.price ?? 0

            /*** For Color And Quanitity ***/

            let colorsAndQuantity = createDataForConfigurableProductColorQuantity()
            let uniquecolors = colorsAndQuantity.uniqueColor
            let uniquequantity = colorsAndQuantity.uniqueQuantity
            let allColors = colorsAndQuantity.allColors
            let allQuantity = colorsAndQuantity.allQuantity

            var defaultPrice = model.price
            var defaultSpecialPrice = specialPrice

            if model.type_id == SalonServiceTypes.configurable {
                let prices = getConfigurableProductsPrice(element: model)
                defaultPrice = prices.price
                defaultSpecialPrice = prices.splPrice

            }

            var strReviewCount: String = ""
            if let reviewCount = model.extension_attributes?.total_reviews, reviewCount > 0 {
                strReviewCount = String(format: " \(SalonServiceSpecifierFormat.reviewFormat) reviews", reviewCount)
            }

            ratingPercentage = model.extension_attributes?.rating_percentage ?? 0.0
            ratingPercentage = ((ratingPercentage / 100) * 5 )

            let obj = ProductDetailsModel(imageUrls: arrayOfImages, productId: model.id!,
                                          productName: model.name ?? "", sku: model.sku,
                                          productDescription: productDescription,
                                          price: String(format: " ₹ %@", defaultPrice?.cleanForPrice ?? " ₹ 0"),
                                          specialPrice: String(format: " ₹ %@", defaultSpecialPrice.cleanForPrice ),
                                          priceDouble: defaultPrice ?? 0.0,
                                          specialPriceDouble: defaultSpecialPrice,
                                          reviewCount: strReviewCount, ratingPercentage: ratingPercentage,
                                          offerPercentage: offerPercentage.cleanForRating + "%", productURL: model.extension_attributes?.product_url ?? "",
                                          isWishListSelected: model.extension_attributes?.wishlist_flag ?? false,
                                          isProductSelected: false, isOutOfStock: model.extension_attributes?.stock_status ?? 1,
                                          type_id: model.type_id ?? "", uniqueColors: uniquecolors,
                                          uniqueQuantities: uniquequantity, allColors: allColors, allQuantities: allQuantity)

            modelTopHeaderData = obj
            sections.append(configureSection(idetifier: .productDetails, items: 1, data: []))
        }

        self.updateWishListButtonOnNavigationBar()
        updateBottomAddToCartButton(isStatus: false)

        /* Code Commented To Show Allready Added this product in Cart
         if (self.serverDataForAllCartItemsGuest?.first(where: { $0.sku == self.modelTopHeaderData?.sku})) != nil {
         self.modelTopHeaderData?.isProductSelected = true
         updateBottomAddToCartButton(isStatus: true)
         }
         
         if (self.serverDataForAllCartItemsCustomer?.first(where: { $0.sku == self.modelTopHeaderData?.sku})) != nil {
         self.modelTopHeaderData?.isProductSelected = true
         updateBottomAddToCartButton(isStatus: true)
         }*/
        /* Code Commented To Show Allready Added this product in Cart
         if self.modelTopHeaderData?.type_id == SalonServiceTypes.configurable {
         createDataInCaseConfigurableProductIsAddedInCart()
         
         }*/

        dispatchGroupDataFeeding.leave()
    }

    func getConfigurableProductsPrice(element: ServiceDetailModule.ServiceDetails.Response) -> (price: Double, splPrice: Double) {

        if let extension_attributes = element.extension_attributes, let arrObj = extension_attributes.configurable_subproduct_options {
            let amount = arrObj.sorted { (model1, model2) -> Bool in
                guard let price = model1.price, let price2 = model2.price else {
                    return false
                }

                if price < price2 {
                    return true
                }
                return false
            }

            var specialPrice = 0.0
            var priceObj = 0.0

            if let firstObj = amount.first {

                specialPrice = firstObj.price ?? 0
                priceObj = firstObj.price ?? 0

                var isSpecialDateInbetweenTo = false

                if let strDateFrom = firstObj.special_from_date, !strDateFrom.isEmpty, !strDateFrom.containsIgnoringCase(find: "null") {

                    let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
                    let fromDateInt: Int = Int(strDateFrom.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

                    if currentDateInt >= fromDateInt {
                        isSpecialDateInbetweenTo = true
                        if let strDateTo = firstObj.special_to_date, !strDateTo.isEmpty, !strDateTo.containsIgnoringCase(find: "null") {
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
                    specialPrice = firstObj.special_price ?? 0.0
                }
                else {
                    specialPrice = firstObj.price ?? 0.0
                }

                return (priceObj, specialPrice)
            }
        }
        return (0.0, 0.0)
    }

    // MARK: createDataForAfterTips
    func createDataForAfterTips() {
        dispatchGroupDataFeeding.enter()

        if afterTipsData.isEmpty {
            if let data = serverDataProductDetails?.extension_attributes?.tips_info, !data.isEmpty {
                for(_, element) in data.enumerated() {
                    if let string = element.value, !string.isEmpty {
                        let responseObject = string
                        var data = responseObject.components(separatedBy: "\r\n")
                        data = data.filter { $0 != "" }
                        let menu = PointsCellData(title: element.label ?? "NA", points: data)
                        afterTipsData.append(menu)
                    }
                }
                if !afterTipsData.isEmpty {
                    sections.append(configureSection(idetifier: .additionalDetails, items: (afterTipsData.count), data: afterTipsData))
                }
            }
        }
        dispatchGroupDataFeeding.leave()

    }

    // MARK: createDataForFrequentlyBoughtTogether
    func createDataForFrequentlyBoughtTogether() // Related
    {
        dispatchGroupDataFeeding.enter()
        arrFrequentlyBoughtTogetherData.removeAll()
        if self.modelTopHeaderData?.isOutOfStock == 1 {
            if arrFrequentlyBoughtTogetherData.isEmpty {

                if let frequentBookData = serverDataProductDetails?.product_links?.filter({ $0.link_type == "related"}), !frequentBookData.isEmpty {

                    for(_, element) in frequentBookData.enumerated() {

                        var specialPrice: Double = 0.0
                        var offerPercentage: Double = 0
                        var productImage: String = ""
                        var strBaseMediaUrl: String = ""
                        var ratingPercentage = 0.0

                        if let value = element.type_id, value.equalsIgnoreCase(string: SalonServiceTypes.simple), let intOutOfStock = element.stock_status, intOutOfStock == 1 {
                            // ****** Check for special price
                            var isSpecialDateInbetweenTo = false

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

                            //specialPrice = (specialPrice != 0) ?  specialPrice :  element.price ?? 0

                            if let extension_attributes = element.extension_attributes {
                                strBaseMediaUrl = extension_attributes.media_url ?? ""
                            }

                            if let imageUrl = element.custom_attributes?.filter({ $0.attribute_code == "image" }), !strBaseMediaUrl.isEmpty {
                                productImage = strBaseMediaUrl + (imageUrl.first?.value.description ?? "")
                            }

                            ratingPercentage = element.extension_attributes?.rating_percentage ?? 0.0
                            ratingPercentage = ((ratingPercentage / 100) * 5 )

                            let model = ProductModel(productId: element.id ?? 0, productName: element.name ?? "", price: element.price!, specialPrice: specialPrice, reviewCount: String(format: " \(SalonServiceSpecifierFormat.reviewFormat)", element.extension_attributes?.total_reviews ?? "0"), ratingPercentage: ratingPercentage, showCheckBox: true, offerPercentage: offerPercentage.cleanForRating, isFavourite: element.extension_attributes?.wishlist_flag ?? false, strImage: productImage, sku: (element.sku ?? ""), isProductSelected: false, type_id: element.type_id ?? "", type_of_service: element.extension_attributes?.type_of_service ?? "")

                            arrFrequentlyBoughtTogetherData.append(model)

                        }
                    }
                }
            }
            if !arrFrequentlyBoughtTogetherData.isEmpty {

                /* Code Commented To Show Allready Added this product in Cart
                 for (index, element1)in arrFrequentlyBoughtTogetherData.enumerated() {
                 if let allCartGuest = self.serverDataForAllCartItemsGuest {
                 if allCartGuest.firstIndex(where: { $0.sku == element1.sku }) != nil {
                 arrFrequentlyBoughtTogetherData[index].isProductSelected = true
                 
                 }
                 } else {
                 if let allCartCustomer = self.serverDataForAllCartItemsCustomer {
                 if allCartCustomer.firstIndex(where: { $0.sku == element1.sku }) != nil {
                 arrFrequentlyBoughtTogetherData[index].isProductSelected = true
                 
                 }
                 }
                 }
                 }*/

                sections.append(configureSection(idetifier: .frequently_bought, items: arrFrequentlyBoughtTogetherData.count, data: arrFrequentlyBoughtTogetherData))
                // updateCartCellHideAndShow()
            }
        }

        dispatchGroupDataFeeding.leave()
    }

    // MARK: createDataForCustomerAlsoBought // upsell
    func createDataForCustomerAlsoBought() {
        dispatchGroupDataFeeding.enter()

        if arrCustomerAlsoBought.isEmpty {
            if let customerAlsoBoughtData = serverDataProductDetails?.product_links?.filter({ $0.link_type == "upsell"}), !customerAlsoBoughtData.isEmpty {

                for(_, element) in customerAlsoBoughtData.enumerated() {
                    var specialPrice: Double = 0.0
                    var offerPercentage: Double = 0
                    var productImage: String = ""
                    var strBaseMediaUrl: String = ""
                    var ratingPercentage = 0.0
                    specialPrice = element.price ?? 0

                    if let intOutOfStock = element.stock_status, intOutOfStock == 1 {
                        // ****** Check for special price
                        var isSpecialDateInbetweenTo = false

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

                        //specialPrice = (specialPrice != 0) ?  specialPrice :  element.price ?? 0

                        if let extension_attributes = element.extension_attributes {
                            strBaseMediaUrl = extension_attributes.media_url ?? ""
                        }

                        if let imageUrl = element.custom_attributes?.filter({ $0.attribute_code == "image" }), !strBaseMediaUrl.isEmpty {
                            productImage = strBaseMediaUrl + (imageUrl.first?.value.description ?? "")
                        }
                        ratingPercentage = element.extension_attributes?.rating_percentage ?? 0.0
                        ratingPercentage = ((ratingPercentage / 100) * 5 )

                        let model = ProductModel(productId: element.id ?? 0, productName: element.name ?? "", price: element.price!, specialPrice: specialPrice, reviewCount: String(format: " \(SalonServiceSpecifierFormat.reviewFormat)", element.extension_attributes?.total_reviews ?? "0"), ratingPercentage: ratingPercentage, showCheckBox: false, offerPercentage: offerPercentage.cleanForRating, isFavourite: element.extension_attributes?.wishlist_flag ?? false, strImage: productImage, sku: (element.sku ?? ""), isProductSelected: false, type_id: element.type_id ?? "", type_of_service: element.extension_attributes?.type_of_service ?? "")

                        arrCustomerAlsoBought.append(model)

                    }
                    if !arrCustomerAlsoBought.isEmpty {
                        sections.append(configureSection(idetifier: .customers_also_bought, items: arrCustomerAlsoBought.count, data: arrCustomerAlsoBought))
                    }
                }

            }
        }
        dispatchGroupDataFeeding.leave()

    }

    // MARK: createDataForRecentlyViewedProduct
    func createDataForRecentlyViewedProduct() {
        dispatchGroupDataFeeding.enter()

        if arrRecentlyViewedData.isEmpty {
            if let recentlyViewedProducts = self.serverDataProductDetails?.extension_attributes?.recently_viewed_products {
                for model in recentlyViewedProducts {
                    var specialPrice = model.price ?? 0
                    var offerPercentage: Double = 0
                    let isFevo = GenericClass.sharedInstance.isuserLoggedIn().status ? (model.wishlist_flag ?? false) : false

                    // ****** Check for special price
                    var isSpecialDateInbetweenTo = false

                    if let specialFrom = model.special_from_date {

                        let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
                        let fromDateInt: Int = Int(specialFrom.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

                        if currentDateInt >= fromDateInt {
                            isSpecialDateInbetweenTo = true
                            if let specialTo = model.special_to_date {
                                let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
                                let toDateInt: Int = Int(specialTo.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

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
                        if let splPrice = model.special_price, splPrice != 0 {
                            specialPrice = splPrice
                            offerPercentage = specialPrice.getPercent(price: model.price ?? 0)
                        }
                    }

                    let intId: Int64? = Int64(model.id!)
                    arrRecentlyViewedData.append(ProductModel(productId: intId!, productName: model.name ?? "", price: model.price ?? 0, specialPrice: specialPrice, reviewCount: model.total_reviews?.cleanForPrice ?? "0", ratingPercentage: (model.rating_percentage ?? 0.0).getPercentageInFive(), showCheckBox: false, offerPercentage: offerPercentage.cleanForRating, isFavourite: isFevo, strImage: (model.image ?? ""), sku: (model.sku ?? ""), isProductSelected: false, type_id: model.type_id ?? "", type_of_service: ""))
                }
                if !arrRecentlyViewedData.isEmpty {
                    sections.append(configureSection(idetifier: .recently_viewed, items: arrRecentlyViewedData.count, data: arrRecentlyViewedData))
                }
            }
        }
        dispatchGroupDataFeeding.leave()

    }

    // MARK: Set Values For Cutomer Ratings And Reviews
    func setValuesForCutomerRatingsAndReviews(cell: CustomerRatingAndReviewCell) {

        var RateAndReviews: String = "" //  4.5/5
        RateAndReviews = String(format: "%@/5", ((serverDataProductReviews?.data?.product_rating_percentage ?? 0.0) / 100 * 5).cleanForRating)
        cell.lblRating.text = RateAndReviews
        cell.lblRatingAndReviews.text = String(format: "%d Ratings & %d Reviews", serverDataProductReviews?.data?.product_rating_count ?? 0, serverDataProductReviews?.data?.product_review_count ?? 0)
        cell.btnRateService.setTitle("Rate Product", for: .normal)

        let productRatingCount = serverDataProductReviews?.data?.product_rating_count ?? 0
        for (_, element) in (serverDataProductReviews?.data?.all_star_rating?.enumerated())! {
            let progressValue = element
            let progressBarFinalValue = (Float(progressValue.value) / Float(productRatingCount)).isNaN ? 0: Float(progressValue.value) / Float(productRatingCount)

            switch progressValue.key {
            case "1":
                print("\(progressValue.value)")
                cell.progressViewFirst.progress = progressBarFinalValue
            case "2":
                print("\(progressValue.value)")
                cell.progressViewSecond.progress = progressBarFinalValue

            case "3":
                print("\(progressValue.value)")
                cell.progressViewThird.progress = progressBarFinalValue

            case "4":
                print("\(progressValue.value)")
                cell.progressViewFourth.progress = progressBarFinalValue
            case "5":
                print("\(progressValue.value)")
                cell.progressViewFifth.progress = progressBarFinalValue

            default:
                print("Type is something else")
            }

        }

    }
    // MARK: Set Values For Cutomer Ratings And Reviews
    func setValuesForCutomerFeedBack(indexPath: IndexPath, cell: ReviewThumpsUpDownCell) {

        let model = serverDataProductReviews?.data?.review_items?[indexPath.row]
        cell.lblCustomerComments.text = model?.detail ?? ""
        cell.lblcustomerName.text = String(format: "- %@ | %@%@ %@", model?.nickname ?? "", (model?.created_at ?? "").getFormattedDate().dayDateName, (model?.created_at ?? "").getFormattedDate().daySuffix(), (model?.created_at ?? "").getFormattedDate().monthNameAndYear)
        cell.lblRating.text = String(format: "%@/5", ((model?.rating_votes?.first?.percent ?? 0.0) / 100 * 5).cleanForRating)
    }

}

extension ProductDetailsModuleVC: ProductSelectionDelegate {

    func moveToCart(indexPath: IndexPath) {
        print("moveToCart \(indexPath)")
    }
    func actionAddOnsBundle(indexPath: IndexPath) {
        print("actionAddOnsBundle \(indexPath)")
    }

    func actionQunatity(quantity: Int, indexPath: IndexPath) {
        print("quntity:\(quantity)")
    }

    func selectedItem(indexpath: IndexPath, identifier: SectionIdentifier) {
        print("Section:\(identifier.rawValue) || item :\(indexpath.row)")

        switch identifier {
        case .additionalDetails:
            self.selectedAdditionalDetailsCell = indexpath.row
            DispatchQueue.main.async {
                self.productDetailsTableView.reloadData()//reloadSections([1,2], with: .none)
                self.productDetailsTableView.selectRow(at: IndexPath(row: 0, section: 1), animated: false, scrollPosition: .middle)
            }
        case .frequently_bought:
            if !arrFrequentlyBoughtTogetherData.isEmpty {
                let model = arrFrequentlyBoughtTogetherData[indexpath.row]
                if model.productId > 0 && !model.sku.isEmpty {
                    let vc = ProductDetailsModuleVC.instantiate(fromAppStoryboard: .Products)
                    vc.objProductId = model.productId
                    vc.objProductSKU = model.sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }

            }
        case .customers_also_bought:
            if !arrCustomerAlsoBought.isEmpty {
                let model = arrCustomerAlsoBought[indexpath.row]
                if model.productId > 0 && !model.sku.isEmpty {
                    let vc = ProductDetailsModuleVC.instantiate(fromAppStoryboard: .Products)
                    vc.objProductId = model.productId
                    vc.objProductSKU = model.sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        case .recently_viewed:
            if !arrRecentlyViewedData.isEmpty {
                let model = arrRecentlyViewedData[indexpath.row]
                if model.productId > 0 && !model.sku.isEmpty {
                    let vc = ProductDetailsModuleVC.instantiate(fromAppStoryboard: .Products)
                    vc.objProductId = model.productId
                    vc.objProductSKU = model.sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        default:
            break
        }

        //        if identifier == .additionalDetails{
        //            self.selectedAdditionalDetailsCell = indexpath.row
        //            DispatchQueue.main.async {
        //                self.productDetailsTableView.reloadData()//reloadSections([1,2], with: .none)
        //                self.productDetailsTableView.selectRow(at: IndexPath(row: 0, section: 1), animated: false, scrollPosition: .middle)
        //            }
        //        }

    }

    func wishlistStatus(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {

    }
    // MARK: updateCell
    func updateCellForWishList(status: Bool) {

        if let cell = self.productDetailsTableView.cellForRow(at:
            IndexPath(row: self.identifierLocal == .frequently_bought ? 1 : 0,
                      section: self.selectedIndexWishList.section)) as? ProductsCollectionCell {
            if let productCell = cell.productCollectionView.cellForItem(at: IndexPath(row: self.selectedIndexWishList.row, section: 0)) as? TrendingProductsCell {

                switch self.identifierLocal {
                case .frequently_bought:
                    let model = arrFrequentlyBoughtTogetherData[selectedIndexWishList.row]
                    updateWishListFlagFrequentlyBought(status: status, productCell: productCell, cell: cell)
                    !arrCustomerAlsoBought.isEmpty ? updateOtherCellIncaseSameProductInOtherSection(identifier: .customers_also_bought, model: model, status: status): nil
                    !arrRecentlyViewedData.isEmpty ? updateOtherCellIncaseSameProductInOtherSection(identifier: .recently_viewed, model: model, status: status): nil
                case .customers_also_bought:
                    let model = arrCustomerAlsoBought[selectedIndexWishList.row]
                    updateWishListFlagCustomerAlsoBought(status: status, productCell: productCell, cell: cell)
                    !arrFrequentlyBoughtTogetherData.isEmpty ? updateOtherCellIncaseSameProductInOtherSection(identifier: .frequently_bought, model: model, status: status): nil
                    !arrRecentlyViewedData.isEmpty ? updateOtherCellIncaseSameProductInOtherSection(identifier: .recently_viewed, model: model, status: status): nil

                case .recently_viewed:
                    let model = arrRecentlyViewedData[selectedIndexWishList.row]
                    updateWishListFlagRecentlyViewed(status: status, productCell: productCell, cell: cell)
                    !arrFrequentlyBoughtTogetherData.isEmpty ? updateOtherCellIncaseSameProductInOtherSection(identifier: .frequently_bought, model: model, status: status): nil
                    !arrCustomerAlsoBought.isEmpty ? updateOtherCellIncaseSameProductInOtherSection(identifier: .customers_also_bought, model: model, status: status): nil

                default:
                    break
                }
            }
        }

    }

    func updateWishListFlagFrequentlyBought(status: Bool, productCell: TrendingProductsCell, cell: ProductsCollectionCell) {
        self.arrFrequentlyBoughtTogetherData[self.selectedIndexWishList.row].isFavourite = status
        GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(self.arrFrequentlyBoughtTogetherData[self.selectedIndexWishList.row].productId)", changedState: status))

        self.sections[self.selectedIndexWishList.section].data = self.arrFrequentlyBoughtTogetherData
        productCell.configureCell(model: self.arrFrequentlyBoughtTogetherData[self.selectedIndexWishList.row])
        cell.configuration.data = self.arrFrequentlyBoughtTogetherData[self.selectedIndexWishList.row]

    }
    func updateWishListFlagCustomerAlsoBought(status: Bool, productCell: TrendingProductsCell, cell: ProductsCollectionCell) {

        self.arrCustomerAlsoBought[self.selectedIndexWishList.row].isFavourite = status
        GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(self.arrCustomerAlsoBought[self.selectedIndexWishList.row].productId)", changedState: status))
        self.sections[self.selectedIndexWishList.section].data = self.arrCustomerAlsoBought
        productCell.configureCell(model: self.arrCustomerAlsoBought[self.selectedIndexWishList.row])
        cell.configuration.data = self.arrCustomerAlsoBought[self.selectedIndexWishList.row]
    }
    func updateWishListFlagRecentlyViewed(status: Bool, productCell: TrendingProductsCell, cell: ProductsCollectionCell) {
        self.arrRecentlyViewedData[self.selectedIndexWishList.row].isFavourite = status
        GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(self.arrRecentlyViewedData[self.selectedIndexWishList.row].productId)", changedState: status))
        productCell.configureCell(model: self.arrRecentlyViewedData[self.selectedIndexWishList.row])
        self.sections[self.selectedIndexWishList.section].data = self.arrRecentlyViewedData
        cell.configuration.data = self.arrRecentlyViewedData[self.selectedIndexWishList.row]
    }

    func updateOtherCellIncaseSameProductInOtherSection(identifier: SectionIdentifier, model: ProductModel, status: Bool) {

        switch identifier {
        case .frequently_bought:
            if let rowIndex = arrFrequentlyBoughtTogetherData.firstIndex(where: { $0.sku == model.sku}) {
                if getCellAndSection(identifier: .frequently_bought, rowIndex: rowIndex).found {
                    self.arrFrequentlyBoughtTogetherData[rowIndex].isFavourite = status
                    GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(self.arrFrequentlyBoughtTogetherData[rowIndex].productId)", changedState: status))

                    self.sections[getCellAndSection(identifier: .frequently_bought, rowIndex: rowIndex).sectionIndex].data = self.arrFrequentlyBoughtTogetherData
                    // getCellAndSection(identifier: .frequently_bought, rowIndex: rowIndex).productCell.configureCell(model: self.arrFrequentlyBoughtTogetherData[rowIndex])
                    //getCellAndSection(identifier: .frequently_bought, rowIndex: rowIndex).cell.configuration.data = self.arrFrequentlyBoughtTogetherData[rowIndex]
                }
            }
        case .customers_also_bought:
            if let rowIndex = arrCustomerAlsoBought.firstIndex(where: { $0.sku == model.sku}) {
                if getCellAndSection(identifier: .customers_also_bought, rowIndex: rowIndex).found {
                    self.arrCustomerAlsoBought[rowIndex].isFavourite = status
                    GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(self.arrCustomerAlsoBought[rowIndex].productId)", changedState: status))
                    self.sections[getCellAndSection(identifier: .customers_also_bought, rowIndex: rowIndex).sectionIndex].data = self.arrCustomerAlsoBought
                    //getCellAndSection(identifier: .customers_also_bought, rowIndex: rowIndex).productCell.configureCell(model: self.arrCustomerAlsoBought[rowIndex])
                    // getCellAndSection(identifier: .customers_also_bought, rowIndex: rowIndex).cell.configuration.data = self.arrCustomerAlsoBought[rowIndex]
                }
            }
        case .recently_viewed:
            if let rowIndex = arrRecentlyViewedData.firstIndex(where: { $0.sku == model.sku}) {
                if getCellAndSection(identifier: .recently_viewed, rowIndex: rowIndex).found {
                    self.arrRecentlyViewedData[rowIndex].isFavourite = status
                    GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(self.arrRecentlyViewedData[rowIndex].productId)", changedState: status))
                    self.sections[getCellAndSection(identifier: .recently_viewed, rowIndex: rowIndex).sectionIndex].data = self.arrRecentlyViewedData
                    // getCellAndSection(identifier: .recently_viewed, rowIndex: rowIndex).productCell.configureCell(model: self.arrRecentlyViewedData[rowIndex])
                    // getCellAndSection(identifier: .recently_viewed, rowIndex: rowIndex).cell.configuration.data = self.arrRecentlyViewedData[rowIndex]
                }
            }
        default:
            break
        }
    }

    func getCellAndSection(identifier: SectionIdentifier, rowIndex: Int)  ->(found: Bool, sectionIndex: Int) {
        var isFound: Bool = false
        var sectionAtIndex: Int = 0
        if let sectionIndex = sections.firstIndex(where: { $0.identifier == identifier }) {

            isFound = true
            sectionAtIndex = sectionIndex
            return(isFound, sectionAtIndex)

        }
        return(isFound, sectionAtIndex)
    }

    func checkBoxSelection(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {
        print("CheckBox:\(status) || \(identifier.rawValue) || item :\(indexpath.row)")
        selectedIndexWishList = indexpath
        identifierLocal = SectionIdentifier.frequently_bought
        GenericClass.sharedInstance.isuserLoggedIn().status == true ? checkBoxSelectionForCustomer(status: status, indexpath: indexpath, identifier: identifierLocal) : checkBoxSelectionForGuest(status: status, indexpath: indexpath, identifier: identifierLocal)
        // btnTotalPrice.setTitle(String(format: "₹ %@ >", createDataForBottomMoreItemsWithProduct().1.cleanForPrice), for: .normal)

    }

    func checkBoxSelectionForGuest(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {
        if let cell = self.productDetailsTableView.cellForRow(at: IndexPath(row: self.identifierLocal == .frequently_bought ? 1 : 0, section: self.selectedIndexWishList.section)) as? ProductsCollectionCell {
            if let productCell = cell.productCollectionView.cellForItem(at: IndexPath(row: self.selectedIndexWishList.row, section: 0)) as? TrendingProductsCell {
                if !arrFrequentlyBoughtTogetherData.isEmpty {
                    let status: Bool = arrFrequentlyBoughtTogetherData[indexpath.row].isProductSelected

                    /* Code Commented To Show Allready Added this product in Cart
                     if let containsObj = serverDataForAllCartItemsGuest?.contains(where: { $0.sku == arrFrequentlyBoughtTogetherData[indexpath.row].sku}), containsObj == false {
                     Code Commented To Show Allready Added this product in Cart */
                    arrFrequentlyBoughtTogetherData[indexpath.row].isProductSelected = status == true ? false : true
                    self.sections[self.selectedIndexWishList.section].data = arrFrequentlyBoughtTogetherData
                    productCell.configureCell(model: self.arrFrequentlyBoughtTogetherData[self.selectedIndexWishList.row])
                    cell.configuration.data = self.arrFrequentlyBoughtTogetherData[self.selectedIndexWishList.row]
                    // updateCartCellHideAndShow()

                    arrFrequentlyBoughtTogetherData[indexpath.row].isProductSelected == true ?arrayOFSelectedFrequentlyBought.append(arrFrequentlyBoughtTogetherData[indexpath.row]) : arrayOFSelectedFrequentlyBought.removeAll {$0.sku == arrFrequentlyBoughtTogetherData[indexpath.row].sku}

                    updateBottomAddToCartButton(isStatus: !arrayOFSelectedFrequentlyBought.isEmpty ? false : modelTopHeaderData?.isProductSelected == true ? true : false )
                    totalPriceView.isHidden = !arrayOFSelectedFrequentlyBought.isEmpty ? false : true
                    /* Code Commented To Show Allready Added this product in Cart } Code Commented To Show Allready Added this product in Cart */
                }
            }
        }
    }
    func checkBoxSelectionForCustomer(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {
        if let cell = self.productDetailsTableView.cellForRow(at: IndexPath(row: self.identifierLocal == .frequently_bought ? 1 : 0, section: self.selectedIndexWishList.section)) as? ProductsCollectionCell {
            if let productCell = cell.productCollectionView.cellForItem(at: IndexPath(row: self.selectedIndexWishList.row, section: 0)) as? TrendingProductsCell {
                if !arrFrequentlyBoughtTogetherData.isEmpty {
                    /* Code Commented To Show Allready Added this product in Cart
                     let status: Bool = arrFrequentlyBoughtTogetherData[indexpath.row].isProductSelected
                     if let containsObj = serverDataForAllCartItemsCustomer?.contains(where: { $0.sku == arrFrequentlyBoughtTogetherData[indexpath.row].sku}), containsObj == false {
                     Code Commented To Show Allready Added this product in Cart*/
                    arrFrequentlyBoughtTogetherData[indexpath.row].isProductSelected = status == true ? false : true
                    self.sections[self.selectedIndexWishList.section].data = arrFrequentlyBoughtTogetherData
                    productCell.configureCell(model: self.arrFrequentlyBoughtTogetherData[self.selectedIndexWishList.row])
                    cell.configuration.data = self.arrFrequentlyBoughtTogetherData[self.selectedIndexWishList.row]
                    // updateCartCellHideAndShow()
                    arrFrequentlyBoughtTogetherData[indexpath.row].isProductSelected == true ?arrayOFSelectedFrequentlyBought.append(arrFrequentlyBoughtTogetherData[indexpath.row]) : arrayOFSelectedFrequentlyBought.removeAll {$0.sku == arrFrequentlyBoughtTogetherData[indexpath.row].sku}
                    updateBottomAddToCartButton(isStatus: !arrayOFSelectedFrequentlyBought.isEmpty ? false : modelTopHeaderData?.isProductSelected == true ? true : false )
                    totalPriceView.isHidden = !arrayOFSelectedFrequentlyBought.isEmpty ? false : true
                    /* Code Commented To Show Allready Added this product in Cart
                     }  Code Commented To Show Allready Added this product in Cart */

                }
            }
        }
    }

}

extension ProductDetailsModuleVC: HeaderDelegate {

    func actionViewAll(identifier: SectionIdentifier) {
        print("ViewAllAction : \(identifier.rawValue)")
        switch identifier {
        case .customer_rating_review:
            let vc = AllReviewsVC.instantiate(fromAppStoryboard: .Products)
            vc.productId = String(format: "%d", objProductId ?? 0)
            self.navigationController?.pushViewController(vc, animated: true)

        default: break
        }
    }
}

extension ProductDetailsModuleVC: ProductDelegates {

    func actionColorSelection(indexPath: IndexPath, color: ProductConfigurableColorQuanity) {
        print("Selected Color Index:\(indexPath.row) -- \(color)")

        if self.modelTopHeaderData?.isProductSelected == false {
            for (index, _) in (self.modelTopHeaderData?.uniqueColors.enumerated())! {
                self.modelTopHeaderData?.uniqueColors[index].isProductSelected = false
            }
            self.modelTopHeaderData?.uniqueColors[indexPath.row].isProductSelected = true

            if let valueIndex = self.modelTopHeaderData?.uniqueColors[indexPath.row].value_index {
                let objData = checkWhichColorQuantityIsAvailable(value_Index: valueIndex, allColor: self.modelTopHeaderData?.allColors ?? [], allQuantity: self.modelTopHeaderData?.allQuantities ?? [])
                setPriceForConfigurableProductColorOrQuantitySelection(price: String(format: " ₹ %@", objData.priceDouble.cleanForPrice ) ,
                                                                       priceDouble: objData.priceDouble ,
                                                                       specialPrice: String(format: " ₹ %@", objData.specialPriceDouble.cleanForPrice ),
                                                                       specialPriceDoble: objData.specialPriceDouble )
            }

            let indexPathOfCell = IndexPath(row: 0, section: 0)
            if let cell = self.productDetailsTableView.cellForRow(at: indexPathOfCell) as? ProductDetailsCell {
                cell.configureCell(model: self.modelTopHeaderData!)
            }

        }
    }

    func actionQuantitySelection(indexPath: IndexPath, quantity: ProductConfigurableColorQuanity) {
        print("Selected Quantity Index:\(indexPath.row) --- \(quantity)")

        if self.modelTopHeaderData?.isProductSelected == false {
            for (index, _) in (self.modelTopHeaderData?.uniqueQuantities.enumerated())! {
                self.modelTopHeaderData?.uniqueQuantities[index].isProductSelected = false
            }
            self.modelTopHeaderData?.uniqueQuantities[indexPath.row].isProductSelected = true
            if let valueIndex = self.modelTopHeaderData?.uniqueQuantities[indexPath.row].value_index {
                let objData = checkWhichQuantityColorIsAvailable(value_Index: valueIndex, allColor: self.modelTopHeaderData?.allColors ?? [], allQuantity: self.modelTopHeaderData?.allQuantities ?? [])
                setPriceForConfigurableProductColorOrQuantitySelection(price: String(format: " ₹ %@", objData.priceDouble.cleanForPrice ) ,
                                                                       priceDouble: objData.priceDouble ,
                                                                       specialPrice: String(format: " ₹ %@", objData.specialPriceDouble.cleanForPrice ),
                                                                       specialPriceDoble: objData.specialPriceDouble )
            }

            let indexPathOfCell = IndexPath(row: 0, section: 0)
            if let cell = self.productDetailsTableView.cellForRow(at: indexPathOfCell) as? ProductDetailsCell,
                let model = self.modelTopHeaderData {
                cell.configureCell(model: model)
            }
        }
    }

    func optionsBeTheFirstToReview() {

        if !(self.modelTopHeaderData?.reviewCount.isEmpty)! {

            optionsToOpenAllReviewsForTopHeader()
            return

        }
        //        if  GenericClass.sharedInstance.isuserLoggedIn().status {
        //            let vc = RateTheProductVC.instantiate(fromAppStoryboard: .Products)
        //            self.view.alpha = screenPopUpAlpha
        //            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: {
        //                vc.lblProductName.text = self.modelTopHeaderData?.productName ?? ""
        //                vc.product_id = self.modelTopHeaderData?.productId ?? 0
        //                vc.showProductImage(imageStr: self.modelTopHeaderData?.imageUrls.first ?? "")
        //
        //            })
        //            vc.onDoneBlock = { [unowned self] result in
        //                self.view.alpha = 1.0
        //            } }
        // else { openLoginWindow() }
    }

    func selectedProduct(indexPath: IndexPath) {
        print("Selected Product : \(indexPath.row)")
    }
}

extension ProductDetailsModuleVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let data = sections[section]
        guard data.items > 0 else {
            return 0
        }
        if data.identifier == .frequently_bought {
            return 2
        }
        else if data.identifier == .frequently_bought {
            return 2
        }
        else if data.identifier == .customers_also_bought {
            return 1
        }
        else if data.identifier == .recently_viewed {
            return 1
        }
        else if data.identifier == .additionalDetails {

            return afterTipsData[selectedAdditionalDetailsCell].points.count + 1

        }
        return data.items
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var data = self.sections[indexPath.section]

        if data.identifier == .productDetails {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.productDetailsCell, for: indexPath) as? ProductDetailsCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            // cell.colorPickerView.isHidden = true
            cell.delegate = self
            if let model = modelTopHeaderData {
                cell.configureCell(model: model)
            }
            return cell

        }
        else if data.identifier == .cashbackOffer {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.cashbackOfferCell, for: indexPath) as? CashbackOfferCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell

        }
        else if data.identifier == .quntity {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.productQuantityCell, for: indexPath) as? ProductQuantityCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell

        }
        else if data.identifier == .additionalDetails {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.productsCollectionCell, for: indexPath) as? ProductsCollectionCell else {
                    return UITableViewCell()
                }
                cell.tableViewIndexPath = indexPath
                cell.selectionDelegate = self
                cell.hideCheckBox = true
                cell.addSectionSpacing = is_iPAD ? 0 : 0
                data.selectedIndex = selectedAdditionalDetailsCell
                cell.selectedMenuCell = selectedAdditionalDetailsCell
                cell.configureCollectionView(configuration: data, scrollDirection: .horizontal)
                cell.selectionStyle = .none
                return cell
            }
            else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "PointsCell") as? PointsCell else {
                    return UITableViewCell()
                }
                cell.configureCell(text: (!afterTipsData.isEmpty ? afterTipsData[selectedAdditionalDetailsCell].points[indexPath.row - 1] : "").htmlAttributedMembership(family: "\(FontName.FuturaPTBook)", size: is_iPAD ? 5 : 9,colorHex: "#707070", csstextalign: "left", defaultFont: FontName.FuturaPTBook.rawValue)!)
                print("IndexAtCell:\(selectedAdditionalDetailsCell)")

                cell.selectionStyle = .none
                return cell
            }

        }
            /*else if data.identifier == .specifications{
             let cell:ProductSpcificationCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.productSpcificationCell, for: indexPath) as! ProductSpcificationCell
             cell.selectionStyle = .none
             cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
             let model = arrayOfSpecificationData[indexPath.row]
             cell.configureCell(model: model)
             return cell
             
         }*/else if data.identifier == .frequently_bought {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.productFullCell, for: indexPath) as? ProductFullCell else {
                    return UITableViewCell()
                }
                let modelObj = ProductFullModel(productName: modelTopHeaderData?.productName ?? "", productPrice: modelTopHeaderData?.specialPrice ?? "₹ 0", imageUrl: modelTopHeaderData?.imageUrls.first ?? "")
                cell.configureCell(model: modelObj)
                cell.selectionStyle = .none
                return cell
            }
            else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.productsCollectionCell, for: indexPath) as? ProductsCollectionCell else {
                    return UITableViewCell()
                }
                cell.tableViewIndexPath = indexPath
                cell.selectionDelegate = self
                cell.hideCheckBox = false
                cell.configureCollectionView(configuration: data, scrollDirection: .vertical)
                cell.selectionStyle = .none
                return cell
            }

        }
            //         else if data.identifier == .cart_calculation{
            //            guard let cell:AddServiceInYourCartCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.addServiceInYourCartCell, for: indexPath) as? AddServiceInYourCartCell else{
            //                return UITableViewCell()
            //            }
            //            cell.delegate = self
            //            updateFrequentlyBoughtProductsDataCart(addServiceInYourCartCell: cell)
            //            cell.selectionStyle = .none
            //            return cell
            //
            //        }
        else if data.identifier == .customer_rating_review {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.customerRatingAndReviewCell, for: indexPath) as? CustomerRatingAndReviewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.delegate = self
            setValuesForCutomerRatingsAndReviews(cell: cell)
            return cell

        }
        else if data.identifier == .feedbackDetails {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.reviewThumpsUpDownCell, for: indexPath) as? ReviewThumpsUpDownCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            setValuesForCutomerFeedBack(indexPath: indexPath, cell: cell)
            return cell

        }
        else {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.productsCollectionCell, for: indexPath) as? ProductsCollectionCell else {
                return UITableViewCell()
            }
            cell.tableViewIndexPath = indexPath
            cell.selectionDelegate = self
            cell.addSectionSpacing = is_iPAD ? 25 : 15
            cell.hideCheckBox = true
            cell.configureCollectionView(configuration: data, scrollDirection: .horizontal)
            cell.selectionStyle = .none
            return cell
        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if sections.isEmpty {
            return nil
        }

        let data = self.sections[section]

        if !data.showHeader {
            return nil
        }

        if data.identifier == .new_arrivals {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.headerViewWithSubTitleCell) as? HeaderViewWithSubTitleCell else {
                return UITableViewCell()
            }
            cell.configureHeader(title: data.title, subTitle: data.subTitle, hideAllButton: true)

            if let titleFont = data.textFont,
                let subTitleFont = data.textFont {
                cell.setFont(titleFont: titleFont, subtitleFont: subTitleFont)
            }
            cell.identifier = data.identifier
            cell.delegate = self
            return cell

        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.headerViewWithTitleCell) as? HeaderViewWithTitleCell else {
                return UITableViewCell()
            }

            if let font = data.textFont {
                cell.setFont(font: font)
            }
            cell.identifier = data.identifier
            cell.delegate = self

            if data.identifier == .customer_rating_review {
                cell.configureHeader(title: data.title, hideAllButton: (self.serverDataProductReviews?.data?.review_items?.count)!  > 0 ? false : true)
            }
            /*  if data.identifier == .specifications{
             cell.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
             }*/

            return cell
        }

    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let data = self.sections[section]
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: data.footerHeight))
        view.backgroundColor = UIColor.white
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let data = self.sections[section]
        return data.showHeader ? data.headerHeight : 0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let data = self.sections[section]
        return data.showFooter ? data.footerHeight : 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = self.sections[indexPath.section]
        if data.identifier == .frequently_bought {
            if indexPath.row != 0 {
                let height: CGFloat
                let bottomMargin: CGFloat = is_iPAD ? 30 : 20

                if data.items % (is_iPAD ? 3 : 2) == 0 {
                    height = (data.cellHeight + bottomMargin) * CGFloat((Int(data.items / (is_iPAD ? 3 : 2))))
                }
                else {
                    height = (data.cellHeight + bottomMargin) * (CGFloat((Int(data.items / (is_iPAD ? 3 : 2)) + 1)))
                }
                return height//data.cellHeight
            }
        }
        else if data.identifier == .recently_viewed || data.identifier == .customers_also_bought {
            return data.cellHeight
        }
        else if data.identifier == .additionalDetails, indexPath.row == 0 {
            return data.cellHeight
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
        //let data = sections[indexPath.section]
    }

}

extension ProductDetailsModuleVC {

    func configureSection(idetifier: SectionIdentifier, items: Int, data: Any) -> SectionConfiguration {

        let headerHeight: CGFloat = is_iPAD ? 70 : 50
        let leftMargin: CGFloat = is_iPAD ? 25 : 15

        let font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 30.0 : 20.0)

        //        case productDetails = "Product Details"
        //        case cashbackOffer = "Cashback Offer"
        //        case quntity = "Quantity"
        //        case frequently_bought = "Frequently bought together"
        //        case cart_calculation = "Cart Calculation"
        //        case customer_rating_review = "Customers Rating and Review"
        //        case feedbackDetails = "Feedback"
        //        case customers_also_bought = "Customers also bought"

        switch idetifier {

        case .productDetails, .cashbackOffer, .quntity, .cart_calculation, .feedbackDetails:

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: 0, showHeader: false, showFooter: false, headerHeight: 0, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: true, textFont: font, textColor: UIColor.black, items: items, identifier: idetifier, data: data)

        case .customer_rating_review:

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: 0, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: true, textFont: font, textColor: UIColor.black, items: items, identifier: idetifier, data: data)

        case .additionalDetails:

            let height: CGFloat = is_iPAD ? 70 : 50
            let width: CGFloat = productDetailsTableView.frame.size.width

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: false, showFooter: false, headerHeight: 0, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: true, textFont: font, textColor: UIColor.black, items: items, identifier: idetifier, data: data)

            /*case .specifications:
             
             return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: 0, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: font, textColor: .black, items: items, identifier: idetifier, data: data)*/

        case .frequently_bought:

            let height: CGFloat = is_iPAD ? 475 : 400
            let width: CGFloat = is_iPAD ? ((productDetailsTableView.frame.size.width - 100) / 3) : ((productDetailsTableView.frame.size.width - 45) / 2)

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: leftMargin, isPagingEnabled: false, textFont: font, textColor: .black, items: items, identifier: idetifier, data: data)

        case .recently_viewed, .customers_also_bought:

            let height: CGFloat = is_iPAD ? 475 : 400
            let width: CGFloat = is_iPAD ? ((productDetailsTableView.frame.size.width - 100) / 3) : ((productDetailsTableView.frame.size.width - 45) / 2)

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: font, textColor: .black, items: items, identifier: idetifier, data: data)

        default :
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: 0, showHeader: false, showFooter: false, headerHeight: 0, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: false, textFont: font, textColor: UIColor.black, items: 0, identifier: idetifier, data: data)
        }
    }
}

// MARK: Login Delegate
extension ProductDetailsModuleVC: LoginRegisterDelegate {
    func doLoginRegister() {
        // Put your code here
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {[unowned self] in
            let vc = LoginModuleVC.instantiate(fromAppStoryboard: .Main)
            let navigationContrl = UINavigationController(rootViewController: vc)
            self.present(navigationContrl, animated: true, completion: nil)
        }
    }
}

// MARK: Add Cart Additinal Services
extension ProductDetailsModuleVC: AddServiceInYourCartCellCellDelegate {
    func addAdditionalService(indexPath: IndexPath) {
        print("addAction Clicked Index \(indexPath)")

    }
}
// MARK: CustomerRatingReviewCellDelegate
extension ProductDetailsModuleVC: CustomerRatingReviewCellDelegate {
    func actionToRateProductOrService() {

        if  GenericClass.sharedInstance.isuserLoggedIn().status {
            let vc = RateTheProductVC.instantiate(fromAppStoryboard: .Products)
            self.view.alpha = screenPopUpAlpha
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: {
                vc.lblProductName.text = self.modelTopHeaderData?.productName ?? ""
                vc.product_id = self.modelTopHeaderData?.productId ?? 0
                vc.showProductImage(imageStr: self.modelTopHeaderData?.imageUrls.first ?? "")
            })
            vc.onDoneBlock = { [unowned self] result in
                self.view.alpha = 1.0
            } }
 else { openLoginWindow() }
    }

}
// MARK: Call Webservice
extension ProductDetailsModuleVC {
    // MARK: callProductDetailsAPI
    func callProductDetailsAPI() {

        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()

        var queryString = ""
        let productSKU = objProductSKU ?? ""//"L-INOA200ML"

        queryString += String(format: "%@?", productSKU)

        if  let userSelectionForService = GenericClass.sharedInstance.getSalonId(), userSelectionForService != "0" {
            queryString += String(format: "salon_id=%@", userSelectionForService)
        }

        let request = ServiceDetailModule.ServiceDetails.Request(requestedParameters: queryString)
        interactor?.doGetRequestWithParameter(request: request, method: HTTPMethod.get)
    }

    // MARK: callProductReviewsAPI
    func callProductReviewsAPI() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()

        let request = ServiceDetailModule.ServiceDetails.ProductReviewRequest(product_id: String(format: "%d", objProductId!), limit: maxlimitToReviewOnServiceDetails, page: 1)
        interactor?.doPostRequestProductReviews(request: request, method: HTTPMethod.post)
    }

    // MARK: callRecentlyViewProductsAPI
//        func callRecentlyViewProductsAPI()
//        {
//            EZLoadingActivity.show("Loading...", disableUI: true)
//            dispatchGroup.enter()
//            let request = ProductDetailsModule.RecentlyViewedProducts.Request(customer_id: GenericClass.sharedInstance.getCustomerId().toString, limit: 5)
//            interactor?.doPostRequestRecentlyViewedProducts(request: request, method: HTTPMethod.post)
//        }

    /** Add To Cart API's End */

    func displaySuccess<T: Decodable>(viewModel: T) {

        DispatchQueue.main.async {[unowned self] in
            if T.self == ServiceDetailModule.ServiceDetails.Response.self {
                // Product Details
                self.parseProductDetailsData(viewModel: viewModel)
            }
            else if T.self == ServiceDetailModule.ServiceDetails.ProductReviewResponse.self {
                // Products Reviews
                self.parseProductReviewResponse(viewModel: viewModel)
            }
            else if T.self == ServiceDetailModule.ServiceDetails.RateAServiceResponse.self {
                // Rate a Sevice
                self.parseRateAServiceResponse(viewModel: viewModel)
            }
        }

//            else if T.self == ProductDetailsModule.RecentlyViewedProducts.Response.self    {
//                // Recently viewed Products
//                self.parseRecentlyViewedProducts(viewModel: viewModel)
//            }
    }
    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        dispatchGroup.leave()
        if (errorMessage ?? "").containsIgnoringCase(find: inActiveCartQuoteId) {
            return
        }
        self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage!)
    }

    func displaySuccess<T: Decodable>(responseSuccess: [T]) {
    }

    // MARK: Parsing Methods
    func parseProductDetailsData<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ServiceDetailModule.ServiceDetails.Response
        self.serverDataProductDetails = obj
        self.dispatchGroup.leave()
    }

    func parseProductReviewResponse<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ServiceDetailModule.ServiceDetails.ProductReviewResponse
        if obj?.status == true {
            self.serverDataProductReviews = obj
        }
        else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj?.message ?? "" )
        }
        self.dispatchGroup.leave()
    }

    func parseRateAServiceResponse<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ServiceDetailModule.ServiceDetails.RateAServiceResponse
        if obj?.status == true {
            self.showAlert(alertTitle: alertTitleSuccess, alertMessage: obj?.message ?? "")
        }
        else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj?.message ?? "")
        }
        self.dispatchGroup.leave()
    }

//    func parseRecentlyViewedProducts<T:Decodable>(viewModel: T){
//        // Recently viewed Products
//        let obj :ProductDetailsModule.RecentlyViewedProducts.Response = viewModel as! ProductDetailsModule.RecentlyViewedProducts.Response
//        if(obj.status == true)
//        {
//            self.serverDataRecentlyViewedProducts = obj
//        }
//        else
//        {
//            self.showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "")
//        }
//        self.dispatchGroup.leave()
//    }
//

}
