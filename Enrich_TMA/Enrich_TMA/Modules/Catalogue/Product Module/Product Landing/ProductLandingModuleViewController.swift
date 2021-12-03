//
//  ProductLandingModuleViewController.swift
//  EnrichSalon
//

import UIKit
import FirebaseAnalytics
protocol ProductLandingModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
}

class ProductLandingModuleViewController: UIViewController, ProductLandingModuleDisplayLogic {
    @IBOutlet weak private var productTableView: UITableView!
    var pageControl: UIPageControl?
    var interactor: ProductLandingModuleBusinessLogic?

    let strCategoryId = GenericClass.sharedInstance.getProductCategoryId()
    var sections = [SectionConfiguration]()
    var arrBlogsforUI: [GetInsightFulDetails] = []
    var modelProductDataForUI: ModelForProductDataUI = ModelForProductDataUI()
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

        productTableView.register(UINib(nibName: CellIdentifier.productCategoryBackImageCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.productCategoryBackImageCell)
        productTableView.register(UINib(nibName: CellIdentifier.productCategoryFrontImageCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.productCategoryFrontImageCell)
        productTableView.register(UINib(nibName: CellIdentifier.headerViewWithTitleCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.headerViewWithTitleCell)
        productTableView.register(UINib(nibName: CellIdentifier.headerViewWithSubTitleCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.headerViewWithSubTitleCell)

        productTableView.separatorStyle = .none
        productTableView.contentInsetAdjustmentBehavior = .never
        getProductCategoriesFromServer()
        getInsightFromServer()
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
        if serverDataProductCategory == nil {
            EZLoadingActivity.show("", disableUI: true)
        }
        getDataFromServer()
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

        if !modelProductDataForUI.banners.isEmpty {
            DispatchQueue.main.async {
                self.productTableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
            }
            sections.append(self.configureSection(idetifier: .advetisement, items: self.modelProductDataForUI.banners.count, data: self.modelProductDataForUI.banners))
        }

        if let serverData = serverDataProductCategory, let child1 = serverData.data, let children = child1.children {
            sections.append(self.configureSection(idetifier: .category, items: children.count, data: []))
        }

        if !modelProductDataForUI.offers.isEmpty {
            sections.append(self.configureSection(idetifier: .irresistible, items: self.modelProductDataForUI.offers.count, data: self.modelProductDataForUI.offers))
        }

        if !modelProductDataForUI.trending_products.isEmpty {
            sections.append(self.configureSection(idetifier: .trending, items: self.modelProductDataForUI.trending_products.count, data: self.modelProductDataForUI.trending_products))
        }

        if !modelProductDataForUI.new_products.isEmpty {
            sections.append(self.configureSection(idetifier: .new_arrivals, items: self.modelProductDataForUI.new_products.count, data: self.modelProductDataForUI.new_products ))
        }

        self.setBrandsModel()
        if !modelProductDataForUI.brands.isEmpty {
            sections.append(self.configureSection(idetifier: .popular, items: self.modelProductDataForUI.brands.count, data: self.modelProductDataForUI.brands))
        }

        if !modelProductDataForUI.recently_viewed.isEmpty {
            sections.append(self.configureSection(idetifier: .recently_viewed, items: self.modelProductDataForUI.recently_viewed.count, data: self.modelProductDataForUI.recently_viewed))
        }

//        if !arrBlogsforUI.isEmpty {
//            sections.append(self.configureSection(idetifier: .get_insightful, items: arrBlogsforUI.count, data: arrBlogsforUI as Any))
//        }
    }

    // MARK: - Top Navigation Bar And  Actions
    func showNavigationBarRigtButtons() {
        guard let sosImg = UIImage(named: "SOS"),
            let searchImg = UIImage(named: "searchImg") else {
                return
        }

        let searchButton = UIBarButtonItem(image: searchImg, style: .plain, target: self, action: #selector(didTapSearchButton))
        searchButton.tintColor = UIColor.black
        searchButton.tag = 1

        let sosButton = UIBarButtonItem(image: sosImg, style: .plain, target: self, action: #selector(didTapSOSButton))
        sosButton.tintColor = UIColor.black

        navigationItem.title = ""
        if showSOS {
            navigationItem.rightBarButtonItems = [searchButton, sosButton]
        }
        else {
            navigationItem.rightBarButtonItems = [searchButton]
        }
    }

    @objc func didTapSOSButton() {
        SOSFactory.shared.raiseSOSRequest()
    }

    @objc func didTapSearchButton() {
        let searchModuleVC = SearchModuleVC.instantiate(fromAppStoryboard: .Services)
        self.navigationController?.pushViewController(searchModuleVC, animated: false)
    }

    @objc func didTapCartButton() {
    }
}

// MARK: Call Webservice
extension ProductLandingModuleViewController {
    // MARK: - This Api response contains : offers/banners/trendingProducts/NewArrivals/PopularBrands Data
    func getDataFromServer() {
        let request = ProductLandingModule.Something.Request(category_id: strCategoryId, customer_id: GenericClass.sharedInstance.getCustomerId().toString, limit: maxlimitToProductQuantity, salon_id: nil)
        interactor?.doPostRequest(request: request, method: HTTPMethod.post)
    }

    // MARK: - This Api response contains : Product Categories
    func getProductCategoriesFromServer() {
        let request = ProductLandingModule.Something.ProductCategoryRequest(category_id: strCategoryId, customer_id: GenericClass.sharedInstance.getCustomerId().toString)
        interactor?.doPostRequestProductCategory(request: request, method: HTTPMethod.post)
    }
    // MARK: - This Api response contains : Get Insight - blogs
    func getInsightFromServer() {
        let request = ProductLandingModule.Something.Request(category_id: "", customer_id: "", limit: maxlimitToProductQuantity, salon_id: nil)
        self.interactor?.doPostRequestBlogs(request: request, method: HTTPMethod.post)
    }
    // MARK: API callQuoteIdAPI
    func callQuoteIdMineAPI() {
        let request = ProductDetailsModule.GetQuoteIDMine.Request()
        self.interactor?.doPostRequestGetQuoteIdMine(request: request, accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken)
    }
    func callToGetQuoteIdGuestAPI() {
        let request = ProductDetailsModule.GetQuoteIDGuest.Request()
        self.interactor?.doPostRequestGetQuoteIdGuest(request: request, method: HTTPMethod.post)
    }

    func setBrandsModel() {
        var arrBrand: [PopularBranchModel] = []
        if let serverData = serverDataProductCategory, let arrData = serverData.data, let arrBrandsObj = arrData.brands, !arrBrandsObj.isEmpty {
            for model in arrBrandsObj {
                arrBrand.append(PopularBranchModel(value: model.value ?? "", title: model.label ?? "", imageUrl: model.swatch_image_url ?? ""))
            }
        }
        self.modelProductDataForUI.brands = arrBrand
    }

    func displaySuccess<T: Decodable>(viewModel: T) {
        print("viewModel : \(T.self)")

        DispatchQueue.main.async {
            // Update UI
            if T.self == HairTreatmentModule.Something.RemoveFromWishListResponse.self {
                EZLoadingActivity.hide()
                self.updateCellForWishList(status: false)
                let obj = viewModel as? HairTreatmentModule.Something.RemoveFromWishListResponse
                if obj?.status == true {
                    self.showToast(alertTitle: alertTitleSuccess, message: obj?.message ?? "", seconds: toastMessageDuration)
                }
                else {
                    self.showToast(alertTitle: alertTitle, message: obj?.message ?? "", seconds: toastMessageDuration)
                }
                DispatchQueue.main.async {
                    self.updateUIAfterServerData()
                    self.productTableView.reloadData()
                }
            }
            else if T.self == HairTreatmentModule.Something.AddToWishListResponse.self {
                EZLoadingActivity.hide()
                self.updateCellForWishList(status: true)
                let obj = viewModel as? HairTreatmentModule.Something.AddToWishListResponse
                if obj?.status == true {
                    self.showToast(alertTitle: alertTitleSuccess, message: obj?.message ?? "", seconds: toastMessageDuration)
                }
                else {
                    self.showToast(alertTitle: alertTitle, message: obj?.message ?? "", seconds: toastMessageDuration)
                }
                DispatchQueue.main.async {
                    self.updateUIAfterServerData()
                    self.productTableView.reloadData()
                }
            }
            else if T.self == ProductLandingModule.Something.Response.self {

                let obj = viewModel as? ProductLandingModule.Something.Response
                if obj?.status == true {
                    self.serverData = obj
                        self.modelProductDataForUI = (self.interactor?.getBannersOffersTrending_productsNew_products(serverDataObj: obj, isLogin: GenericClass.sharedInstance.isuserLoggedIn().status))!
                        DispatchQueue.main.async {
                            self.updateUIAfterServerData()
                            self.productTableView.reloadData()
                            EZLoadingActivity.hide()
                        }
                }
                else {
                    EZLoadingActivity.hide()
                    self.showAlert(alertTitle: alertTitle, alertMessage: obj?.message ?? "")
                }
            }
            else if T.self == ProductLandingModule.Something.ProductCategoryResponse.self {
                // Product Category Response
                let obj = viewModel as? ProductLandingModule.Something.ProductCategoryResponse
                    if obj?.status == true {
                        self.serverDataProductCategory = obj
                    }
                    else {
                        EZLoadingActivity.hide()
                        self.showAlert(alertTitle: alertTitle, alertMessage: obj?.message ?? "" )
                    }
                    DispatchQueue.main.async {
                        self.updateUIAfterServerData()
                        self.productTableView.reloadData()
                    }
            }
            else if let obj = viewModel as? ProductLandingModule.Something.ResponseBlogs {
                if obj.status == true {
                    self.blogsData = obj
                        self.arrBlogsforUI = self.interactor?.getBlogs(serverDataObj: obj) as? [GetInsightFulDetails] ?? []
                        DispatchQueue.main.async {
                            self.updateUIAfterServerData()
                            self.productTableView.reloadData()
                        }
                }
                else {
                    self.showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "")
                }
            }
        }
    }

    func displaySuccess<T: Decodable>(responseSuccess: [T]) {
    }

    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        if (errorMessage ?? "").compareIgnoringCase(find: inActiveCartQuoteId) {
            return
        }
        self.showToast(alertTitle: alertTitle, message: errorMessage ?? "", seconds: toastMessageDuration)
    }
}

extension ProductLandingModuleViewController: ProductSelectionDelegate {
    func moveToCart(indexPath: IndexPath) {
        print("moveToCart \(indexPath)")
    }

    func notifyMe(indexPath: IndexPath) {}

    func actionAddOnsBundle(indexPath: IndexPath) {
        print("actionAddOnsBundle \(indexPath)")
    }

    func actionQunatity(quantity: Int, indexPath: IndexPath) {
        print("quntity:\(quantity)")
    }

    func selectedItem(indexpath: IndexPath, identifier: SectionIdentifier) {
        print("Section:\(identifier.rawValue) || item :\(indexpath.row)")
        switch identifier {
        case .category: break
        case .get_insightful: break
            //BlogListingViewController
//            let model = arrBlogsforUI[indexpath.row]
//            let vc = BlogDetailsModuleVC.instantiate(fromAppStoryboard: .Blog)
//            vc.blog_id = model.blogId
//            self.navigationController?.pushViewController(vc, animated: true)

        case .trending:
            if !modelProductDataForUI.trending_products.isEmpty {
                let model = modelProductDataForUI.trending_products[indexpath.row]
                if model.productId > 0 && !model.sku.isEmpty {
                    let vc = ProductDetailsModuleVC.instantiate(fromAppStoryboard: .Products)
                    vc.objProductId = model.productId
                    vc.objProductSKU = model.sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

        case .new_arrivals:
            let vc = ProductDetailsModuleVC.instantiate(fromAppStoryboard: .Products)
            if  !modelProductDataForUI.new_products.isEmpty {
                let model = modelProductDataForUI.new_products[indexpath.row]
                print("\(model.productId) , \(model.sku)")
                vc.objProductId = model.productId
                vc.objProductSKU = model.sku
            }
            self.navigationController?.pushViewController(vc, animated: true)

        case .recently_viewed:
            let vc = ProductDetailsModuleVC.instantiate(fromAppStoryboard: .Products)
            if !modelProductDataForUI.recently_viewed.isEmpty {
                let model = modelProductDataForUI.recently_viewed[indexpath.row]
                print("\(model.productId) , \(model.sku)")
                vc.objProductId = model.productId
                vc.objProductSKU = model.sku
            }
            self.navigationController?.pushViewController(vc, animated: true)

        case .popular:
            let vc = ProductListingModuleViewController.instantiate(fromAppStoryboard: .Products)
            if  let model = serverDataProductCategory, let arrData = model.data, let brandsObj = arrData.brands, !brandsObj.isEmpty {
                let modelObj = brandsObj[indexpath.row]
                vc.strTitle = modelObj.label ?? ""
//                vc.arrfiltersData = serverData?.data?.filters ?? []
                vc.modelDataForListing = ListingDataModel(category_id: Int64(strCategoryId),
                                                          gender: Int64(GenericClass.sharedInstance.getGender() ?? "0")!,
                                                          salon_id: Int64(GenericClass.sharedInstance.getSalonId() ?? "0"),
                                                          brand_unit: Int64(modelObj.value!),
                                                          is_trending: nil,
                                                          hair_type: nil,
                                                          is_newArrival: false)
            }
            self.navigationController?.pushViewController(vc, animated: true)

        default:
            break
        }
    }

    func wishlistStatus(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {
    }
}

extension ProductLandingModuleViewController: LoginRegisterDelegate {
    func doLoginRegister() {
        // Put your code here
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            let vc = LoginModuleVC.instantiate(fromAppStoryboard: .Main)
            let navigationContrl = UINavigationController(rootViewController: vc)
            navigationContrl.modalPresentationStyle = .fullScreen
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
//            vc.arrfiltersData = (serverData?.data?.filters) ?? []
            vc.modelDataForListing = ListingDataModel(
                category_id: Int64(strCategoryId),
                gender: Int64(GenericClass.sharedInstance.getGender() ?? "0") ?? 0,
                salon_id: Int64(GenericClass.sharedInstance.getSalonId() ?? "0"),
                brand_unit: nil, is_trending: true,
                hair_type: nil, is_newArrival: false)
            self.navigationController?.pushViewController(vc, animated: true)

        case .new_arrivals:
            let vc = ProductListingModuleViewController.instantiate(fromAppStoryboard: .Products)
            vc.strTitle = identifier.rawValue
//            vc.arrfiltersData = serverData?.data?.filters ?? []
            vc.modelDataForListing = ListingDataModel(category_id: Int64(strCategoryId), gender: Int64(GenericClass.sharedInstance.getGender() ?? "0")!, salon_id: Int64(GenericClass.sharedInstance.getSalonId() ?? "0"), brand_unit: nil, is_trending: nil, hair_type: nil, is_newArrival: true)
            self.navigationController?.pushViewController(vc, animated: true)

        case .get_insightful: break
//            let vc = BlogListingModuleVC.instantiate(fromAppStoryboard: .Blog)
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

                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.productCategoryBackImageCell, for: indexPath) as? ProductCategoryBackImageCell else {
                    return UITableViewCell()
                }

                cell.selectionStyle = .none
                cell.lblTitle.text = childData.name ?? ""
                if let strImg = childData.category_img, !strImg.isEmpty {
                    cell.imgHairCare.kf.setImage(with: URL(string: strImg ), placeholder: UIImage(named: "productDefault"), options: nil, progressBlock: nil, completionHandler: nil)
                }
                return cell

            }
            else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.productCategoryFrontImageCell, for: indexPath) as? ProductCategoryFrontImageCell else {
                    return UITableViewCell()
                }
                cell.selectionStyle = .none
                cell.lblTitle.text = childData.name ?? ""
                if let strImg = childData.category_img, !strImg.isEmpty {
                    cell.imgHairCare.kf.setImage(with: URL(string: strImg), placeholder: UIImage(named: "productDefault"), options: nil, progressBlock: nil, completionHandler: nil)
                }
                return cell
            }

        }
        else {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.productsCollectionCell, for: indexPath) as? ProductsCollectionCell else {
                return UITableViewCell()
            }
            cell.tableViewIndexPath = indexPath
            cell.pageControl = pageControl
            cell.selectionDelegate = self

            cell.addSectionSpacing = (data.identifier == .advetisement ? 0 : (is_iPAD ? 25 : 15) )
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.headerViewWithSubTitleCell) as? HeaderViewWithSubTitleCell else {
                return UITableViewCell()
            }
            cell.configureHeader(title: data.title, subTitle: data.subTitle, hideAllButton: false)
            cell.setFont(titleFont: data.textFont ?? UIFont(), subtitleFont: data.textFont ?? UIFont())
            cell.identifier = data.identifier
            cell.delegate = self
            return cell

        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.headerViewWithTitleCell) as? HeaderViewWithTitleCell else {
                return UITableViewCell()
            }
            cell.configureHeader(title: data.title, hideAllButton: true)
            cell.identifier = data.identifier
            cell.delegate = self
            if data.identifier == .trending || data.identifier == .get_insightful {
                cell.configureHeader(title: data.title, hideAllButton: false)
            }
            cell.setFont(font: data.textFont ?? UIFont())
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let data = self.sections[section]
        if data.identifier == .advetisement {

            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: data.footerHeight))
            let pageControl = UIPageControl(frame: CGRect(x: view.frame.origin.x, y: 5, width: view.frame.size.width, height: data.footerHeight))
            pageControl.pageIndicatorTintColor = .lightGray
            pageControl.currentPageIndicatorTintColor = .red
            pageControl.numberOfPages = data.items
            self.pageControl = pageControl
            view.backgroundColor = UIColor.white
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProductsCollectionCell {
                cell.pageControl = pageControl
            }
            view.addSubview(pageControl)
            return view
        }
        return nil
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = self.sections[indexPath.section]
        return data.cellHeight
    }

    //    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    //        let data = self.sections[section]
    //        return data.showHeader ? data.headerHeight : 0
    //    }

    //    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
    //        let data = self.sections[section]
    //        return data.showFooter ? data.footerHeight : 0
    //    }

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

        let data = self.sections[indexPath.section]
        switch data.identifier {

        case .category:
            if let serverData = serverDataProductCategory, let child1 = serverData.data, let children = child1.children {
                let childData = children[indexPath.row]
                let vc = SubProdListModuleViewController.instantiate(fromAppStoryboard: .Products)
                vc.categoryModel = childData
//                vc.arrBrandforUI = self.modelProductDataForUI.brands
                vc.arrGetInsightfulforUI = self.arrBlogsforUI
                self.navigationController?.pushViewController(vc, animated: true)
                self.modelProductDataForUI = ModelForProductDataUI()
            }
        default : break
        }

        //        if indexPath.section == 1 {
        //            if let serverData = serverDataProductCategory, let child1 = serverData.data, let children = child1.children {
        //                let childData = children[indexPath.row]
        //                let vc = SubProdListModuleViewController.instantiate(fromAppStoryboard: .Products)
        //                vc.categoryModel = childData
        //                vc.arrBrandforUI = self.modelProductDataForUI.brands
        //                vc.arrGetInsightfulforUI = self.arrBlogsforUI
        //
        //                self.navigationController?.pushViewController(vc, animated: true)
        //
        //                self.modelProductDataForUI = ModelForProductDataUI()
        //                self.serverDataProductCategory = nil
        //
        //            }
        //        }
    }

}

