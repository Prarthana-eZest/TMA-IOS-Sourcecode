import UIKit
import FirebaseAnalytics

protocol SearchModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
}

class SearchModuleVC: UIViewController {

    var interactor: ProductListingModuleBusinessLogic?

    @IBOutlet weak var tblShowSearch: UITableView!
    lazy var searchBar: UISearchBar = UISearchBar()
    @IBOutlet weak var searchBarObj: UISearchBar!
    var strSearchText = ""
    var arrItems: [HairTreatmentModule.Something.Items] = []
    private let dispatchGroup = DispatchGroup()// Multi Web Service Calls Hanle Dispatch
    private var totalItemsCount: Int = 0
    private var currentPage = 1
    private var favoSelectedIndexPath = 0
    var isBestsellerProducts = false
    var isServiceClicked = false
    var serverDataForSelectedTrendingService: HairTreatmentModule.Something.Response?
    var subCategoryDataObjSelectedIndex = 0
    private var memberShipDetails: ClubMembershipModule.MembershipDetails.Response?
    private var membershipKnowMore: ClubMembershipModule.MembershipKnowMore.Response?
    private var selectedIndexOfCell = 0

    @IBOutlet weak var lblProductNotFound: UILabel!
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

        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchModuleVC.dismissKeyboard))
        view.addGestureRecognizer(tap)

        tblShowSearch.delegate = self
        tblShowSearch.dataSource = self
        tblShowSearch.register(UINib(nibName: CellIdentifier.hairTreatmentCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.hairTreatmentCell)

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
        lblProductNotFound.text = TableViewNoData.tableViewNoSearchResults
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.addCustomBackButton(title: "")

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        if arrItems.isEmpty {
            self.view.endEditing(true)
            self.searchBar.resignFirstResponder()
        }
    }
}

extension SearchModuleVC: ProductListingModuleDisplayLogic {

    // MARK: - Get Search data
    func parseData(text: String) -> [FilterKeys] {

        var encodingStr = text.replacingOccurrences(of: " ", with: "+")
        encodingStr = encodingStr.replacingOccurrences(of: "&", with: "%26")

        var arrForKeysValues: [FilterKeys] = []
        let arrayAttrSet = [FilterKeys(field: "attribute_set_id", value: GenericClass.sharedInstance.getServiceAttributeId(), type: "eq"), FilterKeys(field: "attribute_set_id", value: GenericClass.sharedInstance.getProductAttributeId(), type: "eq"), FilterKeys(field: "attribute_set_id", value: GenericClass.sharedInstance.getMembershipAttributeId(), type: "eq")]
        arrForKeysValues.append(FilterKeys(field: "filter", value: arrayAttrSet, type: ""))
        let array = [FilterKeys(field: "name", value: "\(encodingStr)", type: "like"),
                     FilterKeys(field: "description", value: "\(encodingStr)", type: "like"),
                                FilterKeys(field: "short_description", value: "\(encodingStr)", type: "like")]
        arrForKeysValues.append(FilterKeys(field: "description_own", value: array, type: ""))
        arrForKeysValues.append(FilterKeys(field: "type_id", value: "giftcard", type: "neq"))

        let arrayVis = [FilterKeys(field: "visibility", value: 4, type: "eq"), FilterKeys(field: "visibility", value: 3, type: "eq")]
        arrForKeysValues.append(FilterKeys(field: "filter", value: arrayVis, type: ""))
        arrForKeysValues.append(FilterKeys(field: "status", value: 1, type: "eq"))
        var arrSalonId: [FilterKeys] = []

        if  let userData = UserDefaults.standard.value(MyProfile.GetUserProfile.UserData.self, forKey: UserDefauiltsKeys.k_Key_LoginUser),
            let salonId = userData.salon_id {
            arrSalonId = [FilterKeys(field: "salon_id", value: salonId, type: "finset" ), FilterKeys(field: "salon_id", value: "ecommerce", type: "finset")]
        }
        else {
            arrSalonId = [FilterKeys(field: "salon_id", value: "ecommerce", type: "finset")]
        }
        if !arrSalonId.isEmpty {
            arrForKeysValues.append(FilterKeys(field: "filter", value: arrSalonId, type: ""))
        }

        //        arrForKeysValues.append(FilterKeys(field: "type_id", value: "configurable", type: "neq"))

        return arrForKeysValues
    }

