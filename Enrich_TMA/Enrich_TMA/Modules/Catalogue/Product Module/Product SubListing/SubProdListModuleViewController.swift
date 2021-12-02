//
//  SubProdListModuleViewController.swift
//  EnrichSalon
//

import UIKit

protocol SubProdListModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])

}

class SubProdListModuleViewController: UIViewController {

    @IBOutlet weak private var tblSubProducts: UITableView!
    var interactor: SubProdListModuleBusinessLogic?

    var sections = [SectionConfiguration]()
    var category_type = ""
    var intCategoryId = "3"
    private let dispatchGroup = DispatchGroup()

    var arrGetInsightfulforUI: [GetInsightFulDetails] = []
    var arrBrandforUI: [PopularBranchModel] = []
    //var arrSubCategoryListforUI: [ServiceModel] = []
    var arrHairStyleforUI: [HairstylesModel] = []
    var arrPopularCareProductsforUI: [ProductModel] = []

    var categoryModel = ProductLandingModule.Something.CategoryModel()
    var serverDataProductCategory: ProductLandingModule.Something.ProductCategoryResponse?
    var serverDataSubCategoryTypes: SubProdListModule.Categories.ResponseTypes?

    var indexPathForWishlist = IndexPath()
    var identifierLocal: SectionIdentifier = .parentVC

    var arrFevoriteProducts: [ProductModel] = []
    var isLodingViewFirstTime = true

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
        let interactor = SubProdListModuleInteractor()
        let presenter = SubProdListModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //        hideKeyboardWhenTappedAround()
        showNavigationBarRigtButtons()

        self.tblSubProducts.register(UINib(nibName: "ProductCategoryBackImageCell", bundle: nil), forCellReuseIdentifier: "ProductCategoryBackImageCell")
        self.tblSubProducts.register(UINib(nibName: "ProductCategoryFrontImageCell", bundle: nil), forCellReuseIdentifier: "ProductCategoryFrontImageCell")
        self.tblSubProducts.register(UINib(nibName: "HeaderViewWithTitleCell", bundle: nil), forCellReuseIdentifier: "HeaderViewWithTitleCell")

        self.tblSubProducts.separatorStyle = .none
        self.tblSubProducts.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        self.navigationController?.addCustomBackButton(title: categoryModel.name ?? "")

        intCategoryId = categoryModel.id ?? "3"

        arrPopularCareProductsforUI = interactor!.getPopularProductArray(data: categoryModel)

        getProductCategoriesFromServer()

        dispatchGroup.notify(queue: .main) {[unowned self] in
            self.isLodingViewFirstTime = false
            EZLoadingActivity.hide()
            self.updateUIAfterServerData()
            DispatchQueue.main.async {[unowned self] in
                self.tblSubProducts.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.navigationBar.isHidden = false

        if !GenericClass.sharedInstance.getFevoriteProductSet().isEmpty && !isLodingViewFirstTime {
            arrPopularCareProductsforUI = interactor!.getPopularProductArray(data: categoryModel)
            updateUIAfterServerData()
        }
        if (isuserLoggedIn().status) {
            getAllCartItemsAPICustomer()
        } else {
            getAllCartItemsAPIGuest()
        }
    }

    // MARK: Top Navigation Bar And  Actions
    func showNavigationBarRigtButtons() {
        let searchImg = UIImage(named: "searchImg")!
        let cartImg = UIImage(named: "cartTab")!

        let searchButton = UIBarButtonItem(image: searchImg, style: .plain, target: self, action: #selector(didTapSearchButton))
        searchButton.tintColor = UIColor.black
        searchButton.tag = 1
        let cartBtn = UIBarButtonItem(image: cartImg, style: .plain, target: self, action: #selector(didTapCartButton))
        searchButton.tintColor = UIColor.black
        cartBtn.tag = 0

        navigationItem.title = ""
        navigationItem.rightBarButtonItems = [cartBtn, searchButton]
    }

    @objc func didTapSearchButton() {
    }

    @objc func didTapCartButton() {
        pushToCartView()
    }
}

// MARK: - CALL APIS
extension SubProdListModuleViewController {

    // MARK: This Api response contains : Product Categories
    func getProductCategoriesFromServer() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        let request = ProductLandingModule.Something.ProductCategoryRequest(category_id: intCategoryId, customer_id: GenericClass.sharedInstance.getCustomerId().toString)
        interactor?.doPostRequestProductCategory(request: request, method: HTTPMethod.post)
    }

    // MARK: This Api response contains : Product Categories types
    func getTypeOfCategoriesFromServer() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()

        let request = SubProdListModule.Categories.RequestTypes(category_type: self.category_type)
        interactor?.doPostRequestTypes(request: request, method: HTTPMethod.post)
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
            let request = ProductDetailsModule.GetAllCartsItemCustomer.Request(accessToken: self.isuserLoggedIn().accessToken)

            interactor?.doGetRequestToGetAllCartItemsCustomer(request: request, method: HTTPMethod.get)

        } else {
            callQuoteIdMineAPI()
        }
    }
}

