//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.

import UIKit

class ServiceDetailModuleVC: UIViewController, SalonServiceModuleDisplayLogic {
    @IBOutlet weak private var serviceDetailsTableView: UITableView!

    private var sections = [SectionConfiguration]()

    var selectedAdditionalDetailsCell = 0

    //**** Variables For Bottom Cart  Oultets And Canstraints***** //
    @IBOutlet weak private var cartViewBottom: UIView!
    @IBOutlet weak private var constraintsCartViewHeight: NSLayoutConstraint!
    @IBOutlet weak private var constraintsBookingDetailsButtonHeight: NSLayoutConstraint!
    @IBOutlet weak private var lblCartViewHours: UILabel!
    @IBOutlet weak private var lblCartViewServicesAndAmount: UILabel!
    //**** Variables For Bottom Cart ***** //

    //**** Variables Add Service Bottom Button Outlets And Canstraints ***** //
    @IBOutlet weak private var addServiceViewBottom: UIView!
    @IBOutlet weak private var constraintsAddServiceViewHeight: NSLayoutConstraint!
    @IBOutlet weak private var constraintsAddServiceButtonBottomsHeight: NSLayoutConstraint!
    @IBOutlet weak private var addServiceButtonBottom: UIButton!
    //**** Variables Add Service Bottom Button Oultets And Canstraints ***** //

    internal var interactor: SalonServiceModuleBusinessLogic?
    // Local Variables
    internal var isShowAddToCart: Bool = true // This flag is created to check user is comming from searchTab to disable addToCart Functionality
    internal let dispatchGroup = DispatchGroup()
    internal let dispatchGroupDataFeeding = DispatchGroup()

    var serverData: [HairTreatmentModule.Something.Items] = [] // This is for data carry Forward From Listing Screen
    var subCategoryDataObjSelectedIndex: Int = 0 // This is for data carry Forward From Listing Screen
    private var serverDataProductDetails: ServiceDetailModule.ServiceDetails.Response? // Product Details Service Data
    private var serverDataFrequentlyAvailedService: ServiceDetailModule.ServiceDetails.FrequentlyAvailedProductResponse? // FrequentlyAvailedProductResponse
    private var serverDataProductReviews: ServiceDetailModule.ServiceDetails.ProductReviewResponse? // ProductReviewResponse
    private var arrafterTipsData = [PointsCellData]()// After Tips And Details
    private var arrfrequentlyBookedData = [HairTreatmentModule.Something.Items]() // FrequentlyBooked
    private var arrOfGetInsight: [GetInsightFulDetails] = [] // Array Of GetInsight
    private var recommendedProductsData =  [ProductModel]() //=
    private var serverDataForSelectedService: [HairTreatmentModule.Something.Items] = [] // Created For  Frequently availed services
    private var arrFrequentlyAvailedData =  [TrendingService]()

    //** Cart API Variables
    private var serverDataForAllCartItemsGuest: [ProductDetailsModule.GetAllCartsItemGuest.Response]?
    private var serverDataForAllCartItemsCustomer: [ProductDetailsModule.GetAllCartsItemCustomer.Response]?
    private var isAddingParentOrChildProductToCart: Bool = false // True means Paraent else Adding Product From FrequentlyBookedTogether
    private var selectedFrequentlyBookedTogetherIndex = IndexPath(row: 0, section: 0)
    // Multi Web Service Calls Handle Dispatch

    private var identifierLocal: SectionIdentifier = .parentVC
    private var selectedIndexWishList = IndexPath(row: 0, section: 0)

    // Call Back Function
    var onDoneBlock: ((Bool, [HairTreatmentModule.Something.Items]) -> Void)?

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
        UISettings()
        addSOSButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationItem.setHidesBackButton(false, animated: false)
        self.navigationController?.addCustomBackButton(title: "")

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        // Back Button Clicked
        if self.navigationController?.viewControllers.index(of: self) == nil {
            onDoneBlock?(true, self.serverData)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        serverData[subCategoryDataObjSelectedIndex].isItemSelected = false

        /* Code Commented To for Database and Cache
         let modelObjectItem = serverData?.items?[subCategoryDataObjSelectedIndex]
         let records = CoreDataStack.sharedInstance.allRecords(SelectedSalonService.self)
         for (_, element) in records.enumerated() {
         if(element.selectedItemId == modelObjectItem!.id) {
         serverData?.items?[subCategoryDataObjSelectedIndex].isItemSelected = true
         break
         }

         }*/

        sections.removeAll()
        getDataFromServer()
    }

