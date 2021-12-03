//
//  SubProdListModuleViewController.swift
//  EnrichSalon
//

import UIKit
import FirebaseAnalytics

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
    var intCategoryId = GenericClass.sharedInstance.getProductCategoryId()
    private let dispatchGroup = DispatchGroup()

    var arrGetInsightfulforUI: [GetInsightFulDetails] = []
    var arrBrandforUI: [PopularBranchModel] = []
    var arrSubCategoryListforUI: [ServiceModel] = []
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

        self.tblSubProducts.register(UINib(nibName: CellIdentifier.productCategoryBackImageCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.productCategoryBackImageCell)
        self.tblSubProducts.register(UINib(nibName: CellIdentifier.productCategoryFrontImageCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.productCategoryFrontImageCell)
        self.tblSubProducts.register(UINib(nibName: CellIdentifier.headerViewWithTitleCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.headerViewWithTitleCell)

        self.tblSubProducts.separatorStyle = .none
        self.tblSubProducts.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        self.navigationController?.addCustomBackButton(title: categoryModel.name ?? "")

        intCategoryId = categoryModel.id ?? GenericClass.sharedInstance.getProductCategoryId()

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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: Top Navigation Bar And  Actions
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
        self.navigationController?.pushViewController(searchModuleVC, animated: true)
    }

    @objc func didTapCartButton() {
    }
}

// MARK: - CALL APIS
extension SubProdListModuleViewController {

    // MARK: This Api response contains : Product Categories
    func getProductCategoriesFromServer() {
        EZLoadingActivity.show("", disableUI: true)
        dispatchGroup.enter()
        let request = ProductLandingModule.Something.ProductCategoryRequest(category_id: intCategoryId, customer_id: GenericClass.sharedInstance.getCustomerId().toString)
        interactor?.doPostRequestProductCategory(request: request, method: HTTPMethod.post)
    }

    // MARK: This Api response contains : Product Categories types
    func getTypeOfCategoriesFromServer() {
        EZLoadingActivity.show("", disableUI: true)
        dispatchGroup.enter()

        let request = SubProdListModule.Categories.RequestTypes(category_type: self.category_type, category_id: Int64(intCategoryId))
        interactor?.doPostRequestTypes(request: request, method: HTTPMethod.post)
    }

}

// MARK: - SUCCESS ERROR HANDLING
extension SubProdListModuleViewController: SubProdListModuleDisplayLogic {

    func setBrandsModel() {
        var arrBrand: [PopularBranchModel] = []
        if let serverData = serverDataProductCategory, let arrData = serverData.data, let arrBrandsObj = arrData.brands, !arrBrandsObj.isEmpty {
            for model in arrBrandsObj {
                arrBrand.append(PopularBranchModel(value: model.value ?? "", title: model.label ?? "", imageUrl: model.swatch_image_url ?? ""))
            }
        }
        self.arrBrandforUI = arrBrand
        self.updateUIAfterServerData()
    }

    func displaySuccess<T: Decodable>(viewModel: T) {
        DispatchQueue.main.async {[unowned self] in
            EZLoadingActivity.hide()
            // Update UI
            print("\(viewModel)")
            if let object = viewModel as? SubProdListModule.Categories.ResponseTypes {
                self.parseResponseCategoryTypes(obj: object)
            }
            else if let object = viewModel as? ProductLandingModule.Something.ProductCategoryResponse {
                self.parseResponseCategories(obj: object)
            }
        }
    }
    func displaySuccess<T: Decodable>(responseSuccess: [T]) {

    }

    func parseResponseCategories(obj: ProductLandingModule.Something.ProductCategoryResponse ) {
        if obj.status == true {
            self.serverDataProductCategory = obj
            self.arrSubCategoryListforUI = self.interactor!.getServiceModel(data: obj)
            self.setBrandsModel()

            if let catData = obj.data, let categoryType = catData.category_type {
                self.category_type = categoryType
                self.getTypeOfCategoriesFromServer()
            }
        }
        else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj.message )
        }
        self.dispatchGroup.leave()
    }

    func parseResponseCategoryTypes(obj: SubProdListModule.Categories.ResponseTypes) {
        if obj.status == true {
            self.serverDataSubCategoryTypes = obj
            self.setBrandsModel()
            self.arrHairStyleforUI = self.interactor!.getCategoryTypeModel(data: obj.data!)
        }
        else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "Error in response" )
        }
        self.dispatchGroup.leave()
    }

    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        dispatchGroup.leave()
        if (errorMessage ?? "").compareIgnoringCase(find: inActiveCartQuoteId) {
            return
        }
        self.showToast(alertTitle: alertTitle, message: errorMessage ?? "", seconds: toastMessageDuration)
    }
}

