//
//  ProductListingModuleViewController.swift
//  EnrichSalon
//

import UIKit
protocol ProductListingModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
}

// MARK: -
class ProductListingModuleViewController: UIViewController, ProductListingModuleDisplayLogic {
    @IBOutlet weak private var productsCollectionView: UICollectionView!
    @IBOutlet weak private var btnFilter: UIButton!
    @IBOutlet weak private var btnSort: UIButton!

    var arrfiltersData = [HairServiceModule.Something.Filters]()
    var interactor: ProductListingModuleBusinessLogic?

    var modelDataForListing = ListingDataModel(category_id: nil, gender: nil, salon_id: nil, brand_unit: nil, is_trending: nil, hair_type: nil, is_newArrival: false)
    var sortSelectedIndex = -1

    var arrItems: [HairTreatmentModule.Something.Items]?
    private let dispatchGroup = DispatchGroup()

    var fevoSelectedIndex = 0

    var currentPage = 1
    var totalItemsCount: Int = 0
    var isFilterApplied = false

    var isBestsellerProducts = false

    var strTitle = "Products"
    var strTypeCategory = "hair_type"

    // MARK: - Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Setup
    private func setup() {
        let viewController = self
        let interactor = ProductListingModuleInteractor()
        let presenter = ProductListingModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
        showNavigationBarRigtButtons()
    }

    // MARK: - View lifecycle    
    override func viewDidLoad() {
        super.viewDidLoad()
        productsCollectionView.register(UINib(nibName: "TrendingProductsCell", bundle: nil), forCellWithReuseIdentifier: "TrendingProductsCell")
        btnFilter.isHidden = arrfiltersData.isEmpty ? true : false

        callProductListing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
        self.navigationController?.navigationBar.isHidden = false
        self.view.alpha = 1.0
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationItem.setHidesBackButton(false, animated: false)
        self.navigationController?.addCustomBackButton(title: strTitle)
        checkFevoriteListInAll()
        if (isuserLoggedIn().status) {
            getAllCartItemsAPICustomer()
        } else {
            getAllCartItemsAPIGuest()
        }
    }

    func checkFevoriteListInAll() {
        let arrObject = GenericClass.sharedInstance.getFevoriteProductSet()
        for model in arrObject {
            if let row = self.arrItems?.firstIndex(where: {"\($0.id!)" == model.productId!}) {
                arrItems?[row].extension_attributes?.wishlist_flag = model.changedState!
                self.productsCollectionView.reloadData()
            }
        }
    }