    func addSOSButton() {
        guard let sosImg = UIImage(named: "SOS") else {
            return
        }
        let sosButton = UIBarButtonItem(image: sosImg, style: .plain, target: self, action: #selector(didTapSOSButton))
        sosButton.tintColor = UIColor.black
        navigationItem.title = ""
        if showSOS {
            navigationItem.rightBarButtonItems = [sosButton]
        }
    }

    @objc func didTapSOSButton() {
        SOSFactory.shared.raiseSOSRequest()
    }

    // MARK: getDataFromServer
    func getDataFromServer() {

        isAddingParentOrChildProductToCart = true
        self.showAndHideBottomCart(guestCart: self.serverDataForAllCartItemsGuest ?? [], customerCart: self.serverDataForAllCartItemsCustomer ?? [])
        updateAddToServiceButton()
//        if GenericClass.sharedInstance.isuserLoggedIn().status {
//            getAllCartItemsAPICustomer()
//        }
//        else {
//            getAllCartItemsAPIGuest()
//        }
        showNavigationBarRigtButtons()

        callProductDetailsAPI()
        callProductReviewsAPI()
        callFrequentlyAvailedAPI()
        callInsightAPI()
        notifyUpdate()

    }

    func notifyUpdate() {
        dispatchGroup.notify(queue: .main) {[unowned self] in
            print("dispatchGroup")
            self.configureSections()
            self.updateWishListButtonOnNavigationBar()

            self.dispatchGroupDataFeeding.notify(queue: .main) {[unowned self] in
                print("dispatchGroupDataFeeding")
                EZLoadingActivity.hide()
                self.serviceDetailsTableView.reloadData()
            }
        }
    }

    func UISettings() {
        // Do any additional setup after loading the view.

        serviceDetailsTableView.register(UINib(nibName: CellIdentifier.serviceDescriptionCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.serviceDescriptionCell)
        serviceDetailsTableView.register(UINib(nibName: CellIdentifier.customerRatingAndReviewCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.customerRatingAndReviewCell)
        serviceDetailsTableView.register(UINib(nibName: CellIdentifier.reviewThumpsUpDownCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.reviewThumpsUpDownCell)
        serviceDetailsTableView.register(UINib(nibName: CellIdentifier.serviceDetailsHairTreatmentCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.serviceDetailsHairTreatmentCell)
        serviceDetailsTableView.register(UINib(nibName: CellIdentifier.addServiceInYourCartCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.addServiceInYourCartCell)

        serviceDetailsTableView.register(UINib(nibName: CellIdentifier.headerViewWithTitleCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.headerViewWithTitleCell)
        serviceDetailsTableView.register(UINib(nibName: CellIdentifier.headerViewWithSubTitleCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.headerViewWithSubTitleCell)
        serviceDetailsTableView.register(UINib(nibName: CellIdentifier.headerViewWithAdCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.headerViewWithAdCell)

        serviceDetailsTableView.separatorColor = .clear
        serviceDetailsTableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        //        serviceDetailsTableView.estimatedRowHeight = 50

    }

    // MARK: Configure Sections
    func configureSections() {

        //sections.removeAll()

        if sections.isEmpty {
            sections.append(configureSection(idetifier: .serviceDetails, items: 1, data: []))

            createDataForAfterTips()
            createDataForFrequentlyBookedTogether()
           // createDataForRecommendedProducts()

            if let productReview = serverDataProductReviews?.data?.all_star_rating, !productReview.isEmpty {
                sections.append(configureSection(idetifier: .customer_rating_review, items: 1, data: []))
            }

            if let productReview = serverDataProductReviews?.data?.review_items, !productReview.isEmpty {
                sections.append(configureSection(idetifier: .feedbackDetails, items: productReview.count, data: []))
            }

            createDataForFrequentlyAvailedService()

//            if !arrOfGetInsight.isEmpty {
//                sections.append(self.configureSection(idetifier: .get_insightful, items: arrOfGetInsight.count, data: arrOfGetInsight as Any))
//            }
        }

    }

    // MARK: Default Configurable(Radio)Selected
    func setDefaultValueForConfigurable(forFrequentlyBooked: Bool) {

        switch forFrequentlyBooked {
        case true:
            var isAnySelected: Bool = false
            for(_, element)in (self.arrfrequentlyBookedData.enumerated()) {
                if (element.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! {

                    if (element.extension_attributes?.configurable_subproduct_options?.first(where: { $0.isSubProductConfigurableSelected == true})) != nil {
                        isAnySelected = true

                    }
                }
            }

            if isAnySelected == false {
                for(index, element)in (self.arrfrequentlyBookedData.enumerated()) {
                    if (element.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! {
                        for(index2, _)in (element.extension_attributes?.configurable_subproduct_options?.enumerated())! {
                            self.arrfrequentlyBookedData[index].extension_attributes?.configurable_subproduct_options?[index2].isSubProductConfigurableSelected = true
                            break
                        }

                    }

                }
            }
        case false: // For Frequently Availed Services
            var isAnySelected: Bool = false
            for(_, element)in (serverDataForSelectedService.enumerated()) {
                if (element.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! {
                    if (element.extension_attributes?.configurable_subproduct_options?.first(where: { $0.isSubProductConfigurableSelected == true})) != nil {
                        isAnySelected = true

                    }
                }

            }

            if isAnySelected == false {

                for(index, element)in (serverDataForSelectedService.enumerated()) {
                    if (element.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! {
                        for(index2, _)in (element.extension_attributes?.configurable_subproduct_options?.enumerated())! {
                            serverDataForSelectedService[index].extension_attributes?.configurable_subproduct_options?[index2].isSubProductConfigurableSelected = true
                            break
                        }

                    }

                }
            }

        }

    }

    // MARK: Top Navigation Bar And  Actions
    func showNavigationBarRigtButtons() {
      //  let cartImg = UIImage(named: "cartTab")!
       // let callPhoneImg = UIImage(named: "callPhoneImg")!
        let shareButtonImg = UIImage(named: "navigationBarshare")!
      //  let wishListImg = UIImage(named: "navigationBarwishlistUnSelected")!

//        let callButton = UIBarButtonItem(image: callPhoneImg, style: .plain, target: self, action: #selector(didTapCallButton))
//        callButton.tintColor = UIColor.black
//        callButton.tag = 0
        let shareButton = UIBarButtonItem(image: shareButtonImg, style: .plain, target: self, action: #selector(didTapShare))
        shareButton.tintColor = UIColor.black
        shareButton.tag = 1

//        let wishListButton = UIBarButtonItem(image: wishListImg, style: .plain, target: self, action: #selector(didTapWishList))
//        wishListButton.tintColor = UIColor.black
//        wishListButton.tag = 2
//
//        let cartBtn = UIBarButtonItem(image: cartImg, style: .plain, target: self, action: #selector(didTapCartButton))
//        cartBtn.tintColor = UIColor.black
//        cartBtn.tag = 3

        navigationItem.rightBarButtonItems = [shareButton]
    }

    @objc func didTapCallButton() {
        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
            if self.isPhone(userSelectionForService.salon_PhoneNumber) {
                userSelectionForService.salon_PhoneNumber.makeACall()
            }
        }
    }
    @objc func didTapCartButton() {
        pushToCartView()
    }

    @objc func didTapShare() {
        //let text = "This is the text...."
        //let image = UIImage(named: "onboard2")
        let myWebsite = NSURL(string: "\(serverDataProductDetails?.extension_attributes?.product_url ?? "http://www.enrichsalon.com")")
        //let shareAll = [text , image! , myWebsite] as [Any]
        let shareAll = [myWebsite as Any] as [Any]

        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)

    }
    @objc func didTapWishList() {
//        identifierLocal = SectionIdentifier.parentVC
//        if GenericClass.sharedInstance.isuserLoggedIn().status {
//            let productId: Int64 = (self.serverData[subCategoryDataObjSelectedIndex].id)!
//
//            let element = self.navigationItem.rightBarButtonItems?.first(where: { $0.tag == 2})
//            element?.image == UIImage(named: "navigationBarwishlistSelected")! ? self.removeFromWishListApiCall(productId: productId) : self.addToWishListApiCall(productId: productId)
//            return
//        }
//
//        openLoginWindow()

    }

    // MARK: optionsToOpenAllReviews
    func optionsToOpenAllReviewsForToHeader() {
        let vc = AllReviewsVC.instantiate(fromAppStoryboard: .Products)
        let model = self.serverData[self.subCategoryDataObjSelectedIndex]
        vc.productId = String(format: "%d", model.id ?? 0)
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func optionsToOpenAllReviewsForFrequentlyBookedTogether(indexPath: IndexPath) {
        let vc = AllReviewsVC.instantiate(fromAppStoryboard: .Products)
        let model = self.arrfrequentlyBookedData[indexPath.row]
        vc.productId = String(format: "%d", model.id ?? 0)
        self.navigationController?.pushViewController(vc, animated: true)

    }

    // MARK: pushToCartView
    func pushToCartView() {
//        let cartModuleViewController = CartModuleVC.instantiate(fromAppStoryboard: .HomeLanding)
//        self.navigationController?.isNavigationBarHidden = false
//        self.navigationController?.pushViewController(cartModuleViewController, animated: true)

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
    // MARK: IBActions
    @IBAction func clickToAddService(_ sender: Any) {

//            if  let model = self.serverData[subCategoryDataObjSelectedIndex] {
//                isAddingParentOrChildProductToCart = true
//            if CartHelper.sharedInstance.toShowAlertForAllAddToCartServiceScenerio(model: model, serverDataForAllCartItemsGuest: serverDataForAllCartItemsGuest ?? [], serverDataForAllCartItemsCustomer: serverDataForAllCartItemsCustomer ?? [], viewController: self) {
//                GenericClass.sharedInstance.isuserLoggedIn().status ? addToCartSimpleOrVirtualProductForCustomer(selected: model) : addToCartSimpleOrVirtualProductForGuest(selected: model)
//                }
//            }

    }

    @IBAction func clickToBookingDetails(_ sender: Any) {
//        let bookingDetailsModuleViewController = BookingDetailsModuleViewController.instantiate(fromAppStoryboard: .BookAppointment)
//        self.navigationController?.pushViewController(bookingDetailsModuleViewController, animated: true)
        pushToCartView()
    }

    // MARK: updateCartBadgeNumber
    func updateCartBadgeNumber(badgeCount: Int) {
        badgeCount > 0 ? self.navigationItem.rightBarButtonItems?.first(where: { $0.tag == 3})?.addBadge(number: badgeCount) : self.navigationItem.rightBarButtonItems?.first(where: { $0.tag == 3})?.removeBadge()
        badgeCount > 0 ? ApplicationFactory.shared.customTabbarController.increaseBadge(indexOfTab: 3, num: String(format: "%d", badgeCount)) : ApplicationFactory.shared.customTabbarController.nilBadge(indexOfTab: 3)

    }

    // MARK: updateParentServiceAfterAddToCart
    func updateParentServiceAfterAddToCart() {
        self.serverData[subCategoryDataObjSelectedIndex].isItemSelected = true

        if serviceDetailsTableView.isCellVisible(section: 0, row: 0) {
            let indexPathOfCell = IndexPath(row: 0, section: 0)
            if let cell = serviceDetailsTableView.cellForRow(at: indexPathOfCell) as? ServiceDescriptionCell {
            let model = self.serverData[subCategoryDataObjSelectedIndex]

            if (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! ||  (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.bundle))! {
                if model.isItemSelected == true {
                    cell.dropdownText.isUserInteractionEnabled = false
                    cell.dropdownText.isUserInteractionEnabled = false
                }
            }
            self.setValues(cell: cell)
        }
        }

        /* Code Commented To for Database and Cache
         CoreDataStack.sharedInstance.updateDataBase(obj: self.serverData[subCategoryDataObjSelectedIndex] as AnyObject)*/
    }

    // MARK: updateFrequentlyBookedServiceAfterAddToCart
    func updateFrequentlyBookedServiceAfterAddToCart() {
        if let cell = self.serviceDetailsTableView.cellForRow(at: selectedFrequentlyBookedTogetherIndex) as? ServiceDetailsHairTreatmentCell {
        self.arrfrequentlyBookedData[selectedFrequentlyBookedTogetherIndex.row].isItemSelected = true
        cell.addServiceButton.isSelected = true
        cell.addServiceButton.isUserInteractionEnabled = false
        }
        /* Code Commented To for Database and Cache
         let model = self.arrfrequentlyBookedData[selectedFrequentlyBookedTogetherIndex.row]

         if self.arrfrequentlyBookedData.count > 0 {
         if(!(model.isItemSelected ?? false)!) {
         self.arrfrequentlyBookedData[selectedFrequentlyBookedTogetherIndex.row].isItemSelected = true
         self.setFrequentlyBookedTogether(indexPath: selectedFrequentlyBookedTogetherIndex, cell: cell)

         CoreDataStack.sharedInstance.updateDataBase(obj: self.arrfrequentlyBookedData[selectedFrequentlyBookedTogetherIndex.row] as AnyObject)
         }

         }*/

        /* Add Service Section will not show
         if let i = sections.index(where: { $0.identifier == .cart_calculation }) {

         sections.remove(at: i)
         if let i = sections.index(where: { $0.identifier == .frequently_booked_together }) {

         self.serviceDetailsTableView.reloadData()
         self.serviceDetailsTableView.selectRow(at: IndexPath.init(row: 0, section: i), animated: false, scrollPosition: .middle)
         }

         }

         if let i = sections.index(where: { $0.identifier == .frequently_booked_together }) {

         showAddServiceSectionOrNot(index: i+1)

         }

         if let i = sections.index(where: { $0.identifier == .cart_calculation }) {

         self.serviceDetailsTableView.reloadData()
         self.serviceDetailsTableView.selectRow(at: IndexPath.init(row: 0, section: i), animated: false, scrollPosition: .middle)

         }*/
    }

    // MARK: updateCell
    func updateCellForWishList(status: Bool) {

        switch self.identifierLocal {
        case .parentVC:
            self.serverData[self.subCategoryDataObjSelectedIndex].isWishSelected = status
            self.serverData[self.subCategoryDataObjSelectedIndex].extension_attributes?.wishlist_flag = status
            self.updateWishListButtonOnNavigationBar()

        case .recently_viewed:
            if let cell = self.serviceDetailsTableView.cellForRow(at: IndexPath(row: 0, section: self.selectedIndexWishList.section)) as? ProductsCollectionCell {
            if let productCell = cell.productCollectionView.cellForItem(at: IndexPath(row: self.selectedIndexWishList.row, section: 0)) as? TrendingProductsCell {
                updateWishListFlagRecentlyViewed(status: status, productCell: productCell, cell: cell)
            }
        }

        default:
            break
        }

    }
    func updateWishListFlagRecentlyViewed(status: Bool, productCell: TrendingProductsCell, cell: ProductsCollectionCell) {
        self.recommendedProductsData[self.selectedIndexWishList.row].isFavourite = status
        GenericClass.sharedInstance.setFevoriteProductSet(model: ChangedFevoProducts(productId: "\(self.recommendedProductsData[self.selectedIndexWishList.row].productId)", changedState: status))
        productCell.configureCell(model: self.recommendedProductsData[self.selectedIndexWishList.row])
        self.sections[self.selectedIndexWishList.section].data = self.recommendedProductsData
        cell.configuration.data = self.recommendedProductsData[self.selectedIndexWishList.row]
    }
}

extension ServiceDetailModuleVC: ProductSelectionDelegate {
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
            self.serviceDetailsTableView.reloadData()//reloadSections([1,2], with: .none)
            self.serviceDetailsTableView.selectRow(at: IndexPath(row: 0, section: 1), animated: false, scrollPosition: .middle)

        case .recently_viewed:
            let vc = ProductDetailsModuleVC.instantiate(fromAppStoryboard: .Products)
            vc.objProductId = Int64(recommendedProductsData[indexpath.row].productId)
            vc.objProductSKU = recommendedProductsData[indexpath.row].sku
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: true)

        case .get_insightful:
            break
//            let model = arrOfGetInsight[indexpath.row]
//            let vc = BlogDetailsModuleVC.instantiate(fromAppStoryboard: .Blog)
//            vc.blog_id = model.blogId
//            self.navigationController?.pushViewController(vc, animated: true)

        case .frequently_availed_services:
            let model = arrFrequentlyAvailedData[indexpath.row]
            getDataForSelectedService(subCategoryId: model.id )

        default:
            break
        }

    }

    func wishlistStatus(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {
        print("WishList:\(status) || \(identifier.rawValue) || item :\(indexpath.section)")

        selectedIndexWishList = indexpath

        if !GenericClass.sharedInstance.isuserLoggedIn().status {
            openLoginWindow()
            return
        }
        switch identifier {

        case .recently_viewed:
            break
//            identifierLocal = SectionIdentifier.recently_viewed
//            let model = recommendedProductsData[indexpath.row]
//            model.isFavourite ? removeFromWishListApiCall(productId: model.productId) : addToWishListApiCall(productId: model.productId)
        default:
            break
        }

    }

    func checkBoxSelection(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {
        print("CheckBox:\(status) || \(identifier.rawValue) || item :\(indexpath.row)")
    }

}

extension ServiceDetailModuleVC: HeaderDelegate {

    func actionViewAll(identifier: SectionIdentifier) {
        print("ViewAllAction : \(identifier.rawValue)")
        switch identifier {
        case .get_insightful:
            break
//            let vc = BlogListingModuleVC.instantiate(fromAppStoryboard: .Blog)
//            self.navigationController?.pushViewController(vc, animated: true)
        case .customer_rating_review:
            let vc = AllReviewsVC.instantiate(fromAppStoryboard: .Products)
            let model = self.serverData[self.subCategoryDataObjSelectedIndex]
            self.navigationController?.pushViewController(vc, animated: true)
        default: break
        }

    }
}

extension ServiceDetailModuleVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let data = sections[section]
        guard data.items > 0 else {
            return 0
        }

        if data.identifier == .recently_viewed {
            return 1
        }
        else if data.identifier == .frequently_availed_services {
            return 1
        }
        else if data.identifier == .cart_calculation {
            return 1
        }
        else if data.identifier == .get_insightful {
            return 1
        }
        else if data.identifier == .additionalDetails {

            return arrafterTipsData[selectedAdditionalDetailsCell].points.count + 1
        }
        return data.items
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var data = sections[indexPath.section]

        if data.identifier == .serviceDetails {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.serviceDescriptionCell) as? ServiceDescriptionCell else {
                return UITableViewCell()
            }

            cell.selectionStyle = .none
            cell.delegate = self
            cell.configureCell()
            self.setValues(cell: cell)

            cell.needsUpdateConstraints()
            cell.updateConstraints()
            cell.setNeedsLayout()
            cell.setNeedsDisplay()
            cell.layoutSubviews()

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
                cell.configureCell(title: arrafterTipsData[selectedAdditionalDetailsCell].points[indexPath.row - 1])
                print("IndexAtCell:\(selectedAdditionalDetailsCell)")

                cell.selectionStyle = .none
                return cell
            }

        }
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
        else if data.identifier == .frequently_booked_together {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.serviceDetailsHairTreatmentCell) as? ServiceDetailsHairTreatmentCell else {
                return UITableViewCell()
            }
            cell.indexPath = indexPath
            cell.delegate = self
            cell.configureCell(tableView, cellForRowAt: indexPath)
            setFrequentlyBookedTogether(indexPath: indexPath, cell: cell)
//            if isShowAddToCart {
//                cell.addServiceButton.isHidden = true
//            }
            cell.selectionStyle = .none
            return cell

        }
        else if data.identifier == .cart_calculation {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.addServiceInYourCartCell) as? AddServiceInYourCartCell else {
                return UITableViewCell()
            }
            cell.indexPath = indexPath
            cell.delegate = self
            updatefrequentlyAddedServiceData(addServiceInYourCartCell: cell)
            cell.selectionStyle = .none
            return cell

        }
        else {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.productsCollectionCell, for: indexPath) as? ProductsCollectionCell else {
                return UITableViewCell()
            }
            cell.tableViewIndexPath = indexPath
            cell.selectionDelegate = self
            cell.hideCheckBox = true
            cell.addSectionSpacing = is_iPAD ? 25 : 15
            cell.configureCollectionView(configuration: data, scrollDirection: .horizontal)
            cell.selectionStyle = .none
            return cell
        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if sections.isEmpty {
            return nil
        }

        let data = sections[section]

        if !data.showHeader {
            return nil
        }

        if data.identifier == .frequently_booked_together {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.headerViewWithSubTitleCell) as? HeaderViewWithSubTitleCell else {
                return UITableViewCell()
            }
            cell.configureHeader(title: data.title, subTitle: data.subTitle, hideAllButton: true)
            cell.identifier = data.identifier
            cell.delegate = self
            return cell

        }
        else if data.identifier == .recently_viewed {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.headerViewWithAdCell) as? HeaderViewWithAdCell else {
                return UITableViewCell()
            }
            cell.titleLabel.text = data.title
            cell.addTextLabel.text = "Earn 200 points on purchase of any these products together with this head massage" //data.title
            cell.identifier = data.identifier
            cell.viewAllButton.isHidden = true
            cell.delegate = self
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.headerViewWithTitleCell) as? HeaderViewWithTitleCell else {
                return UITableViewCell()
            }
            cell.identifier = data.identifier
            cell.delegate = self
            if data.identifier == .customer_rating_review {
                cell.configureHeader(title: data.title, hideAllButton: (serverDataProductReviews?.data?.review_items?.count)!  > 0 ? false : true)
            }
            if data.identifier == .frequently_availed_services {
                cell.configureHeader(title: data.title, hideAllButton: true)
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let data = sections[section]
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: data.footerHeight))
        view.backgroundColor = UIColor.white
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let data = sections[section]
        return data.showHeader ? data.headerHeight : 0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let data = sections[section]
        return data.showFooter ? data.footerHeight : 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let data = sections[indexPath.section]
        if data.identifier == .get_insightful ||
            data.identifier == .recently_viewed ||
            data.identifier == .frequently_availed_services {

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

    // MARK: Set Value For Service Description Cell
    func setValues(cell: ServiceDescriptionCell) {

         let model = self.serverData[self.subCategoryDataObjSelectedIndex]
        let elements = serverDataProductDetails?.extension_attributes?.recommended_for_info?.components(separatedBy: ",") ?? []
        cell.recommendedFor = elements
        cell.priceLabel.text = String(format: " ₹ \(model.price?.cleanForPrice ?? " 0")")
        cell.dropdownText.text  = "  Service add-ons to avail"
        cell.lblServiceTitle.text = model.name
        //cell.viewUnderline.isHidden = true
        cell.viewUnderline.isHidden = false
        cell.lblOldPrice.isHidden = true
        var offerPercentage: Double = 0
        cell.offerView.isHidden = true

        if model.type_id == SalonServiceTypes.simple || model.type_id == SalonServiceTypes.virtual {
            let specialPriceObj = checkSpecialPriceSimpleProduct(element: model)
            self.serverData[self.subCategoryDataObjSelectedIndex].specialPrice = specialPriceObj.isHavingSpecialPrice ? specialPriceObj.specialPrice : 0

            let strPrice = String(format: " ₹ %@", model.price?.cleanForPrice ?? "0")
            let strSpecialPrice = String(format: " ₹ %@", self.serverData[self.subCategoryDataObjSelectedIndex].specialPrice?.cleanForPrice ?? "0")

            let attributeString = NSMutableAttributedString(string: "")
            attributeString.append(strPrice.strikeThrough())
            cell.lblOldPrice.attributedText = attributeString

            cell.lblOldPrice.isHidden = specialPriceObj.specialPrice == model.price ? true : specialPriceObj.specialPrice > 0 ? false : true

            cell.priceLabel.text = specialPriceObj.isHavingSpecialPrice ? strSpecialPrice :  strPrice

            if  !cell.lblOldPrice.isHidden {
                offerPercentage = specialPriceObj.specialPrice.getPercent(price: model.price ?? 0)
                cell.lblDiscount.text = offerPercentage.cleanForRating + "%"
                cell.offerView.isHidden = false

            }
        }

        var strReviewCount: String = ""
        if let reviewCount = model.extension_attributes?.total_reviews, reviewCount > 0 {
            strReviewCount = String(format: " \(SalonServiceSpecifierFormat.reviewFormat) reviews", reviewCount)
            cell.viewUnderline.isHidden = false
            cell.lblReviews.isHidden = false
        }
        else {
            strReviewCount = "0 reviews"
            cell.viewUnderline.isHidden = true
        }
        cell.lblReviews.text = strReviewCount

        if (cell.lblReviews.text?.isEqual(noReviewsMessage))! {
            //cell.viewUnderline.isHidden = false
        }

        cell.ratingsView.rating = 0
        if let rating = model.extension_attributes?.rating_percentage, rating > 0 {
            cell.ratingsView.rating = ((rating) / 100 * 5)
        }

        var hideDropDown = true

//        self.addServiceButtonBottom.isSelected = false
//        self.addServiceButtonBottom.isUserInteractionEnabled = false
        self.addServiceButtonBottom.isUserInteractionEnabled = true

        cell.dropdownText.isUserInteractionEnabled = true
        cell.btnPlus.isUserInteractionEnabled = true

        if (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! ||  (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.bundle))! {
            hideDropDown = false
            self.updateAddOnsForServiceDescriptionCell(cell: cell)
            if (model.isItemSelected) != nil && model.isItemSelected == true {
                cell.dropdownText.isUserInteractionEnabled = false
                cell.btnPlus.isUserInteractionEnabled = false
            }

        }
        else {// Simple Cell

            self.updateAddToServiceButton()
            if let serviceTime = model.custom_attributes?.first(where: { $0.attribute_code == "service_time"}) {
                let responseObject = serviceTime.value.description
                let doubleVal: Double = (responseObject.toDouble() ?? 0 ) * 60

                cell.lblServiceHours.text = String(format: "%@", doubleVal.asString(style: .brief))

            }
        }

        /*** Image Set ***/
        // var imagePath:String = ""
        cell.descriptionText.isHidden = true

        if let descriptionData = model.custom_attributes?.first(where: { $0.attribute_code == "description"}) {
            var responseObject = descriptionData.value.description.withoutHtml
            responseObject = responseObject.trim()
            cell.descriptionText.text = responseObject
            cell.descriptionText.isHidden = responseObject.isEmpty

            //            if responseObject == nil{
            //                cell.descriptionLabelHeight.constant = 0
            //            }
        }

        //        if let imageUrl = model?.custom_attributes?.filter({ $0.attribute_code == "image" })
        //        {
        //            imagePath = imageUrl.first?.value.description ?? ""
        //        }
        //

        cell.serviceImageView.kf.indicatorType = .activity

        if  !(model.extension_attributes?.media_url ?? "").isEmpty &&  !(model.media_gallery_entries?.first?.file ?? "").isEmpty {

            let url = URL(string: String(format: "%@%@", model.extension_attributes?.media_url ?? "", (model.media_gallery_entries?.first?.file)! ))

            cell.serviceImageView.kf.setImage(with: url, placeholder: UIImage(named: "Servicelisting-card-default"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            cell.serviceImageView.image = UIImage(named: "Servicelisting-card-default")
        }

        cell.hideControls(hideDropDown: hideDropDown, hideCollection: !elements.isEmpty ? false : true)

    }
    // MARK: updateAddOnsForServiceDescriptionCell
    func updateAddOnsForServiceDescriptionCell(cell: ServiceDescriptionCell) {

        var serviceCount: Int = 0
        var arrayOfAddOnsTitle = [String]()
        var serviceTotalPrice: Double = 0
        var serviceStikeThroughPrice: Double = 0
        var offerPercentage: Double = 0
        var serviceTime: Double = 0

        let model = self.serverData[subCategoryDataObjSelectedIndex]
        if (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.bundle))! {
            serviceTotalPrice = 0
            if let productOptions = model.extension_attributes?.bundle_product_options {
                let productLinks = productOptions.compactMap {
                    $0.product_links?.filter { $0.isBundleProductOptionsSelected ?? false }
                }.flatMap { $0 }
                serviceCount = productLinks.count
                productLinks.forEach {
                    //  serviceTotalPrice += ($0.price ?? 0)
                    serviceTotalPrice += ((($0.specialPrice ?? 0.0) > Double(0.0)) && (($0.specialPrice ?? 0.0) < ($0.price ?? Double(0.0)))) ? $0.specialPrice ?? 0 :  ($0.price ?? 0)
                    serviceStikeThroughPrice += ($0.price ?? 0)
                    let doubleVal: Double = ($0.extension_attributes?.service_time?.toDouble() ?? 0 ) * 60
                    serviceTime += doubleVal

                    arrayOfAddOnsTitle.append($0.sku ?? "")
                    self.addServiceButtonBottom.isSelected = false
                    self.addServiceButtonBottom.isUserInteractionEnabled = true
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
                    cell.offerView.isHidden = false

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
                //serviceTotalPrice += (productLinks?.price ?? 0)
                serviceTotalPrice += (((productLinks?.special_price ?? 0.0) > Double(0.0)) && ((productLinks?.special_price ?? 0.0) < (productLinks?.price ?? Double(0.0))))   ? productLinks?.special_price ?? 0 :  (productLinks?.price ?? 0)
                let doubleVal: Double = (productLinks?.service_time?.toDouble() ?? 0 ) * 60
                serviceTime += doubleVal

                if let title = productLinks?.option_title {
                    arrayOfAddOnsTitle.append(title.description)
                }

                self.addServiceButtonBottom.isSelected = false
                self.addServiceButtonBottom.isUserInteractionEnabled = true
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
                    cell.offerView.isHidden = false

                }

            }

        }

        // This is common for both bundle and configure cell (Multi and Radio Selection )
        if !arrayOfAddOnsTitle .isEmpty {
            if (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.bundle))! {
                if serviceCount > 1 {
                    serviceCount -= 1

                    cell.dropdownText.text = String(format: "  %@ + %d add-ons", arrayOfAddOnsTitle.first ?? "NA", serviceCount)
                }
                else {
                    cell.dropdownText.text = String(format: "  %@", arrayOfAddOnsTitle.first ?? "NA")

                }
            }
            else {
                cell.dropdownText.text = String(format: "  %@", arrayOfAddOnsTitle.first ?? "NA")

            }

        }
        cell.priceLabel.text = String(format: " ₹ \(serviceTotalPrice.cleanForPrice)")
        self.serverData[subCategoryDataObjSelectedIndex].price = serviceTotalPrice
        let stringValue = String(format: "%@", serviceTime.asString(style: .brief))
        cell.lblServiceHours.resetServiceTime(text: stringValue, rangeText: serviceTime.asString(style: .brief))

    }

    // MARK: Set Value Frequently Booked Together
    func setFrequentlyBookedTogether(indexPath: IndexPath, cell: ServiceDetailsHairTreatmentCell) {

        cell.countLabel.isHidden = true
        cell.countButton.isHidden = true
        cell.stackViewConstraintCountLabel.isHidden = true
        var offerPercentage: Double = 0
        cell.memberOfferView.isHidden = true

        let model = self.arrfrequentlyBookedData[indexPath.row]
        cell.lblPrice.text = String(format: " ₹ \(model.price?.cleanForPrice ?? " 0")")
        cell.lblHeading.text = model.name

        cell.lblOldPrice.isHidden = true

        if model.type_id == SalonServiceTypes.simple || model.type_id == SalonServiceTypes.virtual {
            let specialPriceObj = checkSpecialPriceSimpleProduct(element: model)
            self.arrfrequentlyBookedData[indexPath.row].specialPrice = specialPriceObj.isHavingSpecialPrice ? specialPriceObj.specialPrice : 0

            let strPrice = String(format: " ₹ %@", model.price?.cleanForPrice ?? "0")
            let strSpecialPrice = String(format: " ₹ %@", self.arrfrequentlyBookedData[indexPath.row].specialPrice?.cleanForPrice ?? "0")

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

        if let shortDescription = model.custom_attributes?.first(where: { $0.attribute_code == "description"}) {
            var responseObject = shortDescription.value.description.withoutHtml
            responseObject = responseObject.trim()
            cell.lblDescription.text = responseObject

        }
        //cell.viewUnderline.isHidden = true
        cell.viewUnderline.isHidden = false

        var strReviewCount: String = ""
        if let reviewCount = model.extension_attributes?.total_reviews, reviewCount > 0 {
            strReviewCount = String(format: " \(SalonServiceSpecifierFormat.reviewFormat) reviews", reviewCount)
        }
        else {
            strReviewCount = "\(noReviewsMessage)"
           // cell.viewUnderline.isHidden = false

        }
        cell.lblReviews.text = strReviewCount
        cell.ratingView.rating = 0
        if let rating = model.extension_attributes?.rating_percentage, rating > 0 {
            cell.ratingView.rating = ((rating) / 100 * 5)
        }

        cell.countLabel.textColor = UIColor(red: 74 / 255.0, green: 74 / 255.0, blue: 74 / 255.0, alpha: 1.0)
        cell.countLabel.text  = "  Service add-ons to avail"

        if (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! ||  (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.bundle))! {

            cell.countLabel.isHidden = false
            cell.countButton.isHidden = false
            cell.stackViewConstraintCountLabel.isHidden = false
            cell.countLabel.isUserInteractionEnabled = true
            cell.countButton.isUserInteractionEnabled = true
//            cell.addServiceButton.isUserInteractionEnabled = false

            self.updateAddOnsFrequentlyBookedCell(indexPath: indexPath, cell: cell)

        }
        else /// Simple

        {
            if let serviceTime = model.custom_attributes?.first(where: { $0.attribute_code == "service_time"}) {
                let responseObject = serviceTime.value.description
                let doubleVal: Double = (responseObject.toDouble() ?? 0 ) * 60
                let stringValue = String(format: "Service Time:  %@", doubleVal.asString(style: .brief))
                cell.lblServiceHours.resetServiceTime(text: stringValue, rangeText: doubleVal.asString(style: .brief))

            }
            if model.isItemSelected == true {
                cell.addServiceButton.isSelected = true
                cell.addServiceButton.isUserInteractionEnabled = false

            }
        }

        if (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! ||  (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.bundle))! {
            if model.isItemSelected == true {
                cell.countLabel.isUserInteractionEnabled = false
                cell.countButton.isUserInteractionEnabled = false
            }
        }

    }

    // MARK: updateAddOnsFrequentlyBookedCell
    func updateAddOnsFrequentlyBookedCell(indexPath: IndexPath, cell: ServiceDetailsHairTreatmentCell) {

        var serviceTime: Double = 0
        var serviceCount: Int = 0
        var arrayOfAddOnsTitle = [String]()
        var serviceTotalPrice: Double = 0
        var serviceStikeThroughPrice: Double = 0
        var offerPercentage: Double = 0

        let model = self.arrfrequentlyBookedData[indexPath.row]
        if (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.bundle))! {
            serviceTotalPrice = 0
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
                    self.addServiceButtonBottom.isSelected = false
                    self.addServiceButtonBottom.isUserInteractionEnabled = true
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
            offerPercentage = 0

            if let productOptions = model.extension_attributes?.configurable_subproduct_options {
                let productLinks = productOptions.first(where: { $0.isSubProductConfigurableSelected == true})

                serviceCount += 1
                // serviceTotalPrice += (productLinks?.price ?? 0)
                serviceTotalPrice += (((productLinks?.special_price ?? 0.0) > Double(0.0)) && ((productLinks?.special_price ?? 0.0) < (productLinks?.price ?? Double(0.0))))   ? productLinks?.special_price ?? 0 :  (productLinks?.price ?? 0)

                let doubleVal: Double = (productLinks?.service_time?.toDouble() ?? 0 ) * 60
                serviceTime += doubleVal
                arrayOfAddOnsTitle.append(productLinks?.option_title?.description ?? "")
                cell.addServiceButton.isUserInteractionEnabled = true
                self.addServiceButtonBottom.isSelected = false
                self.addServiceButtonBottom.isUserInteractionEnabled = true
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
        else {
            cell.countLabel.text = " Service add-ons to avail"
        }

        cell.lblPrice.text = String(format: " ₹ \(serviceTotalPrice.cleanForPrice)")
        self.arrfrequentlyBookedData[indexPath.row].price = serviceTotalPrice
        let stringValue = String(format: "Service Time:  %@", serviceTime.asString(style: .brief))
        cell.lblServiceHours.resetServiceTime(text: stringValue, rangeText: serviceTime.asString(style: .brief))

    }

    func checkSpecialPriceSimpleProduct(element: HairTreatmentModule.Something.Items) -> (isHavingSpecialPrice: Bool, specialPrice: Double, offerPercentage: Double ) {

        // ****** Check for special price
        var isSpecialDateInbetweenTo = false
        var specialPrice: Double = 0.0
        var offerPercentage: Double = 0

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

        return (isSpecialDateInbetweenTo, specialPrice, offerPercentage.rounded(toPlaces: 1))
    }

    // MARK: showAddServiceSectionOrNot
    func showAddServiceSectionOrNot(index: Int) {
        if !self.arrfrequentlyBookedData.isEmpty {
            if self.arrfrequentlyBookedData.contains(where: { $0.isItemSelected == true }) {
                sections.insert(configureSection(idetifier: .cart_calculation, items: 1, data: [] ), at: index )
            }
        }

    }
    // MARK: updateADDFrequentlyAdddeService
    func updatefrequentlyAddedServiceData(addServiceInYourCartCell: AddServiceInYourCartCell) {

        var intAddOnCount: Int = 0
        var addOnPrice: Double = 0
        if !self.arrfrequentlyBookedData.isEmpty {

            for(_, element) in self.arrfrequentlyBookedData.enumerated() {
                if element.isItemSelected == true {
                    addOnPrice += (element.price ?? 0.0)
                    intAddOnCount += 1
                }
            }

            addServiceInYourCartCell.lblItemValue.text = String(format: "₹ %.1f", self.serverData[subCategoryDataObjSelectedIndex].price ?? 0.0)
            addServiceInYourCartCell.lblAddons.text = String(format: "%d Add-ons", intAddOnCount)
            addServiceInYourCartCell.lblAddonsValue.text = String(format: "₹ %.1f", addOnPrice)
            addServiceInYourCartCell.lblTotalValue.text = String(format: "₹ %.1f", (addOnPrice + (self.serverData[subCategoryDataObjSelectedIndex].price ?? 0.0)))

            if (self.serverData[self.subCategoryDataObjSelectedIndex].isItemSelected) != nil {
                addServiceInYourCartCell.btnAddService.setTitle(String(format: "Add %d services in Your Cart", intAddOnCount), for: .normal)
                updateAddToServiceButton()
            }
            else {
                addServiceInYourCartCell.btnAddService.setTitle(String(format: "Add %d services in Your Cart", intAddOnCount + 1), for: .normal)
                updateAddToServiceButton()

            }

        }

    }

    // MARK: Set Values For Cutomer Ratings And Reviews
    func setValuesForCutomerRatingsAndReviews(cell: CustomerRatingAndReviewCell) {

        var RateAndReviews: String = "" //  4.5/5
        cell.btnRateService.setTitle("RATE SERVICE", for: .normal)

        RateAndReviews = String(format: "%@/5", ((serverDataProductReviews?.data?.product_rating_percentage ?? 0.0) / 100 * 5).cleanForRating)
        cell.lblRating.text = RateAndReviews
        cell.lblRatingAndReviews.text = String(format: "%d Ratings & %d Reviews", serverDataProductReviews?.data?.product_rating_count ?? 0, serverDataProductReviews?.data?.product_review_count ?? 0)

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

        //        progressFifthValue = progressFifthValue/100
        // cell.progressViewFifth.progress = ((progressFifthValue)/serverDataProductReviews?.data?.product_rating_count ?? 0) * 100

    }

    // MARK: Set Values For Cutomer Ratings And Reviews
    func setValuesForCutomerFeedBack(indexPath: IndexPath, cell: ReviewThumpsUpDownCell) {

        let model = serverDataProductReviews?.data?.review_items?[indexPath.row]
        cell.lblCustomerComments.text = model?.detail ?? ""
        cell.lblcustomerName.text = String(format: "- %@ | %@%@ %@", model?.nickname ?? "", (model?.created_at ?? "").getFormattedDate().dayDateName, (model?.created_at ?? "").getFormattedDate().daySuffix(), (model?.created_at ?? "").getFormattedDate().monthNameAndYear)
        cell.lblRating.text = String(format: "%@/5", ((model?.rating_votes?.first?.percent ?? 0.0) / 100 * 5).cleanForRating)

    }
}

// MARK: CustomerRatingReviewCellDelegate
extension ServiceDetailModuleVC: CustomerRatingReviewCellDelegate {
    func actionToRateProductOrService() {
        let model = self.serverData[self.subCategoryDataObjSelectedIndex]
        if  GenericClass.sharedInstance.isuserLoggedIn().status {
            let vc = RateTheProductVC.instantiate(fromAppStoryboard: .Products)
            self.view.alpha = screenPopUpAlpha
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: {
                vc.lblProductName.text = model.name ?? ""
                vc.product_id = model.id ?? 0
                if  !(model.extension_attributes?.media_url ?? "").isEmpty &&  !(model.media_gallery_entries?.first?.file ?? "").isEmpty {
                    vc.showProductImage(imageStr: String(format: "%@%@", model.extension_attributes?.media_url ?? "", (model.media_gallery_entries?.first?.file)! ), typeServiceOrProduct: "Service")
                }

            })
            vc.onDoneBlock = { [unowned self] result in
                self.view.alpha = 1.0
            } }
 else { openLoginWindow() }
    }

}

extension ServiceDetailModuleVC {

    func configureSection(idetifier: SectionIdentifier, items: Int, data: Any) -> SectionConfiguration {

        var headerHeight: CGFloat = is_iPAD ? 70 : 50
        let leftMargin: CGFloat = is_iPAD ? 25 : 15

        let font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 30.0 : 20.0)

        switch idetifier {

        case .serviceDetails,
             .feedbackDetails:

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: 0, showHeader: false, showFooter: false, headerHeight: 0, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: true, textFont: font, textColor: UIColor.black, items: items, identifier: idetifier, data: data)

        case .customer_rating_review:

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: 0, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: true, textFont: font, textColor: UIColor.black, items: items, identifier: idetifier, data: data)

        case .additionalDetails:

            let height: CGFloat = is_iPAD ? 70 : 50
            let width: CGFloat = serviceDetailsTableView.frame.size.width

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: false, showFooter: false, headerHeight: 0, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: true, textFont: font, textColor: UIColor.black, items: items, identifier: idetifier, data: data)

        case .frequently_availed_services:

            headerHeight = is_iPAD ? 90 : 60
            let height: CGFloat = is_iPAD ? 450 : 300
            let width: CGFloat = self.serviceDetailsTableView.frame.size.width - (leftMargin * 2)

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: font, textColor: .black, items: items, identifier: idetifier, data: data)

        case .frequently_booked_together:

            let header: CGFloat = is_iPAD ? 135 : 90

            let height: CGFloat = is_iPAD ? 360 : 240
            let width: CGFloat = self.serviceDetailsTableView.frame.size.width

            var subHeading: String = ""
            if let categoryName = self.serverData[subCategoryDataObjSelectedIndex].name, !categoryName.isEmpty {
                subHeading = String(format: "With %@", categoryName)
            }

            return SectionConfiguration(title: idetifier.rawValue, subTitle: subHeading, cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: header, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: font, textColor: .black, items: items, identifier: idetifier, data: data)

        case .recently_viewed:

            //let header: CGFloat = is_iPAD ? 165 : 110
            let header: CGFloat = is_iPAD ? 90 : 60
            let height: CGFloat = is_iPAD ? 475 : 400
            let width: CGFloat = is_iPAD ? ((serviceDetailsTableView.frame.size.width - 100) / 3) : ((serviceDetailsTableView.frame.size.width - 45) / 2)

            return SectionConfiguration(title: "Recommended products", subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: header, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: font, textColor: .black, items: items, identifier: idetifier, data: data)

        case .get_insightful:

            let height: CGFloat = is_iPAD ? 350 : 240
            let width: CGFloat = is_iPAD ? 400 : 240

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: leftMargin, rightMarging: 0, isPagingEnabled: false, textFont: font, textColor: .black, items: items, identifier: idetifier, data: data)

        default :
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: 0, showHeader: false, showFooter: false, headerHeight: 0, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: false, textFont: font, textColor: UIColor.black, items: 0, identifier: idetifier, data: data)
        }
    }
}

// MARK: Frequently Availed Service
extension ServiceDetailModuleVC {
    // MARK: open ServiceDetails
    func openServiceDetails() {
        let serviceDetailModuleVC = ServiceDetailModuleVC
            .instantiate(fromAppStoryboard: .Services)
        serviceDetailModuleVC.serverData = serverDataForSelectedService
       // serviceDetailModuleVC.isShowAddToCart = false
        serviceDetailModuleVC.subCategoryDataObjSelectedIndex = 0
        serviceDetailModuleVC.isShowAddToCart = true
        var salonId = GenericClass.sharedInstance.getSalonId()

        if let model: HairTreatmentModule.Something.Items = serverDataForSelectedService.first {
            if let custom_attributes = model.custom_attributes {
                for model in custom_attributes {
                    if model.attribute_code == "salon_id" {

                        if  let cartSalonId = UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_key_CartHavingSalonIdIfService) as? String {
                            salonId = cartSalonId
                        }

                        if  let salonID = salonId, "\(model.value)".containsIgnoringCase(find: salonID) {
                            serviceDetailModuleVC.isShowAddToCart = false
                        }
                    }
                }
            }
        }

        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(serviceDetailModuleVC, animated: true)
        serviceDetailModuleVC.onDoneBlock = { result, data in
            if result {}
else {}
        }
    }

}