// MARK: - UPDATE UI AND CONFIGURE DATA
extension SubProdListModuleViewController {

    // MARK: updateUIAfterServerData
    func updateUIAfterServerData() {
        // configureSections
        sections.removeAll()

        // SUB-CATEGORY
        if !arrSubCategoryListforUI.isEmpty {
            sections.append(configureSection(idetifier: .serviceCell, items: arrSubCategoryListforUI.count, data: arrSubCategoryListforUI as Any))
        }

        // BRANDS
        if !arrBrandforUI.isEmpty {
            sections.append(configureSection(idetifier: .popular, items: arrBrandforUI.count, data: arrBrandforUI as Any))
        }

        // HAIRTYPE
        if !self.arrHairStyleforUI.isEmpty {
            sections.append(configureSection(idetifier: .shop_by_hairtype, items: self.arrHairStyleforUI.count, data: self.arrHairStyleforUI as Any))
        }

        // Popular Products - NEW PRODUCTS
        if !arrPopularCareProductsforUI.isEmpty {
            sections.append(configureSection(idetifier: .new_arrivals, items: arrPopularCareProductsforUI.count, data: arrPopularCareProductsforUI as Any))
        }

        // Get Insghtful - BLOGS
//        if !arrGetInsightfulforUI.isEmpty {
//            sections.append(configureSection(idetifier: .get_insightful, items: (arrGetInsightfulforUI as AnyObject).count, data: arrGetInsightfulforUI))
//        }

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
            let height: CGFloat = is_iPAD ? 120 : 100
            let width: CGFloat = is_iPAD ? 120 : 90

            return SectionConfiguration(title: "Shop by type", subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: false, textFont: normalFont, textColor: .black, items: items, identifier: idetifier, data: data)

        case .popular:

            let height: CGFloat = is_iPAD ? 240 : 200
            let width: CGFloat = is_iPAD ? 192 : 160

            return SectionConfiguration(title: "Shop by brands", subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: normalFont, textColor: .black, items: items, identifier: idetifier, data: data)

        case .new_arrivals:

            let height: CGFloat = is_iPAD ? 475 : 400
            let width: CGFloat = is_iPAD ? ((tblSubProducts.frame.size.width - 100) / 3) : ((tblSubProducts.frame.size.width - 45) / 2)

            return SectionConfiguration(title: ("Popular" + " \(categoryModel.name ?? "") products".lowercased()), subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: normalFont, textColor: .black, items: items, identifier: idetifier, data: data)

        case .get_insightful:

            let height: CGFloat = is_iPAD ? 350 : 240
            let width: CGFloat = is_iPAD ? 400 : 240

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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.productsCollectionCell, for: indexPath) as? ProductsCollectionCell else {
            return UITableViewCell()
        }
        cell.tableViewIndexPath = indexPath
        cell.selectionDelegate = self
        if data.identifier == .serviceCell {
            cell.configureCollectionView(configuration: data, scrollDirection: .vertical)
        }
        else {
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

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.headerViewWithTitleCell) as? HeaderViewWithTitleCell else {
            return UITableViewCell()
        }
        cell.configureHeader(title: data.title, hideAllButton: true)
        if data.identifier == .new_arrivals || data.identifier == .get_insightful {
            cell.configureHeader(title: data.title, hideAllButton: false)
        }
        cell.setFont(font: data.textFont ?? UIFont())
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
            //            let vc = BlogListingModuleVC.instantiate(fromAppStoryboard: .Blog)
            //            self.navigationController?.pushViewController(vc, animated: true)

        case .new_arrivals:
            let vc = ProductListingModuleViewController.instantiate(fromAppStoryboard: .Products)
            //            vc.arrfiltersData = (self.serverDataProductCategory?.data?.filters) ?? []
            vc.modelDataForListing = ListingDataModel(category_id: Int64(intCategoryId), gender: Int64(GenericClass.sharedInstance.getGender() ?? "0"), salon_id: Int64(GenericClass.sharedInstance.getSalonId() ?? "0"), brand_unit: nil, is_trending: nil, hair_type: nil, is_newArrival: false)
            vc.strTitle = "Popular" + " \(categoryModel.name ?? "") products".lowercased()
            vc.isBestsellerProducts = true
            self.navigationController?.pushViewController(vc, animated: true)

        default:
            break
        }
    }
}

// MARK: - HANDLE COLLECTION ACTIONS
extension SubProdListModuleViewController: ProductSelectionDelegate {

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