    // MARK: - Call API - Search product listing
    func callProductListing(text: String) {
        EZLoadingActivity.show("", disableUI: true)
        self.dispatchGroup.enter()
        if arrItems.isEmpty {
            tblShowSearch.isHidden = true
        }
        lblProductNotFound.isHidden = true
        isServiceClicked = false
        let query = interactor?.getURLForType(arrSubCat_type: self.parseData(text: text), pageSize: kProductCountPerPageForListing, currentPageNo: self.currentPage, is_config_bundle_brief_info_required: true)
        let request = HairTreatmentModule.Something.Request(queryString: query ?? "")
        interactor?.doGetRequestWithParameter(request: request, isBestSeller: isBestsellerProducts )
    }

    // MARK: getDataForSelectedTrendingService
    func getDataForSelectedTrendingService(subCategoryId: String, genderId: String = "") {
        EZLoadingActivity.show("", disableUI: true)
        dispatchGroup.enter()
        var queryString = "[filterGroups][0][filters][0][field]=entity_id&searchCriteria[filterGroups][0][filters][0][value]=\(subCategoryId)&searchCriteria[filterGroups][0][filters][0][conditionType]=eq"

        if !genderId.isEmpty {
            queryString += String(format: "&searchCriteria[filterGroups][1][filters][0][field]=gender&searchCriteria[filterGroups][1][filters][0][value]=\(genderId)&searchCriteria[filterGroups][1][filters][0][conditionType]=finset")

        }
        if  let userSalonId = GenericClass.sharedInstance.getSalonId(), userSalonId != "0" {
            queryString += String(format: "&searchCriteria[filterGroups][2][filters][0][field]=salon_id&searchCriteria[filterGroups][2][filters][0][value]=%@&searchCriteria[filterGroups][2][filters][0][conditionType]=finset", userSalonId)
        }

        queryString += String(format: "&searchCriteria[filterGroups][3][filters][0][field]=visibility&searchCriteria[filterGroups][3][filters][0][value]=4&searchCriteria[filterGroups][3][filters][0][conditionType]=eq")

//        if  GenericClass.sharedInstance.isuserLoggedIn().status {
//            queryString += String(format: "&customer_id=%@", GenericClass.sharedInstance.isuserLoggedIn().customerId.toString)
//        }
        queryString += String(format: "&is_custom=true")

        isServiceClicked = true
        let request = HairTreatmentModule.Something.Request(queryString: queryString)
        interactor?.doGetRequestWithParameter(request: request, isBestSeller: isBestsellerProducts)

    }
    func getKnowMoreMembershipDetails(membershipSku: String) {
        EZLoadingActivity.show("", disableUI: true)
        dispatchGroup.enter()
        let request = ClubMembershipModule.MembershipKnowMore.Request(membership_product_sku: membershipSku)
        interactor?.postToGetMemberShipBenefits(request: request)

    }
    func getMembershipDetails() {
        EZLoadingActivity.show("", disableUI: true)
        dispatchGroup.enter()
        let request = ClubMembershipModule.MembershipDetails.Request()
        interactor?.doGetRequestToMembershipDetails(request: request, method: .get)
    }

    // MARK: - Success
    func displaySuccess<T>(viewModel: T) where T: Decodable {
        EZLoadingActivity.hide()
        if let obj = viewModel as? HairTreatmentModule.Something.Response {
                /* Code Commented To for Database and Cache
                 let finaldata = GenericClass.sharedInstance.checkDataInDatabase(data: obj)
                 self.serverDataForSelectedTrendingService = finaldata*/
                if let totalCount = obj.total_count, totalCount > 0 {
                    self.serverDataForSelectedTrendingService = obj
                    self.parseResponseProductListing(obj: obj)
                    self.setDefaultValueForConfigurable()
                }
                else {
                  self.tblShowSearch.isHidden = true
                  self.lblProductNotFound.isHidden = false
                }
            EZLoadingActivity.hide()
            self.dispatchGroup.leave()
        }
        else if T.self == ClubMembershipModule.MembershipKnowMore.Response.self {
            self.parseMembershipKnowMore(viewModel: viewModel)
        }
        else if T.self == ClubMembershipModule.MembershipDetails.Response.self {
            // Member
            self.parseMembershipData(viewModel: viewModel)
        }
    }

    func displaySuccess<T: Decodable>(responseSuccess: [T]) {
        EZLoadingActivity.hide()
    }

