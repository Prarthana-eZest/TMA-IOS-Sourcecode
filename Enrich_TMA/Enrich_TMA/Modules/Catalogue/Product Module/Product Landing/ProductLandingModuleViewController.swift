//
//  ProductLandingModuleViewController.swift
//  EnrichSalon
//

import UIKit
protocol ProductLandingModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
}

class ProductLandingModuleViewController: UIViewController, ProductLandingModuleDisplayLogic {
    @IBOutlet weak private var productTableView: UITableView!
    var pageControl: UIPageControl?
    var interactor: ProductLandingModuleBusinessLogic?

    let strCategoryId = "3"
    private let dispatchGroup = DispatchGroup()

    var sections = [SectionConfiguration]()
    var arrBlogsforUI: [GetInsightFulDetails] = []
    var modelProductDataForUI: ModelForProductDataUI = ModelForProductDataUI()

    var reposStoreProductServerData: LocalJSONStore<ModelForProductDataUI> = LocalJSONStore(storageType: .cache)
    var reposStoreProductCategory: LocalJSONStore<ProductLandingModule.Something.ProductCategoryResponse> = LocalJSONStore(storageType: .cache)

    var serverData: ProductLandingModule.Something.Response?
    var blogsData: ProductLandingModule.Something.ResponseBlogs?
    var serverDataProductCategory: ProductLandingModule.Something.ProductCategoryResponse?
    var indexPathForWishlist = IndexPath()
    var identifierLocal: SectionIdentifier = .parentVC

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
        let interactor = ProductLandingModuleInteractor()
        let presenter = ProductLandingModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
        showNavigationBarRigtButtons()
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        productTableView.register(UINib(nibName: "ProductCategoryBackImageCell", bundle: nil), forCellReuseIdentifier: "ProductCategoryBackImageCell")
        productTableView.register(UINib(nibName: "ProductCategoryFrontImageCell", bundle: nil), forCellReuseIdentifier: "ProductCategoryFrontImageCell")
        productTableView.register(UINib(nibName: "HeaderViewWithTitleCell", bundle: nil), forCellReuseIdentifier: "HeaderViewWithTitleCell")
        productTableView.register(UINib(nibName: "HeaderViewWithSubTitleCell", bundle: nil), forCellReuseIdentifier: "HeaderViewWithSubTitleCell")