// MARK: Parsing Methods
extension ServiceDetailModuleVC {
    func parseProductDetails<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ServiceDetailModule.ServiceDetails.Response
        self.serverDataProductDetails = obj
        self.dispatchGroup.leave()
    }
    func parseFrequentlyAvailedProducts<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ServiceDetailModule.ServiceDetails.FrequentlyAvailedProductResponse
        if obj?.status == true {
            self.serverDataFrequentlyAvailedService = obj
        }
        else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj?.message ?? "" )

        }
        self.dispatchGroup.leave()

    }

    func parseProductReviews<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ServiceDetailModule.ServiceDetails.ProductReviewResponse

        if obj?.status == true {
            self.serverDataProductReviews = obj
        }
        else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj?.message ?? "" )

        }
        self.dispatchGroup.leave()
    }
    func parseRateAService<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ServiceDetailModule.ServiceDetails.RateAServiceResponse
        if obj?.status == true {
            self.showAlert(alertTitle: alertTitleSuccess, alertMessage: obj?.message ?? "")

        }
        else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj?.message ?? "")

        }
        self.dispatchGroup.leave()
    }

    func parseAddToWishList<T: Decodable>(viewModel: T) {
        let obj = viewModel as? HairTreatmentModule.Something.AddToWishListResponse
        if let status = obj?.status, status == true {
            self.updateCellForWishList(status: true)
            self.showToast(alertTitle: alertTitleSuccess, message: obj?.message ?? "", seconds: toastMessageDuration)

        }
        else {

            self.showToast(alertTitle: alertTitle, message: obj?.message ?? "", seconds: toastMessageDuration)

        }
        EZLoadingActivity.hide()
    }
    func parseRemoveFromWishList<T: Decodable>(viewModel: T) {
        let obj = viewModel as? HairTreatmentModule.Something.RemoveFromWishListResponse
        if obj?.status == true {
            self.updateCellForWishList(status: false)
            self.showToast(alertTitle: alertTitleSuccess, message: obj?.message ?? "", seconds: toastMessageDuration)

        }
        else {
            self.showToast(alertTitle: alertTitle, message: obj?.message ?? "", seconds: toastMessageDuration )

        }
        EZLoadingActivity.hide()

    }
    func parseGetInsight<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ProductLandingModule.Something.ResponseBlogs

        if obj?.status == true {
            let interactorProduct = ProductLandingModuleInteractor()
            self.arrOfGetInsight = interactorProduct.getBlogs(serverDataObj: obj) as? [GetInsightFulDetails] ?? []
        }
        else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj?.message ?? "")
        }
        self.dispatchGroup.leave()

    }
    func parseAddFrequentlyAvailedServices<T: Decodable>(viewModel: T) {
        if let obj = viewModel as? HairTreatmentModule.Something.Response {
            if let objCount = obj.total_count, objCount > 0 {
            /* Code Commented To for Database and Cache
             let finaldata = GenericClass.sharedInstance.checkDataInDatabase(data: obj)
             self.serverDataForSelectedService = finaldata*/
                self.serverDataForSelectedService = obj.items ?? []
            self.setDefaultValueForConfigurable(forFrequentlyBooked: false)
            self.openServiceDetails()

        }}
        self.dispatchGroup.leave()
    }
    func parseGetAllCartsItemCustomer<T: Decodable>(responseSuccess: [T]) {
        // GetAllCartItemsForCustomer
        if  let responseObj = responseSuccess as? [ProductDetailsModule.GetAllCartsItemCustomer.Response] {
            self.serverDataForAllCartItemsCustomer = responseObj
            updateAddToServiceButton()
            self.showAndHideBottomCart(guestCart: self.serverDataForAllCartItemsGuest ?? [], customerCart: self.serverDataForAllCartItemsCustomer ?? [])
            self.updateCartBadgeNumber(badgeCount: self.serverDataForAllCartItemsCustomer?.count ?? 0)

        }
        else {
            self.showAlert(alertTitle: alertTitle, alertMessage: GenericError)

        }
        self.dispatchGroup.leave()

    }

    func parseGetAllCartsItemGuest<T: Decodable>(responseSuccess: [T]) {

//        if  let responseObj = responseSuccess as? [ProductDetailsModule.GetAllCartsItemGuest.Response] {
//            self.serverDataForAllCartItemsGuest = responseObj
//            updateAddToServiceButton()
//            self.showAndHideBottomCart(guestCart: self.serverDataForAllCartItemsGuest ?? [], customerCart: self.serverDataForAllCartItemsCustomer ?? [])
//            self.updateCartBadgeNumber(badgeCount: self.serverDataForAllCartItemsGuest?.count ?? 0)
//            let salonAddress = CartHelper.sharedInstance.getSalonAddressInCaseServiceInCart(serverDataForAllCartItemsGuest: responseObj, serverDataForAllCartItemsCustomer: [])
//            if !salonAddress.isEmpty {
//                UserDefaults.standard.set(salonAddress.first?.salon_id, forKey: UserDefauiltsKeys.k_key_CartHavingSalonIdIfService)
//
//            }
//            else {
//                UserDefaults.standard.removeObject(forKey: UserDefauiltsKeys.k_key_CartHavingSalonIdIfService)
//
//            }
//
//        }
//        else {self.showAlert(alertTitle: alertTitle, alertMessage: GenericError)}
//
//        self.dispatchGroup.leave()

    }
    func parseDataGetQuoteIDMine<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ProductDetailsModule.GetQuoteIDMine.Response
        if obj?.status == true {
            UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart)

            self.getAllCartItemsAPICustomer()
        }
        else {}
        self.dispatchGroup.leave()
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
        self.dispatchGroup.leave()
    }
    // MARK: Parsing Methods For Carts
    func parseDataBulkProductGuest<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ProductDetailsModule.AddBulkProductGuest.Response
        if obj?.status == true {
            // Success Needs To check
            isAddingParentOrChildProductToCart ? self.updateParentServiceAfterAddToCart() : self.updateFrequentlyBookedServiceAfterAddToCart()
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
            isAddingParentOrChildProductToCart ? self.updateParentServiceAfterAddToCart() : self.updateFrequentlyBookedServiceAfterAddToCart()
            self.getAllCartItemsAPICustomer()
        }
        else {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj?.message ?? "")

        }
        self.dispatchGroup.leave()

    }

}