// MARK: - SUCCESS ERROR HANDLING
extension SubProdListModuleViewController: SubProdListModuleDisplayLogic {

    func displaySuccess<T: Decodable>(viewModel: T) {
        DispatchQueue.main.async {[unowned self] in
            EZLoadingActivity.hide()
            // Update UI
            print("\(viewModel)")
            if let object = viewModel as? HairTreatmentModule.Something.RemoveFromWishListResponse {
                self.parseResponseRemoveWishlist(obj: object)
            } else if let object = viewModel as? HairTreatmentModule.Something.AddToWishListResponse {
               self.parseResponseAddWishlist(obj: object)
            } else if let object = viewModel as? SubProdListModule.Categories.ResponseTypes {
                self.parseResponseCategoryTypes(obj: object)
            } else if let object = viewModel as? ProductLandingModule.Something.ProductCategoryResponse {
               self.parseResponseCategories(obj: object)
            } else if T.self == ProductDetailsModule.GetQuoteIDMine.Response.self {
                // GetQuoteIdMine
                self.parseDataGetQuoteIDMine(viewModel: viewModel)
            } else if T.self == ProductDetailsModule.GetQuoteIDGuest.Response.self {
                // GetQuoteIdGuest
                self.parseDataGetQuoteIDGuest(viewModel: viewModel)
            }
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

    func parseResponseCategories(obj: ProductLandingModule.Something.ProductCategoryResponse ) {
        if(obj.status == true) {
            self.serverDataProductCategory = obj
           // self.arrSubCategoryListforUI = self.interactor!.getServiceModel(data: obj)

            if let catData = obj.data, let categoryType = catData.category_type {
                self.category_type = categoryType
                self.getTypeOfCategoriesFromServer()
            }
        } else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj.message )
        }
        self.dispatchGroup.leave()
    }

    func parseResponseCategoryTypes(obj: SubProdListModule.Categories.ResponseTypes) {
        if(obj.status == true) {
            self.serverDataSubCategoryTypes = obj
            self.arrHairStyleforUI = self.interactor!.getCategoryTypeModel(data: obj.data!)
        } else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "Error in response" )
        }
        self.dispatchGroup.leave()
    }

    func parseResponseAddWishlist(obj: HairTreatmentModule.Something.AddToWishListResponse) {
        if(obj.status == true) {
            updateCellForWishList(status: true)
            self.showToast(alertTitle: alertTitleSuccess, message: obj.message, seconds: toastMessageDuration)
        } else {
            self.showToast(alertTitle: alertTitle, message: obj.message, seconds: toastMessageDuration)
        }
        self.dispatchGroup.leave()
    }

    func parseResponseRemoveWishlist(obj: HairTreatmentModule.Something.RemoveFromWishListResponse) {
        if(obj.status == true) {
            updateCellForWishList(status: false)
            self.showToast(alertTitle: alertTitleSuccess, message: obj.message, seconds: toastMessageDuration)
        } else {
            self.showToast(alertTitle: alertTitle, message: obj.message, seconds: toastMessageDuration)
        }
        self.dispatchGroup.leave()
    }

    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        dispatchGroup.leave()
        self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage!)
    }
}

// MARK: - UPDATE UI AND CONFIGURE DATA
extension SubProdListModuleViewController {