        productTableView.separatorStyle = .none
        productTableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)

         reposStoreProductServerData = LocalJSONStore(storageType: .cache, filename: String(format: "%@_3", CacheFileNameKeys.k_file_name_productLandingData.rawValue), folderName: CacheFolderNameKeys.k_folder_name_ProductLandingData.rawValue)

        reposStoreProductCategory = LocalJSONStore(storageType: .cache, filename: String(format: "%@_3", CacheFileNameKeys.k_file_name_productLandingCategories.rawValue), folderName: CacheFolderNameKeys.k_folder_name_ProductLandingCategories.rawValue)
        productTableView.contentInsetAdjustmentBehavior = .never
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.isHidden = false
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationItem.setHidesBackButton(false, animated: false)
        self.navigationController?.addCustomBackButton(title: "")

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getRepositoryProductsCategoryData()
        getRepositoryProductsServerData()
        getDataFromServer()
        getProductCategoriesFromServer()
        getInsightFromServer()
        if (isuserLoggedIn().status) {
            getAllCartItemsAPICustomer()
        } else {
            getAllCartItemsAPIGuest()
        }

        if self.serverDataProductCategory == nil {
            EZLoadingActivity.show("Loading...", disableUI: true)
        }

        dispatchGroup.notify(queue: .main) {
            EZLoadingActivity.hide()
            self.updateUIAfterServerData()
            DispatchQueue.main.async {
                self.productTableView.reloadData()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {

        GenericClass.sharedInstance.removeFevoriteProductSet()
    StorageType.cache.clearStorageForSubfolder(subfolder: CacheFolderNameKeys.k_folder_name_ProductLandingData.rawValue)
    StorageType.cache.clearStorageForSubfolder(subfolder: CacheFolderNameKeys.k_folder_name_ProductLandingCategories.rawValue)
        }
    }

    // MARK: - updateUIAfterServerData
    func updateUIAfterServerData() {
        sections.removeAll()

        if modelProductDataForUI.banners.count > 0 {
            sections.append(self.configureSection(idetifier: .advetisement, items: self.modelProductDataForUI.banners.count, data: self.modelProductDataForUI.banners))
        }

        if let serverData = serverDataProductCategory, let child1 = serverData.data, let children = child1.children {
            sections.append(self.configureSection(idetifier: .category, items: children.count, data: []))
        }

        if modelProductDataForUI.offers.count > 0 {
            sections.append(self.configureSection(idetifier: .irresistible, items: self.modelProductDataForUI.offers.count, data: self.modelProductDataForUI.offers))
        }

        if modelProductDataForUI.trending_products.count > 0 {
            sections.append(self.configureSection(idetifier: .trending, items: self.modelProductDataForUI.trending_products.count, data: self.modelProductDataForUI.trending_products))
        }

        if modelProductDataForUI.new_products.count > 0 {
            sections.append(self.configureSection(idetifier: .new_arrivals, items: self.modelProductDataForUI.new_products.count, data: self.modelProductDataForUI.new_products ))
        }

        if modelProductDataForUI.brands.count > 0 {
            sections.append(self.configureSection(idetifier: .popular, items: self.modelProductDataForUI.brands.count, data: self.modelProductDataForUI.brands))
        }

        if modelProductDataForUI.recently_viewed.count > 0 {
            sections.append(self.configureSection(idetifier: .recently_viewed, items: self.modelProductDataForUI.recently_viewed.count, data: self.modelProductDataForUI.recently_viewed))
        }

        if arrBlogsforUI.count > 0 {
            sections.append(self.configureSection(idetifier: .get_insightful, items: arrBlogsforUI.count, data: arrBlogsforUI as Any))
        }
    }

    // MARK: - Top Navigation Bar And  Actions
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

// MARK: Call Webservice
extension ProductLandingModuleViewController {
    // MARK: - This Api response contains : offers/banners/trendingProducts/NewArrivals/PopularBrands Data
    func getDataFromServer() {
        dispatchGroup.enter()
        let request = ProductLandingModule.Something.Request(category_id: strCategoryId, customer_id: GenericClass.sharedInstance.getCustomerId().toString, limit: maxlimitToProductQuantity)
        interactor?.doPostRequest(request: request, method: HTTPMethod.post)
    }

    // MARK: - This Api response contains : Product Categories
    func getProductCategoriesFromServer() {
        dispatchGroup.enter()
        let request = ProductLandingModule.Something.ProductCategoryRequest(category_id: strCategoryId, customer_id: GenericClass.sharedInstance.getCustomerId().toString)
        interactor?.doPostRequestProductCategory(request: request, method: HTTPMethod.post)
    }

    // MARK: - This Api response contains : Get Insight
    func getInsightFromServer() {
        dispatchGroup.enter()
        let request = ProductLandingModule.Something.Request(category_id: "", customer_id: "", limit: maxlimitToProductQuantity)
        interactor?.doPostRequestBlogs(request: request, method: HTTPMethod.post)
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

    func displaySuccess<T: Decodable>(viewModel: T) {
        print("viewModel : \(T.self)")

        DispatchQueue.main.async {
            // Update UI
            if T.self == HairTreatmentModule.Something.RemoveFromWishListResponse.self {
                EZLoadingActivity.hide()
                self.updateCellForWishList(status: false)
                let obj: HairTreatmentModule.Something.RemoveFromWishListResponse = viewModel as! HairTreatmentModule.Something.RemoveFromWishListResponse
                if(obj.status == true) {
                    self.showToast(alertTitle: alertTitleSuccess, message: obj.message, seconds: toastMessageDuration)
                } else {
                    self.showToast(alertTitle: alertTitle, message: obj.message, seconds: toastMessageDuration)
                }
                self.dispatchGroup.leave()
            } else if T.self == HairTreatmentModule.Something.AddToWishListResponse.self {
                EZLoadingActivity.hide()
                self.updateCellForWishList(status: true)
                let obj: HairTreatmentModule.Something.AddToWishListResponse = viewModel as! HairTreatmentModule.Something.AddToWishListResponse
                if(obj.status == true) {
                    self.showToast(alertTitle: alertTitleSuccess, message: obj.message, seconds: toastMessageDuration)
                } else {
                    self.showToast(alertTitle: alertTitle, message: obj.message, seconds: toastMessageDuration)
                }
                self.dispatchGroup.leave()
            } else if T.self == ProductLandingModule.Something.Response.self {

                let obj: ProductLandingModule.Something.Response = viewModel as! ProductLandingModule.Something.Response
                if(obj.status == true) {
                    self.serverData = obj
                    self.modelProductDataForUI = (self.interactor?.getBannersOffersTrending_productsNew_products(serverDataObj: obj, isLogin: self.isuserLoggedIn().status))!
                    self.reposStoreProductServerData.save(self.modelProductDataForUI)

                } else {
                    self.showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "")

                }
                self.dispatchGroup.leave()

            } else if T.self == ProductLandingModule.Something.ProductCategoryResponse.self {
                // Product Category Response
                let obj: ProductLandingModule.Something.ProductCategoryResponse = viewModel as! ProductLandingModule.Something.ProductCategoryResponse

                if(obj.status == true) {
                    self.serverDataProductCategory = obj
                    self.reposStoreProductCategory.save(obj)
                } else {
                    self.showAlert(alertTitle: alertTitle, alertMessage: obj.message )

                }
                self.dispatchGroup.leave()

            } else if T.self == ProductLandingModule.Something.ResponseBlogs.self {
                // ******** BLOGS
                let obj: ProductLandingModule.Something.ResponseBlogs = viewModel as! ProductLandingModule.Something.ResponseBlogs

                if(obj.status == true) {
                    self.blogsData = obj
                    self.arrBlogsforUI = self.interactor?.getBlogs(serverDataObj: obj) as! [GetInsightFulDetails]
                } else {
                    self.showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "")
                }
                self.dispatchGroup.leave()
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

    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()

        dispatchGroup.leave()
        self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage!)
    }
}

extension ProductLandingModuleViewController: ProductSelectionDelegate {

    func actionQunatity(quantity: Int, indexPath: IndexPath) {
        print("quntity:\(quantity)")
    }

    func selectedItem(indexpath: IndexPath, identifier: SectionIdentifier) {
        print("Section:\(identifier.rawValue) || item :\(indexpath.row)")
        switch identifier {
        case .category: break
        case .get_insightful:break
            //BlogListingViewController
//            let model = arrBlogsforUI[indexpath.row]
//            let vc = BlogDetailsModuleViewController.instantiate(fromAppStoryboard: .Blog)
//            vc.blog_id = model.blogId
//            self.navigationController?.pushViewController(vc, animated: true)

        case .trending:
            if let arr = modelProductDataForUI.trending_products as? [ProductModel], arr.count > 0 {
                let model = arr[indexpath.row]
                if(model.productId > 0 && !model.sku.isEmpty) {
                    let vc = ProductDetailsModuleViewController.instantiate(fromAppStoryboard: .Products)
                    vc.objProductId = model.productId
                    vc.objProductSKU = model.sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

        case .new_arrivals:
            let vc = ProductDetailsModuleViewController.instantiate(fromAppStoryboard: .Products)
            if let arr = modelProductDataForUI.new_products as? [ProductModel], arr.count > 0 {
                let model = arr[indexpath.row]
                print("\(model.productId) , \(model.sku)")
                vc.objProductId = model.productId
                vc.objProductSKU = model.sku
            }
            self.navigationController?.pushViewController(vc, animated: true)

        case .popular:
            let vc = ProductListingModuleViewController.instantiate(fromAppStoryboard: .Products)
            if let arr = modelProductDataForUI.brands as? [PopularBranchModel], arr.count > 0 {
                let model = arr[indexpath.row]
                vc.strTitle = model.title
                vc.arrfiltersData = serverData?.data?.filters ?? []
                vc.modelDataForListing = ListingDataModel(category_id: Int64(strCategoryId), gender: Int64(GenericClass.sharedInstance.getGender() ?? "0")!, salon_id: Int64(GenericClass.sharedInstance.getSalonId() ?? "0"), brand_unit: Int64(model.value), is_trending: nil, hair_type: nil, is_newArrival: false)
            }
            self.navigationController?.pushViewController(vc, animated: true)

        default:
            break
        }

    }

    func addToWishListApiCall(productId: Int64) {
            var arrayOfWishList  = [HairTreatmentModule.Something.Wishlist_item]()
            let wishListItem = HairTreatmentModule.Something.Wishlist_item(product: productId, qty: 1)
            arrayOfWishList.append(wishListItem)
            EZLoadingActivity.show("Loading...", disableUI: true)
            dispatchGroup.enter()
            let request = HairTreatmentModule.Something.AddToWishListRequest(customer_id: GenericClass.sharedInstance.getCustomerId().toString, wishlist_item: arrayOfWishList)
        interactor?.doPostRequestAddToWishList(request: request, method: HTTPMethod.post, accessToken: isuserLoggedIn().accessToken)
    }

    func wishlistStatus(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {

        if isuserLoggedIn().status {
            indexPathForWishlist = indexpath
            identifierLocal = identifier

            switch identifier {
                case .trending:
                    let arr: [ProductModel] = self.modelProductDataForUI.trending_products as! [ProductModel]
                    setValueOfIsFavourite(arr: arr, index: indexpath.row)

                case .new_arrivals:
                    let arr: [ProductModel] = self.modelProductDataForUI.new_products as! [ProductModel]
                    setValueOfIsFavourite(arr: arr, index: indexpath.row)

                default:
                    break
            }
            return
        }

        //DoLoginPopUpVC
        let vc = DoLoginPopUpVC.instantiate(fromAppStoryboard: .Location)
        vc.delegate = self
        self.view.alpha = screenPopUpAlpha
        self.appDelegate.window?.rootViewController!.present(vc, animated: true, completion: nil)
        vc.onDoneBlock = {[unowned self] result in
            if(result) {} else {}
            self.view.alpha = 1.0
        }
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

    func removeFromFavourite(productId: Int64) {
        dispatchGroup.enter()
        let request =
            HairTreatmentModule.Something.RemoveFromWishListRequest(customer_id: GenericClass.sharedInstance.getCustomerId().toString, product_id: productId)
        interactor?.doPostRequestRemoveFromWishList(request: request, method: HTTPMethod.post, accessToken: isuserLoggedIn().accessToken)
    }
}

extension ProductLandingModuleViewController: LoginRegisterDelegate {
    func doLoginRegister() {
        // Put your code here
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            let vc = LoginModuleVC.instantiate(fromAppStoryboard: .Main)
            let navigationContrl = UINavigationController(rootViewController: vc)
            self.present(navigationContrl, animated: true, completion: nil)
        }
    }
}

extension ProductLandingModuleViewController: HeaderDelegate {

    func actionViewAll(identifier: SectionIdentifier) {
        print("ViewAllAction : \(identifier.rawValue)")
        switch identifier {

        case .trending:
            let vc = ProductListingModuleViewController.instantiate(fromAppStoryboard: .Products)
            vc.strTitle = identifier.rawValue
            vc.arrfiltersData = (serverData?.data?.filters) ?? []
            vc.modelDataForListing = ListingDataModel(category_id: Int64(strCategoryId), gender: Int64(GenericClass.sharedInstance.getGender() ?? "0")!, salon_id: Int64(GenericClass.sharedInstance.getSalonId() ?? "0"), brand_unit: nil, is_trending: true, hair_type: nil, is_newArrival: false)
            self.navigationController?.pushViewController(vc, animated: true)

        case .new_arrivals:
            let vc = ProductListingModuleViewController.instantiate(fromAppStoryboard: .Products)
            vc.strTitle = identifier.rawValue
            vc.arrfiltersData = serverData?.data?.filters ?? []
            vc.modelDataForListing = ListingDataModel(category_id: Int64(strCategoryId), gender: Int64(GenericClass.sharedInstance.getGender() ?? "0")!, salon_id: Int64(GenericClass.sharedInstance.getSalonId() ?? "0"), brand_unit: nil, is_trending: nil, hair_type: nil, is_newArrival: true)
            self.navigationController?.pushViewController(vc, animated: true)

        case .get_insightful:break
//            let vc = BlogListingModuleViewController.instantiate(fromAppStoryboard: .Blog)
//            self.navigationController?.pushViewController(vc, animated: true)

        default:
            break
        }
    }
}

extension ProductLandingModuleViewController: UITableViewDelegate, UITableViewDataSource {

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

        if data.identifier == .category {

            guard let serverData = serverDataProductCategory,
                let child1 = serverData.data,
                let children = child1.children else {
                return UITableViewCell()
            }

            let childData = children[indexPath.row]
            if indexPath.row % 2 == 0 {

                let cell: ProductCategoryBackImageCell = tableView.dequeueReusableCell(withIdentifier: "ProductCategoryBackImageCell", for: indexPath) as! ProductCategoryBackImageCell
                    cell.selectionStyle = .none
                        cell.lblTitle.text = childData.name ?? ""
                        if let strImg = childData.category_img, !strImg.isEmpty {
                            cell.imgHairCare.kf.setImage(with: URL(string: strImg ), placeholder: UIImage(named: "reviewAavatarImg"), options: nil, progressBlock: nil, completionHandler: nil)
                        }
                return cell

            } else {
                let cell: ProductCategoryFrontImageCell = tableView.dequeueReusableCell(withIdentifier: "ProductCategoryFrontImageCell", for: indexPath) as! ProductCategoryFrontImageCell
                cell.selectionStyle = .none
                cell.lblTitle.text = childData.name ?? ""
                if let strImg = childData.category_img, !strImg.isEmpty {
                    cell.imgHairCare.kf.setImage(with: URL(string: strImg), placeholder: UIImage(named: "reviewAavatarImg"), options: nil, progressBlock: nil, completionHandler: nil)
                }
                return cell
            }

        } else {

            let cell: ProductsCollectionCell = tableView.dequeueReusableCell(withIdentifier: "ProductsCollectionCell", for: indexPath) as! ProductsCollectionCell
            cell.tableViewIndexPath = indexPath
            cell.pageControl = pageControl
            cell.selectionDelegate = self
            cell.configureCollectionView(configuration: data, scrollDirection: .horizontal)
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let data = self.sections[section]

        guard data.showHeader else {
            return nil
        }

        if data.identifier == .new_arrivals {
            let cell: HeaderViewWithSubTitleCell = tableView.dequeueReusableCell(withIdentifier: "HeaderViewWithSubTitleCell") as! HeaderViewWithSubTitleCell
            cell.titleLabel.text = data.title
            cell.subTitleLabel.text = data.subTitle
            cell.titleLabel.font = data.textFont
            cell.subTitleLabel.font = data.textFont
            cell.identifier = data.identifier
            cell.delegate = self
            return cell

        } else {
            let cell: HeaderViewWithTitleCell = tableView.dequeueReusableCell(withIdentifier: "HeaderViewWithTitleCell") as! HeaderViewWithTitleCell
            cell.titleLabel.text = data.title
            cell.titleLabel.font = data.textFont
            cell.identifier = data.identifier
            cell.delegate = self
            cell.viewAllButton.isHidden = true
            if data.identifier == .trending || data.identifier == .get_insightful {
                cell.viewAllButton.isHidden = false
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let data = self.sections[section]
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: data.footerHeight))
        let pageControl = UIPageControl(frame: CGRect(x: view.frame.origin.x, y: 5, width: view.frame.size.width, height: data.footerHeight))
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .red
        if data.identifier == .advetisement {
            pageControl.numberOfPages = data.items
        }
        self.pageControl = pageControl
        view.backgroundColor = UIColor.white
        view.addSubview(pageControl)
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
        return self.sections[indexPath.section].cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
        if indexPath.section == 1 {
            if let serverData = serverDataProductCategory, let child1 = serverData.data, let children = child1.children {
                let childData = children[indexPath.row]
                let vc = SubProdListModuleViewController.instantiate(fromAppStoryboard: .Products)
                vc.categoryModel = childData
                vc.arrBrandforUI = self.modelProductDataForUI.brands
                vc.arrGetInsightfulforUI = self.arrBlogsforUI

                self.navigationController?.pushViewController(vc, animated: true)

                self.modelProductDataForUI = ModelForProductDataUI()
                self.serverDataProductCategory = nil

            }
        }
    }

}

extension ProductLandingModuleViewController {

    func configureSection(idetifier: SectionIdentifier, items: Int, data: Any) -> SectionConfiguration {

        let headerHeight: CGFloat = is_iPAD ? 70 : 50
        let leftMargin: CGFloat = is_iPAD ? 25 : 15
        let categoryFont = UIFont(name: "NotoSerif-Bold", size: is_iPAD ? 30.0 : 20.0)
        let normalFont = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 30.0 : 20.0)

        switch idetifier {

        case .advetisement: // banner

            let height: CGFloat = is_iPAD ? 320 : 200
            let width: CGFloat = self.productTableView.frame.size.width

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: false, showFooter: true, headerHeight: headerHeight, footerHeight: 30, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: true, textFont: nil, textColor: UIColor.black, items: items, identifier: idetifier, data: data)

        case .category:

            let height: CGFloat = is_iPAD ? 180 : 150
            let width: CGFloat = self.productTableView.frame.size.width
            let textColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: categoryFont, textColor: textColor, items: items, identifier: idetifier, data: data)

        case .irresistible:

            let height: CGFloat = is_iPAD ? 240 : 160
            let width: CGFloat = self.productTableView.frame.size.width

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: normalFont, textColor: .black, items: items, identifier: idetifier, data: data)

        case .trending, .recently_viewed:

            let height: CGFloat = is_iPAD ? 475 : 400
            let width: CGFloat = is_iPAD ? ((productTableView.frame.size.width - 100) / 3) : ((productTableView.frame.size.width - 45) / 2)

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: normalFont, textColor: .black, items: items, identifier: idetifier, data: data)

        case .new_arrivals:

            let header: CGFloat = is_iPAD ? 120 : 70
            let height: CGFloat = is_iPAD ? 475 : 400
            let width: CGFloat = is_iPAD ? ((productTableView.frame.size.width - 100) / 3) : ((productTableView.frame.size.width - 45) / 2)

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "Find your new favourite beauty product", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: header, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: normalFont, textColor: .black, items: items, identifier: idetifier, data: data)

        case .popular:

            let height: CGFloat = is_iPAD ? 240 : 200
            let width: CGFloat = is_iPAD ? 200 : 160

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: normalFont, textColor: .black, items: items, identifier: idetifier, data: data)

        case .get_insightful:

            let height: CGFloat = is_iPAD ? 408 : 340
            let width: CGFloat = is_iPAD ? 288 : 240

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: normalFont, textColor: .black, items: items, identifier: idetifier, data: data)

        default :
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: 0, showHeader: false, showFooter: false, headerHeight: 0, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: false, textFont: nil, textColor: UIColor.black, items: 0, identifier: idetifier, data: data)
        }
    }
}