// MARK: CartBottom View
extension ServiceDetailModuleVC {
    func showAndHideBottomCart(guestCart: [ProductDetailsModule.GetAllCartsItemGuest.Response], customerCart: [ProductDetailsModule.GetAllCartsItemCustomer.Response]) {

        /* Code Commented To for Database and Cache
         let records = CoreDataStack.sharedInstance.allRecords(SelectedSalonService.self)*/
//        let isHideShow = CartHelper.sharedInstance.getCartSalonHomeServiceValues(lblHour: self.lblCartViewHours, lblService: self.lblCartViewServicesAndAmount, guestCart: guestCart, customerCart: customerCart)
//
//        DispatchQueue.main.async {[unowned self] in
//            self.constraintsCartViewHeight.constant = isHideShow ? 0 : (is_iPAD ? 120 : 70)
//            self.constraintsBookingDetailsButtonHeight.constant = isHideShow ? 0 : (is_iPAD ? 70 : 45)
//            self.cartViewBottom.isHidden = isHideShow
//            self.cartViewBottom.layoutIfNeeded()
//        }

        /* Code Commented To for Database and Cache GenericClass.sharedInstance.getCartSalonHomeServiceValues(lblHour: self.lblCartViewHours, lblService: self.lblCartViewServicesAndAmount)*/

    }
}