    // MARK: updateUIAfterServerData
    func updateUIAfterServerData() {
        // configureSections
        sections.removeAll()

        // SUB-CATEGORY
//        if arrSubCategoryListforUI.count > 0 {
//            sections.append(configureSection(idetifier: .serviceCell, items: arrSubCategoryListforUI.count, data: arrSubCategoryListforUI as Any))
//        }

        // BRANDS
        if arrBrandforUI.count > 0 {
            sections.append(configureSection(idetifier: .popular, items: arrBrandforUI.count, data: arrBrandforUI as Any))
        }

        // HAIRTYPE
        if self.arrHairStyleforUI.count > 0 {
            sections.append(configureSection(idetifier: .shop_by_hairtype, items: self.arrHairStyleforUI.count, data: self.arrHairStyleforUI as Any))
        }

        // Popular Products - NEW PRODUCTS
        if arrPopularCareProductsforUI.count > 0 {
            sections.append(configureSection(idetifier: .new_arrivals, items: arrPopularCareProductsforUI.count, data: arrPopularCareProductsforUI as Any))
        }

        // Get Insghtful - BLOGS
        if arrGetInsightfulforUI.count > 0 {
            sections.append(configureSection(idetifier: .get_insightful, items: (arrGetInsightfulforUI as AnyObject).count, data: arrGetInsightfulforUI))
        }

         DispatchQueue.main.async {[unowned self] in
            self.tblSubProducts.reloadData()
         }
    }

    func configureSection(idetifier: SectionIdentifier, items: Int, data: Any) -> SectionConfiguration {

        let headerHeight: CGFloat = is_iPAD ? 70 : 50
        let leftMargin: CGFloat = is_iPAD ? 25 : 15

        let normalFont = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 30.0 : 20.0)

        switch idetifier {
        case .serviceCell:

            let height: CGFloat = is_iPAD ? 90 : 70
            let width: CGFloat = self.tblSubProducts.frame.width / 2.3

            return SectionConfiguration(title: "", subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: leftMargin, isPagingEnabled: false, textFont: normalFont, textColor: .black, items: items, identifier: idetifier, data: data)

        case .shop_by_hairtype:

            let height: CGFloat = is_iPAD ? 180 : 150
            var width: CGFloat = self.tblSubProducts.frame.width / 6
            width = (width < 90) ? 90 : width

            return SectionConfiguration(title: "Shop by type", subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: false, textFont: normalFont, textColor: .black, items: items, identifier: idetifier, data: data)

        case .popular:

            let height: CGFloat = is_iPAD ? 240 : 200
            let width: CGFloat = is_iPAD ? 192 : 160

            return SectionConfiguration(title: "Shop by brands", subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: normalFont, textColor: .black, items: items, identifier: idetifier, data: data)

        case .new_arrivals:

            let height: CGFloat = is_iPAD ? 475 : 400
            let width: CGFloat = is_iPAD ? ((tblSubProducts.frame.size.width - 100) / 3) : ((tblSubProducts.frame.size.width - 45) / 2)

            return SectionConfiguration(title: "Popular \(categoryModel.name ?? "") products", subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: normalFont, textColor: .black, items: items, identifier: idetifier, data: data)

        case .get_insightful:

            let height: CGFloat = is_iPAD ? 408 : 340
            let width: CGFloat = is_iPAD ? 288 : 240

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: normalFont, textColor: .black, items: items, identifier: idetifier, data: data)

        default :
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: 0, showHeader: false, showFooter: false, headerHeight: 0, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: false, textFont: nil, textColor: UIColor.black, items: 0, identifier: idetifier, data: data)
        }
    }
}

// MARK: - TABLEVIEW DELEGATES
extension SubProdListModuleViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sections[section].identifier == .category {
            return sections[section].items
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let data = self.sections[indexPath.section]
        guard let cell: ProductsCollectionCell = tableView.dequeueReusableCell(withIdentifier: "ProductsCollectionCell", for: indexPath) as? ProductsCollectionCell else {
            return UITableViewCell()
        }
        cell.tableViewIndexPath = indexPath
        cell.selectionDelegate = self
        if data.identifier == .serviceCell {
            cell.configureCollectionView(configuration: data, scrollDirection: .vertical)
        } else {
            cell.configureCollectionView(configuration: data, scrollDirection: .horizontal)
        }
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let data = self.sections[section]

        if !data.showHeader {
            return nil
        }

        guard let cell: HeaderViewWithTitleCell = tableView.dequeueReusableCell(withIdentifier: "HeaderViewWithTitleCell") as? HeaderViewWithTitleCell else {
            return UITableViewCell()
        }
        cell.titleLabel.text = data.title
        cell.titleLabel.font = data.textFont
        cell.viewAllButton.isHidden = true
        if data.identifier == .new_arrivals || data.identifier == .get_insightful {
            cell.viewAllButton.isHidden = false
        }
        cell.identifier = data.identifier
        cell.delegate = self

