//
//  ApplyCouponViewController.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 05/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol ApplyCouponDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
}

class ApplyCouponViewController: UIViewController {
    @IBOutlet weak private var tableView: UITableView!
    var interactor: ApplyCouponBusinessLogic?

    var sections = [SectionConfiguration]()
    var onDoneBlock: ((Bool, String, PaymentMode.ApplyCoupon.Response) -> Void)?
    var arrCoupons: [ApplyCouponModel.GetCoupons.ResponseCoupons] = []
    var strCouponCode = ""
    var tapObj: UITapGestureRecognizer?
    var quote_id = ""

    // MARK: - Object lifecycle
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
        let interactor = ApplyCouponInteractor()
        let presenter = ApplyCouponPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }

    // MARK: callDeleteCouponAPI
    func callApplyCouponAPI(couponCode: String) {
        strCouponCode = couponCode
        EZLoadingActivity.show("Loading...", disableUI: true)
        let request = PaymentMode.ApplyCoupon.Request(coupon: couponCode, is_custom: "1", pos_request: "1", quote_id: quote_id)
        interactor?.doPostApplyCoupon(request: request)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //Looks for single or multiple taps.

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: CellIdentifier.headerViewWithTitleCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.headerViewWithTitleCell)
        tableView.register(UINib(nibName: CellIdentifier.enterCouponCodeCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.enterCouponCodeCell)
        addSOSButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.addCustomBackButton(title: "Apply Coupon")
        KeyboardAnimation.sharedInstance.beginKeyboardObservation(self.view)
        self.tableView.separatorColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callCouponsListing()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardAnimation.sharedInstance.endKeyboardObservation()
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

    func updateSection() {
        // configureSections
        sections.removeAll()
        sections.append(configureSection(idetifier: .enterCouponCode, items: 1, data: []))
        sections.append(configureSection(idetifier: .availableCoupons, items: self.arrCoupons.count, data: self.arrCoupons))
        tableView.reloadData()
    }
}

extension ApplyCouponViewController: ApplyCouponDisplayLogic {
    // MARK: Create
    func parseData() -> [FilterKeys] {

        if let userData = UserDefaults.standard.value(MyProfile.GetUserProfile.UserData.self, forKey: UserDefauiltsKeys.k_Key_LoginUser) {
            var arrForKeysValues: [FilterKeys] = []
            arrForKeysValues.append(FilterKeys(field: "is_active", value: false, type: "neq"))
            arrForKeysValues.append(FilterKeys(field: "use_auto_generation", value: 0, type: "eq"))

            let salonList = [FilterKeys(field: "salon_list", value: userData.salon_id ?? "", type: "finset"), FilterKeys(field: "salon_list", value: "all", type: "finset")]

            arrForKeysValues.append( FilterKeys(field: "couponList", value: salonList, type: ""))

            arrForKeysValues.append(FilterKeys(field: "offer_applicable", value: "cma", type: "finset"))
            arrForKeysValues.append(FilterKeys(field: "days", value: Date().dayName, type: "finset"))

            arrForKeysValues.append(FilterKeys(field: "code", value: "", type: "neq"))
            arrForKeysValues.append(FilterKeys(field: "from_date", value: Date().dayYearMonthDate, type: "lteq"))
            arrForKeysValues.append(FilterKeys(field: "to_date", value: Date().dayYearMonthDate, type: "gteq"))

            return arrForKeysValues
        }
        return []
    }
    func callCouponsListing() {
        EZLoadingActivity.show("", disableUI: true)
        if let query = interactor?.getURLForType(arrSubCat_type: self.parseData(), pageSize: 0, currentPageNo: 0) {
            let request = ApplyCouponModel.GetCoupons.Request(queryString: query)
            interactor?.doGetCouponListParameter(request: request)
        }
    }
    // Display logic
    func displaySuccess<T: Decodable>(viewModel: T) {
        EZLoadingActivity.hide()
        if let object = viewModel as? ApplyCouponModel.GetCoupons.Response {
            self.arrCoupons = object.data?.items ?? []
            updateSection()
        }
        else if let model = viewModel as? PaymentMode.ApplyCoupon.Response {
            if model.status == true {
                self.showToast(alertTitle: alertTitleSuccess, message: model.message ?? "", seconds: toastMessageDuration)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                    self.navigationController?.popViewController(animated: true)
                    self.onDoneBlock?(true, self.strCouponCode, model)
                }
            }
            else {
                self.showToast(alertTitle: alertTitle, message: model.message ?? "", seconds: toastMessageDuration)
            }
        }

    }
    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        DispatchQueue.main.async { [unowned self] in
            self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
        }
    }
}