    func parseResponseProductListing(obj: HairTreatmentModule.Something.Response) {
        totalItemsCount = obj.total_count ?? 0
        if let items = obj.items, !items.isEmpty {
            arrItems += (obj.items ?? [])
        }

        if arrItems.isEmpty == false {
            currentPage += 1
            tblShowSearch.isHidden = false
            tblShowSearch.reloadData()
        }
        else {
            if arrItems.isEmpty  && !strSearchText.isEmpty {
            self.tblShowSearch.isHidden = true
            self.lblProductNotFound.isHidden = false
                }
        }
    }
    func parseMembershipData<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ClubMembershipModule.MembershipDetails.Response
        self.memberShipDetails = obj
        EZLoadingActivity.hide()
        self.dispatchGroup.leave()
        let model = self.arrItems[selectedIndexOfCell]
        getKnowMoreMembershipDetails(membershipSku: model.sku ?? "")

    }

    func parseMembershipKnowMore<T: Decodable>(viewModel: T) {
        if let obj = viewModel as? ClubMembershipModule.MembershipKnowMore.Response {

//            if let status = obj.status, status == true {
//                membershipKnowMore = obj
//                switch obj.data?.name {
//                case MembershipType.clubMemberShip :
//                    actionToBecomeMember()
//
//                case MembershipType.premierMembership :
//                    actionToBecomePremierMember()
//                case MembershipType.eliteMembership :
//                    actionToBecomeEliteMember()
//                default: break
//                }
//
//            }
//            else {
//                self.showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "")
//            }
        }

        EZLoadingActivity.hide()
        self.dispatchGroup.leave()

    }

    // MARK: - Error
    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        self.dispatchGroup.leave()
        DispatchQueue.main.async { [unowned self] in
            self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
        }
    }
}