        if data.identifier == .specifications {
            cell.backgroundColor = UIColor(red: 248 / 255, green: 248 / 255, blue: 248 / 255, alpha: 1.0)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let data = self.sections[section]
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: data.footerHeight))
        return view
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = self.sections[indexPath.section]
        return data.cellHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let data = self.sections[section]
        return data.showHeader ? data.headerHeight : 0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        let data = self.sections[section]
        return data.showFooter ? data.footerHeight : 0
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
        if indexPath.section == 0 {
            if let data = self.serverDataProductCategory?.data, let child = data.children {
                let height = is_iPAD ? 120 : 90
                let count = (child.count % 2 == 0) ? child.count / 2 : (child.count / 2 + 1)
                return CGFloat(count * height)
            }
            return 0
        }
        return self.sections[indexPath.section].cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
    }
}

// MARK: - HANDLE VIEWALL ACTION
extension SubProdListModuleViewController: HeaderDelegate {
    func actionViewAll(identifier: SectionIdentifier) {
        switch identifier {
        case .get_insightful: break
//            let vc = BlogListingModuleViewController.instantiate(fromAppStoryboard: .Blog)
//            self.navigationController?.pushViewController(vc, animated: true)

        case .new_arrivals:
            let vc = ProductListingModuleViewController.instantiate(fromAppStoryboard: .Products)
            vc.arrfiltersData = (self.serverDataProductCategory?.data?.filters) ?? []
            vc.modelDataForListing = ListingDataModel(category_id: Int64(intCategoryId), gender: Int64(GenericClass.sharedInstance.getGender() ?? "0"), salon_id: Int64(GenericClass.sharedInstance.getSalonId() ?? "0"), brand_unit: nil, is_trending: nil, hair_type: nil, is_newArrival: false)
            vc.strTitle = "Popular haircare products"
            vc.isBestsellerProducts = true
            self.navigationController?.pushViewController(vc, animated: true)

        default:
            break
        }
    }
}

// MARK: - HANDLE COLLECTION ACTIONS
extension SubProdListModuleViewController: ProductSelectionDelegate {
    func actionQunatity(quantity: Int, indexPath: IndexPath) {
        print("quntity:\(quantity)")
    }