extension ProductLandingModuleViewController {

    func configureSection(idetifier: SectionIdentifier, items: Int, data: Any) -> SectionConfiguration {

        let headerHeight: CGFloat = is_iPAD ? 70 : 50
        let leftMargin: CGFloat = is_iPAD ? 25 : 15
        let normalFont = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 30.0 : 20.0)

        switch idetifier {

        case .advetisement: // banner

            let height: CGFloat = is_iPAD ? 320 : 200
            let width: CGFloat = self.productTableView.frame.size.width

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: false, showFooter: true, headerHeight: headerHeight, footerHeight: 30, leftMargin: 0, rightMarging: 0, isPagingEnabled: true, textFont: nil, textColor: UIColor.black, items: items, identifier: idetifier, data: data)

        case .category:

            let height: CGFloat = is_iPAD ? 270 : 175
            let width: CGFloat = self.productTableView.frame.size.width
            let textColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: normalFont, textColor: textColor, items: items, identifier: idetifier, data: data)

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

            let height: CGFloat = is_iPAD ? 350 : 250
            let width: CGFloat = is_iPAD ? 400 : 250

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: normalFont, textColor: .black, items: items, identifier: idetifier, data: data)

        default :
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: 0, showHeader: false, showFooter: false, headerHeight: 0, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: false, textFont: nil, textColor: UIColor.black, items: 0, identifier: idetifier, data: data)
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

            DispatchQueue.main.async { [unowned self] in
                self.updateUIAfterServerData()
                self.productTableView.reloadData()
            }
        }

    }
}