    // MARK: - Top Navigation Bar And  Actions
    func showNavigationBarRigtButtons() {
        self.navigationItem.setHidesBackButton(false, animated: false)
        let searchImg = UIImage(named: "searchImg")!
        let cartImg = UIImage(named: "cartTab")!

        let searchButton = UIBarButtonItem(image: searchImg, style: .plain, target: self, action: #selector(didTapSearchButton))
        searchButton.tintColor = UIColor.black

        let cartBtn = UIBarButtonItem(image: cartImg, style: .plain, target: self, action: #selector(didTapCartButton))
        searchButton.tintColor = UIColor.black

        navigationItem.title = ""
        navigationItem.rightBarButtonItems = [cartBtn, searchButton]
    }

    @objc func didTapCartButton() {
        // Redirect on cart screen
        pushToCartView()
    }

    @objc func didTapSearchButton() {
        let vc = ProductListingSearchViewController.instantiate(fromAppStoryboard: .Products)
        vc.category_id = modelDataForListing.category_id ?? 0
        vc.isBestsellerProducts = self.isBestsellerProducts
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func hideNavigationBarRigtButtons() {
        navigationItem.rightBarButtonItems = []
        self.navigationItem.setHidesBackButton(true, animated: false)

    }
}

// MARK: - Call Webservice
extension ProductListingModuleViewController {
    // -----------------  CALL APIs
    func callProductListing() {
        let query = interactor?.getURLForType(customer_id: GenericClass.sharedInstance.getCustomerId().toDouble, arrSubCat_type: getSortedQueryArray(), pageSize: kProductCountPerPageForListing, currentPageNo: self.currentPage)
        let request = HairTreatmentModule.Something.Request(queryString: query!)
        interactor?.doGetRequestWithParameter(request: request, isBestSeller: isBestsellerProducts)
    }
    // MARK: API callQuoteIdAPI
    func callQuoteIdMineAPI() {
        // EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        let request = ProductDetailsModule.GetQuoteIDMine.Request()
        interactor?.doPostRequestGetQuoteIdMine(request: request, accessToken: self.isuserLoggedIn().accessToken)
    }
    func callToGetQuoteIdGuestAPI() {
        //EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        let request = ProductDetailsModule.GetQuoteIDGuest.Request()
        interactor?.doPostRequestGetQuoteIdGuest(request: request, method: HTTPMethod.post)
    }

    func getAllCartItemsAPIGuest() {

        if let object = UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDGuest.Response.self, forKey: UserDefauiltsKeys.k_key_GuestQuoteIdForCart) {

            //EZLoadingActivity.show("Loading...", disableUI: true)
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
            //            EZLoadingActivity.show("Loading...", disableUI: true)
            dispatchGroup.enter()
            //let request = ProductDetailsModule.GetAllCartsItemCustomer.Request(quote_id: object.data?.quote_id ?? 0, accessToken: self.isuserLoggedIn().accessToken )
            let request = ProductDetailsModule.GetAllCartsItemCustomer.Request(accessToken: self.isuserLoggedIn().accessToken )

            interactor?.doGetRequestToGetAllCartItemsCustomer(request: request, method: HTTPMethod.get)

        } else {
            callQuoteIdMineAPI()
        }
    }

    // -----------------  SUCCESS HANDLING
    func displaySuccess<T: Decodable>(viewModel: T) {
        EZLoadingActivity.hide()
        if let object = viewModel as? HairTreatmentModule.Something.RemoveFromWishListResponse {
            parseResponseRemoveFevoModel(obj: object )
        } else if let object = viewModel as? HairTreatmentModule.Something.AddToWishListResponse {
            parseResponseAddFevoModel(obj: object )
        } else if let object = viewModel as? HairTreatmentModule.Something.Response {
            parseResponseProductListingModel(obj: object)
        } else if T.self == ProductDetailsModule.GetQuoteIDMine.Response.self {
            // GetQuoteIdMine
            self.parseDataGetQuoteIDMine(viewModel: viewModel)
        } else if T.self == ProductDetailsModule.GetQuoteIDGuest.Response.self {
            // GetQuoteIdGuest
            self.parseDataGetQuoteIDGuest(viewModel: viewModel)
        }
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
    func parseResponseProductListingModel(obj: HairTreatmentModule.Something.Response) {

        totalItemsCount = obj.total_count ?? 0
        if (obj.items?.count != 0) {
            arrItems = (arrItems ?? []) + (obj.items ?? [])
        }

        if let arr = arrItems, arr.isEmpty == false {
            currentPage = currentPage + 1
            self.productsCollectionView.reloadData()
        } else {
            self.showToast(alertTitle: "", message: "No products available for this category.", seconds: toastMessageDuration)
             if !isFilterApplied {
                DispatchQueue.main.asyncAfter(deadline: .now() + toastMessageDuration) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    func parseResponseAddFevoModel(obj: HairTreatmentModule.Something.AddToWishListResponse) {

        if let arrItemsObj = arrItems, arrItemsObj.count > 0 {
            var modelFevo = arrItemsObj[fevoSelectedIndex]
            modelFevo.extension_attributes?.wishlist_flag = true
            modelFevo.isWishSelected = true
            arrItems![fevoSelectedIndex] = modelFevo

            GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(modelFevo.id!)", changedState: true))
        }

        // Rate a Sevice
        if(obj.status == true) {
            self.showToast(alertTitle: alertTitleSuccess, message: obj.message, seconds: toastMessageDuration)
        } else {
            self.showToast(alertTitle: alertTitle, message: obj.message, seconds: toastMessageDuration)
        }
        self.dispatchGroup.leave()

    }

    func parseResponseRemoveFevoModel(obj: HairTreatmentModule.Something.RemoveFromWishListResponse) {

        if let arrItemsObj = arrItems, arrItemsObj.count > 0 {
            var modelFevo = arrItemsObj[fevoSelectedIndex]
            modelFevo.isWishSelected = false
            modelFevo.extension_attributes?.wishlist_flag = false
            arrItems![fevoSelectedIndex] = modelFevo

            GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(modelFevo.id!)", changedState: false))
        }

        if(obj.status == true) {
            self.showToast(alertTitle: alertTitleSuccess, message: obj.message, seconds: toastMessageDuration)
        } else {
            self.showToast(alertTitle: alertTitle, message: obj.message, seconds: toastMessageDuration)
        }
        self.dispatchGroup.leave()
    }

    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        DispatchQueue.main.async { [unowned self] in
            self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate & UICollectionViewDelegateFlowLayout
extension ProductListingModuleViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (arrItems ?? []).count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let model = arrItems![indexPath.row]
        guard let cell: TrendingProductsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingProductsCell", for: indexPath) as? TrendingProductsCell else {
            return UICollectionViewCell()
        }
        cell.btnCheckBox.isHidden = true
        cell.delegate = self
        cell.indexPath = indexPath
        cell.configureCell(model: interactor!.getProductModel(element: model, isLogin: self.isuserLoggedIn().status))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = is_iPAD ? 475 : 400
        let width: CGFloat = is_iPAD ? (collectionView.frame.size.width / 3) - 15 : (collectionView.frame.size.width / 2) - 5
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return is_iPAD ? 25 : 15
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let arr = arrItems, arr.count > 0 {
            let model = arr[indexPath.row]
            if let id = model.id, let sku = model.sku {
                let vc = ProductDetailsModuleViewController.instantiate(fromAppStoryboard: .Products)
                vc.objProductId = id
                vc.objProductSKU = sku
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == ((arrItems ?? []).count - 1) && (arrItems ?? []).count < totalItemsCount {
            callProductListing()
        }
    }
}

// MARK: - ProductActionDelegate
extension ProductListingModuleViewController: ProductActionDelegate {

    func actionQunatity(quantity: Int, indexPath: IndexPath) {
        print("quntity:\(quantity)")
    }

    func wishlistStatus(status: Bool, indexPath: IndexPath) {

        if isuserLoggedIn().status {
            fevoSelectedIndex = indexPath.row

            if let arrItemsObj = arrItems, arrItemsObj.count > 0 {
                let modelFevo = arrItemsObj[fevoSelectedIndex]
                if let isFavo = modelFevo.extension_attributes?.wishlist_flag {
                    if isFavo {
                        self.removeFromFavourite(productId: modelFevo.id ?? 0 )
                    } else {
                        self.addToWishListApiCall(productId: modelFevo.id ?? 0)
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                EZLoadingActivity.hide()
                DispatchQueue.main.async {
                    self.productsCollectionView.reloadData()
                }
            }
            return
        }

        //DoLoginPopUpVC
        let vc = DoLoginPopUpVC.instantiate(fromAppStoryboard: .Location)
        vc.delegate = self
        self.view.alpha = screenPopUpAlpha
        self.appDelegate.window?.rootViewController!.present(vc, animated: true, completion: nil)
        vc.onDoneBlock = {[unowned self]  result in
            // Do something
            if(result) {} else {}
            self.view.alpha = 1.0
        }
    }

    func checkboxStatus(status: Bool, indexPath: IndexPath) {
    }

    func addToWishListApiCall(productId: Int64) {
        dispatchGroup.enter()
        var arrayOfWishList  = [HairTreatmentModule.Something.Wishlist_item]()
        let wishListItem = HairTreatmentModule.Something.Wishlist_item(product: productId, qty: 1)
        arrayOfWishList.append(wishListItem)
//                EZLoadingActivity.show("Loading...", disableUI: true)
        let request = HairTreatmentModule.Something.AddToWishListRequest(customer_id: GenericClass.sharedInstance.getCustomerId().toString, wishlist_item: arrayOfWishList)
        interactor?.doPostRequestAddToWishList(request: request, method: HTTPMethod.post, accessToken: isuserLoggedIn().accessToken)
    }

    func removeFromFavourite(productId: Int64) {
        dispatchGroup.enter()
        let request =
            HairTreatmentModule.Something.RemoveFromWishListRequest(customer_id: GenericClass.sharedInstance.getCustomerId().toString, product_id: productId)
        interactor?.doPostRequestRemoveFromWishList(request: request, method: HTTPMethod.post, accessToken: isuserLoggedIn().accessToken)
    }

}

// MARK: - LoginRegisterDelegate
extension ProductListingModuleViewController: LoginRegisterDelegate {
    func doLoginRegister() {
        // Put your code here
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            let vc = LoginModuleVC.instantiate(fromAppStoryboard: .Main)
            let navigationContrl = UINavigationController(rootViewController: vc)
            self.appDelegate.window?.rootViewController!.present(navigationContrl, animated: true, completion: nil)
        }
    }
}

// MARK: - SortSelectionDelegate
extension ProductListingModuleViewController: SortSelectionDelegate {

    @IBAction func actionBtnSort(_ sender: Any) {
        let vc = SortProductViewController.instantiate(fromAppStoryboard: .Products)
        vc.selectedIndex = sortSelectedIndex
        vc.delegate = self
        self.view.alpha = screenPopUpAlpha
        self.appDelegate.window?.rootViewController!.present(vc, animated: true, completion: nil)
    }

    @IBAction func actionBtnFilter(_ sender: Any) {

//        if !self.arrfiltersData.isEmpty {
//            let filterServicesModuleViewController = FilterServicesModuleViewController
//                .instantiate(fromAppStoryboard: .Services)
//
//            filterServicesModuleViewController.arrfitersPassServerData = self.arrfiltersData
//            filterServicesModuleViewController.arrfiltersServerDataLeftTableView = self.arrfiltersData
//
//            self.view.alpha = screenPopUpAlpha
//            self.appDelegate.window?.rootViewController!.present(filterServicesModuleViewController, animated: true, completion: nil)
//            filterServicesModuleViewController.onDoneBlock = { result, filterValues, isFilterClear in
//                self.isFilterApplied = true
//                if(result) { // This is For usee clicked Apply or Close
//                    if(filterValues.count > 0 ) {
//                        self.arrfiltersData = filterValues
//                    }
//                    self.currentPage = 1
//                    self.totalItemsCount = 0
//                    self.arrItems = []
//                    self.productsCollectionView.reloadData()
//                    self.callProductListing()
//                }
//                self.view.alpha = 1.0
//            }
//        }
    }

    func SortSelectedIndex(index: Int) {
        self.view.alpha = 1.0
        currentPage = 1
        totalItemsCount = 0
        sortSelectedIndex = index
        arrItems = []
        productsCollectionView.reloadData()
        callProductListing()
    }

    func CloseSortView() {
        self.view.alpha = 1.0
    }
}

// MARK: - FilterKeys Array
extension ProductListingModuleViewController {

    func parseFilterKeys() -> [FilterKeys] {
        var arrForKeysValues: [FilterKeys] = []

        if let category_id = modelDataForListing.category_id {
            arrForKeysValues.append(FilterKeys(field: "category_id", value: category_id, type: "eq"))
        }

        if let gender = modelDataForListing.gender, gender != 0 {
            arrForKeysValues.append(FilterKeys(field: "gender", value: gender, type: "eq"))
        }

        if let salon_id = modelDataForListing.salon_id, salon_id != 0 {
            arrForKeysValues.append(FilterKeys(field: "salon_id", value: salon_id, type: "finset"))
        }

        if let brand_unit = modelDataForListing.brand_unit {
            arrForKeysValues.append(FilterKeys(field: "brand_unit", value: brand_unit, type: "eq"))
        }

        if let is_trending = modelDataForListing.is_trending {
            let intData: Int64 = is_trending ? 1 : 0
            arrForKeysValues.append(FilterKeys(field: "is_trending", value: intData, type: "eq"))
        }

        if let hair_type = modelDataForListing.hair_type {
            arrForKeysValues.append(FilterKeys(field: strTypeCategory, value: hair_type, type: "eq"))
        }

        if modelDataForListing.is_newArrival == true {
            let strToTodayDate = Date().dayYearMonthDate + " 00-00-00"
            let strFromTodayDate = Date().dayYearMonthDate + " 23-59-59"

            arrForKeysValues.append(FilterKeys(field: "news_from_date", value: strToTodayDate, type: "lteq"))
            arrForKeysValues.append(FilterKeys(field: "news_to_date", value: strFromTodayDate, type: "gteq"))
        }

        return arrForKeysValues
    }

    func getSortedQueryArray() -> [FilterKeys] {
        var arrFinal = getFilterQueryArray()
        if (sortSelectedIndex != -1) {
            switch sortSelectedIndex {
            case SortIndexNames.Popularity.rawValue:
                arrFinal.append(FilterKeys(field: "sort", value: "DESC", type: "popularity"))
            case SortIndexNames.PriccLowtoHigh.rawValue:
                arrFinal.append(FilterKeys(field: "sort", value: "ASC", type: "price"))
            case SortIndexNames.PriceHighttoLow.rawValue:
                arrFinal.append(FilterKeys(field: "sort", value: "DESC", type: "price"))
            case SortIndexNames.Newest.rawValue:
                arrFinal.append(FilterKeys(field: "sort", value: "DESC", type: "entity_id"))
            default: break
            }
        }
        return arrFinal
    }

    func getFilterQueryArray() -> [FilterKeys] {

        var arrParse = parseFilterKeys()

        for values in arrfiltersData {

            let arrVlues: [HairServiceModule.Something.Values]
                = (values.values ?? []).filter {$0.isChildSelected == true && $0.attr_code?.trim() != "price" && $0.attr_code?.trim() != "cat"}
            var arrFilters: [FilterKeys] = []

            // ************  ONLY FOR PRICE
            let arrPrice: [HairServiceModule.Something.Values]
                = (values.values ?? []).filter {$0.isChildSelected == true && $0.attr_code?.trim() == "price"}

            // ************ ONLY FOR FIlter Category
            let arrCategory: [HairServiceModule.Something.Values]
                = (values.values ?? []).filter {$0.isChildSelected == true && $0.attr_code?.trim() == "cat"}

            // Category logic
            if !arrCategory.isEmpty {
                var strIds = ""
                for model in arrCategory {
                    strIds = (strIds.isEmpty) ? "\(model.value ?? "")" : strIds + ",\(model.value ?? "")"
                }
                if let row = arrParse.firstIndex(where: {$0.field == "category_id"}) {
                    arrParse[row] = FilterKeys(field: "category_id", value: strIds, type: "in")
                } else {
                    arrParse.append(FilterKeys(field: "category_id", value: strIds, type: "in"))
                }
            }

            // Price logic
            if !arrPrice.isEmpty {
                var arrfrom: [FilterKeys] = []
                var arrTo: [FilterKeys] = []

                for value in arrPrice {
                    if  let attrCode = value.attr_code?.trim(), !attrCode.isEmpty,
                        let attrValue = value.value?.description.trim(), !attrValue.isEmpty {
                            let arr: Array = attrValue.components(separatedBy: "-")
                            let first_value = (arr.first?.isEmpty)! ? "0" : arr.first
                            let second_value = (arr.last?.isEmpty)! ? "999999" : arr.last
                            arrfrom.append(FilterKeys(field: attrCode, value: first_value, type: "gteq"))
                            arrTo.append(FilterKeys(field: attrCode, value: second_value, type: "lteq"))
                    }
                }
                arrParse.append(FilterKeys(field: "filter", value: arrfrom, type: ""))
                arrParse.append(FilterKeys(field: "filter", value: arrTo, type: ""))
            }

            // ADD OTHER KEYS
            for value in arrVlues {
                if  let attrCode = value.attr_code?.trim(), !attrCode.isEmpty,
                    let attrValue = value.value?.description.trim(), !attrValue.isEmpty {
                    if attrCode.lowercased().contains("color") {
                        arrFilters.append(FilterKeys(field: attrCode, value: attrValue, type: "eq"))
                    } else {
                        arrFilters.append(FilterKeys(field: attrCode, value: attrValue, type: "finset"))
                    }
                }
            }

            if !arrFilters.isEmpty {
                arrParse.append(FilterKeys(field: "filter", value: arrFilters, type: ""))
            }
        }
        arrParse.append(FilterKeys(field: "visibility", value: 4, type: "eq"))

        return arrParse
    }
}

extension ProductListingModuleViewController {
    func parseDataGetQuoteIDMine<T: Decodable>(viewModel: T) {
        let obj: ProductDetailsModule.GetQuoteIDMine.Response = viewModel as! ProductDetailsModule.GetQuoteIDMine.Response
        if(obj.status == true) {
            UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart)

            self.getAllCartItemsAPICustomer()
        } else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "")

        }
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
        self.dispatchGroup.leave()
    }
    
    func parseGetAllCartsItemGuest<T: Decodable>(responseSuccess: [T]) {
        
        if  let responseObj: [ProductDetailsModule.GetAllCartsItemGuest.Response] = responseSuccess as? [ProductDetailsModule.GetAllCartsItemGuest.Response] {
            updateCartBadgeNumber(count: responseObj.count)
            
        }else {self.showAlert(alertTitle: alertTitle, alertMessage: GenericError)}
        
        self.dispatchGroup.leave()
    }
    func parseGetAllCartsItemCustomer<T: Decodable>(responseSuccess: [T]) {
        // GetAllCartItemsForCustomer
        if  let responseObj: [ProductDetailsModule.GetAllCartsItemCustomer.Response] = responseSuccess as? [ProductDetailsModule.GetAllCartsItemCustomer.Response] {
            self.updateCartBadgeNumber(count: responseObj.count)
        } else {
            self.showAlert(alertTitle: alertTitle, alertMessage: GenericError)

        }
        self.dispatchGroup.leave()

    }

    // MARK: updateCartBadgeNumber
    func updateCartBadgeNumber(count: Int) {
        count > 0 ? self.navigationItem.rightBarButtonItems?.first(where: { $0.tag == 0})?.addBadge(number: count) : self.navigationItem.rightBarButtonItems?.first(where: { $0.tag == 0})?.removeBadge()
        count > 0 ? self.appDelegate.customTabbarController.increaseBadge(indexOfTab: 3, num: String(format: "%d", count)) : self.appDelegate.customTabbarController.nilBadge(indexOfTab: 3)

    }
    func pushToCartView() {
//        let cartModuleViewController = CartModuleVC.instantiate(fromAppStoryboard: .HomeLanding)
//        self.navigationController?.isNavigationBarHidden = false
//        self.navigationController?.pushViewController(cartModuleViewController, animated: true)

    }
}
