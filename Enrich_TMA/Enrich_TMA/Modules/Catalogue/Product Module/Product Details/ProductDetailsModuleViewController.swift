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

protocol AddServiceInYourCartCellCellDelegate: class {
    func addAdditionalService(indexPath: IndexPath)
}

class ProductDetailsModuleViewController: UIViewController, ProductDetailsModuleDisplayLogic {
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
        showNavigationBarRigtButtons()
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

        //updatedFevouriteData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshView()
    }

    // MARK: initialSetUp
    func initializeCells() {
        self.productDetailsTableView.register(UINib(nibName: "ProductDetailsCell", bundle: nil), forCellReuseIdentifier: "ProductDetailsCell")
        self.productDetailsTableView.register(UINib(nibName: "CashbackOfferCell", bundle: nil), forCellReuseIdentifier: "CashbackOfferCell")
        self.productDetailsTableView.register(UINib(nibName: "ProductQuantityCell", bundle: nil), forCellReuseIdentifier: "ProductQuantityCell")
        self.productDetailsTableView.register(UINib(nibName: "ProductFullCell", bundle: nil), forCellReuseIdentifier: "ProductFullCell")
        self.productDetailsTableView.register(UINib(nibName: "ProductSpcificationCell", bundle: nil), forCellReuseIdentifier: "ProductSpcificationCell")
        self.productDetailsTableView.register(UINib(nibName: "CustomerRatingAndReviewCell", bundle: nil), forCellReuseIdentifier: "CustomerRatingAndReviewCell")
        self.productDetailsTableView.register(UINib(nibName: "AddServiceInYourCartCell", bundle: nil), forCellReuseIdentifier: "AddServiceInYourCartCell")
        self.productDetailsTableView.register(UINib(nibName: "ReviewThumpsUpDownCell", bundle: nil), forCellReuseIdentifier: "ReviewThumpsUpDownCell")

        self.productDetailsTableView.register(UINib(nibName: "HeaderViewWithTitleCell", bundle: nil), forCellReuseIdentifier: "HeaderViewWithTitleCell")
        self.productDetailsTableView.register(UINib(nibName: "HeaderViewWithSubTitleCell", bundle: nil), forCellReuseIdentifier: "HeaderViewWithSubTitleCell")
    }
    func refreshView() {
        arrRecentlyViewedData.removeAll()
        arrCustomerAlsoBought.removeAll()
        arrFrequentlyBoughtTogetherData.removeAll()
        arrayOFSelectedFrequentlyBought.removeAll()
        serverDataForAllCartItemsCustomer?.removeAll()
        totalPriceView.isHidden = arrayOFSelectedFrequentlyBought.count > 0 ? false : true
        afterTipsData.removeAll()
        if (isuserLoggedIn().status) {
            getAllCartItemsAPICustomer()
        } else {
            getAllCartItemsAPIGuest()
        }

        callProductDetailsAPI()
        callProductReviewsAPI()

        //        if (isuserLoggedIn().status)
        //        {
        //            callRecentlyViewProductsAPI()
        //        }
        //** Cart API Section

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
    func updateCartBadgeNumber(count: Int) {
        count > 0 ? self.navigationItem.rightBarButtonItems?.first(where: { $0.tag == 0})?.addBadge(number: count) : self.navigationItem.rightBarButtonItems?.first(where: { $0.tag == 0})?.removeBadge()
        count > 0 ? self.appDelegate.customTabbarController.increaseBadge(indexOfTab: 3, num: String(format: "%d", count)) : self.appDelegate.customTabbarController.nilBadge(indexOfTab: 3)

    }

    // MARK: updateBottomAddToCartButton
    func updateBottomAddToCartButton(isStatus: Bool) {
        var buttonTitle: String = "ADD TO CART"
        buttonTitle = isStatus == true ? "GO TO CART" : "ADD TO CART"
        self.btnAddToCart.setTitle(buttonTitle, for: .normal)
    }

    // MARK: updatedFevouriteData
    /*  func updatedFevouriteData(){
     let arrObject = GenericClass.sharedInstance.getFevoriteProductSet()
     
     if !arrObject.isEmpty{
     if !arrCustomerAlsoBought.isEmpty{
     for model in arrObject {
     if let row = self.arrCustomerAlsoBought.firstIndex(where: {"\($0.productId)" == model.productId!}){
     self.arrCustomerAlsoBought[row].isFavourite = model.changedState!
     }
     }
     }
     
     if !arrRecentlyViewedData.isEmpty{
     for model in arrObject {
     if let row = self.arrRecentlyViewedData.firstIndex(where: {"\($0.productId)" == model.productId!}){
     self.arrRecentlyViewedData[row].isFavourite = model.changedState!
     }
     }
     }
     
     
     if !arrFrequentlyBoughtTogetherData.isEmpty{
     for model in arrObject {
     if let row = self.arrFrequentlyBoughtTogetherData.firstIndex(where: {"\($0.productId)" == model.productId!}){
     self.arrFrequentlyBoughtTogetherData[row].isFavourite = model.changedState!
     }
     }
     }
     
     self.dispatchGroupDataFeeding.notify(queue: .main) {[unowned self] in
     print("dispatchGroupDataFeeding")
     EZLoadingActivity.hide()
     self.productDetailsTableView.reloadData()
     }
     }
     }*/

    // MARK: Top Navigation Bar And  Actions
    func showNavigationBarRigtButtons() {
        let cartImg = UIImage(named: "cartTab")!
        let shareButtonImg = UIImage(named: "navigationBarshare")!
        let wishListImg = UIImage(named: "navigationBarwishlistUnSelected")!

        let cartBtn = UIBarButtonItem(image: cartImg, style: .plain, target: self, action: #selector(didTapCartButton))
        cartBtn.tintColor = UIColor.black
        cartBtn.tag = 0

        let shareButton = UIBarButtonItem(image: shareButtonImg, style: .plain, target: self, action: #selector(didTapShareButton))
        shareButton.tintColor = UIColor.black
        shareButton.tag = 1

        let wishListButton = UIBarButtonItem(image: wishListImg, style: .plain, target: self, action: #selector(didTapWishList))
        wishListButton.tintColor = UIColor.black
        wishListButton.tag = 2

        navigationItem.rightBarButtonItems = [wishListButton, cartBtn, shareButton]
    }

    @objc func didTapCartButton() {
        pushToCartView()
    }
    @objc func didTapShareButton() {

        let myWebsite = NSURL(string: "\(modelTopHeaderData?.productURL ?? "http://www.enrichsalon.com")")
        let shareAll = [myWebsite] as! [NSURL]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    @objc func didTapWishList() {
        identifierLocal = SectionIdentifier.parentVC

        if isuserLoggedIn().status {
            let element = self.navigationItem.rightBarButtonItems?.first(where: { $0.tag == 2})
            element?.image == UIImage(named: "navigationBarwishlistSelected")! ? removeFromWishListAPI(productId: objProductId!) : addToWishListAPI(productId: objProductId!)
            return
        }
        openLoginWindow()

    }

    // MARK: OpenLoginWindow
    func openLoginWindow() {

        //DoLoginPopUpVC
        let vc = DoLoginPopUpVC.instantiate(fromAppStoryboard: .Location)
        vc.delegate = self
        self.view.alpha = screenPopUpAlpha
        self.appDelegate.window?.rootViewController!.present(vc, animated: true, completion: nil)
        vc.onDoneBlock = { [unowned self] result in
            // Do something
            if(result) {} else {}
            self.view.alpha = 1.0

        }
    }

    // MARK: createDataForConfigurableProductColor
    func createDataForConfigurableProductColor() -> ([ProductConfigurableColorQuanity]) {
        var arrData = [ProductConfigurableColorQuanity]()
        if let model = self.serverDataProductDetails {
            if let arrayOfData = model.extension_attributes?.configurable_subproduct_options {
                for (_, element) in arrayOfData.enumerated() {
                    if (element.attribute_code?.equalsIgnoreCase(string: ProductConfigurableDetailType.color))!
                    {
                        let dataModel = ProductConfigurableColorQuanity(productId: Int64(element.product_id ?? "0") ?? 0, productColorOrQty: element.swatch_option_value ?? "", sku: element.sku ?? "",price: element.price ?? 0, specialPrice: 0, isProductSelected: false)
                        arrData.append(dataModel)
                    }

                }
            }
        }

        return arrData
    }

    // MARK: createDataForConfigurableProductQuanitity
    func createDataForConfigurableProductQuanitity() -> ([ProductConfigurableColorQuanity]) {
        var arrData = [ProductConfigurableColorQuanity]()
        if let model = self.serverDataProductDetails {
            if let arrayOfData = model.extension_attributes?.configurable_subproduct_options {
                for (_, element) in arrayOfData.enumerated() {
                    if (element.attribute_code?.equalsIgnoreCase(string: ProductConfigurableDetailType.quantity))!
                    {
                        let dataModel = ProductConfigurableColorQuanity(productId: Int64(element.product_id ?? "0") ?? 0, productColorOrQty: element.default_title ?? "", sku: element.sku ?? "", price: element.price ?? 0, specialPrice: 0, isProductSelected: false)
                        arrData.append(dataModel)
                    }
                }
            }
        }

        return arrData
    }

    func pushToCartView() {
//        let cartModuleViewController = CartModuleVC.instantiate(fromAppStoryboard: .HomeLanding)
//        self.navigationController?.isNavigationBarHidden = false
//        self.navigationController?.pushViewController(cartModuleViewController, animated: true)

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
        if self.btnAddToCart.currentTitle != "GO TO CART" {
            if(isuserLoggedIn().status) {
                addToCartSimpleOrVirtualProductForCustomer()
            } else {
                addToCartSimpleOrVirtualProductForGuest()
            }
        } else {
            pushToCartView()

        }
    }
    @IBAction func actionTotalPrice(_ sender: UIButton) {

        let vc = PriceDetailsViewController.instantiate(fromAppStoryboard: .Products)
        self.view.alpha = screenPopUpAlpha
        vc.arrData = createDataForBottomMoreItemsWithProduct().0
        self.appDelegate.window?.rootViewController!.present(vc, animated: true, completion: nil)
        vc.onDoneBlock = { [unowned self] result in
            // Do something
            if(result) {} else {}
            self.view.alpha = 1.0

        }
    }

    // MARK: createDataForBottomMoreItemsWithProduct
    func createDataForBottomMoreItemsWithProduct() -> ([ProductCartAddOnsModel], Double) {
        var finalAmountPayable: Double = 0
        var arrData = [ProductCartAddOnsModel]()
        arrData.append(ProductCartAddOnsModel(productName: modelTopHeaderData?.productName ?? "", price: modelTopHeaderData?.specialPrice ?? "" ))
        finalAmountPayable += (Double(modelTopHeaderData?.specialPrice.components(separatedBy: " ").last ?? "0") ?? 0)

        if(!arrayOFSelectedFrequentlyBought.isEmpty) {
            let productsSelected = arrFrequentlyBoughtTogetherData.filter { $0.isProductSelected == true }
            for (_, element) in productsSelected.enumerated() {
                arrData.append(ProductCartAddOnsModel(productName: element.productName, price: "₹ \(element.specialPrice.cleanForPrice )" ))
                finalAmountPayable += Double(element.specialPrice)
            }
        }

        arrData.append(ProductCartAddOnsModel(productName: "Amount Payable", price: String(format: "₹ %@", finalAmountPayable.cleanForPrice )))

        return (arrData, finalAmountPayable)
    }

    // MARK: addToCartSimpleOrVirtualProductForCustomer
    func addToCartSimpleOrVirtualProductForCustomer() {
        if let object = UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDMine.Response.self, forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart) {

            if (modelTopHeaderData?.isProductSelected == false) {

                let model = ProductModel(productId: modelTopHeaderData?.productId ?? 0, productName: modelTopHeaderData?.productName ?? "", price: 0 / 0, specialPrice: 0.0, reviewCount: "0", ratingPercentage: 0.0, showCheckBox: true, offerPercentage: "0", isFavourite: false, strImage: "", sku: (modelTopHeaderData?.sku ?? ""), isProductSelected: false, type_id: modelTopHeaderData?.type_id ?? "")
                arrayOFSelectedFrequentlyBought.append(model)

            }
            countOfAddProductRequestGuestOrCustomer = arrayOFSelectedFrequentlyBought.count
            for (_, element) in arrayOFSelectedFrequentlyBought.enumerated() {
                callAddToCartAPIMine(quote_Id: object.data?.quote_id ?? 0, skuu: element.sku, quantityy: 1)
            }

        } else {
            callQuoteIdMineAPI()
            if let object = UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDMine.Response.self, forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart) {
                if (modelTopHeaderData?.isProductSelected == false) {
                    let model = ProductModel(productId: modelTopHeaderData?.productId ?? 0, productName: modelTopHeaderData?.productName ?? "", price: 0 / 0, specialPrice: 0.0, reviewCount: "0", ratingPercentage: 0.0, showCheckBox: true, offerPercentage: "0", isFavourite: false, strImage: "", sku: (modelTopHeaderData?.sku ?? ""), isProductSelected: false, type_id: modelTopHeaderData?.type_id ?? "")
                    arrayOFSelectedFrequentlyBought.append(model)

                }
                countOfAddProductRequestGuestOrCustomer = arrayOFSelectedFrequentlyBought.count
                for (_, element) in arrayOFSelectedFrequentlyBought.enumerated() {
                    callAddToCartAPIMine(quote_Id: object.data?.quote_id ?? 0, skuu: element.sku, quantityy: 1)
                }

            }
        }

    }

    // MARK: addToCartSimpleOrVirtualProductForGuest
    func addToCartSimpleOrVirtualProductForGuest() {
        if let object = UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDGuest.Response.self, forKey: UserDefauiltsKeys.k_key_GuestQuoteIdForCart) {

            if (modelTopHeaderData?.isProductSelected == false) {
                let model = ProductModel(productId: modelTopHeaderData?.productId ?? 0, productName: modelTopHeaderData?.productName ?? "", price: 0 / 0, specialPrice: 0.0, reviewCount: "0", ratingPercentage: 0.0, showCheckBox: true, offerPercentage: "0", isFavourite: false, strImage: "", sku: (modelTopHeaderData?.sku ?? ""), isProductSelected: false, type_id: modelTopHeaderData?.type_id ?? "")
                arrayOFSelectedFrequentlyBought.append(model)

            }
            countOfAddProductRequestGuestOrCustomer = arrayOFSelectedFrequentlyBought.count
            for (_, element) in arrayOFSelectedFrequentlyBought.enumerated() {
                callAddToCartAPIGuest(quote_Id: object.data?.quote_id ?? "", skuu: element.sku, quantityy: 1)
            }
        } else {
            callToGetQuoteIdGuestAPI()
        }

    }

    // MARK: addToCartBundleProductForCustomer
    func addToCartBundleProductForCustomer() {
    }
    // MARK: addToCartBundleProductForGuest
    func addToCartBundleProductForGuest() {
    }
    // MARK: addToCartConfigurableProductForCustomer
    func addToCartConfigurableProductForCustomer() {
    }
    // MARK: addToCartConfigurableProductForGuest
    func addToCartConfigurableProductForGuest() {
    }

    // MARK: Configure Sections
    func configureSections() {

        // configureSections
        sections.removeAll()
        createDataForProductDetailsTopHeader()

        sections.append(configureSection(idetifier: .cashbackOffer, items: 2, data: []))
        // sections.append(configureSection(idetifier: .quntity,items: 1, data: []))
        // createDataForSpecifications()
        createDataForAfterTips()

        createDataForFrequentlyBoughtTogether()

        if let productReview = serverDataProductReviews?.data?.all_star_rating, productReview.count > 0 {
            sections.append(configureSection(idetifier: .customer_rating_review, items: 1, data: []))
        }

        if let productReview = serverDataProductReviews?.data?.review_items, productReview.count > 0 {
            sections.append(configureSection(idetifier: .feedbackDetails, items: productReview.count, data: []))
        }
        createDataForCustomerAlsoBought()
        if isuserLoggedIn().status {
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
        var offerPercentage = 0

        if let model = self.serverDataProductDetails {
            for(_, element)in (model.media_gallery_entries?.enumerated())! {
                arrayOfImages.append(String(format: "%@%@", model.extension_attributes?.media_url ?? "", element.file ?? ""))
            }

            if let descriptionData = model.custom_attributes?.first(where: { $0.attribute_code == "description"}) {
                var responseObject = descriptionData.value.description.withoutHtml
                responseObject = responseObject.trim()
                productDescription = responseObject
            }

            // ****** Check for special price
            var isSpecialDateInbetweenTo = true

            if let specialFrom = model.custom_attributes?.filter({ $0.attribute_code == "special_from_date" }), let strDateFrom = specialFrom.first?.value.description,!strDateFrom.isEmpty,!strDateFrom.containsIgnoringCase(find: "null") {
                if Date().description.getFormattedDate() >= strDateFrom.getFormattedDate() {
                    isSpecialDateInbetweenTo = true
                } else {
                    isSpecialDateInbetweenTo = false
                }
            }

            if let specialTo = model.custom_attributes?.filter({ $0.attribute_code == "special_to_date" }), let strDateTo = specialTo.first?.value.description,!strDateTo.isEmpty,!strDateTo.containsIgnoringCase(find: "null") {
                if Date().description.getFormattedDate() <= strDateTo.getFormattedDate() {
                    isSpecialDateInbetweenTo = true
                } else {
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
                offerPercentage = Int(specialPrice.getPercent(price: model.price ?? 0))
            } else {
                specialPrice = model.price ?? 0
            }
          //  specialPrice = (specialPrice != 0) ?  specialPrice :  model.price ?? 0

            /*** For Color And Quanitity ***/


            let colors = createDataForConfigurableProductColor()
            let quantity = createDataForConfigurableProductQuanitity()

            var strReviewCount:String = ""
            if let reviewCount = model.extension_attributes?.total_reviews,reviewCount > 0
            {
                strReviewCount = String(format: " \(SalonServiceSpecifierFormat.reviewFormat) reviews", reviewCount)
            }
            else
            {
                strReviewCount = "\(noReviewsMessage)"
            }
            
            let obj = ProductDetailsModel(imageUrls: arrayOfImages, productId: model.id!, productName: model.name ?? "", sku: model.sku, productDescription: productDescription, price: String(format: " ₹ %@", model.price?.cleanForPrice ?? " ₹ 0"), specialPrice: String(format: " ₹ %@", specialPrice.cleanForPrice ), reviewCount: strReviewCount, ratingPercentage: model.extension_attributes?.rating_percentage ?? 0.0, offerPercentage: String(format: "\(SalonServiceSpecifierFormat.priceFormat)", offerPercentage), productURL: model.extension_attributes?.product_url ?? "", isWishListSelected: model.extension_attributes?.wishlist_flag ?? false, isProductSelected: false, type_id: model.type_id ?? "", colors: colors,quantities: quantity)
            
            modelTopHeaderData = obj
            sections.append(configureSection(idetifier: .productDetails, items: 1, data: []))
        }
        self.updateWishListButtonOnNavigationBar()
        updateBottomAddToCartButton(isStatus: false)
        if (self.serverDataForAllCartItemsGuest?.first(where: { $0.sku == self.modelTopHeaderData?.sku})) != nil {
            self.modelTopHeaderData?.isProductSelected = true
            updateBottomAddToCartButton(isStatus: true)
        }

        if (self.serverDataForAllCartItemsCustomer?.first(where: { $0.sku == self.modelTopHeaderData?.sku})) != nil {
            self.modelTopHeaderData?.isProductSelected = true
            updateBottomAddToCartButton(isStatus: true)
        }

        dispatchGroupDataFeeding.leave()
    }

    // MARK: createDataForSpecifications
    //    func createDataForSpecifications()
    //    {
    //        dispatchGroupDataFeeding.enter()
    //
    //        if(arrayOfSpecificationData.count == 0)
    //        {
    //            if let model = serverDataProductDetails
    //            {
    //                if let descriptionData = model.custom_attributes?.filter({ $0.attribute_code == "specifications"})
    //                {
    //                    let responseObject =  descriptionData.first?.value.description.withoutHtml
    //                    var data = responseObject!.components(separatedBy: "\n")
    //                    data = data.filter { $0 != "" }
    //                    for(_,element)in data.enumerated()
    //                    {
    //                        let menu = ProductSpecificationModel.init(point: element)
    //                        arrayOfSpecificationData.append(menu)
    //                    }
    //
    //                    if !arrayOfSpecificationData.isEmpty
    //                    {
    //                        sections.append(configureSection(idetifier: .specifications,items: arrayOfSpecificationData.count, data: []))
    //                    }
    //                }
    //            }
    //        }
    //        dispatchGroupDataFeeding.leave()
    //
    //    }
    // MARK: createDataForAfterTips
    func createDataForAfterTips() {
        dispatchGroupDataFeeding.enter()

        if(afterTipsData.isEmpty) {
            if let data = serverDataProductDetails?.extension_attributes?.tips_info, !data.isEmpty {
                for(_, element) in (serverDataProductDetails?.extension_attributes?.tips_info?.enumerated())! {
                    if let string = element.value, !string.isEmpty {
                        let responseObject = string
                        var data = responseObject.components(separatedBy: "\r\n")
                        data = data.filter { $0 != "" }
                        let menu = PointsCellData(title: element.label ?? "NA", points: data)
                        afterTipsData.append(menu)
                    }
                }
                if(!afterTipsData.isEmpty) {
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
        if(arrFrequentlyBoughtTogetherData.count == 0) {
            if let frequentBookData = serverDataProductDetails?.product_links?.filter({ $0.link_type == "related"}), !frequentBookData.isEmpty {
                var specialPrice: Double = 0.0
                var offerPercentage: Double = 0
                var productImage: String = ""

                for(_, element) in frequentBookData.enumerated() {

                    // ****** Check for special price
                    var isSpecialDateInbetweenTo = true

                    if let specialFrom = element.custom_attributes?.filter({ $0.attribute_code == "special_from_date" }), let strDateFrom = specialFrom.first?.value.description,!strDateFrom.isEmpty,!strDateFrom.containsIgnoringCase(find: "null") {
                        if Date().description.getFormattedDate() >= strDateFrom.getFormattedDate() {
                            isSpecialDateInbetweenTo = true
                        } else {
                            isSpecialDateInbetweenTo = false
                        }
                    }

                    if let specialTo = element.custom_attributes?.filter({ $0.attribute_code == "special_to_date" }), let strDateTo = specialTo.first?.value.description,!strDateTo.isEmpty,!strDateTo.containsIgnoringCase(find: "null") {
                        if Date().description.getFormattedDate() <= strDateTo.getFormattedDate() {
                            isSpecialDateInbetweenTo = true
                        } else {
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
                    } else {
                        specialPrice = element.price ?? 0
                    }

                    //                    specialPrice = (specialPrice != 0) ?  specialPrice :  element.price ?? 0

                    if let imageUrl = element.custom_attributes?.first(where: { $0.attribute_code == "image" }) {
                        productImage = imageUrl.value.description
                    }

                    //                    productImage = (String(format:"%@%@",element.extension_attributes?.media_url ?? "",element.media_gallery_entries?.first?.file ?? ""))

                    let model = ProductModel(productId: element.id!, productName: element.name ?? "", price: element.price!, specialPrice: specialPrice, reviewCount: String(format: " \(SalonServiceSpecifierFormat.reviewFormat)", element.extension_attributes?.total_reviews ?? "0"), ratingPercentage: element.extension_attributes?.rating_percentage ?? 0.0, showCheckBox: true, offerPercentage: String(format: "\(SalonServiceSpecifierFormat.priceFormat)", offerPercentage), isFavourite: element.extension_attributes?.wishlist_flag ?? false, strImage: productImage, sku: (element.sku ?? ""), isProductSelected: false, type_id: element.type_id ?? "")

                    arrFrequentlyBoughtTogetherData.append(model)

                }
            }
        }

        if(!arrFrequentlyBoughtTogetherData.isEmpty) {
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
            }

            sections.append(configureSection(idetifier: .frequently_bought, items: arrFrequentlyBoughtTogetherData.count, data: arrFrequentlyBoughtTogetherData))
            // updateCartCellHideAndShow()
        }
        dispatchGroupDataFeeding.leave()
    }

    // MARK: createDataForCustomerAlsoBought // upsell
    func createDataForCustomerAlsoBought() {
        dispatchGroupDataFeeding.enter()

        if(arrCustomerAlsoBought.isEmpty) {
            if let customerAlsoBoughtData = serverDataProductDetails?.product_links?.filter({ $0.link_type == "upsell"}), !customerAlsoBoughtData.isEmpty {
                var specialPrice: Double = 0.0
                var offerPercentage: Double = 0
                var productImage: String = ""

                for(_, element) in customerAlsoBoughtData.enumerated() {
                    specialPrice = element.price ?? 0

                    // ****** Check for special price
                    var isSpecialDateInbetweenTo = true

                    if let specialFrom = element.custom_attributes?.filter({ $0.attribute_code == "special_from_date" }), let strDateFrom = specialFrom.first?.value.description,!strDateFrom.isEmpty,!strDateFrom.containsIgnoringCase(find: "null") {
                        if Date().description.getFormattedDate() >= strDateFrom.getFormattedDate() {
                            isSpecialDateInbetweenTo = true
                        } else {
                            isSpecialDateInbetweenTo = false
                        }
                    }

                    if let specialTo = element.custom_attributes?.filter({ $0.attribute_code == "special_to_date" }), let strDateTo = specialTo.first?.value.description,!strDateTo.isEmpty,!strDateTo.containsIgnoringCase(find: "null") {
                        if Date().description.getFormattedDate() <= strDateTo.getFormattedDate() {
                            isSpecialDateInbetweenTo = true
                        } else {
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
                    } else {
                        specialPrice = element.price ?? 0
                    }

                    //specialPrice = (specialPrice != 0) ?  specialPrice :  element.price ?? 0

                    //  productImage = (String(format:"%@%@",element.extension_attributes?.media_url ?? "",element.media_gallery_entries?.first?.file ?? ""))
                    if let imageUrl = element.custom_attributes?.first(where: { $0.attribute_code == "image" }) {
                        productImage = imageUrl.value.description
                    }

                    let model = ProductModel(productId: element.id!, productName: element.name ?? "", price: element.price!, specialPrice: specialPrice, reviewCount: String(format: " \(SalonServiceSpecifierFormat.reviewFormat)", element.extension_attributes?.total_reviews ?? "0"), ratingPercentage: element.extension_attributes?.rating_percentage ?? 0.0, showCheckBox: false, offerPercentage: String(format: "\(SalonServiceSpecifierFormat.priceFormat)", offerPercentage), isFavourite: element.extension_attributes?.wishlist_flag ?? false, strImage: productImage, sku: (element.sku ?? ""), isProductSelected: false, type_id: element.type_id ?? "")

                    arrCustomerAlsoBought.append(model)

                }
                if(!arrCustomerAlsoBought.isEmpty) {
                    sections.append(configureSection(idetifier: .customers_also_bought, items: arrCustomerAlsoBought.count, data: arrCustomerAlsoBought))
                }
            }
        }
        dispatchGroupDataFeeding.leave()

    }

    // MARK: createDataForRecentlyViewedProduct
    func createDataForRecentlyViewedProduct() {
        dispatchGroupDataFeeding.enter()

        if(arrRecentlyViewedData.isEmpty ) {
            if let recentlyViewedProducts = self.serverDataProductDetails?.extension_attributes?.recently_viewed_products {
                for model in recentlyViewedProducts {
                    var specialPrice = model.price ?? 0
                    var offerPercentage: Double = 0
                    let isFevo = self.isuserLoggedIn().status ? (model.wishlist_flag ?? false) : false

                    // ****** Check for special price
                    var isSpecialDateInbetweenTo = true

                    if let specialFrom = model.special_from_date {
                        if Date().description.getFormattedDate() >= specialFrom.getFormattedDate() {
                            isSpecialDateInbetweenTo = true
                        } else {
                            isSpecialDateInbetweenTo = false
                        }
                    }

                    if let specialTo = model.special_to_date {
                        if Date().description.getFormattedDate() <= specialTo.getFormattedDate() {
                            isSpecialDateInbetweenTo = true
                        } else {
                            isSpecialDateInbetweenTo = false
                        }
                    }

                    if isSpecialDateInbetweenTo  {
                        if let splPrice = model.special_price, splPrice != 0 {
                            specialPrice = splPrice
                            offerPercentage = specialPrice.getPercent(price: model.price ?? 0)
                        }
                    }

                    let intId: Int64? = Int64(model.id!)
                    arrRecentlyViewedData.append(ProductModel(productId: intId!, productName: model.name ?? "", price: model.price ?? 0, specialPrice: specialPrice, reviewCount: String(format: "\(model.total_reviews ?? 0)"), ratingPercentage: (model.rating_percentage ?? 0.0).getPercentageInFive(), showCheckBox: false, offerPercentage: String(format: "\(SalonServiceSpecifierFormat.priceFormat)", offerPercentage), isFavourite: isFevo, strImage: (model.image ?? ""), sku: (model.sku ?? ""), isProductSelected: false, type_id: model.type_id ?? ""))
                }
                if(!arrRecentlyViewedData.isEmpty) {
                    sections.append(configureSection(idetifier: .recently_viewed, items: arrRecentlyViewedData.count, data: arrRecentlyViewedData))
                }
            }
        }
        dispatchGroupDataFeeding.leave()
        
        
    }
    
    
    //MARK:Update Cell For WishList  Selected And UnSelected WebService Call
    /*  func updateCartCellHideAndShow()  {
     if let i = sections.index(where: { $0.identifier == .cart_calculation }) {
     
     sections.remove(at: i)
     if let i = sections.index(where: { $0.identifier == .frequently_bought }) {
     
     self.productDetailsTableView.reloadData()
     self.productDetailsTableView.selectRow(at: IndexPath.init(row: 0, section: i), animated: true, scrollPosition: .middle)
     }
     }
     
     if let i = sections.index(where: { $0.identifier == .frequently_bought }) {
     
     showAddProductCartSectionOrNot(index: i+1)
     
     }
     
     if let i = sections.index(where: { $0.identifier == .cart_calculation }) {
     
     self.productDetailsTabView.reloadData()
     self.productDetailsTableView.selectRow(at: IndexPath.init(row: 0, section: i), animated: false, scrollPosition: .middle)
     
     }
     }
     //MARK: showAddProductCartSectionOrNot
     func showAddProductCartSectionOrNot(index:Int)  {
     if self.arrFrequentlyBoughtTogetherData.count > 0
     {
     if self.arrFrequentlyBoughtTogetherData.contains(where: { $0.isProductSelected == true })
     {
     sections.insert(configureSection(idetifier: .cart_calculation, items: 1, data:[] ), at:index )
     }
     }
     
     }
     
     
     //MARK: updateFrequentlyBoughtProductsDataCart
     func updateFrequentlyBoughtProductsDataCart(addServiceInYourCartCell:AddServiceInYourCartCell)  {
     
     var intAddOnCount:Int = 0
     var addOnPrice:Double = 0
     if !arrFrequentlyBoughtTogetherData.isEmpty
     {
     for(_,element) in arrFrequentlyBoughtTogetherData.enumerated()
     {
     if (element.isProductSelected == true)
     {
     addOnPrice = addOnPrice + element.specialPrice
     intAddOnCount = intAddOnCount + 1
     }
     }
     
     addServiceInYourCartCell.lblItemValue.text = modelTopHeaderData?.specialPrice
     addServiceInYourCartCell.lblAddons.text = String(format:"%d Add-ons",intAddOnCount)
     addServiceInYourCartCell.lblAddonsValue.text = String(format:"₹ %.1f",addOnPrice)
     addServiceInYourCartCell.lblTotalValue.text = String(format:"₹ %.1f",(addOnPrice + (arrFrequentlyBoughtTogetherData[selectedIndexWishList.row].specialPrice )))
     
     if modelTopHeaderData?.isProductSelected ?? false
     {

    }

    // MARK: Update Cell For WishList  Selected And UnSelected WebService Call
    // MARK: tTogetherData[selectedIndexWishList.row].specialPrice )))

     if modelTopHeaderData?.isProductSelected ?? false {
     addServiceInYourCartCell.btnAddService.setTitle(String(format:"ADD %d PRODUCTS IN YOUR CART",intAddOnCount), for: .normal)
     } else {
     addServiceInYourCartCell.btnAddService.setTitle(String(format:"ADD %d PRODUCTS IN YOUR CART",intAddOnCount + 1), for: .normal)
     }

     }

     }*/

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
                break
            case "2":
                print("\(progressValue.value)")
                cell.progressViewSecond.progress = progressBarFinalValue
                break

            case "3":
                print("\(progressValue.value)")
                cell.progressViewThird.progress = progressBarFinalValue
                break

            case "4":
                print("\(progressValue.value)")
                cell.progressViewFourth.progress = progressBarFinalValue
                break

            case "5":
                print("\(progressValue.value)")
                cell.progressViewFifth.progress = progressBarFinalValue
                break

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

extension ProductDetailsModuleViewController: ProductSelectionDelegate {

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
            if(!arrFrequentlyBoughtTogetherData.isEmpty) {
                let model = arrFrequentlyBoughtTogetherData[indexpath.row]
                if(model.productId > 0 && !model.sku.isEmpty) {
                    let vc = ProductDetailsModuleViewController.instantiate(fromAppStoryboard: .Products)
                    vc.objProductId = model.productId
                    vc.objProductSKU = model.sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }

            }
        case .customers_also_bought:
            if(!arrCustomerAlsoBought.isEmpty) {
                let model = arrCustomerAlsoBought[indexpath.row]
                if(model.productId > 0 && !model.sku.isEmpty) {
                    let vc = ProductDetailsModuleViewController.instantiate(fromAppStoryboard: .Products)
                    vc.objProductId = model.productId
                    vc.objProductSKU = model.sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        case .recently_viewed:
            if(!arrRecentlyViewedData.isEmpty) {
                let model = arrRecentlyViewedData[indexpath.row]
                if(model.productId > 0 && !model.sku.isEmpty) {
                    let vc = ProductDetailsModuleViewController.instantiate(fromAppStoryboard: .Products)
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
        //                self.productDetailsTableView.selectRow(at: IndexPath.init(row: 0, section: 1), animated: false, scrollPosition: .middle)
        //            }
        //        }

    }

    func wishlistStatus(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {
        print("WishList:\(status) || \(identifier.rawValue) || item :\(indexpath.section)")

        selectedIndexWishList = indexpath

        if !isuserLoggedIn().status {
            openLoginWindow()
            return
        }
        switch identifier {
        case .frequently_bought:
            identifierLocal = SectionIdentifier.frequently_bought
            let model = arrFrequentlyBoughtTogetherData[indexpath.row]
            model.isFavourite ? removeFromWishListAPI(productId: model.productId) : addToWishListAPI(productId: model.productId)
        case .customers_also_bought:
            identifierLocal = SectionIdentifier.customers_also_bought
            let model = arrCustomerAlsoBought[indexpath.row]
            model.isFavourite ? removeFromWishListAPI(productId: model.productId) : addToWishListAPI(productId: model.productId)
        case .recently_viewed:
            identifierLocal = SectionIdentifier.recently_viewed
            let model = arrRecentlyViewedData[indexpath.row]
            model.isFavourite ? removeFromWishListAPI(productId: model.productId) : addToWishListAPI(productId: model.productId)
        default:
            break
        }

    }
    // MARK: updateCell
    func updateCellForWishList(status: Bool) {

        let cell: ProductsCollectionCell = self.productDetailsTableView.cellForRow(at: IndexPath(row: self.identifierLocal == .frequently_bought ? 1 : 0, section: self.selectedIndexWishList.section)) as! ProductsCollectionCell
        if let productCell = cell.productCollectionView.cellForItem(at: IndexPath(row: self.selectedIndexWishList.row, section: 0)) as? TrendingProductsCell {

            switch self.identifierLocal {
            case .frequently_bought:
                let model = arrFrequentlyBoughtTogetherData[selectedIndexWishList.row]
                updateWishListFlagFrequentlyBought(status: status, productCell: productCell, cell: cell)
                arrCustomerAlsoBought.count > 0 ? updateOtherCellIncaseSameProductInOtherSection(identifier: .customers_also_bought, model: model, status: status): nil
                arrRecentlyViewedData.count > 0 ? updateOtherCellIncaseSameProductInOtherSection(identifier: .recently_viewed, model: model, status: status): nil
            case .customers_also_bought:
                let model = arrCustomerAlsoBought[selectedIndexWishList.row]
                updateWishListFlagCustomerAlsoBought(status: status, productCell: productCell, cell: cell)
                arrFrequentlyBoughtTogetherData.count > 0 ? updateOtherCellIncaseSameProductInOtherSection(identifier: .frequently_bought, model: model, status: status): nil
                arrRecentlyViewedData.count > 0 ? updateOtherCellIncaseSameProductInOtherSection(identifier: .recently_viewed, model: model, status: status): nil

            case .recently_viewed:
                let model = arrRecentlyViewedData[selectedIndexWishList.row]
                updateWishListFlagRecentlyViewed(status: status, productCell: productCell, cell: cell)
                arrFrequentlyBoughtTogetherData.count > 0 ? updateOtherCellIncaseSameProductInOtherSection(identifier: .frequently_bought, model: model, status: status): nil
                arrCustomerAlsoBought.count > 0 ? updateOtherCellIncaseSameProductInOtherSection(identifier: .customers_also_bought, model: model, status: status): nil

            default:
                break
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
        isuserLoggedIn().status == true ? checkBoxSelectionForCustomer(status: status, indexpath: indexpath, identifier: identifierLocal) : checkBoxSelectionForGuest(status: status, indexpath: indexpath, identifier: identifierLocal)
        btnTotalPrice.setTitle(String(format: "₹ %@ >", createDataForBottomMoreItemsWithProduct().1.cleanForPrice), for: .normal)

    }

    func checkBoxSelectionForGuest(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {
        let cell: ProductsCollectionCell = self.productDetailsTableView.cellForRow(at: IndexPath(row: self.identifierLocal == .frequently_bought ? 1 : 0, section: self.selectedIndexWishList.section)) as! ProductsCollectionCell
        if let productCell = cell.productCollectionView.cellForItem(at: IndexPath(row: self.selectedIndexWishList.row, section: 0)) as? TrendingProductsCell {
            if(!arrFrequentlyBoughtTogetherData.isEmpty) {
                let status: Bool = arrFrequentlyBoughtTogetherData[indexpath.row].isProductSelected
                if let containsObj = serverDataForAllCartItemsGuest?.contains(where: { $0.sku == arrFrequentlyBoughtTogetherData[indexpath.row].sku}), containsObj == false {
                    arrFrequentlyBoughtTogetherData[indexpath.row].isProductSelected = status == true ? false : true
                    self.sections[self.selectedIndexWishList.section].data = arrFrequentlyBoughtTogetherData
                    productCell.configureCell(model: self.arrFrequentlyBoughtTogetherData[self.selectedIndexWishList.row])
                    cell.configuration.data = self.arrFrequentlyBoughtTogetherData[self.selectedIndexWishList.row]
                    // updateCartCellHideAndShow()

                    arrFrequentlyBoughtTogetherData[indexpath.row].isProductSelected == true ?arrayOFSelectedFrequentlyBought.append(arrFrequentlyBoughtTogetherData[indexpath.row]) : arrayOFSelectedFrequentlyBought.removeAll {$0.sku == arrFrequentlyBoughtTogetherData[indexpath.row].sku}

                    updateBottomAddToCartButton(isStatus: arrayOFSelectedFrequentlyBought.count > 0 ? false : modelTopHeaderData?.isProductSelected == true ? true : false )
                    totalPriceView.isHidden = arrayOFSelectedFrequentlyBought.count > 0 ? false : true
                }
            }
        }
    }
    func checkBoxSelectionForCustomer(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {
        let cell: ProductsCollectionCell = self.productDetailsTableView.cellForRow(at: IndexPath(row: self.identifierLocal == .frequently_bought ? 1 : 0, section: self.selectedIndexWishList.section)) as! ProductsCollectionCell
        if let productCell = cell.productCollectionView.cellForItem(at: IndexPath(row: self.selectedIndexWishList.row, section: 0)) as? TrendingProductsCell {
            if(!arrFrequentlyBoughtTogetherData.isEmpty) {
                let status: Bool = arrFrequentlyBoughtTogetherData[indexpath.row].isProductSelected
                if let containsObj = serverDataForAllCartItemsCustomer?.contains(where: { $0.sku == arrFrequentlyBoughtTogetherData[indexpath.row].sku}), containsObj == false {
                    arrFrequentlyBoughtTogetherData[indexpath.row].isProductSelected = status == true ? false : true
                    self.sections[self.selectedIndexWishList.section].data = arrFrequentlyBoughtTogetherData
                    productCell.configureCell(model: self.arrFrequentlyBoughtTogetherData[self.selectedIndexWishList.row])
                    cell.configuration.data = self.arrFrequentlyBoughtTogetherData[self.selectedIndexWishList.row]
                    // updateCartCellHideAndShow()
                    arrFrequentlyBoughtTogetherData[indexpath.row].isProductSelected == true ?arrayOFSelectedFrequentlyBought.append(arrFrequentlyBoughtTogetherData[indexpath.row]) : arrayOFSelectedFrequentlyBought.removeAll {$0.sku == arrFrequentlyBoughtTogetherData[indexpath.row].sku}
                    updateBottomAddToCartButton(isStatus: arrayOFSelectedFrequentlyBought.count > 0 ? false : modelTopHeaderData?.isProductSelected == true ? true : false )
                    totalPriceView.isHidden = arrayOFSelectedFrequentlyBought.count > 0 ? false : true
                }
            }
        }
    }

}

extension ProductDetailsModuleViewController: HeaderDelegate {

    func actionViewAll(identifier: SectionIdentifier) {
        print("ViewAllAction : \(identifier.rawValue)")
        switch identifier {
        case .customer_rating_review:
            let vc = AllReviewsVC.instantiate(fromAppStoryboard: .Products)
            self.navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
}

extension ProductDetailsModuleViewController: ProductDelegates {
    
    func actionColorSelection(indexPath: IndexPath, color: ProductConfigurableColorQuanity) {
        print("Selected Color Index:\(indexPath.row)")
    }
    
    func actionQuantitySelection(indexPath: IndexPath, quantity: ProductConfigurableColorQuanity) {
        print("Selected Quantity Index:\(indexPath.row)")
    }


    func optionsBeTheFirstToReview(){
        if  isuserLoggedIn().status {
            let vc = RateTheProductVC.instantiate(fromAppStoryboard: .Products)
            self.view.alpha = screenPopUpAlpha
            self.appDelegate.window?.rootViewController!.present(vc, animated: true, completion: {
                vc.lblProductName.text = self.modelTopHeaderData?.productName ?? ""
                vc.productImageURL = self.modelTopHeaderData?.imageUrls.first ?? ""
                vc.product_id = self.modelTopHeaderData?.productId ?? 0
            })
            vc.onDoneBlock = { [unowned self] result in
                self.view.alpha = 1.0
            } }
        else { openLoginWindow() }
    }

    func selectedProduct(indexPath: IndexPath) {
        print("Selected Product : \(indexPath.row)")
    }
}

extension ProductDetailsModuleViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = self.sections[section]

        if data.identifier == .frequently_bought {
            return 2
        } else if data.identifier == .frequently_bought {
            return 2
        } else if data.identifier == .customers_also_bought {
            return 1
        } else if data.identifier == .recently_viewed {
            return 1
        } else if data.identifier == .additionalDetails {

            return afterTipsData[selectedAdditionalDetailsCell].points.count + 1

        }
        return data.items
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let data = self.sections[indexPath.section]

        if data.identifier == .productDetails {
            guard let cell: ProductDetailsCell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailsCell", for: indexPath) as? ProductDetailsCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
           // cell.colorPickerView.isHidden = true
            cell.delegate = self
//            if let arrayOfData = serverDataProductDetails?.extension_attributes?.configurable_subproduct_options, !arrayOfData.isEmpty {
//                cell.colorPickerView.isHidden = false
//
//            }
            cell.configureCell(model: modelTopHeaderData!)
            return cell

        } else if data.identifier == .cashbackOffer {
            guard let cell: CashbackOfferCell = tableView.dequeueReusableCell(withIdentifier: "CashbackOfferCell", for: indexPath) as? CashbackOfferCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell

        } else if data.identifier == .quntity {
            guard let cell: ProductQuantityCell = tableView.dequeueReusableCell(withIdentifier: "ProductQuantityCell", for: indexPath) as? ProductQuantityCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell

        } else if data.identifier == .additionalDetails {
            if indexPath.row == 0 {
                guard let cell: ProductsCollectionCell = tableView.dequeueReusableCell(withIdentifier: "ProductsCollectionCell", for: indexPath) as? ProductsCollectionCell else {
                    return UITableViewCell()
                }
                cell.tableViewIndexPath = indexPath
                cell.selectionDelegate = self
                cell.hideCheckBox = true
                cell.addSectionSpacing = is_iPAD ? 0 : 0
                cell.selectedMenuCell = selectedAdditionalDetailsCell
                cell.configureCollectionView(configuration: data, scrollDirection: .horizontal)
                cell.selectionStyle = .none
                return cell
            } else {
                guard let cell: PointsCell = tableView.dequeueReusableCell(withIdentifier: "PointsCell") as? PointsCell else {
                    return UITableViewCell()
                }
                cell.titleLabel.text = afterTipsData[selectedAdditionalDetailsCell].points[indexPath.row - 1]
                print("IndexAtCell:\(selectedAdditionalDetailsCell)")

                cell.selectionStyle = .none
                return cell
            }

        }
            /*else if data.identifier == .specifications{
             let cell:ProductSpcificationCell = tableView.dequeueReusableCell(withIdentifier: "ProductSpcificationCell", for: indexPath) as! ProductSpcificationCell
             cell.selectionStyle = .none
             cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
             let model = arrayOfSpecificationData[indexPath.row]
             cell.configureCell(model: model)
             return cell
             
         }*/else if data.identifier == .frequently_bought {
            if indexPath.row == 0 {
                guard let cell: ProductFullCell = tableView.dequeueReusableCell(withIdentifier: "ProductFullCell", for: indexPath) as? ProductFullCell else {
                    return UITableViewCell()
                }
                let modelObj = ProductFullModel(productName: modelTopHeaderData?.productName ?? "", productPrice: modelTopHeaderData?.specialPrice ?? "₹ 0", imageUrl: modelTopHeaderData?.imageUrls.first ?? "")
                cell.configureCell(model: modelObj)
                cell.selectionStyle = .none
                return cell
            } else {
                guard let cell: ProductsCollectionCell = tableView.dequeueReusableCell(withIdentifier: "ProductsCollectionCell", for: indexPath) as? ProductsCollectionCell else {
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
            //            guard let cell:AddServiceInYourCartCell = tableView.dequeueReusableCell(withIdentifier: "AddServiceInYourCartCell", for: indexPath) as? AddServiceInYourCartCell else{
            //                return UITableViewCell()
            //            }
            //            cell.delegate = self
            //            updateFrequentlyBoughtProductsDataCart(addServiceInYourCartCell: cell)
            //            cell.selectionStyle = .none
            //            return cell
            //
            //        }
        else if data.identifier == .customer_rating_review {
            guard let cell: CustomerRatingAndReviewCell = tableView.dequeueReusableCell(withIdentifier: "CustomerRatingAndReviewCell", for: indexPath) as? CustomerRatingAndReviewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.delegate = self
            setValuesForCutomerRatingsAndReviews(cell: cell)
            return cell

        } else if data.identifier == .feedbackDetails {
            guard let cell: ReviewThumpsUpDownCell = tableView.dequeueReusableCell(withIdentifier: "ReviewThumpsUpDownCell", for: indexPath) as? ReviewThumpsUpDownCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            setValuesForCutomerFeedBack(indexPath: indexPath, cell: cell)
            return cell

        } else {

            guard let cell: ProductsCollectionCell = tableView.dequeueReusableCell(withIdentifier: "ProductsCollectionCell", for: indexPath) as? ProductsCollectionCell else {
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

        let data = self.sections[section]

        if !data.showHeader {
            return nil
        }

        if data.identifier == .new_arrivals {
            guard let cell: HeaderViewWithSubTitleCell = tableView.dequeueReusableCell(withIdentifier: "HeaderViewWithSubTitleCell") as? HeaderViewWithSubTitleCell else {
                return UITableViewCell()
            }
            cell.titleLabel.text = data.title
            cell.subTitleLabel.text = data.subTitle
            cell.titleLabel.font = data.textFont
            cell.subTitleLabel.font = data.textFont
            cell.btnViewAll.isHidden = true
            cell.identifier = data.identifier
            cell.delegate = self
            return cell

        } else {
            guard let cell: HeaderViewWithTitleCell = tableView.dequeueReusableCell(withIdentifier: "HeaderViewWithTitleCell") as? HeaderViewWithTitleCell else {
                return UITableViewCell()
            }
            cell.titleLabel.text = data.title
            cell.titleLabel.font = data.textFont
            cell.viewAllButton.isHidden = true
            cell.identifier = data.identifier
            cell.delegate = self

            if data.identifier == .customer_rating_review {
                cell.viewAllButton.isHidden = (self.serverDataProductReviews?.data?.review_items?.count)!  > 0 ? false : true
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

                if data.items % 2 == 0 {
                    height = (data.cellHeight + bottomMargin) * CGFloat((Int(data.items / 2)))
                } else {
                    height = (data.cellHeight + bottomMargin) * (CGFloat((Int(data.items / 2) + 1)))
                }
                return height//data.cellHeight
            }
        } else if data.identifier == .recently_viewed || data.identifier == .customers_also_bought {
            return data.cellHeight
        } else if data.identifier == .additionalDetails, indexPath.row == 0 {
            return data.cellHeight
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
        //let data = sections[indexPath.section]
    }

}

extension ProductDetailsModuleViewController {

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
extension ProductDetailsModuleViewController: LoginRegisterDelegate {
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
extension ProductDetailsModuleViewController: AddServiceInYourCartCellCellDelegate {
    func addAdditionalService(indexPath: IndexPath) {
        print("addAction Clicked Index \(indexPath)")

    }
}
// MARK: CustomerRatingReviewCellDelegate
extension ProductDetailsModuleViewController: CustomerRatingReviewCellDelegate {
    func actionToRateProductOrService() {

        if  isuserLoggedIn().status {
            let vc = RateTheProductVC.instantiate(fromAppStoryboard: .Products)
            self.view.alpha = screenPopUpAlpha
            self.appDelegate.window?.rootViewController!.present(vc, animated: true, completion: {
                vc.lblProductName.text = self.modelTopHeaderData?.productName ?? ""
                vc.productImageURL = self.modelTopHeaderData?.imageUrls.first ?? ""
                vc.product_id = self.modelTopHeaderData?.productId ?? 0
            })
            vc.onDoneBlock = { [unowned self] result in
                self.view.alpha = 1.0
            } }
        else { openLoginWindow() }
    }
    
}
// MARK: Call Webservice
extension ProductDetailsModuleViewController {
    // MARK: callProductDetailsAPI
    func callProductDetailsAPI() {

        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()

        var queryString = ""
        let productSKU = objProductSKU ?? ""//"L-INOA200ML"

        queryString += String(format: "%@?", productSKU)

        if  let userSelectionForService = GenericClass.sharedInstance.getSalonId(), userSelectionForService != "0"   {
            queryString += String(format: "salon_id=%@", userSelectionForService)
        }

        if  isuserLoggedIn().status {
                queryString += String(format: "&customer_id=%@&", isuserLoggedIn().customerId)
        }
        let request = ServiceDetailModule.ServiceDetails.Request(requestedParameters: queryString)
        interactor?.doGetRequestWithParameter(request: request, method: HTTPMethod.get)
    }

    // MARK: callProductReviewsAPI
    func callProductReviewsAPI() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()

        let request = ServiceDetailModule.ServiceDetails.ProductReviewRequest(product_id: String(format: "%d", objProductId!), limit: maxlimitToProductQuantity)
        interactor?.doPostRequestProductReviews(request: request, method: HTTPMethod.post)
    }

    // MARK: callRecentlyViewProductsAPI
    //    func callRecentlyViewProductsAPI()
    //    {
    //        EZLoadingActivity.show("Loading...", disableUI: true)
    //        dispatchGroup.enter()
    //        let request = ProductDetailsModule.RecentlyViewedProducts.Request.init(customer_id: GenericClass.sharedInstance.getCustomerId().toString, limit: 5)
    //        interactor?.doPostRequestRecentlyViewedProducts(request: request, method: HTTPMethod.post)
    //    }
    //

    // MARK: API Call ADD TO WishList
    func addToWishListAPI(productId: Int64) {
        var arrayOfWishList  = [HairTreatmentModule.Something.Wishlist_item]()
        let wishListItem = HairTreatmentModule.Something.Wishlist_item(product: productId, qty: 1)
        arrayOfWishList.append(wishListItem)

        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()

        let request = HairTreatmentModule.Something.AddToWishListRequest(customer_id: GenericClass.sharedInstance.getCustomerId().toString, wishlist_item: arrayOfWishList)
        interactor?.doPostRequestAddToWishList(request: request, method: HTTPMethod.post, accessToken: isuserLoggedIn().accessToken)
    }
    // MARK: API Call REMOVE FROM WishList
    func removeFromWishListAPI(productId: Int64) {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()

        let request = HairTreatmentModule.Something.RemoveFromWishListRequest(customer_id: GenericClass.sharedInstance.getCustomerId().toString, product_id: productId)
        interactor?.doPostRequestRemoveFromWishList(request: request, method: HTTPMethod.post, accessToken: isuserLoggedIn().accessToken)
    }

    /**Add To Cart API's Start*/
    // MARK: API callQuoteIdAPI
    func callQuoteIdMineAPI() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        let request = ProductDetailsModule.GetQuoteIDMine.Request()
        interactor?.doPostRequestGetQuoteIdMine(request: request, accessToken: self.isuserLoggedIn().accessToken)
    }
    func callToGetQuoteIdGuestAPI() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        let request = ProductDetailsModule.GetQuoteIDGuest.Request()
        interactor?.doPostRequestGetQuoteIdGuest(request: request, method: HTTPMethod.post)
    }

    // MARK: API callAddToCartAPIMine
    func callAddToCartAPIMine(quote_Id: Int64, skuu: String, quantityy: Int) {

        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        let cartItem = ProductDetailsModule.AddSimpleOrVirtualProductToCartMine.Cart_item(quote_id: quote_Id, sku: skuu, qty: quantityy)
        let request = ProductDetailsModule.AddSimpleOrVirtualProductToCartMine.Request(cart_item: cartItem)
        var salonId: String = ""
        if  let userSalonId = GenericClass.sharedInstance.getSalonId(), userSalonId != "0" {
            salonId = userSalonId
        }

        interactor?.doPostRequestAddSimpleOrVirtualProductToCartMine(request: request, method: HTTPMethod.post, accessToken: isuserLoggedIn().accessToken, customer_id: GenericClass.sharedInstance.getCustomerId().toString, salon_id: salonId )
    }

    // MARK: API callAddToCartAPIGuest
    func callAddToCartAPIGuest(quote_Id: String, skuu: String, quantityy: Int) {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        let cartItem = ProductDetailsModule.AddSimpleOrVirtualProductToCartGuest.Cart_item(quote_id: quote_Id, sku: skuu, qty: quantityy)
        var salonId: String = ""
        if let salonid = GenericClass.sharedInstance.getSalonId(), salonid != "0" {
            salonId = salonid
        }
        let request = ProductDetailsModule.AddSimpleOrVirtualProductToCartGuest.Request(cart_item: cartItem, salon_id: salonId)
        interactor?.doPostRequestAddSimpleOrVirtualProductToCartGuest(request: request, method: HTTPMethod.post)
    }
    func getAllCartItemsAPIGuest() {

        if let object = UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDGuest.Response.self, forKey: UserDefauiltsKeys.k_key_GuestQuoteIdForCart) {

            EZLoadingActivity.show("Loading...", disableUI: true)
            dispatchGroup.enter()
            let request = ProductDetailsModule.GetAllCartsItemGuest.Request(quote_id: object.data?.quote_id ?? "")
            interactor?.doGetRequestToGetAllCartItemsGuest(request: request, method: HTTPMethod.get)
        } else {
            callToGetQuoteIdGuestAPI()
        }

    }
    func getAllCartItemsAPICustomer() {
        // Success Needs To check Static
        if let object = UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDMine.Response.self, forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart) {
            EZLoadingActivity.show("Loading...", disableUI: true)
            dispatchGroup.enter()
            //let request = ProductDetailsModule.GetAllCartsItemCustomer.Request(quote_id: object.data?.quote_id ?? 0, accessToken: self.isuserLoggedIn().accessToken )
             let request = ProductDetailsModule.GetAllCartsItemCustomer.Request(accessToken: self.isuserLoggedIn().accessToken )
            interactor?.doGetRequestToGetAllCartItemsCustomer(request: request, method: HTTPMethod.get)

        } else {
            callQuoteIdMineAPI()
        }
    }

    /** Add To Cart API's End */

    func displaySuccess<T: Decodable>(viewModel: T) {

        DispatchQueue.main.async {[unowned self] in
            if T.self == ServiceDetailModule.ServiceDetails.Response.self {
                // Product Details
                self.parseProductDetailsData(viewModel: viewModel)
            } else if T.self == ServiceDetailModule.ServiceDetails.ProductReviewResponse.self {
                // Products Reviews
                self.parseProductReviewResponse(viewModel: viewModel)
            } else if T.self == ServiceDetailModule.ServiceDetails.RateAServiceResponse.self {
                // Rate a Sevice
                self.parseRateAServiceResponse(viewModel: viewModel)
            }

                //            else if T.self == ProductDetailsModule.RecentlyViewedProducts.Response.self    {
                //                // Recently viewed Products
                //                self.parseRecentlyViewedProducts(viewModel: viewModel)
                //            }
            else if T.self == ProductDetailsModule.GetQuoteIDMine.Response.self {
                // GetQuoteIdMine
                self.parseDataGetQuoteIDMine(viewModel: viewModel)
            } else if T.self == ProductDetailsModule.GetQuoteIDGuest.Response.self {
                // GetQuoteIdGuest
                self.parseDataGetQuoteIDGuest(viewModel: viewModel)
            } else if T.self == ProductDetailsModule.AddSimpleOrVirtualProductToCartMine.Response.self {
                // AddToCartSimpleOrVirtualProductToCartMine
                self.parseAddSimpleOrVirtualProductToCartMine(viewModel: viewModel)
            } else if T.self == ProductDetailsModule.AddSimpleOrVirtualProductToCartGuest.Response.self {
                // AddToCartSimpleOrVirtualProductToCartGuest
                self.parseAddSimpleOrVirtualProductToCartGuest(viewModel: viewModel)
            } else if T.self == HairTreatmentModule.Something.AddToWishListResponse.self {
                // Add To WishList
                self.parseAddToWishListResponse(viewModel: viewModel)
            } else if T.self == HairTreatmentModule.Something.RemoveFromWishListResponse.self {
                // Remove From WishList
                self.parseRemoveFromWishListResponse(viewModel: viewModel)
            }
        }
    }
    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        dispatchGroup.leave()
        self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage!)
    }

    func displaySuccess<T: Decodable>(responseSuccess: [T]) {
        DispatchQueue.main.async {[unowned self] in
            if  [T].self == [ProductDetailsModule.GetAllCartsItemCustomer.Response].self {
                // GetAllCartItemsForCustomer
                self.parseGetAllCartsItemCustomer(responseSuccess: responseSuccess)
            }
            else if [T].self == [ProductDetailsModule.GetAllCartsItemGuest.Response].self {
                // GetAllCartItemsForGuest
                self.parseGetAllCartsItemGuest(responseSuccess: responseSuccess)
            }
        }
    }

    // MARK: Parsing Methods
    func parseProductDetailsData<T: Decodable>(viewModel: T) {
        let obj: ServiceDetailModule.ServiceDetails.Response = viewModel as! ServiceDetailModule.ServiceDetails.Response
        self.serverDataProductDetails = obj
        self.dispatchGroup.leave()
    }

    func parseProductReviewResponse<T: Decodable>(viewModel: T) {
        let obj: ServiceDetailModule.ServiceDetails.ProductReviewResponse = viewModel as! ServiceDetailModule.ServiceDetails.ProductReviewResponse
        print("Product review \(obj)")

        if(obj.status == true) {
            self.serverDataProductReviews = obj
        } else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "" )
        }
        self.dispatchGroup.leave()
    }

    func parseRateAServiceResponse<T: Decodable>(viewModel: T) {
        let obj: ServiceDetailModule.ServiceDetails.RateAServiceResponse = viewModel as! ServiceDetailModule.ServiceDetails.RateAServiceResponse
        if(obj.status == true ) {
            self.showAlert(alertTitle: alertTitleSuccess, alertMessage: obj.message ?? "")
        } else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "")
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

    func parseDataGetQuoteIDMine<T: Decodable>(viewModel: T) {
        let obj: ProductDetailsModule.GetQuoteIDMine.Response = viewModel as! ProductDetailsModule.GetQuoteIDMine.Response
        if(obj.status == true) {
            UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart)

            self.getAllCartItemsAPICustomer()
        } else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "")

        }
        EZLoadingActivity.hide()
        self.dispatchGroup.leave()
    }

    func parseDataGetQuoteIDGuest<T: Decodable>(viewModel: T) {
        // GetQuoteIdGuest
        let obj: ProductDetailsModule.GetQuoteIDGuest.Response = viewModel as! ProductDetailsModule.GetQuoteIDGuest.Response
        if(obj.status == true) {
            // Success Needs To check
            UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_key_GuestQuoteIdForCart)
            self.getAllCartItemsAPIGuest()
        } else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "")

        }
        EZLoadingActivity.hide()
        self.dispatchGroup.leave()
    }

    func parseAddSimpleOrVirtualProductToCartMine<T: Decodable>(viewModel: T) {
        let obj: ProductDetailsModule.AddSimpleOrVirtualProductToCartMine.Response = viewModel as! ProductDetailsModule.AddSimpleOrVirtualProductToCartMine.Response
        if let messageObj = obj.message, !messageObj.isEmpty {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "")

        } else {
            // Success Case
            updateBottomAddToCartButton(isStatus: true)
            self.modelTopHeaderData?.isProductSelected = true
            if let row = arrFrequentlyBoughtTogetherData.index(where: {$0.sku == obj.sku}) {
                arrFrequentlyBoughtTogetherData[row].isProductSelected = true
            }
            if(!arrayOFSelectedFrequentlyBought.isEmpty) {
                arrayOFSelectedFrequentlyBought.removeAll {$0.sku == obj.sku}
            }
            if (arrayOFSelectedFrequentlyBought.isEmpty) {
                countOfAddProductRequestGuestOrCustomer > 1 ? getAllCartItemsAPICustomer() : self.updateCartBadgeNumber(count: (self.serverDataForAllCartItemsCustomer?.count ?? 0) + countOfAddProductRequestGuestOrCustomer)
            }

        }
        EZLoadingActivity.hide()
        self.dispatchGroup.leave()
    }
    func parseAddSimpleOrVirtualProductToCartGuest<T: Decodable>(viewModel: T) {
        let obj: ProductDetailsModule.AddSimpleOrVirtualProductToCartGuest.Response = viewModel as! ProductDetailsModule.AddSimpleOrVirtualProductToCartGuest.Response
        if let messageObj = obj.message, !messageObj.isEmpty {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "")

        } else // Success
        {
            updateBottomAddToCartButton(isStatus: true)
            self.modelTopHeaderData?.isProductSelected = true
            if let row = arrFrequentlyBoughtTogetherData.index(where: {$0.sku == obj.sku}) {
                arrFrequentlyBoughtTogetherData[row].isProductSelected = true
            }
            if(!arrayOFSelectedFrequentlyBought.isEmpty) {
                arrayOFSelectedFrequentlyBought.removeAll {$0.sku == obj.sku}
            }
            if (arrayOFSelectedFrequentlyBought.isEmpty) {
                countOfAddProductRequestGuestOrCustomer > 1 ? getAllCartItemsAPIGuest() : self.updateCartBadgeNumber(count: (self.serverDataForAllCartItemsGuest?.count ?? 0) + countOfAddProductRequestGuestOrCustomer)
            }
        }
        EZLoadingActivity.hide()
        self.dispatchGroup.leave()
    }
   

    func parseAddToWishListResponse<T: Decodable>(viewModel: T) {
        let obj: HairTreatmentModule.Something.AddToWishListResponse = viewModel as! HairTreatmentModule.Something.AddToWishListResponse
        if(obj.status == true) {
            if self.identifierLocal == .parentVC {
                self.modelTopHeaderData?.isWishListSelected = true
                GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(self.modelTopHeaderData!.productId)", changedState: true))
            } else {
                self.updateCellForWishList(status: true)
            }
            self.showToast(alertTitle: alertTitleSuccess, message: obj.message, seconds: toastMessageDuration)
        } else {
            self.showToast(alertTitle: alertTitle, message: obj.message, seconds: toastMessageDuration)
        }
        EZLoadingActivity.hide()
        self.updateWishListButtonOnNavigationBar()
        self.dispatchGroup.leave()
    }
    func parseRemoveFromWishListResponse<T: Decodable>(viewModel: T) {
        let obj: HairTreatmentModule.Something.RemoveFromWishListResponse = viewModel as! HairTreatmentModule.Something.RemoveFromWishListResponse
        if(obj.status == true) {

            if self.identifierLocal == .parentVC {
                self.modelTopHeaderData?.isWishListSelected = false
                GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(self.modelTopHeaderData!.productId)", changedState: false))

            } else {
                self.updateCellForWishList(status: false)
            }
            self.showToast(alertTitle: alertTitleSuccess, message: obj.message, seconds: toastMessageDuration)
        } else {
            self.showToast(alertTitle: alertTitle, message: obj.message, seconds: toastMessageDuration)
        }
        EZLoadingActivity.hide()
        self.updateWishListButtonOnNavigationBar()
        self.dispatchGroup.leave()
    }

    func parseGetAllCartsItemCustomer<T: Decodable>(responseSuccess: [T]) {
        // GetAllCartItemsForCustomer
        if  let responseObj: [ProductDetailsModule.GetAllCartsItemCustomer.Response] = responseSuccess as? [ProductDetailsModule.GetAllCartsItemCustomer.Response] {
            self.serverDataForAllCartItemsCustomer = responseObj
            self.updateCartBadgeNumber(count: self.serverDataForAllCartItemsCustomer?.count ?? 0)
        } else {
            self.showAlert(alertTitle: alertTitle, alertMessage: GenericError)

        }
        EZLoadingActivity.hide()
        self.dispatchGroup.leave()

    }
    
    func parseGetAllCartsItemGuest<T: Decodable>(responseSuccess: [T]) {
        
        
        if  let responseObj: [ProductDetailsModule.GetAllCartsItemGuest.Response] = responseSuccess as? [ProductDetailsModule.GetAllCartsItemGuest.Response] {
            self.serverDataForAllCartItemsGuest = responseObj
            updateCartBadgeNumber(count: self.serverDataForAllCartItemsGuest?.count ?? 0)
            
        }else {self.showAlert(alertTitle: alertTitle, alertMessage: GenericError)}
        
        EZLoadingActivity.hide()
        self.dispatchGroup.leave()
        
    }

}