extension ProductLandingModuleViewController {

    func getRepositoryProductsCategoryData() {
        if let repos = reposStoreProductCategory.storedValue {
            let viewModel: ProductLandingModule.Something.ProductCategoryResponse = repos
            self.serverDataProductCategory = viewModel
        }
    }

    func getRepositoryProductsServerData() {
        if let repos = reposStoreProductServerData.storedValue {
            let viewModel: ModelForProductDataUI = repos
            self.modelProductDataForUI = viewModel
            self.updateUIAfterServerData()
            DispatchQueue.main.async {
                self.productTableView.reloadData()
            }
        }
    }
}

extension ProductLandingModuleViewController {
    func updateCellForWishList(status: Bool) {
        BG { [unowned self] in
            switch self.identifierLocal {
            case .trending:
                self.modelProductDataForUI.trending_products[self.indexPathForWishlist.row].isFavourite = status
                let prodId = self.modelProductDataForUI.trending_products[self.indexPathForWishlist.row].productId
                GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(prodId)", changedState: status))
                        if let row = self.modelProductDataForUI.new_products.firstIndex(where: {$0.productId == prodId}) {
                            self.modelProductDataForUI.new_products[row].isFavourite = status
                    }

            case .new_arrivals:
                self.modelProductDataForUI.new_products[self.indexPathForWishlist.row].isFavourite = status
                let prodId = self.modelProductDataForUI.new_products[self.indexPathForWishlist.row].productId
                GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(prodId)", changedState: status))
                        if let row = self.modelProductDataForUI.trending_products.firstIndex(where: {$0.productId == prodId}) {
                            self.modelProductDataForUI.trending_products[row].isFavourite = status
                    }
            default:
                break
            }

            self.reposStoreProductServerData.save(self.modelProductDataForUI)
            UI { [unowned self] in
                self.updateUIAfterServerData()
                self.productTableView.reloadData()
            }
        }

    }
}

extension ProductLandingModuleViewController {
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
            self.updateCartBadgeNumber(count: responseObj.count ?? 0)
            
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
       // self.navigationController?.pushViewController(cartModuleViewController, animated: true)

    }
}