// MARK: Add Service Button Bottom View
extension ServiceDetailModuleVC {
    func updateAddToServiceButton() {

        DispatchQueue.main.async {[unowned self] in

            self.addServiceButtonBottom.isSelected = false
            self.addServiceButtonBottom.isUserInteractionEnabled = true
            self.addServiceViewBottom.backgroundColor = .black
            if let isSelected = self.serverData[self.subCategoryDataObjSelectedIndex].isItemSelected {
                self.addServiceButtonBottom.isSelected = isSelected
                self.addServiceButtonBottom.isUserInteractionEnabled = isSelected == true ? false :true
                self.addServiceButtonBottom.isHidden = isSelected == true ? true :false
                self.constraintsAddServiceViewHeight.constant = isSelected == true ? is_iPAD ? 0 : 0 :is_iPAD ? 120 : 70
                self.constraintsAddServiceButtonBottomsHeight.constant = isSelected == true ? is_iPAD ? 0 : 0 :is_iPAD ? 70 : 45
                self.addServiceViewBottom.layoutIfNeeded()

            }
            /* Code Commented To for Database and Cache
             let records = CoreDataStack.sharedInstance.allRecords(SelectedSalonService.self)*/

            let records = GenericClass.sharedInstance.isuserLoggedIn().status ? self.serverDataForAllCartItemsCustomer?.count : self.serverDataForAllCartItemsGuest?.count

            if records == 0 {
                self.addServiceButtonBottom.setBackgroundImage(UIImage(named: "enabledButton"), for: .normal)
                self.addServiceButtonBottom.setTitleColor(.white, for: .normal)

            }
            else {
                self.addServiceButtonBottom.setBackgroundImage(UIImage(named: ""), for: .normal)
                self.addServiceButtonBottom.setTitleColor(.black, for: .normal)
                self.addServiceViewBottom.backgroundColor = UIColor(red: 229 / 255, green: 246 / 255, blue: 248 / 255, alpha: 1.0)
            }

//            if self.isShowAddToCart {
//                self.addServiceButtonBottom.isHidden = true
//                self.constraintsAddServiceViewHeight.constant = 0
//                self.constraintsAddServiceButtonBottomsHeight.constant = 0
//                self.addServiceViewBottom.layoutIfNeeded()
//
//            }

            self.addServiceButtonBottom.isUserInteractionEnabled == false ? true: true

        }
    }
    // MARK: UpdateWishListButtonOnNavigationBar
    func updateWishListButtonOnNavigationBar() {

        var isWishListSelected: Bool = false

        if let isSelected = self.serverData[self.subCategoryDataObjSelectedIndex].isWishSelected {
            isWishListSelected = isSelected

        }

        if let isSelected = self.serverData[self.subCategoryDataObjSelectedIndex].extension_attributes?.wishlist_flag {
            isWishListSelected = isSelected

        }

        DispatchQueue.main.async { [unowned self] in
            let element = self.navigationItem.rightBarButtonItems?.first(where: { $0.tag == 2})
            element?.image = isWishListSelected == true ? UIImage(named: "navigationBarwishlistSelected")! : UIImage(named: "navigationBarwishlistUnSelected")!
            element?.tintColor = isWishListSelected == true ? .red : .black
        }
    }
}
extension ServiceDetailModuleVC: LoginRegisterDelegate {
    func doLoginRegister() {
        // Put your code here
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {[unowned self] in
            let vc = LoginModuleVC.instantiate(fromAppStoryboard: .Main)
            let navigationContrl = UINavigationController(rootViewController: vc)
            self.present(navigationContrl, animated: true, completion: nil)
        }
    }
}

