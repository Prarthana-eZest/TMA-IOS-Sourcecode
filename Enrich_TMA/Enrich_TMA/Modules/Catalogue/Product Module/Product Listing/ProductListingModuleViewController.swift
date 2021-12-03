//
//  ProductListingSearchViewController.swift
//  EnrichSalon
//

import UIKit

class ProductListingSearchViewController: UIViewController {

    lazy var searchBar: UISearchBar = UISearchBar()
    @IBOutlet weak private var productsCollectionView: UICollectionView!
    @IBOutlet weak private var lblProductNotFound: UILabel!

    var interactor: ProductListingModuleBusinessLogic?

    var arrItems: [HairTreatmentModule.Something.Items]?
    private let dispatchGroup = DispatchGroup()// Multi Web Service Calls Hanle Dispatch

    var category_id: Int64 = 0
    var modelDataForListing = ListingDataModel(category_id: nil, gender: nil, salon_id: nil, brand_unit: nil, is_trending: nil, hair_type: nil, is_newArrival: false)
    var strTypeCategory = ""
    var totalItemsCount: Int = 0
    var currentPage = 1
    var strSearchText = ""
    var favoSelectedIndexPath = 0
    var isBestsellerProducts = false

    // MARK: - Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let viewController = self
        let interactor = ProductListingModuleInteractor()
        let presenter = ProductListingModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        productsCollectionView.register(UINib(nibName: CellIdentifier.trendingProductsCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.trendingProductsCell)

        searchBar.placeholder = "Search"
        searchBar.setShowsCancelButton(false, animated: false)
        for subview in searchBar.subviews {
            for innerSubview in subview.subviews {
                if innerSubview is UITextField {
                    innerSubview.backgroundColor = searchBarInsideBackgroundColor
                }
            }
        }
        searchBar.delegate = self
        showSearchController()
        searchBar.becomeFirstResponder()

        lblProductNotFound.isHidden = true

        self.navigationController?.addCustomBackButton(title: "")

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkFevoriteListInAll()
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

}

extension ProductListingSearchViewController: ProductListingModuleDisplayLogic {

    func parseFilterKeys() -> [FilterKeys] {
        var arrForKeysValues: [FilterKeys] = []

        if let gender = modelDataForListing.gender, gender != 0 {
            arrForKeysValues.append(FilterKeys(field: "gender", value: gender, type: "eq"))
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

    // MARK: - Get Search data
    func parseData(text: String) -> [FilterKeys] {
        var arrForKeysValues: [FilterKeys] = parseFilterKeys()

        let array = [FilterKeys(field: "name", value: text, type: "like"), FilterKeys(field: "description", value: text, type: "like"), FilterKeys(field: "short_description", value: text, type: "like")]

        arrForKeysValues.append(FilterKeys(field: "category_id", value: category_id, type: "eq"))
        arrForKeysValues.append(FilterKeys(field: "description_own", value: array, type: ""))

        var arrSalonId: [FilterKeys] = []
        //Salon Id and ecommerce key
//        if  let userSalonId = GenericClass.sharedInstance.getUserSalonIdForProducts(), userSalonId != "0" {
//            arrSalonId = [FilterKeys(field: "salon_id", value:userSalonId , type: "finset" ), FilterKeys(field: "salon_id", value: "ecommerce", type: "finset")]
//        } else {
            arrSalonId = [FilterKeys(field: "salon_id", value: "ecommerce", type: "finset")]
//        }

        if !arrSalonId.isEmpty {
            arrForKeysValues.append(FilterKeys(field: "filter", value: arrSalonId, type: ""))
        }

        arrForKeysValues.append(FilterKeys(field: "visibility", value: 4, type: "eq"))
        arrForKeysValues.append(FilterKeys(field: "status", value: 1, type: "eq"))
//        arrForKeysValues.append(FilterKeys(field: "type_id", value: "configurable", type: "neq"))

        return arrForKeysValues
    }

    // MARK: - Call API - Search product listing
    func callProductListing(text: String) {
        EZLoadingActivity.show("", disableUI: true)
        productsCollectionView.isHidden = true
        lblProductNotFound.isHidden = true
        let query = interactor?.getURLForType(customer_id: GenericClass.sharedInstance.getCustomerId().toDouble, arrSubCat_type: self.parseData(text: text), pageSize: kProductCountPerPageForListing, currentPageNo: self.currentPage, is_config_bundle_brief_info_required: true)
        let request = HairTreatmentModule.Something.Request(queryString: query!)
        interactor?.doGetRequestWithParameter(request: request, isBestSeller: isBestsellerProducts )
    }

    // MARK: - Success
    func displaySuccess<T>(viewModel: T) where T: Decodable {

        if let object = viewModel as? HairTreatmentModule.Something.RemoveFromWishListResponse {
            parseResponseRemoveWishlist(obj: object)
            EZLoadingActivity.hide()
        }
        else if let object = viewModel as? HairTreatmentModule.Something.AddToWishListResponse {
            parseResponseAddWishlist(obj: object)
            EZLoadingActivity.hide()
        }
        else if let object = viewModel as? HairTreatmentModule.Something.Response {
            parseResponseProductListing(obj: object)
        }
    }
    func displaySuccess<T: Decodable>(responseSuccess: [T]) {

    }

    func parseResponseProductListing(obj: HairTreatmentModule.Something.Response) {
        totalItemsCount = obj.total_count ?? 0
        if let item = obj.items, !item.isEmpty {
            arrItems = (arrItems ?? []) + (obj.items ?? [])
        }

        if let arr = arrItems, arr.isEmpty == false {
            currentPage += 1
            productsCollectionView.isHidden = false
            productsCollectionView.reloadData()
        }
        else {
            productsCollectionView.isHidden = true
            lblProductNotFound.isHidden = false
        }

        EZLoadingActivity.hide()
    }

    func parseResponseAddWishlist(obj: HairTreatmentModule.Something.AddToWishListResponse) {
        if let arrItemsObj = arrItems, !arrItemsObj.isEmpty {
            var modelFevo = arrItemsObj[favoSelectedIndexPath]
            modelFevo.extension_attributes?.wishlist_flag = true
            modelFevo.isWishSelected = true
            arrItems![favoSelectedIndexPath] = modelFevo
        GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(modelFevo.id!)", changedState: true))
        }

        if obj.status == true {
            self.showToast(alertTitle: alertTitleSuccess, message: obj.message, seconds: toastMessageDuration)
        }
        else {
            self.showToast(alertTitle: alertTitle, message: obj.message, seconds: toastMessageDuration)
        }
        self.dispatchGroup.leave()
    }

    func parseResponseRemoveWishlist(obj: HairTreatmentModule.Something.RemoveFromWishListResponse) {
        if let arrItemsObj = arrItems, !arrItemsObj.isEmpty {
            var modelFevo = arrItemsObj[favoSelectedIndexPath]
            modelFevo.extension_attributes?.wishlist_flag = false
            modelFevo.isWishSelected = false
            arrItems![favoSelectedIndexPath] = modelFevo
        GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(modelFevo.id!)", changedState: false))
        }

        if obj.status == true {
            self.showToast(alertTitle: alertTitleSuccess, message: obj.message, seconds: toastMessageDuration)
        }
        else {
            self.showToast(alertTitle: alertTitle, message: obj.message, seconds: toastMessageDuration)
        }
        self.dispatchGroup.leave()
    }

    // MARK: - Error
    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        self.dispatchGroup.leave()
        DispatchQueue.main.async { [unowned self] in
            self.showToast(alertTitle: alertTitle, message: errorMessage ?? "", seconds: toastMessageDuration)
        }
    }
}

// MARK: - Show & handle search bar on navigation
extension ProductListingSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text, !text.isEmpty {
            strSearchText = "%\(text)%"
            callProductListing(text: "%\(text)%")