extension ApplyCouponViewController: UITextFieldDelegate {
    override func resignFirstResponder() -> Bool {
        return true
    }
}

extension ApplyCouponViewController: ProductSelectionDelegate {
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
        case .category:
            break
        default:
            break
        }

    }

    func wishlistStatus(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {
        print("WishList:\(status) || \(identifier.rawValue) || item :\(indexpath.row)")
    }

    func checkBoxSelection(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {
        print("CheckBox:\(status) || \(identifier.rawValue) || item :\(indexpath.row)")
    }
}

extension ApplyCouponViewController: ApplyCouponCodeDelegate {
    func actionApplyManualCode(couponCode: String) {
        callApplyCouponAPI(couponCode: couponCode)
        if let obj = tapObj {view.removeGestureRecognizer(obj)}
    }
}

extension ApplyCouponViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = sections[section]
        guard data.items > 0 else {
            return 0
        }
        return data.items
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let data = sections[indexPath.section]

        switch data.identifier {
        case .enterCouponCode:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.enterCouponCodeCell, for: indexPath) as? EnterCouponCodeCell else {
                return UITableViewCell()
            }
            cell.txtFCouponCode.delegate = self
            cell.delegate = self
            return cell
        case .availableCoupons:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OfferCellApply", for: indexPath) as? OfferCellApply else {
                return UITableViewCell()
            }
            var strLink = ""
            if self.arrCoupons.count > indexPath.row {
                let model = self.arrCoupons[indexPath.row]
                strLink = model.cma_banner_image ?? ""
            }
            cell.offerImage.image = UIImage(named: "OfferImage")
            if !strLink.isEmpty {
                if let dict = GenericClass.sharedInstance.convertToDictionary(text: strLink), let urlStr = dict["url"] as? String {
                    let url = URL(string: urlStr)
                    cell.offerImage.kf.setImage(with: url, placeholder: UIImage(named: "OfferImage"), options: nil, progressBlock: nil, completionHandler: nil)
                }
            }
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = sections[indexPath.section]
        if data.identifier == .enterCouponCode {
            return UITableView.automaticDimension
        }
        return data.cellHeight
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
        cell.identifier = data.identifier
        cell.backgroundColor = .white

        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let data = self.sections[section]
        return data.showHeader ? data.headerHeight : 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let data = self.sections[indexPath.section]
        if data.identifier == .enterCouponCode { return }
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: alertTitle, message: AlertMessagesToAsk.CouponAppliedAsk, preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Apply", style: .default) { (_) -> Void in
                // APPLY COUPON CODE
                if self.arrCoupons.count > indexPath.row {
                    let model = self.arrCoupons[indexPath.row]
                    let couponCode = model.coupon_code ?? ""
                    let strLink = couponCode
                    self.callApplyCouponAPI(couponCode: strLink)
                }
                self.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "View details", style: .default) { (_) in
                //   OPEN COUPON DETAILS
                if self.arrCoupons.count > indexPath.row {
                    let model = self.arrCoupons[indexPath.row]
                    let vc = OfferDetailVC.instantiate(fromAppStoryboard: .Schedule)
                    vc.modelObj = model
                    vc.navigationController?.addCustomBackButton(title: "Offers")
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension ApplyCouponViewController {

    func configureSection(idetifier: SectionIdentifier, items: Int, data: Any) -> SectionConfiguration {

        let headerHeight: CGFloat = is_iPAD ? 50 : 40
        let width: CGFloat = tableView.frame.size.width
        let margin: CGFloat = is_iPAD ? 25 : 15

        switch idetifier {

        case .enterCouponCode:

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: 0, showHeader: false,
                                        showFooter: false, headerHeight: headerHeight, footerHeight: 0,
                                        leftMargin: margin, rightMarging: margin, isPagingEnabled: false,
                                        textFont: nil, textColor: .black, items: items, identifier: idetifier, data: data)

        case .availableCoupons:

            let height: CGFloat = is_iPAD ? 300 : 250
            let cellWidth: CGFloat = is_iPAD ? ((tableView.frame.size.width - 75) / 2) + 10: (tableView.frame.size.width - 30)

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height,
                                        cellWidth: cellWidth, showHeader: true, showFooter: false,
                                        headerHeight: headerHeight, footerHeight: 0, leftMargin: margin,
                                        rightMarging: margin, isPagingEnabled: false, textFont: nil,
                                        textColor: .black, items: items, identifier: idetifier, data: data)

        default :
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0,
                                        cellWidth: width, showHeader: false, showFooter: false,
                                        headerHeight: headerHeight, footerHeight: 0, leftMargin: 0,
                                        rightMarging: 0, isPagingEnabled: false, textFont: nil,
                                        textColor: .black, items: items, identifier: idetifier, data: data)
        }
    }
}
