import UIKit

class HairServiceModuleVC: UIViewController, SalonServiceModuleDisplayLogic {

    private var interactor: SalonServiceModuleBusinessLogic?

    @IBOutlet weak private var childView: UIView!
    @IBOutlet weak private var bookingDetailsButton: UIButton!
    // Variables For Bottom Cart//
    @IBOutlet weak private var cartViewBottom: UIView!
    @IBOutlet weak private var constraintsCartViewHeight: NSLayoutConstraint!
    @IBOutlet weak private var constraintsBookingDetailsButtonHeight: NSLayoutConstraint!
    @IBOutlet weak private var lblCartViewHours: UILabel!
    @IBOutlet weak private var lblCartViewServicesAndAmount: UILabel!
    @IBOutlet weak private var tableView: UITableView!

    // Variables For Bottom Cart//

    private var selectedCell = 0
    var arrCategories: [HairServiceModule.Something.CategoryModel] = []
    var categoryModel: SalonServiceModule.Something.CategoryModel?
    var arrfiltersData = [HairServiceModule.Something.Filters]()
    var gender_id: String? // Use For HairTreatmentModule API

    var gender: String?
    var reposStoreSalonServiceCategory: LocalJSONStore<HairServiceModule.Something.Response> = LocalJSONStore(storageType: .cache)
    var showORHideFilter: Bool = false
    var searchCancelClicked: Bool = false
    lazy var searchBar: UISearchBar = UISearchBar()
    weak var salonServiceRef: SalonServiceModuleViewController?

    private var totalLoadedRecord: Int64 = 0
    private var recordsPerPage: Int64 = 0
    private var pageNumber: Int = 0
    private var serverDataNewServiceCategory: HairServiceModule.NewServiceCategory.Response?
    private var dataServiceForTable: [HairTreatmentModule.Something.Items] = []
    private var dataServiceForTableOriginal: [HairTreatmentModule.Something.Items] = []
    private var selectedIndexWishList = IndexPath(row: 0, section: 0)
    private var selectedIndexToAddService = IndexPath(row: 0, section: 0)
    private var serverDataForAllCartItemsGuest: [ProductDetailsModule.GetAllCartsItemGuest.Response]?
    private var serverDataForAllCartItemsCustomer: [ProductDetailsModule.GetAllCartsItemCustomer.Response]?
    private let dispatchGroup = DispatchGroup()
    private var search_criteria: HairServiceModule.NewServiceCategory.Search_criteria?

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
        let interactor = SalonServiceModuleInteractor()
        let presenter = SalonServiceModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "Search"
        searchBar.setShowsCancelButton(false, animated: false)
//        searchBar.backgroundColor = UIColor.lightGray
        for subview in searchBar.subviews {
            for innerSubview in subview.subviews {
                if innerSubview is UITextField {
                    innerSubview.backgroundColor = searchBarInsideBackgroundColor
                }
            }
        }
       // searchBar.delegate = self

    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        if let categoryName = self.categoryModel?.name, !categoryName.isEmpty {
            self.navigationController?.addCustomBackButton(title: categoryName)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        UISettings()
    }