extension ServiceDetailModuleVC: ServiceDescriptionCellDelegate {

    func addOns(indexPath: Int) {
        print("addOns Clicked Index \(indexPath)")

        let addOnsModuleViewController = AddOnsModuleViewController
            .instantiate(fromAppStoryboard: .Services)

        addOnsModuleViewController.selectedIndex = subCategoryDataObjSelectedIndex
        addOnsModuleViewController.serverData = self.serverData
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
            self.serverData = data ?? []
            self.view.alpha = 1.0

            let indexPathOfCell = IndexPath(row: 0, section: 0)
            if let cell = self.serviceDetailsTableView.cellForRow(at: indexPathOfCell) as? ServiceDescriptionCell {
            self.setValues(cell: cell)
            }
        }
    }
    func optionsBeTheFirstToReview() {

        let model = self.serverData[self.subCategoryDataObjSelectedIndex]
        if let reviewCount = model.extension_attributes?.total_reviews, reviewCount > 0 {
            optionsToOpenAllReviewsForToHeader()
            return
        }
//        if  GenericClass.sharedInstance.isuserLoggedIn().status {
//            let vc = RateTheProductVC.instantiate(fromAppStoryboard: .Products)
//            self.view.alpha = screenPopUpAlpha
//            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: {
//                vc.lblProductName.text = model?.name ?? ""
//                vc.product_id = model?.id ?? 0
//
//                if  !(model?.extension_attributes?.media_url ?? "").isEmpty &&  !(model?.media_gallery_entries?.first?.file ?? "").isEmpty {
//                    vc.showProductImage(imageStr: String(format: "%@%@", model?.extension_attributes?.media_url ?? "", (model?.media_gallery_entries?.first?.file)! ), typeServiceOrProduct: "Service")
//                }
//
//            })
//            vc.onDoneBlock = { [unowned self] result in
//                self.view.alpha = 1.0
//            }
//        }
//        else {
//            openLoginWindow()
//        }
    }

}