    func selectedItem(indexpath: IndexPath, identifier: SectionIdentifier) {
        print("Section:\(identifier.rawValue) || item :\(indexpath.row)")
        switch identifier {

        // -------- BLOG DETAILS
        case .get_insightful: break
//            let vc = BlogDetailsModuleViewController.instantiate(fromAppStoryboard: .Blog)
//            let model = self.arrGetInsightfulforUI[indexpath.row]
//            vc.blog_id = model.blogId
//            self.navigationController?.pushViewController(vc, animated: true)

        // -------- PRODUCT LISTING
        case .serviceCell: break
//            let vc = ProductListingModuleViewController.instantiate(fromAppStoryboard: .Products)
//            let model: ServiceModel = arrSubCategoryListforUI[indexpath.row]
//            vc.strTitle = model.name
//            vc.arrfiltersData = serverDataProductCategory?.data?.children![indexpath.row].filters ?? []
//            vc.modelDataForListing = ListingDataModel(category_id: Int64(model.id), gender: Int64(GenericClass.sharedInstance.getGender() ?? "0"), salon_id: Int64(GenericClass.sharedInstance.getSalonId() ?? "0"), brand_unit: nil, is_trending: nil, hair_type: nil, is_newArrival: false)
//            self.navigationController?.pushViewController(vc, animated: true)

        // -------- PRODUCT LISTING
        case .shop_by_hairtype:
            let vc = ProductListingModuleViewController.instantiate(fromAppStoryboard: .Products)
            vc.arrfiltersData = (self.serverDataProductCategory?.data?.filters) ?? []
            let model: HairstylesModel = arrHairStyleforUI[indexpath.row]
            vc.strTitle = model.strName
            vc.strTypeCategory = model.categoryType
            vc.modelDataForListing = ListingDataModel(category_id: Int64(intCategoryId), gender: Int64(GenericClass.sharedInstance.getGender() ?? "0"), salon_id: Int64(GenericClass.sharedInstance.getSalonId() ?? "0"), brand_unit: nil, is_trending: nil, hair_type: Int64(model.value), is_newArrival: false)
            self.navigationController?.pushViewController(vc, animated: true)

        // -------- PRODUCT DETAILS
        case .new_arrivals:
            let model: ProductModel = arrPopularCareProductsforUI[indexpath.row]
            if(model.productId > 0 && !model.sku.isEmpty) {
                let vc = ProductDetailsModuleViewController.instantiate(fromAppStoryboard: .Products)
                vc.objProductId = model.productId
                vc.objProductSKU = model.sku
                self.navigationController?.pushViewController(vc, animated: true)
            }

        // -------- PRODUCT LISTING
        case .popular:
            let vc = ProductListingModuleViewController.instantiate(fromAppStoryboard: .Products)
            vc.arrfiltersData = (self.serverDataProductCategory?.data?.filters) ?? []
            let model: PopularBranchModel = arrBrandforUI[indexpath.row] // PopularBranchModel
            vc.strTitle = model.title
            vc.isBestsellerProducts = true
            vc.modelDataForListing = ListingDataModel(category_id: Int64(intCategoryId), gender: Int64(GenericClass.sharedInstance.getGender() ?? "0")!, salon_id: Int64(GenericClass.sharedInstance.getSalonId() ?? "0"), brand_unit: Int64(model.value), is_trending: nil, hair_type: nil, is_newArrival: false)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }

    func addToWishListApiCall(productId: Int64) {
        var arrayOfWishList  = [HairTreatmentModule.Something.Wishlist_item]()
        let wishListItem = HairTreatmentModule.Something.Wishlist_item(product: productId, qty: 1)
        arrayOfWishList.append(wishListItem)
        dispatchGroup.enter()
        EZLoadingActivity.show("Loading...", disableUI: true)
        let request = HairTreatmentModule.Something.AddToWishListRequest(customer_id: GenericClass.sharedInstance.getCustomerId().toString, wishlist_item: arrayOfWishList)
        interactor?.doPostRequestAddToWishList(request: request, method: HTTPMethod.post, accessToken: isuserLoggedIn().accessToken)
    }

    func removeFromFavourite(productId: Int64) {
        dispatchGroup.enter()
        let request =
            HairTreatmentModule.Something.RemoveFromWishListRequest(customer_id: GenericClass.sharedInstance.getCustomerId().toString, product_id: productId)
        interactor?.doPostRequestRemoveFromWishList(request: request, method: HTTPMethod.post, accessToken: isuserLoggedIn().accessToken)
    }

    func setValueOfIsFavourite( arr: [ProductModel], index: Int) {
        if arr.count > 0 {
            let model = arr[index]
            if model.isFavourite == true {
                removeFromFavourite(productId: model.productId )
            } else {
                addToWishListApiCall(productId: model.productId )
            }
        }
    }

    func wishlistStatus(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {

        if isuserLoggedIn().status {
            indexPathForWishlist = indexpath
            identifierLocal = identifier

            switch identifier {
            case .new_arrivals:
                let arr: [ProductModel] = self.arrPopularCareProductsforUI
                self.setValueOfIsFavourite(arr: arr, index: indexpath.row)
            default: break
            }
            return
        }

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
}

// MARK: - OPEN LOGIN SCREEN
extension SubProdListModuleViewController: LoginRegisterDelegate {
    func doLoginRegister() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            let vc = LoginModuleVC.instantiate(fromAppStoryboard: .Main)
            let navigationContrl = UINavigationController(rootViewController: vc)
            self.present(navigationContrl, animated: true, completion: nil)
        }
    }
}

extension SubProdListModuleViewController {
    func updateCellForWishList(status: Bool) {
        let cell: ProductsCollectionCell = self.tblSubProducts.cellForRow(at: IndexPath(row: 0, section: self.indexPathForWishlist.section)) as! ProductsCollectionCell
        if let productCell = cell.productCollectionView.cellForItem(at: IndexPath(row: self.indexPathForWishlist.row, section: 0)) as? TrendingProductsCell {
            switch self.identifierLocal {
            case .new_arrivals:
                var arr: [ProductModel] = self.arrPopularCareProductsforUI
                arr[self.indexPathForWishlist.row].isFavourite = status
                self.arrPopularCareProductsforUI = arr
                self.sections[self.indexPathForWishlist.section].data = arr
                productCell.configureCell(model: arr[self.indexPathForWishlist.row])
                cell.configuration.data = arr

                GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(arr[self.indexPathForWishlist.row].productId)", changedState: status))

            default: break
            }
        }
    }
}

extension SubProdListModuleViewController {
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