// MARK: - Show & handle search bar on navigation
extension SearchModuleVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        searchBar.resignFirstResponder()
        if let text = searchBar.text, !text.isEmpty {
            strSearchText = "%\(text)%"
            callProductListing(text: "%\(text)%")
            arrItems = []
            tblShowSearch.reloadData()
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
            clearSearchData()
            return
        }
        print(query)
    }

    func hideSearchController() {
        navigationItem.titleView = nil
    }

    func showSearchController() {

        navigationItem.titleView = searchBar
        //        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: AlertButtonTitle.cancel, style: .plain, target: self, action: #selector(searchCancel))
    }

    @objc func searchCancel(sender: UIButton) {
        clearSearchData()
    }

    func clearSearchData() {
        self.searchBar.text = ""
        arrItems = []
        currentPage = 1
        tblShowSearch.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension SearchModuleVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !arrItems.isEmpty {
            return arrItems.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.hairTreatmentCell) as? HairTreatmentCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.indexPath = indexPath
        cell.configureCell(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = .none
        setValues( cell: cell, indexPath: indexPath)
        return cell
    }

    // MARK: Set Value For Service Description Cell
    func setValues(cell: HairTreatmentCell, indexPath: IndexPath) {

        if !self.arrItems.isEmpty {
            let model = self.arrItems[indexPath.row]

            cell.lblHeading.text = model.name
            cell.lblPrice.text = String(format: " ₹ %@", model.price?.cleanForPrice ?? " ₹ 0")
            cell.lblOldPrice.isHidden = true
            cell.lblPrice.isHidden = false

            if (model.type_id ?? "").compareIgnoringCase(find: SalonServiceTypes.simple) || (model.type_id ?? "").compareIgnoringCase(find: SalonServiceTypes.virtual) {
                let specialPriceObj = checkSpecialPriceSimpleProduct(element: model)
                self.arrItems[indexPath.row].specialPrice = specialPriceObj.isHavingSpecialPrice ? specialPriceObj.specialPrice : 0
                // cell.lblPrice.text =  String(format: " ₹ %@", specialPriceObj.isHavingSpecialPrice ? specialPriceObj.specialPrice.cleanForPrice : model?.price?.cleanForPrice ?? "0" )

                let strPrice = String(format: " ₹ %@", model.price?.cleanForPrice ?? "0")
                let strSpecialPrice = String(format: " ₹ %@", self.arrItems[indexPath.row].specialPrice?.cleanForPrice ?? "0")

                let attributeString = NSMutableAttributedString(string: "")
                attributeString.append(strPrice.strikeThrough())
                cell.lblOldPrice.attributedText = attributeString

                cell.lblOldPrice.isHidden = specialPriceObj.specialPrice == model.price ? true : specialPriceObj.specialPrice > 0 ? false : true

                cell.lblPrice.text = specialPriceObj.isHavingSpecialPrice ? strSpecialPrice :  strPrice
            }
            else if (model.type_id ?? "").compareIgnoringCase(find: SalonServiceTypes.bundle) {
                cell.lblPrice.isHidden = true
            }

            cell.viewUnderline.isHidden = true
            var strReviewCount: String = ""
            if let reviewCount = model.extension_attributes?.total_reviews, reviewCount > 0 {
                strReviewCount = String(format: " \(SalonServiceSpecifierFormat.reviewFormat) reviews", reviewCount)
                cell.viewUnderline.isHidden = false
            }
            else {
                strReviewCount = "0 reviews"
                cell.viewUnderline.isHidden = true
            }
            cell.lblReviews.text = strReviewCount
            cell.lblDescription.isHidden = true

            /*** Rating And Reviews Condition ***/
            cell.ratingView.rating = 0
            if let rating = model.extension_attributes?.rating_percentage, rating > 0 {
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
            cell.btnWishList.isHidden = true
            cell.btnWishList.isSelected = false

            //            if model.extension_attributes?.wishlist_flag == true || model?.isWishSelected == true {
            //                if GenericClass.sharedInstance.isuserLoggedIn().status {
            //                    cell.btnWishList.isSelected = true
            //                }
            //            }
            /*** Plus Button Condition ***/
            cell.countLabel.textColor = UIColor(red: 74 / 255.0, green: 74 / 255.0, blue: 74 / 255.0, alpha: 1.0)
            cell.countLabel.text  = "  Service add-ons to avail"

            cell.countLabel.isHidden = true
            cell.countButton.isHidden = true
            cell.countLableView.isHidden = true
            cell.dropDownStackView.isHidden = true
            cell.addServiceButton.isHidden = true
            cell.serviceTimeStackView.isHidden = true
            cell.memberOfferView.isHidden = true

            cell.prodDerviceTypeShow.isHidden = false
            cell.lblShowType.isHidden = false

            let productAttributeId: String = GenericClass.sharedInstance.getProductAttributeId()
            let membershipAttributeId: String = GenericClass.sharedInstance.getMembershipAttributeId()

            if model.attribute_set_id == productAttributeId.toDouble() {
                cell.lblShowType.text = "Product"
                cell.imgView_Product.contentMode = .scaleAspectFit

            }
            else if model.attribute_set_id == membershipAttributeId.toDouble() {
                cell.lblShowType.text = "Membership"
                cell.imgView_Product.contentMode = .scaleAspectFit

            }
            else {
                cell.lblShowType.text = "Service"
                cell.imgView_Product.contentMode = .scaleToFill

            }

            if (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! ||  (model.type_id?.equalsIgnoreCase(string: SalonServiceTypes.bundle))! {
                self.updateAddOnCountAndServiceTime(indexPath: indexPath, cell: cell)
            }

            //Condition to Hide AddONs button
            cell.countLabel.isUserInteractionEnabled = true
            cell.countButton.isUserInteractionEnabled = true
            cell.dropDownStackView.isHidden = true

            cell.imgView_Product.image = UIImage(named: "trendingservicesdefault")
            cell.imgView_Product.kf.indicatorType = .activity
            if  !(model.extension_attributes?.media_url ?? "").isEmpty &&  !(model.media_gallery_entries?.first?.file ?? "").isEmpty {
                let url = URL(string: String(format: "%@%@", model.extension_attributes?.media_url ?? "", (model.media_gallery_entries?.first?.file)! ))
                cell.imgView_Product.kf.setImage(with: url, placeholder: UIImage(named: "trendingservicesdefault"), options: nil, progressBlock: nil, completionHandler: nil)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (arrItems.count - 1) && arrItems.count < totalItemsCount {
            callProductListing(text: strSearchText)
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

        return (isSpecialDateInbetweenTo, specialPrice, offerPercentage.rounded(toPlaces: 1))
    }
    //
    func updateAddOnCountAndServiceTime(indexPath: IndexPath, cell: HairTreatmentCell) {

        var serviceTime: Double = 0
        var serviceCount: Int = 0
        var arrayOfAddOnsTitle = [String]()
        var serviceTotalPrice: Double = 0
        var serviceStikeThroughPrice: Double = 0
        var isSpecialDateInbetweenTo = false

        let model = arrItems[indexPath.row]
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
                    cell.lblOldPrice.isHidden = ((($0.specialPrice ?? 0.0) > Double(0.0)) && (($0.specialPrice ?? 0.0) < ($0.price ?? Double(0.0))))  ? false : true

                    if (($0.specialPrice ?? 0.0) > Double(0.0)) && (($0.specialPrice ?? 0.0) < ($0.price ?? Double(0.0))) {
                        let strPrice = String(format: " ₹ %@", (serviceStikeThroughPrice ).cleanForPrice )
                        let attributeString = NSMutableAttributedString(string: "")
                        attributeString.append(strPrice.strikeThrough())
                        cell.lblOldPrice.attributedText = attributeString
                    }

                }
            }

        }
        else // Radio Configurable
        {
            serviceTotalPrice = 0
            serviceStikeThroughPrice = 0
                    
            isSpecialDateInbetweenTo = false

//            if let productOptions = model.extension_attributes?.configurable_subproduct_options {
//                let productLinks = productOptions.first(where: { $0.isSubProductConfigurableSelected == true})
//
//                serviceCount += 1
//                serviceTotalPrice += (((productLinks?.special_price ?? 0.0) > Double(0.0)) && ((productLinks?.special_price ?? 0.0) < (productLinks?.price ?? Double(0.0))))   ? productLinks?.special_price ?? 0 :  (productLinks?.price ?? 0)
//                let doubleVal: Double = (productLinks?.service_time?.toDouble() ?? 0 ) * 60
//                serviceTime += doubleVal
//                if let title = productLinks?.option_title {
//                    arrayOfAddOnsTitle.append(title.description)
//                }
//                cell.addServiceButton.isUserInteractionEnabled = true
//                cell.lblOldPrice.isHidden = (((productLinks?.special_price ?? 0.0) > Double(0.0)) && ((productLinks?.special_price ?? 0.0) < (productLinks?.price ?? Double(0.0)))) ? false : true
//
//                if ((productLinks?.special_price ?? 0.0) > Double(0.0)) && ((productLinks?.special_price ?? 0.0) < (productLinks?.price ?? Double(0.0))) {
//                    let strPrice = String(format: " ₹ %@", (productLinks?.price ?? 0.0).cleanForPrice )
//                    let attributeString = NSMutableAttributedString(string: "")
//                    attributeString.append(strPrice.strikeThrough())
//                    cell.lblOldPrice.attributedText = attributeString
//                }
//
//            }
            
            if let configurable_options_info = model.extension_attributes?.configurable_options_info, !configurable_options_info.isEmpty, let configurable_options_infoData = configurable_options_info.first {
                serviceCount += 1
                isSpecialDateInbetweenTo = GenericClass.sharedInstance.isSpecialPriceApplicable(special_from_date: configurable_options_infoData.special_from_date, special_to_date: configurable_options_infoData.special_to_date)
                cell.lblOldPrice.isHidden = isSpecialDateInbetweenTo ? false : true
                serviceStikeThroughPrice = configurable_options_infoData.price ?? 0.0
                
                if isSpecialDateInbetweenTo {
                    if let specialPriceValue = configurable_options_infoData.special_price {
                        serviceTotalPrice = specialPriceValue
                        let strPrice = String(format: " \(k_RupeeSymbol) %@", (serviceStikeThroughPrice ).rounded().cleanForPrice )
                        let attributeString = NSMutableAttributedString(string: "")
                        attributeString.append(strPrice.strikeThrough())
                        cell.lblOldPrice.attributedText = attributeString

                    }
                }
                else {
                    serviceTotalPrice = configurable_options_infoData.price ?? 0.0
                }
                
            }

        }

        // This is common for both bundle and configure cell (Multi and Radio Selection )
        if !arrayOfAddOnsTitle.isEmpty {
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
        arrItems[indexPath.row].price = serviceTotalPrice
        let stringValue = String(format: "%@", serviceTime.asString(style: .brief))
        cell.lblServiceHours.text = stringValue
    }

    // MARK: Default Configurable(Radio)Selected
    func setDefaultValueForConfigurable() {
        var isAnySelected: Bool = false
        for(_, element)in (arrItems.enumerated()) {
            if (element.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! {
                if (element.extension_attributes?.configurable_subproduct_options?.first(where: { $0.isSubProductConfigurableSelected == true})) != nil {
                    isAnySelected = true

                }
            }
        }

        if isAnySelected == false {

            for(index, element)in (arrItems.enumerated()) {
                if (element.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! {
                    for(index2, _)in (element.extension_attributes?.configurable_subproduct_options?.enumerated())! {
                        arrItems[index].extension_attributes?.configurable_subproduct_options?[index2].isSubProductConfigurableSelected = true
                        break
                    }

                }

            }
        }

    }
}

// MARK: - Add Service Button Bottom View
extension SearchModuleVC: HairTreatmentCellDelegate {
    func moveToCart(indexPath: Int) {
        print("moveToCart Clicked Index \(indexPath)")
    }

    func wishList(indexPath: IndexPath) {
    }

    func addOns(indexPath: Int) {
    }

    func viewDetails(indexPath: Int) {
        print("viewDetails Clicked Index \(indexPath)")
        selectedIndexOfCell = indexPath
        let model = self.arrItems[indexPath]
        if model.attribute_set_id == GenericClass.sharedInstance.getProductAttributeId().toDouble() {
            let vc = ProductDetailsModuleVC.instantiate(fromAppStoryboard: .Products)
            vc.objProductId = model.id
            vc.objProductSKU = model.sku
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if model.attribute_set_id == GenericClass.sharedInstance.getMembershipAttributeId().toDouble() {
            // MemberShip Details
            getMembershipDetails()

        }
        else {

            openServiceDetails(index: indexPath)
            //            self.subCategoryDataObjSelectedIndex = indexPath
            //            getDataForSelectedTrendingService(subCategoryId: "\(model.id ?? 0)", genderId: GenericClass.sharedInstance.getGender() ?? "")
        }
    }

    // MARK: open ServiceDetails
    func openServiceDetails(index: Int) {

        let serviceDetailFromHomeModule = ServiceDetailModuleVC
            .instantiate(fromAppStoryboard: .Services)

        serviceDetailFromHomeModule.serverData = [self.arrItems[index]]
      //  serviceDetailFromHomeModule.serverData = HairTreatmentModule.Something.Response(items: [self.arrItems[index]], search_criteria: nil, total_count: 1)
        serviceDetailFromHomeModule.subCategoryDataObjSelectedIndex = 0

        let model: HairTreatmentModule.Something.Items = self.arrItems[index]

        serviceDetailFromHomeModule.isShowAddToCart = true
        var salonId = GenericClass.sharedInstance.getSalonId()

        if let custom_attributes = model.custom_attributes {
            for model in custom_attributes {
                if model.attribute_code == "salon_id" {

                    if  let cartSalonId = UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_key_CartHavingSalonIdIfService) as? String {
                        salonId = cartSalonId
                    }

                    if  let salonID = salonId, "\(model.value)".containsIgnoringCase(find: salonID) {
                        serviceDetailFromHomeModule.isShowAddToCart = false
                    }
                }
            }
        }

        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(serviceDetailFromHomeModule, animated: true)
        serviceDetailFromHomeModule.onDoneBlock = { result, data in
            if result {}
else {}
        }
    }

    func addAction(indexPath: IndexPath) {
        let model = arrItems[indexPath.row]
        print("addAction Clicked Index model \(model)")
    }

    func optionsBeTheFirstToReview(indexPath: IndexPath) {
        if  GenericClass.sharedInstance.isuserLoggedIn().status {
            let vc = RateTheProductVC.instantiate(fromAppStoryboard: .Products)
            self.view.alpha = screenPopUpAlpha
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: {
                vc.lblProductName.text = self.arrItems[indexPath.row].name ?? ""
                vc.product_id = self.arrItems[indexPath.row].id ?? 0
                vc.showProductImage(imageStr: "")
            })
            vc.onDoneBlock = { [unowned self] result in
                self.view.alpha = 1.0
            } }
 else { openLoginWindow() }
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
}

// MARK: - Open login view
extension SearchModuleVC: LoginRegisterDelegate {
    func doLoginRegister() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            let vc = LoginModuleVC.instantiate(fromAppStoryboard: .Main)
            let navigationContrl = UINavigationController(rootViewController: vc)
            navigationContrl.modalPresentationStyle = .fullScreen
            self.present(navigationContrl, animated: true, completion: nil)
        }
    }
}