// MARK: Add Cart Additinal Services
extension ServiceDetailModuleVC: AddServiceInYourCartCellCellDelegate {
    func addAdditionalService(indexPath: IndexPath) {
        print("addAction Clicked Index \(indexPath)")

    }
}
// MARK: Add Service Button Bottom View
extension ServiceDetailModuleVC: ServiceDetailsHairTreatmentCellDelegate {
    func addOnsServiceDetailsHairTreatmentCell(indexPath: IndexPath) {
        print("addOnsServiceDetailsHairTreatmentCell Clicked Index \(indexPath)")
        if !self.arrfrequentlyBookedData.isEmpty {
            var addonsData = HairTreatmentModule.Something.Response(items: [], search_criteria: nil, total_count: self.arrfrequentlyBookedData.count)
            addonsData.items = arrfrequentlyBookedData

            let addOnsModuleViewController = AddOnsModuleViewController
                .instantiate(fromAppStoryboard: .Services)

            addOnsModuleViewController.selectedIndex = indexPath.row
            addOnsModuleViewController.serverData = addonsData.items ?? []
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
                self.arrfrequentlyBookedData = data ?? []
                self.view.alpha = 1.0

                if let cell = self.serviceDetailsTableView.cellForRow(at: indexPath) as?  ServiceDetailsHairTreatmentCell {
                self.updateAddOnsFrequentlyBookedCell(indexPath: indexPath, cell: cell)
            }
                self.showAndHideBottomCart(guestCart: self.serverDataForAllCartItemsGuest ?? [], customerCart: self.serverDataForAllCartItemsCustomer ?? [])

            }

        }

    }

    func addAction(indexPath: IndexPath) {
        print("addAction Clicked Index \(indexPath)")
//        isAddingParentOrChildProductToCart = false
//        selectedFrequentlyBookedTogetherIndex = indexPath
//        let model = self.arrfrequentlyBookedData[selectedFrequentlyBookedTogetherIndex.row]
//        if CartHelper.sharedInstance.toShowAlertForAllAddToCartServiceScenerio(model: model, serverDataForAllCartItemsGuest: serverDataForAllCartItemsGuest ?? [], serverDataForAllCartItemsCustomer: serverDataForAllCartItemsCustomer ?? [], viewController: self) {
//
//        if !(model.isItemSelected ?? false)! {
//            GenericClass.sharedInstance.isuserLoggedIn().status ? addToCartSimpleOrVirtualProductForCustomer(selected: model) : addToCartSimpleOrVirtualProductForGuest(selected: model)
//
//        }
//        }

    }
    func optionsBeTheFirstToReview(indexPath: IndexPath) {

        let model = self.arrfrequentlyBookedData[indexPath.row]
        if let reviewCount = model.extension_attributes?.total_reviews, reviewCount > 0 {
            optionsToOpenAllReviewsForFrequentlyBookedTogether(indexPath: indexPath)
            return
        }
        if  GenericClass.sharedInstance.isuserLoggedIn().status {
            let vc = RateTheProductVC.instantiate(fromAppStoryboard: .Products)
            self.view.alpha = screenPopUpAlpha
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: {
                vc.lblProductName.text = model.name ?? ""
                vc.product_id = model.id ?? 0
                vc.showProductImage(imageStr: "", typeServiceOrProduct: "Service")
            })
            vc.onDoneBlock = { [unowned self] result in
                self.view.alpha = 1.0
            } }
 else { openLoginWindow() }
    }

}