    // MARK: UISettings
    func UISettings() {

        tableView.register(UINib(nibName: CellIdentifier.hairTreatmentCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.hairTreatmentCell)
        tableView.register(UINib(nibName: CellIdentifier.serviceCategoryTableViewCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.serviceCategoryTableViewCell)

      bookingDetailsButton.layer.cornerRadius = is_iPAD ? 8 : 5
       showNavigationBarRigtButtons()
        //categoryApiCall()
        setObject()
        categoryNewServiceCategoryAPICall()
        self.showAndHideBottomCart(guestCart: [], customerCart: [])
//        if GenericClass.sharedInstance.isuserLoggedIn().status {
//            getAllCartItemsAPICustomer()
//        }
//        else {
//            getAllCartItemsAPIGuest()
//        }

    }

    // MARK: IBAction
    @IBAction func clickToBookingDetails(_ sender: Any) {
        pushToCartView()

    }

}

extension HairServiceModuleVC {
    func getSalonServiceCategoryDataFromCache() -> Bool {
        var havingCachedData: Bool = false
       /* if let childrenId = self.categoryModel?.id, !childrenId.isEmpty {

            reposStoreSalonServiceCategory = LocalJSONStore(storageType: .cache, filename: String(format: "%@_%@", CacheFileNameKeys.k_file_name_salonHomeServiceSubCategory.rawValue, childrenId), folderName: CacheFolderNameKeys.k_folder_name_SalonHomeServiceSubCategory.rawValue)
        }

        if let repos = reposStoreSalonServiceCategory.storedValue {
            havingCachedData = true
            DispatchQueue.main.async {
                    // CATEGORY
                let viewModel: HairServiceModule.Something.Response = repos
                let obj: HairServiceModule.Something.Response = viewModel
                    self.gender_id = obj.data?.gender_id
                    self.arrCategories = obj.data?.children ?? []

                    if (self.categoryModel?.is_combo)! // Combos is not having childrens/subcatregories on Top Menu
                    {
                        if let childrenlId = self.categoryModel?.id, !childrenlId.isEmpty {
                            let obj = self.hairTreatmentVC as? HairTreatmentModuleVC
                            obj?.is_combo = true
                            obj?.is_FilterHappen = false

                            obj?.searchText = ""
                            obj?.subCategoryId = childrenlId
                            obj?.gender_id = self.gender_id
                            self.showORHideFilter = (self.categoryModel?.filters?.count)! > 0 ? true : false
                            self.showNavigationBarRigtButtons()
                            obj?.refreshData()
                        }
                    }
                    else {
                        if !self.arrCategories.isEmpty {

                            let obj = self.hairTreatmentVC as? HairTreatmentModuleVC
                            obj?.is_combo = false
                            obj?.is_FilterHappen = false

                            obj?.searchText = ""
                            let nw = self.arrCategories[self.selectedCell]
                            obj?.subCategoryId = nw.id
                            obj?.gender_id = self.gender_id
                            self.showORHideFilter = (nw.filters?.count)! > 0 ? true : false
                            self.showNavigationBarRigtButtons()
                            obj?.refreshData()

                        }
                    }


            }
    }*/
        return havingCachedData
}
    func showNavigationBarRigtButtons() {

        guard let sosImg = UIImage(named: "SOS"),
            let callPhoneImg = UIImage(named: "callPhoneImg"),
            let filterSelected = UIImage(named: "filterUnSelected"),
            let searchImg = UIImage(named: "searchImg") else {
                   return
        }

        let callButton = UIBarButtonItem(image: callPhoneImg, style: .plain, target: self, action: #selector(didTapCallButton))
        callButton.tag = 0
        callButton.tintColor = UIColor.black
        let filterButton = UIBarButtonItem(image: filterSelected, style: .plain, target: self, action: #selector(didTapFilter))
        filterButton.tag = 1

        filterButton.tintColor = UIColor.black
        let searchButton = UIBarButtonItem(image: searchImg, style: .plain, target: self, action: #selector(didTapSearchButton))
        searchButton.tag = 2

        searchButton.tintColor = UIColor.black

        let sosButton = UIBarButtonItem(image: sosImg, style: .plain, target: self, action: #selector(didTapSOSButton))
        sosButton.tintColor = UIColor.black
        navigationItem.rightBarButtonItems = [searchButton, callButton]

        if self.showORHideFilter {
            navigationItem.rightBarButtonItems?.append(filterButton)
        }
        if showSOS {
            navigationItem.rightBarButtonItems?.append(sosButton)
        }

    }

       @objc func didTapSOSButton() {
           SOSFactory.shared.raiseSOSRequest()
       }

    func hideNavigationBarRigtButtons() {
        navigationItem.rightBarButtonItems = []
        self.navigationItem.setHidesBackButton(true, animated: false)

    }

    @objc func didTapCallButton() {
        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
            if self.isPhone(userSelectionForService.salon_PhoneNumber) {
                userSelectionForService.salon_PhoneNumber.makeACall()
            }
        }
        else {
            if self.isPhone(salonDefaultNumer) {
                salonDefaultNumer.makeACall()
            }

        }
    }
    @objc func didTapFilter() {

       let filterServicesModuleViewController = FilterServicesModuleViewController
            .instantiate(fromAppStoryboard: .Services)

        if let filterData = serverDataNewServiceCategory?.data?.filters, !filterData.isEmpty {
                //let nw = self.arrCategories[selectedCell]
            filterServicesModuleViewController.arrfitersPassServerData = filterData
            }

        if !self.arrfiltersData.isEmpty {
            filterServicesModuleViewController.arrfiltersServerDataLeftTableView = self.arrfiltersData
        }

        self.view.alpha = screenPopUpAlpha

        UIApplication.shared.keyWindow?.rootViewController?.present(filterServicesModuleViewController, animated: true, completion: nil)
        filterServicesModuleViewController.onDoneBlock = { [unowned self] result, filterValues, isFilterClear in
            // Do something
            if(result) // This is For usee clicked Apply or Close
            {
                print("Clicked Apply")
                if !filterValues.isEmpty {
                    self.arrfiltersData = filterValues
                }
                else {
                    self.arrfiltersData.removeAll()

                }
            }
            else {
                print("Clicked Cancel")
            }
            self.view.alpha = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                       self.resetFilterIcon(isFilterClear: isFilterClear)
            }

        }
    }
    @objc func didTapSearchButton() {
        /*self.constraintTopViewSeprator.constant = -15
        hideNavigationBarRigtButtons()
        self.navigationController?.navigationBar.backItem?.hidesBackButton = true
        showSearchController()*/
        let searchModuleVC = SearchModuleVC.instantiate(fromAppStoryboard: .Services)
        self.navigationController?.pushViewController(searchModuleVC, animated: true)

    }

    // MARK: pushToCartView
    func pushToCartView() {
//        let cartModuleViewController = CartModuleVC.instantiate(fromAppStoryboard: .HomeLanding)
//        self.navigationController?.isNavigationBarHidden = false
//        self.navigationController?.pushViewController(cartModuleViewController, animated: true)

    }
    // MARK: RefreshHairTreatMentData
    func refreshDataForFilters() {

        filterSearchCriteria()
        setObject()
        categoryNewServiceCategoryAPICall()

    }

    // MARK: ResetFilterIcon
    func resetFilterIcon(isFilterClear: Bool) {
        if isFilterClear == true {
            self.arrfiltersData.removeAll()
        }
        let element = self.navigationItem.rightBarButtonItems?.first(where: { $0.tag == 1})
         element?.image = isFilterClear == true ? UIImage(named: "filterUnSelected")! : UIImage(named: "filterSelected")!

        self.refreshDataForFilters()

    }
}

// MARK: - Webservice Calls
extension HairServiceModuleVC {

    func displaySuccess<T: Decodable> (viewModel: T) {

        DispatchQueue.main.async { [unowned self] in

            if T.self == HairServiceModule.NewServiceCategory.Response.self {
                self.parseNewServiceCategory(viewModel: viewModel)
            }
            // Add Wishlist Response
                   else if T.self == HairTreatmentModule.Something.AddToWishListResponse.self {
                       self.parseAddToWishList(viewModel: viewModel)
                   }
                       // Remove From Wishlist Response
                   else if T.self == HairTreatmentModule.Something.RemoveFromWishListResponse.self {
                       self.parseRemoveFromWishList(viewModel: viewModel)

                   }
                   else if T.self == ProductDetailsModule.GetQuoteIDMine.Response.self {
                       // GetQuoteIdMine
                       self.parseDataGetQuoteIDMine(viewModel: viewModel)
                   }
                   else if T.self == ProductDetailsModule.GetQuoteIDGuest.Response.self {
                       // GetQuoteIdGuest
                       self.parseDataGetQuoteIDGuest(viewModel: viewModel)
                   }
                   else if T.self == ProductDetailsModule.AddBulkProductGuest.Response.self {
                       // AddBulkProductGuest
                       self.parseDataBulkProductGuest(viewModel: viewModel)
                   }
                   else if T.self == ProductDetailsModule.AddBulkProductMine.Response.self {
                       // AddBulkProductMine
                       self.parseDataBulkProductMine(viewModel: viewModel)
                   }

        }
    }

    func displayError(errorMessage: String?) {
        self.showToast(alertTitle: alertTitle, message: errorMessage ?? "", seconds: toastMessageDuration)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            EZLoadingActivity.hide()

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

}

// MARK: CartBottom View
extension HairServiceModuleVC {
    func showAndHideBottomCart(guestCart: [ProductDetailsModule.GetAllCartsItemGuest.Response], customerCart: [ProductDetailsModule.GetAllCartsItemCustomer.Response]) {
        /* Code Commented To Show Allready Added this product in Cart
        let records = CoreDataStack.sharedInstance.allRecords(SelectedSalonService.self)
        DispatchQueue.main.async {
            self.constraintsCartViewHeight.constant = records.count > 0 ? (is_iPAD ? 120 : 70) :0
             self.constraintsBookingDetailsButtonHeight.constant = records.count > 0 ? (is_iPAD ? 70 : 45) :0
            self.cartViewBottom.isHidden = records.count > 0 ? false : true
            self.cartViewBottom.layoutIfNeeded()
        }

        GenericClass.sharedInstance.getCartSalonHomeServiceValues(lblHour: self.lblCartViewHours, lblService: self.lblCartViewServicesAndAmount)*/
//        salonServiceRef?.setCartItems(serverDataForAllCartItemsGuest: guestCart, serverDataForAllCartItemsCustomer: customerCart)
//        let isHideShow = CartHelper.sharedInstance.getCartSalonHomeServiceValues(lblHour: self.lblCartViewHours, lblService: self.lblCartViewServicesAndAmount, guestCart: guestCart, customerCart: customerCart)
//        self.constraintsCartViewHeight.constant = isHideShow ? 0 : (is_iPAD ? 120 : 70)
//        self.constraintsBookingDetailsButtonHeight.constant = isHideShow ? 0 : (is_iPAD ? 70 : 45)
//        self.cartViewBottom.isHidden = isHideShow
//        self.cartViewBottom.layoutIfNeeded()

    }

}

// MARK: New Service Category Block With all methods
extension HairServiceModuleVC {

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

    func notifyUpdate() {
        dispatchGroup.notify(queue: .main) {[unowned self] in
            print("dispatchGroup")
            self.showAndHideBottomCart(guestCart: self.serverDataForAllCartItemsGuest ?? [], customerCart: self.serverDataForAllCartItemsCustomer ?? [])

            if let data = self.serverDataForAllCartItemsGuest, !data.isEmpty {
                self.showAndHideBottomCart(guestCart: self.serverDataForAllCartItemsGuest ?? [], customerCart: self.serverDataForAllCartItemsCustomer ?? [])

            }
            if let data = self.serverDataForAllCartItemsCustomer, !data.isEmpty {
                self.showAndHideBottomCart(guestCart: self.serverDataForAllCartItemsGuest ?? [], customerCart: self.serverDataForAllCartItemsCustomer ?? [])
            }
            EZLoadingActivity.hide()
            self.reloadTableView()

        }
    }

    func reloadTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }

    func setObject() {
        totalLoadedRecord = 0
        recordsPerPage = maxlimitToServiceCategoryProducts
        pageNumber = 1
    }

    func setNewServiceCategoryData (obj: HairServiceModule.NewServiceCategory.Response) {

        if pageNumber == 1 {
            if let serviceItems = obj.data?.services?.items, !serviceItems.isEmpty {
            self.dataServiceForTable = serviceItems
            self.dataServiceForTableOriginal = serviceItems

            }
        }
        else {
            if let serviceItems = obj.data?.services?.items, !serviceItems.isEmpty {
                let newDataFromServer: [HairTreatmentModule.Something.Items] = serviceItems
                var originalArray: [HairTreatmentModule.Something.Items] = self.dataServiceForTable
                originalArray.append(contentsOf: newDataFromServer)
                self.dataServiceForTable = originalArray
                self.dataServiceForTableOriginal = originalArray

            }
        }
        createDataAndAppendCategoryDataIfAny()
        setDefaultValueForConfigurable()
        self.updateRecordInfo()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.reloadData()
    }

    func updateRecordInfo() {

        if pageNumber == 1 {
            pageNumber = 2
            totalLoadedRecord = recordsPerPage
        }
        else {
            totalLoadedRecord += recordsPerPage
            pageNumber += 1
        }
    }
    // MARK: - Methods for Pagination End
    func loadMoreTableData() {
        categoryNewServiceCategoryAPICall()
    }

    func createDataAndAppendCategoryDataIfAny() {
        self.dataServiceForTable.removeAll(where: {$0.type_id == SalonServiceTypes.category})

        if let category = serverDataNewServiceCategory?.data?.category, !category.isEmpty, dataServiceForTable.count == serverDataNewServiceCategory?.data?.services?.total_number ?? 0 {
            for(_, element) in category.enumerated() {

                var imageURl: String = ""
                if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
                    imageURl = (userSelectionForService.gender == PersonType.male ? element.male_img : element.female_img) ?? ""
                           }
                let mediagallery = HairTreatmentModule.Something.Media_gallery_entries(id: 1, media_type: imageURl, label: "", position: 1, disabled: false, types: [], file: "")

                let newObj = HairTreatmentModule.Something.Items(id: Int64(element.id ?? "0"), sku: "", name: element.name ?? "", link_type: "", attribute_set_id: 0, price: 0.0, specialPrice: 0.0, offerPercentage: "0", status: 0, visibility: 0, type_id: SalonServiceTypes.category, created_at: "", updated_at: "", stock_status: 0, extension_attributes: nil, media_gallery_entries: [mediagallery], custom_attributes: [], isItemSelected: false, isWishSelected: false)

                self.dataServiceForTable.append(newObj)

            }

        }
        self.dataServiceForTableOriginal = dataServiceForTable

    }

    // MARK: - Methods categoryNewServiceCategoryAPICall
    func categoryNewServiceCategoryAPICall() {
           EZLoadingActivity.show("", disableUI: true)

           if self.getSalonServiceCategoryDataFromCache() == false {
               if let childrenlId = self.categoryModel?.id, !childrenlId.isEmpty {
                   if  let userSalonId = GenericClass.sharedInstance.getSalonId(), userSalonId != "0" {

                reposStoreSalonServiceCategory = LocalJSONStore(storageType: .cache, filename: String(format: "%@_%@", CacheFileNameKeys.k_file_name_salonHomeServiceSubCategory.rawValue, childrenlId), folderName: CacheFolderNameKeys.k_folder_name_SalonHomeServiceSubCategory.rawValue)

                    let request = HairServiceModule.NewServiceCategory.Request(customer_id: nil, category_id: childrenlId, salon_id: userSalonId, gender: self.gender ?? "", limit: recordsPerPage, page: pageNumber, search_criteria: self.search_criteria)
                       interactor?.postRequestNewServiceCategory(request: request, method: HTTPMethod.post)
                   }
               }

           }

       }

    func parseNewServiceCategory<T: Decodable>(viewModel: T) {
           if let obj = viewModel as? HairServiceModule.NewServiceCategory.Response {
               if obj.status == true {
                print("New Service Category Data \(obj)")
                self.serverDataNewServiceCategory = obj
                self.setNewServiceCategoryData(obj: obj)
                if let filters = obj.data?.filters {
                    self.showORHideFilter = filters.isEmpty ? false : true
                }
                self.showNavigationBarRigtButtons()

               }
               else {
                   tableView.delegate = self
                   tableView.dataSource = self
                   self.tableView.reloadData()
               }
               EZLoadingActivity.hide()
           }

       }

}

extension HairServiceModuleVC: ServiceCategoryTableViewCellDelegate {
    func viewMoreDetails(indexPath: IndexPath) {
        print("viewMoreDetails Clicked Index \(indexPath)")

        let hairServiceModuleViewController = HairServiceModuleVC.instantiate(fromAppStoryboard: .Services)
        let categoryModel = SalonServiceModule.Something.CategoryModel(id: String(format: "\(dataServiceForTable[indexPath.row].id ?? 0)"), name: dataServiceForTable[indexPath.row].name ?? "", desc: "", male_img: dataServiceForTable[indexPath.row].media_gallery_entries?.first?.media_type, female_img: dataServiceForTable[indexPath.row].media_gallery_entries?.first?.media_type, url: "", is_combo: false, filters: [])
        hairServiceModuleViewController.categoryModel = categoryModel
        hairServiceModuleViewController.salonServiceRef = nil // Aman
        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
            hairServiceModuleViewController.gender = userSelectionForService.gender
        }
        self.navigationController?.pushViewController(hairServiceModuleViewController, animated: true)

    }
}

extension HairServiceModuleVC: HairTreatmentCellDelegate {
    func moveToCart(indexPath: Int) {
        print("moveToCart Clicked Index \(indexPath)")

    }

    func addAction(indexPath: IndexPath) {
        print("addAction Clicked Index \(indexPath)")
//        if GenericClass.sharedInstance.isServiceFlowEnabled().is_services_disabled == false {
//            selectedIndexToAddService = indexPath
//              let model = dataServiceForTable[indexPath.row]
//                if CartHelper.sharedInstance.toShowAlertForAllAddToCartServiceScenerio(model: model, serverDataForAllCartItemsGuest: serverDataForAllCartItemsGuest ?? [], serverDataForAllCartItemsCustomer: serverDataForAllCartItemsCustomer ?? [], viewController: self) {
//
//                    GenericClass.sharedInstance.isuserLoggedIn().status ? addToCartSimpleOrVirtualProductForCustomer(selected: model) : addToCartSimpleOrVirtualProductForGuest(selected: model)
//                }
//        }
//        else {
//            self.showAlert(alertTitle: alertTitle, alertMessage: GenericClass.sharedInstance.isServiceFlowEnabled().disabled_services_msg)
//        }

    }
    func wishList(indexPath: IndexPath) {
        print("wishList Clicked Index \(indexPath)")
        selectedIndexWishList = indexPath

        guard let cell = tableView.cellForRow(at: indexPath) as? HairTreatmentCell  else {
            return
        }

        if GenericClass.sharedInstance.isuserLoggedIn().status {

            if cell.btnWishList.isSelected {
                addToWishListApiCall(indexPath: indexPath)
            }
            else // Remove WishList
            {
                removeFromWishListApiCall(indexPath: indexPath)
            }

            return
        }
        setValues(self.tableView, cellForRowAt: indexPath, cell: cell)

        openLoginWindow()

    }

    func viewDetails(indexPath: Int) {
        print("viewDetails Clicked Index \(indexPath)")

        let serviceDetailVC = ServiceDetailModuleVC
            .instantiate(fromAppStoryboard: .Services)
        serviceDetailVC.serverData = dataServiceForTable
        serviceDetailVC.subCategoryDataObjSelectedIndex = indexPath
        serviceDetailVC.isShowAddToCart = false
        self.navigationController?.pushViewController(serviceDetailVC, animated: true)
        serviceDetailVC.onDoneBlock = { [unowned self] result, data in
            // Do something
            if result {

            }
            else {

            }
            self.dataServiceForTable = data
            /* Code Commented To for Database and Cache
            let finaldata = GenericClass.sharedInstance.checkDataInDatabase(data: self.serverData!)
            self.reposStoreSalonSubCategoryList.save(finaldata)*/
            self.tableView.reloadData()
        }

    }

    func addOns(indexPath: Int) {
        print("addOns Clicked Index \(indexPath)")

        let addOnsModuleViewController = AddOnsModuleViewController
            .instantiate(fromAppStoryboard: .Services)

        addOnsModuleViewController.selectedIndex = indexPath
        addOnsModuleViewController.serverData = dataServiceForTable
        self.view.alpha = screenPopUpAlpha
        UIApplication.shared.keyWindow?.rootViewController?.present(addOnsModuleViewController, animated: true, completion: nil)
        addOnsModuleViewController.onDoneBlock = { [unowned self] result, data in
            // Do something
            if result {
                print("Clicked Add")

            }
            else {
                print("Clicked Cancel")

            }
            self.dataServiceForTable = data ?? []
            self.view.alpha = 1.0
            self.tableView.reloadData()

//            if let parentObj = self.parent {
//                if let parentVC = parentObj as? HairServiceModuleVC {
//                    parentVC.lblNoDataAvailable.isHidden = false
//                }
//            }
        }

    }

    func optionsBeTheFirstToReview(indexPath: IndexPath) {
//        let model = dataServiceForTable[indexPath.row]
//
//        if  GenericClass.sharedInstance.isuserLoggedIn().status {
//            let vc = RateTheProductVC.instantiate(fromAppStoryboard: .Products)
//            self.view.alpha = screenPopUpAlpha
//            self.appDelegate.window?.rootViewController!.present(vc, animated: true, completion: {
//                vc.lblProductName.text = model.name ?? ""
//                vc.product_id = model.id ?? 0
//                if  !(model.extension_attributes?.media_url ?? "").isEmpty &&  !(model.media_gallery_entries?.first?.file ?? "").isEmpty {
//                    vc.showProductImage(imageStr: String(format: "%@%@", model.extension_attributes?.media_url ?? "", (model.media_gallery_entries?.first?.file)!), typeServiceOrProduct: "Service")
//                }
//
//            })
//            vc.onDoneBlock = { [unowned self] result in
//                self.view.alpha = 1.0
//            } }
// else { openLoginWindow() }
    }

    func updateCellAfterAddToCart() {

        guard let cell = tableView.cellForRow(at: selectedIndexToAddService) as? HairTreatmentCell  else {
                return
            }

            let model = dataServiceForTable[selectedIndexToAddService.row]

            if !(model.isItemSelected ?? false)! {
                dataServiceForTable[selectedIndexToAddService.row].isItemSelected = true
                /* Code Commented To for Database and Cache
                 CoreDataStack.sharedInstance.updateDataBase(obj: self.serverData?.items?[indexPath.row] as AnyObject)*/
            }

            setValues(self.tableView, cellForRowAt: selectedIndexToAddService, cell: cell)

    }

}

// MARK: Cart And All API CALLS
extension HairServiceModuleVC {

    // MARK: API Call ADD TO WishList
       func addToWishListApiCall(indexPath: IndexPath) {

//           let productId: Int64 = (dataServiceForTable[indexPath.row].id)!
//           var arrayOfWishList  = [HairTreatmentModule.Something.Wishlist_item]()
//           let wishListItem = HairTreatmentModule.Something.Wishlist_item(product: productId, qty: 1)
//           arrayOfWishList.append(wishListItem)
//            if  GenericClass.sharedInstance.isuserLoggedIn().status == true {
//                   EZLoadingActivity.show("", disableUI: true)
//                   dispatchGroup.enter()
//                   notifyUpdate()
//
//                let request = HairTreatmentModule.Something.AddToWishListRequest(customer_id: GenericClass.sharedInstance.isuserLoggedIn().customerId.toString, wishlist_item: arrayOfWishList)
//                   interactor?.doPostRequestAddToWishList(request: request, method: HTTPMethod.post, accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken)
//           }

       }
       // MARK: API Call REMOVE FROM WishList

       func removeFromWishListApiCall(indexPath: IndexPath) {

//           let itemId: Int64 = (dataServiceForTable[indexPath.row].id)!
//            if  GenericClass.sharedInstance.isuserLoggedIn().status == true {
//                   EZLoadingActivity.show("", disableUI: true)
//                   dispatchGroup.enter()
//                   notifyUpdate()
//
//                let request = HairTreatmentModule.Something.RemoveFromWishListRequest(customer_id: GenericClass.sharedInstance.isuserLoggedIn().customerId.toString, product_id: itemId)
//                   interactor?.doPostRequestRemoveFromWishList(request: request, method: HTTPMethod.post, accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken)
//           }

       }

    // MARK: addToCartSimpleOrVirtualProductForCustomer
    func addToCartSimpleOrVirtualProductForCustomer(selected: HairTreatmentModule.Something.Items) {
//        if let object = UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDMine.Response.self, forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart) {
//            var arrayOfItems =  [ProductDetailsModule.AddBulkProductMine.Items]()
//            var arrayOfSimpleProduct = [ProductModel]()
//
//            if selected.type_id == SalonServiceTypes.simple || selected.type_id == SalonServiceTypes.virtual {
//
//                let model = ProductModel(productId: selected.id ?? 0, productName: selected.name ?? "", price: 0.0, specialPrice: 0.0, reviewCount: "0", ratingPercentage: 0.0, showCheckBox: true, offerPercentage: "0", isFavourite: false, strImage: "", sku: (selected.sku ?? ""), isProductSelected: false, type_id: selected.type_id ?? "", type_of_service: selected.extension_attributes?.type_of_service ?? "")
//                arrayOfSimpleProduct.append(model)
//
//            }
//            else if selected.type_id == SalonServiceTypes.configurable {
//
//                var arrOfConfigurable = [ProductDetailsModule.AddBulkProductMine.Configurable_item_options]()
//                if let productOptions = selected.extension_attributes?.configurable_subproduct_options {
//                    let productLinks = productOptions.first(where: { $0.isSubProductConfigurableSelected == true})
//                    arrOfConfigurable.append(ProductDetailsModule.AddBulkProductMine.Configurable_item_options(option_id: Int64(productLinks?.attribute_id ?? "0"), option_value: Int64(productLinks?.value_index ?? "0")))
//                }
//
//                let extensionAttribute = ProductDetailsModule.AddBulkProductMine.Extension_attributes(configurable_item_options: arrOfConfigurable, bundle_options: nil)
//
//                let productOptions = ProductDetailsModule.AddBulkProductMine.Product_option(extension_attributes: extensionAttribute)
//                let object = ProductDetailsModule.AddBulkProductMine.Items(sku: selected.sku ?? "", qty: 1, product_option: productOptions, appointment_type: selected.extension_attributes?.type_of_service ?? "", is_rebook: false)
//                arrayOfItems.append(object)
//
//            }
//            else if selected.type_id == SalonServiceTypes.bundle {
//
//                var arrOfBundleProduct = [ProductDetailsModule.AddBulkProductMine.Bundle_options]()
//                var arrOfOptionSelected = [Int64]()
//                if let productOptions = selected.extension_attributes?.bundle_product_options {
//                    let productLinks = productOptions.compactMap {
//                        $0.product_links?.filter { $0.isBundleProductOptionsSelected ?? false }
//                    }.flatMap { $0 }
//                    productLinks.forEach {
//                        arrOfOptionSelected.append(Int64($0.id?.description ?? "0") ?? 0)
//                        arrOfBundleProduct.append(ProductDetailsModule.AddBulkProductMine.Bundle_options(option_id: $0.option_id ?? 0, option_selections: arrOfOptionSelected, option_qty: 1 ))
//                        arrOfOptionSelected.removeAll()
//
//                    }
//                }
//
//                let extensionAttribute = ProductDetailsModule.AddBulkProductMine.Extension_attributes(configurable_item_options: nil, bundle_options: arrOfBundleProduct)
//
//                let productOptions = ProductDetailsModule.AddBulkProductMine.Product_option(extension_attributes: extensionAttribute)
//                let object = ProductDetailsModule.AddBulkProductMine.Items(sku: selected.sku ?? "", qty: 1, product_option: productOptions, appointment_type: selected.extension_attributes?.type_of_service ?? "", is_rebook: false)
//                arrayOfItems.append(object)
//
//            }
//
//            for (_, element) in arrayOfSimpleProduct.enumerated() {
//                let object = ProductDetailsModule.AddBulkProductMine.Items(sku: element.sku, qty: 1, product_option: nil, appointment_type: element.type_of_service, is_rebook: false)
//                arrayOfItems.append(object)
//            }
//            if !arrayOfItems.isEmpty {
//                callAddToCartBulkProductAPIMine(items: arrayOfItems, quote_Id: object.data?.quote_id ?? 0 )
//            }
//
//        }
//        else {
//            callQuoteIdMineAPI()
//            if let object = UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDMine.Response.self, forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart) {
//                var arrayOfItems =  [ProductDetailsModule.AddBulkProductMine.Items]()
//                var arrayOfSimpleProduct = [ProductModel]()
//
//                if selected.type_id == SalonServiceTypes.simple || selected.type_id == SalonServiceTypes.virtual {
//
//                    let model = ProductModel(productId: selected.id ?? 0, productName: selected.name ?? "", price: 0.0, specialPrice: 0.0, reviewCount: "0", ratingPercentage: 0.0, showCheckBox: true, offerPercentage: "0", isFavourite: false, strImage: "", sku: (selected.sku ?? ""), isProductSelected: false, type_id: selected.type_id ?? "", type_of_service: selected.extension_attributes?.type_of_service ?? "")
//                    arrayOfSimpleProduct.append(model)
//                }
//                else if selected.type_id == SalonServiceTypes.configurable {
//
//                    var arrOfConfigurable = [ProductDetailsModule.AddBulkProductMine.Configurable_item_options]()
//                    if let productOptions = selected.extension_attributes?.configurable_subproduct_options {
//                        let productLinks = productOptions.first(where: { $0.isSubProductConfigurableSelected == true})
//                        arrOfConfigurable.append(ProductDetailsModule.AddBulkProductMine.Configurable_item_options(option_id: Int64(productLinks?.attribute_id ?? "0"), option_value: Int64(productLinks?.value_index ?? "0")))
//                    }
//
//                    let extensionAttribute = ProductDetailsModule.AddBulkProductMine.Extension_attributes(configurable_item_options: arrOfConfigurable, bundle_options: nil)
//
//                    let productOptions = ProductDetailsModule.AddBulkProductMine.Product_option(extension_attributes: extensionAttribute)
//                    let object = ProductDetailsModule.AddBulkProductMine.Items(sku: selected.sku ?? "", qty: 1, product_option: productOptions, appointment_type: selected.extension_attributes?.type_of_service ?? "", is_rebook: false)
//                    arrayOfItems.append(object)
//                }
//                else if selected.type_id == SalonServiceTypes.bundle {
//
//                    var arrOfBundleProduct = [ProductDetailsModule.AddBulkProductMine.Bundle_options]()
//                    var arrOfOptionSelected = [Int64]()
//                    if let productOptions = selected.extension_attributes?.bundle_product_options {
//                        let productLinks = productOptions.compactMap {
//                            $0.product_links?.filter { $0.isBundleProductOptionsSelected ?? false }
//                        }.flatMap { $0 }
//                        productLinks.forEach {
//                            arrOfOptionSelected.append(Int64($0.id?.description ?? "0") ?? 0)
//                            arrOfBundleProduct.append(ProductDetailsModule.AddBulkProductMine.Bundle_options(option_id: $0.option_id ?? 0, option_selections: arrOfOptionSelected, option_qty: 1 ))
//                            arrOfOptionSelected.removeAll()
//
//                        }
//                    }
//
//                    let extensionAttribute = ProductDetailsModule.AddBulkProductMine.Extension_attributes(configurable_item_options: nil, bundle_options: arrOfBundleProduct)
//
//                    let productOptions = ProductDetailsModule.AddBulkProductMine.Product_option(extension_attributes: extensionAttribute)
//                    let object = ProductDetailsModule.AddBulkProductMine.Items(sku: selected.sku ?? "", qty: 1, product_option: productOptions, appointment_type: selected.extension_attributes?.type_of_service ?? "", is_rebook: false)
//                    arrayOfItems.append(object)
//
//                }
//
//                for (_, element) in arrayOfSimpleProduct.enumerated() {
//                    let object = ProductDetailsModule.AddBulkProductMine.Items(sku: element.sku, qty: 1, product_option: nil, appointment_type: element.type_of_service , is_rebook: false)
//                    arrayOfItems.append(object)
//                }
//
//                if !arrayOfItems.isEmpty {
//                    callAddToCartBulkProductAPIMine(items: arrayOfItems, quote_Id: object.data?.quote_id ?? 0 )
//                }
//
//            }
//        }
    }

    // MARK: addToCartSimpleOrVirtualProductForGuest
    func addToCartSimpleOrVirtualProductForGuest(selected: HairTreatmentModule.Something.Items) {
//        if let object = UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDGuest.Response.self, forKey: UserDefauiltsKeys.k_key_GuestQuoteIdForCart) {
//            var arrayOfItems = [ProductDetailsModule.AddBulkProductGuest.Items]()
//            var arrayOfSimpleProduct = [ProductModel]()
//
//            if selected.type_id == SalonServiceTypes.simple || selected.type_id == SalonServiceTypes.virtual {
//
//                let model = ProductModel(productId: selected.id ?? 0, productName: selected.name ?? "", price: 0.0, specialPrice: 0.0, reviewCount: "0", ratingPercentage: 0.0, showCheckBox: true, offerPercentage: "0", isFavourite: false, strImage: "", sku: (selected.sku ?? ""), isProductSelected: false, type_id: selected.type_id ?? "", type_of_service: selected.extension_attributes?.type_of_service ?? "")
//                arrayOfSimpleProduct.append(model)
//            }
//            else if selected.type_id == SalonServiceTypes.configurable {
//
//                var arrOfConfigurable = [ProductDetailsModule.AddBulkProductGuest.Configurable_item_options]()
//                if let productOptions = selected.extension_attributes?.configurable_subproduct_options {
//                    let productLinks = productOptions.first(where: { $0.isSubProductConfigurableSelected == true})
//                    arrOfConfigurable.append(ProductDetailsModule.AddBulkProductGuest.Configurable_item_options(option_id: Int64(productLinks?.attribute_id ?? "0"), option_value: Int64(productLinks?.value_index ?? "0")))
//                }
//
//                let extensionAttribute = ProductDetailsModule.AddBulkProductGuest.Extension_attributes(configurable_item_options: arrOfConfigurable, bundle_options: nil)
//
//                let productOptions = ProductDetailsModule.AddBulkProductGuest.Product_option(extension_attributes: extensionAttribute)
//                let object = ProductDetailsModule.AddBulkProductGuest.Items(sku: selected.sku ?? "", qty: 1, product_option: productOptions, appointment_type: selected.extension_attributes?.type_of_service ?? "")
//                arrayOfItems.append(object)
//            }
//            else if selected.type_id == SalonServiceTypes.bundle {
//
//                var arrOfBundleProduct = [ProductDetailsModule.AddBulkProductGuest.Bundle_options]()
//                var arrOfOptionSelected = [Int64]()
//                if let productOptions = selected.extension_attributes?.bundle_product_options {
//                    let productLinks = productOptions.compactMap {
//                        $0.product_links?.filter { $0.isBundleProductOptionsSelected ?? false }
//                    }.flatMap { $0 }
//                    productLinks.forEach {
//                        arrOfOptionSelected.append(Int64($0.id?.description ?? "0") ?? 0)
//                        arrOfBundleProduct.append(ProductDetailsModule.AddBulkProductGuest.Bundle_options(option_id: $0.option_id ?? 0, option_selections: arrOfOptionSelected, option_qty: 1 ))
//                        arrOfOptionSelected.removeAll()
//                    }
//
//                }
//
//                let extensionAttribute = ProductDetailsModule.AddBulkProductGuest.Extension_attributes(configurable_item_options: nil, bundle_options: arrOfBundleProduct)
//
//                let productOptions = ProductDetailsModule.AddBulkProductGuest.Product_option(extension_attributes: extensionAttribute)
//                let object = ProductDetailsModule.AddBulkProductGuest.Items(sku: selected.sku ?? "", qty: 1, product_option: productOptions, appointment_type: selected.extension_attributes?.type_of_service ?? "" )
//                arrayOfItems.append(object)
//
//            }
//
//            for (_, element) in arrayOfSimpleProduct.enumerated() {
//                let object = ProductDetailsModule.AddBulkProductGuest.Items(sku: element.sku, qty: 1, product_option: nil, appointment_type: element.type_of_service )
//                arrayOfItems.append(object)
//            }
//            if !arrayOfItems.isEmpty {
//                callAddToCartBulkProductAPIGuest(items: arrayOfItems, quote_Id: object.data?.quote_id ?? "" )
//            }
//
//        }
//        else {
//            callToGetQuoteIdGuestAPI()
//        }

    }

    // MARK: API callQuoteIdMineAPI
    func callQuoteIdMineAPI() {

        let request = ProductDetailsModule.GetQuoteIDMine.Request()
        interactor?.doPostRequestGetQuoteIdMine(request: request, accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken)
    }
    // MARK: API callToGetQuoteIdGuestAPI
    func callToGetQuoteIdGuestAPI() {
        let request = ProductDetailsModule.GetQuoteIDGuest.Request()
        interactor?.doPostRequestGetQuoteIdGuest(request: request, method: HTTPMethod.post)
    }

    // MARK: API callAddToCartBulkProductAPIMine
    func callAddToCartBulkProductAPIMine(items: [ProductDetailsModule.AddBulkProductMine.Items], quote_Id: Int64) {

//        EZLoadingActivity.show("", disableUI: true)
//        dispatchGroup.enter()
//        notifyUpdate()
//        var salonId: String = ""
//        if  let userSalonId = GenericClass.sharedInstance.getSalonId(), userSalonId != "0" {
//            salonId = userSalonId
//        }
////        var serviceAt: String =  ""
////        if  let dummy = UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_Key_SelectedLocationFor) {
////            let obj = dummy as! String
////            serviceAt = obj.lowercased()
////        }
//        let request = ProductDetailsModule.AddBulkProductMine.Request(items: items, quote_id: quote_Id, salon_id: Int64(salonId))
//
//        interactor?.doPostRequestAddBulkProductToCartMine(request: request, method: HTTPMethod.post, accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken, customer_id: GenericClass.sharedInstance.isuserLoggedIn().customerId.toString)
    }

    // MARK: API callAddToCartBulkProductAPIGuest
    func callAddToCartBulkProductAPIGuest(items: [ProductDetailsModule.AddBulkProductGuest.Items], quote_Id: String) {
        EZLoadingActivity.show("", disableUI: true)
        dispatchGroup.enter()
        notifyUpdate()
        var salonId: String = ""
        if  let userSalonId = GenericClass.sharedInstance.getSalonId(), userSalonId != "0" {
            salonId = userSalonId
        }
//        var serviceAt: String =  ""
//        if  let dummy = UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_Key_SelectedLocationFor) {
//            let obj = dummy as! String
//            serviceAt = obj.lowercased()
//        }
        let request = ProductDetailsModule.AddBulkProductGuest.Request(items: items, quote_id: quote_Id, salon_id: Int64(salonId))

        interactor?.doPostRequestAddBulkProductToCartGuest(request: request, method: HTTPMethod.post)
    }
    func getAllCartItemsAPIGuest() {

        if let object = UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDGuest.Response.self, forKey: UserDefauiltsKeys.k_key_GuestQuoteIdForCart) {

            let request = ProductDetailsModule.GetAllCartsItemGuest.Request(quote_id: object.data?.quote_id ?? "")
            interactor?.doGetRequestToGetAllCartItemsGuest(request: request, method: HTTPMethod.get)
        }
        else {
            callToGetQuoteIdGuestAPI()
        }

    }
    func getAllCartItemsAPICustomer() {
        // Success Needs To check Static
        if UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDMine.Response.self, forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart) != nil {

            //let request = ProductDetailsModule.GetAllCartsItemCustomer.Request(quote_id: object.data?.quote_id ?? 0, accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken )
            let request = ProductDetailsModule.GetAllCartsItemCustomer.Request(accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken )
            interactor?.doGetRequestToGetAllCartItemsCustomer(request: request, method: HTTPMethod.get)

        }
        else {
            callQuoteIdMineAPI()
        }
    }