            arrItems = []
            productsCollectionView.reloadData()
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
        perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.75)
    }

    @objc func reload(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.trimmingCharacters(in: .whitespaces) != "" else {
            print("nothing to search")
            return
        }
        print(query)
    }

    func hideSearchController() {
        navigationItem.titleView = nil
    }

    func showSearchController() {

        navigationItem.titleView = searchBar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: AlertButtonTitle.cancel, style: .plain, target: self, action: #selector(searchCancel))
    }

    @objc func searchCancel(sender: UIButton) {
        self.searchBar.text = ""
        self.navigationController?.popViewController(animated: false)
    }
}

// MARK: - Collection view delegates
extension ProductListingSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (arrItems ?? []).count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = arrItems![indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.trendingProductsCell, for: indexPath) as? TrendingProductsCell else {
            return UICollectionViewCell()
        }
        cell.btnCheckBox.isHidden = true
        cell.delegate = self
        cell.indexPath = indexPath
        cell.configureCell(model: interactor!.getProductModel(element: model, isLogin: GenericClass.sharedInstance.isuserLoggedIn().status))
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == ((arrItems ?? []).count - 1) && (arrItems ?? []).count < totalItemsCount {
            callProductListing(text: strSearchText)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let arr = arrItems, !arr.isEmpty {
            let model = arr[indexPath.row]
            if let id = model.id, let sku = model.sku {
                let vc = ProductDetailsModuleVC.instantiate(fromAppStoryboard: .Products)
                vc.objProductId = id
                vc.objProductSKU = sku
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: - Handle Actions - wishlistStatus
extension ProductListingSearchViewController: ProductActionDelegate {

    func moveToCart(indexPath: IndexPath) {
        print("moveToCart \(indexPath)")

    }
    func notifyMe(indexPath: IndexPath) {}

    func actionAddOnCart(indexPath: IndexPath) {
        print("actionAddOnCart")
    }

    func actionQunatity(quantity: Int, indexPath: IndexPath) {
        print("quntity:\(quantity)")
    }

    func wishlistStatus(status: Bool, indexPath: IndexPath) {

    }

    func checkboxStatus(status: Bool, indexPath: IndexPath) {
    }

}

// MARK: - Open login view
extension ProductListingSearchViewController: LoginRegisterDelegate {
    func doLoginRegister() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            let vc = LoginModuleVC.instantiate(fromAppStoryboard: .Main)
            let navigationContrl = UINavigationController(rootViewController: vc)
            navigationContrl.modalPresentationStyle = .fullScreen
            self.present(navigationContrl, animated: true, completion: nil)
        }
    }
}