        // -------- BLOG DETAILS
        case .get_insightful: break
            //            let vc = BlogDetailsModuleVC.instantiate(fromAppStoryboard: .Blog)
            //            let model = self.arrGetInsightfulforUI[indexpath.row]
            //            vc.blog_id = model.blogId
            //            self.navigationController?.pushViewController(vc, animated: true)

        // -------- PRODUCT LISTING
        case .serviceCell:
            let vc = ProductListingModuleViewController.instantiate(fromAppStoryboard: .Products)
            let model: ServiceModel = arrSubCategoryListforUI[indexpath.row]
            vc.strTitle = model.name
            //            vc.arrfiltersData = serverDataProductCategory?.data?.children![indexpath.row].filters ?? []
            vc.modelDataForListing = ListingDataModel(category_id: Int64(model.id), gender: Int64(GenericClass.sharedInstance.getGender() ?? "0"), salon_id: Int64(GenericClass.sharedInstance.getSalonId() ?? "0"), brand_unit: nil, is_trending: nil, hair_type: nil, is_newArrival: false)
            self.navigationController?.pushViewController(vc, animated: true)

        // -------- PRODUCT LISTING
        case .shop_by_hairtype:
            let vc = ProductListingModuleViewController.instantiate(fromAppStoryboard: .Products)
            //            vc.arrfiltersData = (self.serverDataProductCategory?.data?.filters) ?? []
            let model: HairstylesModel = arrHairStyleforUI[indexpath.row]
            vc.strTitle = model.strName
            vc.isBestsellerProducts = false
            vc.strTypeCategory = model.categoryType
            vc.modelDataForListing = ListingDataModel(category_id: Int64(intCategoryId), gender: Int64(GenericClass.sharedInstance.getGender() ?? "0"), salon_id: Int64(GenericClass.sharedInstance.getSalonId() ?? "0"), brand_unit: nil, is_trending: nil, hair_type: Int64(model.value), is_newArrival: false)
            self.navigationController?.pushViewController(vc, animated: true)

        // -------- PRODUCT DETAILS
        case .new_arrivals:
            let model: ProductModel = arrPopularCareProductsforUI[indexpath.row]
            if model.productId > 0 && !model.sku.isEmpty {
                let vc = ProductDetailsModuleVC.instantiate(fromAppStoryboard: .Products)
                vc.objProductId = model.productId
                vc.objProductSKU = model.sku
                self.navigationController?.pushViewController(vc, animated: true)
            }

        // -------- PRODUCT LISTING
        case .popular:
            let vc = ProductListingModuleViewController.instantiate(fromAppStoryboard: .Products)
            //            vc.arrfiltersData = (self.serverDataProductCategory?.data?.filters) ?? []
            let model: PopularBranchModel = arrBrandforUI[indexpath.row] // PopularBranchModel
            vc.strTitle = model.title
            vc.isBestsellerProducts = false
            vc.modelDataForListing = ListingDataModel(category_id: Int64(intCategoryId), gender: Int64(GenericClass.sharedInstance.getGender() ?? "0")!, salon_id: Int64(GenericClass.sharedInstance.getSalonId() ?? "0"), brand_unit: Int64(model.value), is_trending: nil, hair_type: nil, is_newArrival: false)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }

    func setValueOfIsFavourite( arr: [ProductModel], index: Int) {
    }

    func wishlistStatus(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {
    }
}

// MARK: - OPEN LOGIN SCREEN
extension SubProdListModuleViewController: LoginRegisterDelegate {
    func doLoginRegister() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            let vc = LoginModuleVC.instantiate(fromAppStoryboard: .Main)
            let navigationContrl = UINavigationController(rootViewController: vc)
            navigationContrl.modalPresentationStyle = .fullScreen
            self.present(navigationContrl, animated: true, completion: nil)
        }
    }
}

extension SubProdListModuleViewController {
    func updateCellForWishList(status: Bool) {
        let cell = self.tblSubProducts.cellForRow(at: IndexPath(row: 0, section: self.indexPathForWishlist.section)) as? ProductsCollectionCell
        if let productCell = cell?.productCollectionView.cellForItem(at: IndexPath(row: self.indexPathForWishlist.row, section: 0)) as? TrendingProductsCell {
            switch self.identifierLocal {
            case .new_arrivals:
                var arr: [ProductModel] = self.arrPopularCareProductsforUI
                arr[self.indexPathForWishlist.row].isFavourite = status
                self.arrPopularCareProductsforUI = arr
                self.sections[self.indexPathForWishlist.section].data = arr
                productCell.configureCell(model: arr[self.indexPathForWishlist.row])
                cell?.configuration.data = arr

                GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(arr[self.indexPathForWishlist.row].productId)", changedState: status))

            default: break
            }
        }
    }
}