    // MARK: Parsing Methods For Carts
    func parseDataBulkProductGuest<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ProductDetailsModule.AddBulkProductGuest.Response
        if obj?.status == true {
            // Success Needs To check
            self.updateCellAfterAddToCart()
            EZLoadingActivity.hide()
            self.getAllCartItemsAPIGuest()
        }
        else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj?.message ?? "")

        }
        self.dispatchGroup.leave()

    }

    func parseDataBulkProductMine<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ProductDetailsModule.AddBulkProductMine.Response
        if obj?.status == true {
            // Success Needs To check
            if let activeQuoteId = obj?.quote_id {
                GenericClass.sharedInstance.updateCustomerQuoteId(customerQuoteid: activeQuoteId)
            }
            self.updateCellAfterAddToCart()
            EZLoadingActivity.hide()
            self.getAllCartItemsAPICustomer()
        }
        else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj?.message ?? "")

        }
        self.dispatchGroup.leave()

    }

    func parseGetAllCartsItemCustomer<T: Decodable>(responseSuccess: [T]) {
        // GetAllCartItemsForCustomer
//        if  let responseObj = responseSuccess as? [ProductDetailsModule.GetAllCartsItemCustomer.Response] {
//            self.serverDataForAllCartItemsCustomer = responseObj
//            let salonAddress = CartHelper.sharedInstance.getSalonAddressInCaseServiceInCart(serverDataForAllCartItemsGuest: [], serverDataForAllCartItemsCustomer: responseObj)
//            if !salonAddress.isEmpty {
//                UserDefaults.standard.set(salonAddress.first?.salon_id, forKey: UserDefauiltsKeys.k_key_CartHavingSalonIdIfService)
//
//            }
//            else {
//                UserDefaults.standard.removeObject(forKey: UserDefauiltsKeys.k_key_CartHavingSalonIdIfService)
//
//            }
//            GenericClass.sharedInstance.updateCartBadgeNumber(badgeCount: responseObj.count, appDelegate: self.appDelegate)
//            self.showAndHideBottomCart(guestCart: self.serverDataForAllCartItemsGuest ?? [], customerCart: self.serverDataForAllCartItemsCustomer ?? [])
//        }
//        else {
//            self.showAlert(alertTitle: alertTitle, alertMessage: GenericError)
//
//        }

    }

    func parseGetAllCartsItemGuest<T: Decodable>(responseSuccess: [T]) {

//        if  let responseObj = responseSuccess as? [ProductDetailsModule.GetAllCartsItemGuest.Response] {
//            self.serverDataForAllCartItemsGuest = responseObj
//            let salonAddress = CartHelper.sharedInstance.getSalonAddressInCaseServiceInCart(serverDataForAllCartItemsGuest: responseObj, serverDataForAllCartItemsCustomer: [])
//            if !salonAddress.isEmpty {
//                UserDefaults.standard.set(salonAddress.first?.salon_id, forKey: UserDefauiltsKeys.k_key_CartHavingSalonIdIfService)
//
//            }
//            else {
//                UserDefaults.standard.removeObject(forKey: UserDefauiltsKeys.k_key_CartHavingSalonIdIfService)
//
//            }
//            GenericClass.sharedInstance.updateCartBadgeNumber(badgeCount: responseObj.count, appDelegate: self.appDelegate)
//            self.showAndHideBottomCart(guestCart: self.serverDataForAllCartItemsGuest ?? [], customerCart: self.serverDataForAllCartItemsCustomer ?? [])
//
//        }
//        else {self.showAlert(alertTitle: alertTitle, alertMessage: GenericError)}

    }

    func parseDataGetQuoteIDMine<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ProductDetailsModule.GetQuoteIDMine.Response
        if obj?.status == true {
            UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart)

            self.getAllCartItemsAPICustomer()
        }
        else {}
    }

    func parseDataGetQuoteIDGuest<T: Decodable>(viewModel: T) {
        // GetQuoteIdGuest
        let obj = viewModel as? ProductDetailsModule.GetQuoteIDGuest.Response
        if obj?.status == true {
            // Success Needs To check
            UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_key_GuestQuoteIdForCart)
            self.getAllCartItemsAPIGuest()
        }
        else {}
    }

    func parseRemoveFromWishList<T: Decodable>(viewModel: T) {
        let obj = viewModel as? HairTreatmentModule.Something.RemoveFromWishListResponse
        if let status = obj?.status, status == true {
                guard let cell = tableView.cellForRow(at: self.selectedIndexWishList) as? HairTreatmentCell  else {
                    return
                }
                //let cell = tableView.cellForRow(at: self.selectedIndexWishList) as! HairTreatmentCell
                self.dataServiceForTable[self.selectedIndexWishList.row].isWishSelected = false
                self.dataServiceForTable[self.selectedIndexWishList.row].extension_attributes?.wishlist_flag = false

                cell.btnWishList.isSelected = false

            /* Code Commented To for Database and Cache
             let finaldata = GenericClass.sharedInstance.checkDataInDatabase(data: self.serverData!)
             self.reposStoreSalonSubCategoryList.save(finaldata)*/
            self.showToast(alertTitle: alertTitleSuccess, message: obj?.message ?? "", seconds: toastMessageDuration)

        }
        else {
            self.showToast(alertTitle: alertTitle, message: obj?.message ?? "", seconds: toastMessageDuration)

        }
        self.dispatchGroup.leave()

    }

    func parseAddToWishList<T: Decodable>(viewModel: T) {
        let obj = viewModel as? HairTreatmentModule.Something.AddToWishListResponse
        if let status = obj?.status, status == true {

            guard let cell = tableView.cellForRow(at: self.selectedIndexWishList) as? HairTreatmentCell  else {
                    return
                }
                // let cell = tableView.cellForRow(at: self.selectedIndexWishList) as! HairTreatmentCell
                self.dataServiceForTable[self.selectedIndexWishList.row].isWishSelected = true
                self.dataServiceForTable[self.selectedIndexWishList.row].extension_attributes?.wishlist_flag = true
                cell.btnWishList.isSelected = true
            /* Code Commented To for Database and Cache
             let finaldata = GenericClass.sharedInstance.checkDataInDatabase(data: self.serverData!)
             self.reposStoreSalonSubCategoryList.save(finaldata)*/

            self.showToast(alertTitle: alertTitleSuccess, message: obj?.message ?? "", seconds: toastMessageDuration)
        }
        else {
            self.showToast(alertTitle: alertTitle, message: obj?.message ?? "", seconds: toastMessageDuration)
        }

        self.dispatchGroup.leave()

    }

}