// MARK: Data Feeding
extension ServiceDetailModuleVC {

    // MARK: createDataForAfterTips
    func createDataForAfterTips() {
        dispatchGroupDataFeeding.enter()
        arrafterTipsData.removeAll()
        if serverDataProductDetails?.extension_attributes?.tips_info?.count ?? 0 > 0 {
            for(_, element) in (serverDataProductDetails?.extension_attributes?.tips_info?.enumerated())! {
                if let string = element.value, !string.isEmpty {
                    let responseObject = string
                    var data = responseObject.components(separatedBy: "\r\n")
                    data = data.filter { $0 != "" }
                    //                    let unicode = "\\u25CF".unescapingUnicodeCharacters
                    //                    data = data.map { "  \(unicode) \($0)" }
                    let menu = PointsCellData(title: element.label ?? "NA", points: data)
                    arrafterTipsData.append(menu)
                }
            }
            if !arrafterTipsData.isEmpty {
                sections.append(configureSection(idetifier: .additionalDetails, items: (arrafterTipsData.count), data: arrafterTipsData))
            }
        }
        dispatchGroupDataFeeding.leave()

    }

    // MARK: createDataForFrequentlyBookedTogether
    func createDataForFrequentlyBookedTogether() {
        dispatchGroupDataFeeding.enter()
        arrfrequentlyBookedData.removeAll()

        if let frequentBookData = serverDataProductDetails?.product_links?.filter({ $0.link_type == "related"}), !frequentBookData.isEmpty {
            arrfrequentlyBookedData = frequentBookData
            var addonsData = HairTreatmentModule.Something.Response(items: [], search_criteria: nil, total_count: self.arrfrequentlyBookedData.count)
            addonsData.items = arrfrequentlyBookedData
            /* Code Commented To for Database and Cache
             let finaldata = GenericClass.sharedInstance.checkDataInDatabase(data: addonsData)
             arrfrequentlyBookedData = finaldata.items!*/
            arrfrequentlyBookedData = addonsData.items ?? []
            setDefaultValueForConfigurable(forFrequentlyBooked: true)
            sections.append(configureSection(idetifier: .frequently_booked_together, items: arrfrequentlyBookedData.count, data: []))
        }
        dispatchGroupDataFeeding.leave()
    }

    // MARK: createDataForRecommendedProducts
    func createDataForRecommendedProducts() {
        dispatchGroupDataFeeding.enter()

        recommendedProductsData.removeAll()

        if let recommededProducts = serverDataProductDetails?.product_links?.filter({ $0.link_type == "upsell"}), !recommededProducts.isEmpty {
            for(_, element) in recommededProducts.enumerated() {
                if let intOutOfStock = element.stock_status, intOutOfStock == 1 {
                    var imagePath: String = ""
                    var strBaseMediaUrl: String = ""

                    if let extension_attributes = element.extension_attributes {
                        strBaseMediaUrl = extension_attributes.media_url ?? ""
                    }

                    if let imageUrl = element.custom_attributes?.filter({ $0.attribute_code == "image" }), !strBaseMediaUrl.isEmpty {
                        imagePath = strBaseMediaUrl + (imageUrl.first?.value.description ?? "")
                    }

                    var specialPrice = element.price ?? 0
                    var offerPercentage: Double = 0
                    let isFevo = GenericClass.sharedInstance.isuserLoggedIn().status ? (element.extension_attributes?.wishlist_flag ?? false) : false

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
                            offerPercentage = specialPrice.getPercent(price: element.price ?? 0)
                        }
                    }
                   // let obj = RecommendedProduct(productName: element.name ?? "", productImageURL: imagePath, price: specialPrice.cleanForPrice, productId: String(format: "%d", element.id!), sku: element.sku!)
                    //recommendedProductsData.append(obj)

                    recommendedProductsData.append(ProductModel(productId: element.id ?? 0, productName: element.name ?? "", price: element.price ?? 0, specialPrice: specialPrice, reviewCount: element.extension_attributes?.total_reviews?.cleanForPrice ?? "0", ratingPercentage: (element.extension_attributes?.rating_percentage ?? 0.0).getPercentageInFive(), showCheckBox: false, offerPercentage: offerPercentage.cleanForRating, isFavourite: isFevo, strImage: imagePath, sku: element.sku ?? "", isProductSelected: false, type_id: element.type_id ?? "", type_of_service: element.extension_attributes?.type_of_service ?? "" ))
                }
            }
            if !recommendedProductsData.isEmpty {
                sections.append(configureSection(idetifier: .recently_viewed, items: recommendedProductsData.count, data: recommendedProductsData))
            }
        }
        dispatchGroupDataFeeding.leave()
    }

    // MARK: createDataForFrequentlyAvailedService
    func createDataForFrequentlyAvailedService() {
        dispatchGroupDataFeeding.enter()
        arrFrequentlyAvailedData.removeAll()
        var maleOrFemale: String = PersonType.female
        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
            maleOrFemale = userSelectionForService.gender
        }

        if let frequentlyAvailed = self.serverDataFrequentlyAvailedService?.data?.frequently_availed, !frequentlyAvailed.isEmpty {
            for(_, element) in (self.serverDataFrequentlyAvailedService?.data?.frequently_availed?.enumerated())! {
                let obj = TrendingService(serviceName: element.name ?? "", serviceImageURL: element.image ?? "", id: element.id ?? "", sku: element.sku ?? "", imgMaleFemale: maleOrFemale == PersonType.male ? "serviceTrendingMale" : "serviceTrendingFemale"  )

                arrFrequentlyAvailedData.append(obj)
            }
            sections.append(configureSection(idetifier: .frequently_availed_services, items: arrFrequentlyAvailedData.count, data: arrFrequentlyAvailedData))
        }
        dispatchGroupDataFeeding.leave()

    }
}