// MARK: New Service Category TableView Delegates
extension HairServiceModuleVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        if dataServiceForTable.isEmpty {
            tableView.setEmptyMessage(TableViewNoData.tableViewNoServiceAvailable)
            return 0
        }
        else {
            tableView.restore()
            return 1
        }

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return  dataServiceForTable.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var returnCell = UITableViewCell()
        let model = dataServiceForTable[indexPath.row]

        if model.type_id == SalonServiceTypes.category {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.serviceCategoryTableViewCell) as? ServiceCategoryTableViewCell else {
                    return UITableViewCell()
                }
            cell.delegate = self
            cell.selectionStyle = .none
            cell.configure(model: model, indexPath: indexPath)
            returnCell = cell

        }
        else {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.hairTreatmentCell) as? HairTreatmentCell else {
                return UITableViewCell()
            }
           setValues(tableView, cellForRowAt: indexPath, cell: cell)
           returnCell = cell
        }
        return returnCell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if indexPath.row == dataServiceForTable.count - 1 {
            if  serverDataNewServiceCategory?.data?.services?.total_number ?? 0 > totalLoadedRecord {
                loadMoreTableData()
            }
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
           return UITableView.automaticDimension
       }

    // MARK: - Data set for Normal Cell
    func setValues(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, cell: HairTreatmentCell) {

        if  indexPath.row < dataServiceForTable.count {
            cell.delegate = self
            cell.indexPath = indexPath
            cell.configureCell(tableView, cellForRowAt: indexPath)

            let model = dataServiceForTable[indexPath.row]
            cell.lblHeading.text = model.name
            cell.lblPrice.text = String(format: " ₹ %@", model.price?.cleanForPrice ?? "0")
            cell.lblOldPrice.isHidden = true
            cell.memberOfferView.isHidden = true
            var offerPercentage: Double = 0

            if (model.type_id == SalonServiceTypes.simple) || (model.type_id == SalonServiceTypes.virtual) {
                let specialPriceObj = checkSpecialPriceSimpleProduct(element: model)
                dataServiceForTable[indexPath.row].specialPrice = specialPriceObj.isHavingSpecialPrice ? specialPriceObj.specialPrice : 0

                let strPrice = String(format: " ₹ %@", model.price?.cleanForPrice ?? "0")
                let strSpecialPrice = String(format: " ₹ %@", dataServiceForTable[indexPath.row].specialPrice?.cleanForPrice ?? "0")

                let attributeString = NSMutableAttributedString(string: "")
                attributeString.append(strPrice.strikeThrough())
                cell.lblOldPrice.attributedText = attributeString

                cell.lblOldPrice.isHidden = specialPriceObj.specialPrice == model.price ? true : specialPriceObj.specialPrice > 0 ? false : true

                cell.lblPrice.text = specialPriceObj.isHavingSpecialPrice ? strSpecialPrice :  strPrice
                if  !cell.lblOldPrice.isHidden {
                    offerPercentage = specialPriceObj.specialPrice.getPercent(price: model.price ?? 0)
                    cell.lblDiscount.text = offerPercentage.cleanForRating + "%"
                    cell.memberOfferView.isHidden = false

                }
            }

            cell.viewUnderline.isHidden = true
            var strReviewCount: String = ""
            if  let extension_attributes = model.extension_attributes, let reviewCount = extension_attributes.total_reviews, reviewCount > 0.0 {
                strReviewCount = String(format: " \(SalonServiceSpecifierFormat.reviewFormat) reviews", reviewCount)
                cell.viewUnderline.isHidden = false
            }
            else {
                strReviewCount = "0 reviews"
                cell.viewUnderline.isHidden = true
            }
            cell.lblReviews.text = strReviewCount

            cell.lblDescription.isHidden = true
            cell.selectionStyle = .none
            /*** Rating And Reviews Condition ***/

            cell.ratingView.rating = 0
            if let extension_attributes = model.extension_attributes, let rating = extension_attributes.rating_percentage, rating > 0.0 {
                cell.ratingView.rating = ((rating) / 100 * 5)
            }

            if let shortDescription = model.custom_attributes?.first(where: { $0.attribute_code == "short_description"}) {
                let responseObject = shortDescription.value.description.withoutHtml
                cell.lblDescription.text = responseObject
                cell.lblDescription.isHidden = responseObject.isEmpty
            }
            /*** Add Button Condition ***/
            cell.addServiceButton.isSelected = false
            if model.isItemSelected == true {
                cell.addServiceButton.isSelected = true
                cell.addServiceButton.isUserInteractionEnabled = false

            }
            else {
                cell.addServiceButton.isSelected = false
                cell.addServiceButton.isUserInteractionEnabled = true

            }
            /*** WhishList Button Condition ***/

            cell.btnWishList.isSelected = false

            if model.extension_attributes?.wishlist_flag == true || model.isWishSelected == true {
                if GenericClass.sharedInstance.isuserLoggedIn().status {
                    cell.btnWishList.isSelected = true
                }
            }
            /*** Plus Button Condition ***/
            cell.countLabel.textColor = UIColor(red: 74 / 255.0, green: 74 / 255.0, blue: 74 / 255.0, alpha: 1.0)
            cell.countLabel.text  = "  Service add-ons to avail"

            cell.countLabel.isHidden = true
            cell.countButton.isHidden = true
            cell.countLableView.isHidden = true
            cell.dropDownStackView.isHidden = true

            if (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! ||  (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.bundle))! {
                cell.countLabel.isHidden = false
                cell.countButton.isHidden = false
                cell.countLableView.isHidden = false
                cell.dropDownStackView.isHidden = false
                cell.countLabel.isUserInteractionEnabled = true
                cell.countButton.isUserInteractionEnabled = true
                //cell.addServiceButton.isUserInteractionEnabled = false
                self.updateAddOnCountAndServiceTime(indexPath: indexPath, cell: cell)

            }
            else /// Simple

            {

                if let serviceTime = model.custom_attributes?.first(where: { $0.attribute_code == "service_time"}) {
                    let responseObject = serviceTime.value.description
                    let doubleVal: Double = (responseObject.toDouble() ?? 0 ) * 60
                    // let stringValue = String(format:"Service Time:  %@",doubleVal.asString(style: .brief))

                    cell.lblServiceHours.text = String(format: "%@", doubleVal.asString(style: .brief))

                }
                if model.isItemSelected == true {
                    cell.addServiceButton.isSelected = true
                    cell.addServiceButton.isUserInteractionEnabled = false

                }
            }

            //Condition to Hide AddONs button
            if (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! ||  (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.bundle))! {
                if model.isItemSelected == true {
                    cell.countLabel.isUserInteractionEnabled = false
                    cell.countButton.isUserInteractionEnabled = false
                    cell.dropDownStackView.isHidden = false
                }

            }
            cell.imgView_Product.kf.indicatorType = .activity
            if  !(model.extension_attributes?.media_url ?? "").isEmpty &&  !(model.media_gallery_entries?.first?.file ?? "").isEmpty {

                let url = URL(string: String(format: "%@%@", model.extension_attributes?.media_url ?? "", (model.media_gallery_entries?.first?.file)! ))

                cell.imgView_Product.kf.setImage(with: url, placeholder: UIImage(named: "trendingservicesdefault"), options: nil, progressBlock: nil, completionHandler: nil)
            }
            else {
                cell.imgView_Product.image = UIImage(named: "trendingservicesdefault")
            }

        }

    }

    func checkSpecialPriceSimpleProduct(element: HairTreatmentModule.Something.Items) -> (isHavingSpecialPrice: Bool, specialPrice: Double, offerPercentage: Double ) {

        // ****** Check for special price
        var isSpecialDateInbetweenTo = false
        var specialPrice: Double = 0.0
        var offerPercentage: Double = 0

        if let specialFrom = element.custom_attributes?.filter({ $0.attribute_code == "special_from_date" }), let strDateFrom = specialFrom.first?.value.description, !strDateFrom.isEmpty, !strDateFrom.compareIgnoringCase(find: "null") {
            let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
            let fromDateInt: Int = Int(strDateFrom.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

            if currentDateInt >= fromDateInt {
                isSpecialDateInbetweenTo = true
                if let specialTo = element.custom_attributes?.filter({ $0.attribute_code == "special_to_date" }), let strDateTo = specialTo.first?.value.description, !strDateTo.isEmpty, !strDateTo.compareIgnoringCase(find: "null") {
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

        return (isSpecialDateInbetweenTo, specialPrice, offerPercentage.rounded(toPlaces: 1))
    }

    func updateAddOnCountAndServiceTime(indexPath: IndexPath, cell: HairTreatmentCell) {

        var serviceTime: Double = 0
        var serviceCount: Int = 0
        var arrayOfAddOnsTitle = [String]()
        var serviceTotalPrice: Double = 0
        var serviceStikeThroughPrice: Double = 0
        var offerPercentage: Double = 0

        let model = dataServiceForTable[indexPath.row]
        if (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.bundle))! {
            serviceTotalPrice = 0
            serviceStikeThroughPrice = 0
            offerPercentage = 0

            if let productOptions = model.extension_attributes?.bundle_product_options {
                let productLinks = productOptions.compactMap {
                    $0.product_links?.filter { $0.isBundleProductOptionsSelected ?? false }
                }.flatMap { $0 }

                serviceCount = productLinks.count
                productLinks.forEach {
                    //serviceTotalPrice += ($0.price ?? 0)
                    serviceTotalPrice += ((($0.specialPrice ?? 0.0) > Double(0.0)) && (($0.specialPrice ?? 0.0) < ($0.price ?? Double(0.0)))) ? $0.specialPrice ?? 0 :  ($0.price ?? 0)
                    serviceStikeThroughPrice += ($0.price ?? 0)

                    let doubleVal: Double = ($0.extension_attributes?.service_time?.toDouble() ?? 0 ) * 60
                    serviceTime += doubleVal
                    arrayOfAddOnsTitle.append($0.sku ?? "")
                    cell.addServiceButton.isUserInteractionEnabled = true
                    cell.lblOldPrice.isHidden = ((($0.specialPrice ?? 0.0) > Double(0.0)) && (($0.specialPrice ?? 0.0) < ($0.price ?? Double(0.0))))  ? false : true

                    if (($0.specialPrice ?? 0.0) > Double(0.0)) && (($0.specialPrice ?? 0.0) < ($0.price ?? Double(0.0))) {
                        let strPrice = String(format: " ₹ %@", (serviceStikeThroughPrice ).cleanForPrice )
                        let attributeString = NSMutableAttributedString(string: "")
                        attributeString.append(strPrice.strikeThrough())
                        cell.lblOldPrice.attributedText = attributeString
                    }
                }
                if  !cell.lblOldPrice.isHidden {
                    offerPercentage = serviceTotalPrice.getPercent(price: serviceStikeThroughPrice )
                    cell.lblDiscount.text = offerPercentage.cleanForRating + "%"
                    cell.memberOfferView.isHidden = false

                }

            }

        }
        else // Radio Configurable
        {
            serviceTotalPrice = 0
            serviceStikeThroughPrice = 0
            offerPercentage = 0

            if let productOptions = model.extension_attributes?.configurable_subproduct_options {
                let productLinks = productOptions.first(where: { $0.isSubProductConfigurableSelected == true})

                serviceCount += 1
                serviceTotalPrice += (((productLinks?.special_price ?? 0.0) > Double(0.0)) && ((productLinks?.special_price ?? 0.0) < (productLinks?.price ?? Double(0.0))))   ? productLinks?.special_price ?? 0 :  (productLinks?.price ?? 0)
                let doubleVal: Double = (productLinks?.service_time?.toDouble() ?? 0 ) * 60
                serviceTime += doubleVal

                if let title = productLinks?.option_title {
                    arrayOfAddOnsTitle.append(title.description)
                }
                cell.addServiceButton.isUserInteractionEnabled = true
                cell.lblOldPrice.isHidden = (((productLinks?.special_price ?? 0.0) > Double(0.0)) && ((productLinks?.special_price ?? 0.0) < (productLinks?.price ?? Double(0.0)))) ? false : true

                if ((productLinks?.special_price ?? 0.0) > Double(0.0)) && ((productLinks?.special_price ?? 0.0) < (productLinks?.price ?? Double(0.0))) {
                    let strPrice = String(format: " ₹ %@", (productLinks?.price ?? 0.0).cleanForPrice )
                    let attributeString = NSMutableAttributedString(string: "")
                    attributeString.append(strPrice.strikeThrough())
                    cell.lblOldPrice.attributedText = attributeString
                }
                if  !cell.lblOldPrice.isHidden {
                    offerPercentage = (productLinks?.special_price ?? 0.0).getPercent(price: productLinks?.price ?? 0.0 )
                    cell.lblDiscount.text = offerPercentage.cleanForRating + "%"
                    cell.memberOfferView.isHidden = false

                }
            }

        }

        // This is common for both bundle and configure cell (Multi and Radio Selection )
        if !arrayOfAddOnsTitle .isEmpty {
            if (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.bundle))! {
                if serviceCount > 1 {
                    serviceCount -= 1

                    cell.countLabel.text = String(format: "  %@ + %d add-ons", arrayOfAddOnsTitle.first ?? "NA", serviceCount)
                }
                else {
                    cell.countLabel.text = String(format: "  %@", arrayOfAddOnsTitle.first ?? "NA")
                }
            }
            else {
                cell.countLabel.text = String(format: "  %@", arrayOfAddOnsTitle.first ?? "NA")

            }

            cell.countLabel.textColor = .black

        }
        cell.lblPrice.text = String(format: " ₹ %@", serviceTotalPrice.cleanForPrice)
        dataServiceForTable[indexPath.row].price = serviceTotalPrice
        dataServiceForTableOriginal[indexPath.row].price = serviceTotalPrice

        /* Code Commented To for Database and Cache
        if(self.is_FilterHappen == false) {
            reposStoreSalonSubCategoryList.save(serverData!)
        }*/

        let stringValue = String(format: "%@", serviceTime.asString(style: .brief))
        cell.lblServiceHours.text = stringValue
    }

    // MARK: Default Configurable(Radio)Selected
    func setDefaultValueForConfigurable() {
        var isAnySelected: Bool = false
        for(_, element)in dataServiceForTable.enumerated() {
            if (element.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! {
                if (element.extension_attributes?.configurable_subproduct_options?.first(where: { $0.isSubProductConfigurableSelected == true})) != nil {
                    isAnySelected = true

                }
            }
        }

        if isAnySelected == false {

            for(index, element)in dataServiceForTable.enumerated() {
                if (element.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! {
                    for(index2, _)in (element.extension_attributes?.configurable_subproduct_options?.enumerated())! {
                        dataServiceForTable[index].extension_attributes?.configurable_subproduct_options?[index2].isSubProductConfigurableSelected = true
                        dataServiceForTableOriginal[index].extension_attributes?.configurable_subproduct_options?[index2].isSubProductConfigurableSelected = true
                        break
                    }

                }

            }
        }

    }

    func filterSearchCriteria() {

        let allSelectedItems = arrfiltersData.compactMap({value1 in value1.values?.filter({$0.isChildSelected == true})})

        if !allSelectedItems.isEmpty {
            var filter_groups = [HairServiceModule.NewServiceCategory.Filter_groups]()

            for (_, element) in allSelectedItems.enumerated() {

                var filters = [HairServiceModule.NewServiceCategory.Filters]()

                var conditionType: String = "eq"
                if element.count > 1 {
                    conditionType = "finset"
                }

                for (_, elementValue) in element.enumerated() {
                    if elementValue.isChildSelected == true {
                  let newObj = HairServiceModule.NewServiceCategory.Filters(field: elementValue.attr_code, value: elementValue.value?.description, condition_type: conditionType)
                    filters.append(newObj)
                    }
                }
                if !filters.isEmpty {
                let filter_groups1 = HairServiceModule.NewServiceCategory.Filter_groups(filters: filters)
                filter_groups.append(filter_groups1)
                }

            }
        let searchCriteria = HairServiceModule.NewServiceCategory.Search_criteria(filter_groups: filter_groups)

            search_criteria = searchCriteria
        }

    }

}

extension HairServiceModuleVC: LoginRegisterDelegate {
    func doLoginRegister() {
        // Put your code here
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {[unowned self] in
            let vc = LoginModuleVC.instantiate(fromAppStoryboard: .Main)
            let navigationContrl = UINavigationController(rootViewController: vc)
            navigationContrl.modalPresentationStyle = .fullScreen
            self.present(navigationContrl, animated: true, completion: nil)
        }
    }
}
