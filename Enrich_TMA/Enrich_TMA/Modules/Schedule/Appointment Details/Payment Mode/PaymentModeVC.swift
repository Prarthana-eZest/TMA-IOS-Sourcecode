//
//  PaymentModeViewController.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 29/08/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol PaymentModeDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
}

class OfflinePaymentDetails {
    var cash: PaymentDetails
    var cards: [PaymentDetails]
    var others: [PaymentDetails]
    
    init(cash: PaymentDetails, cards: [PaymentDetails], others: [PaymentDetails]) {
        self.cash = cash
        self.cards = cards
        self.others = others
    }
}

class PaymentDetails {
    var use: Int = 0
    var amount: String?
    var method: String?
    var details: String?
    var status_change_cash: Bool = false
    
    init(use: Int, amount: String?, method: String?, details: String?, status_change_cash: Bool) {
        self.use = use
        self.amount = amount
        self.method = method
        self.details = details
        self.status_change_cash = status_change_cash
    }
}


class PaymentModeVC: UIViewController, PaymentModeDisplayLogic {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var btnPayNow: UIButton!
    @IBOutlet weak private var lblPrice: UILabel!
    
    var interactor: PaymentModeBusinessLogic?
    
    var quote_id = ""
    var orderId = ""
    var strAppliedCoupon = ""
    var strAppliedGiftCardCoupon = ""
    var tempCoupon = ""
    var tempGiftCard = ""
    var grandTotal = "0"
    var remainingAmount = "0"
    
    var changeCash = "0"
    var applyChangeToWallet = false
    
    var packageSelected = false
    
    // Appointment details
    var appointmentDetails: Schedule.GetAppointnents.Data?
    
    // Price caluculation
    var arrPricingDetails = [CartAmountCellModel]()
    
    // Cash and Online
    //var paymentDetails: PaymentMode.OfflinePayment.ResponseData?
    var offlinePayments: OfflinePaymentDetails?
    
    // Wallet and Reward
    var customerWalletRewardsPointsPackagesData: PaymentMode.MyWalletRewardPointsPackages.MyWalletRewardPointsPackagesData?
    
    // Calculation totals
    var totals: Totals_html?
    var magentoAmounts: PaymentMode.RedeemPointOrNot.totalData?
    
    // Tableview Sections
    var sections = [SectionConfiguration]()
    
    
    // Wallet and Reward Points
    private var isRedeemPointsApplied: Bool = false
    private var redeemPointsAlreadyAvailed: Double = 0.0
    private var applyWallet: Int = 0 // Wallet not applied in case of zero else applied
    var minRewardPointsLimit: Double = 0.0
    var maxRewardPointsLimit: Double = 0.0
    
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
        let interactor = PaymentModeInteractor()
        let presenter = PaymentModePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.register(UINib(nibName: CellIdentifier.headerViewWithTitleCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.headerViewWithTitleCell)
        tableView.register(UINib(nibName: CellIdentifier.walletAndRewardCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.walletAndRewardCell)
        tableView.register(UINib(nibName: CellIdentifier.applyGiftCardCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.applyGiftCardCell)
        tableView.register(UINib(nibName: CellIdentifier.applyCouponCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.applyCouponCell)
        tableView.register(UINib(nibName: CellIdentifier.cartAmountCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.cartAmountCell)
        tableView.register(UINib(nibName: CellIdentifier.bestPossibleDiscountCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.bestPossibleDiscountCell)
        tableView.register(UINib(nibName: CellIdentifier.cashPaymentCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.cashPaymentCell)
        tableView.register(UINib(nibName: CellIdentifier.onlinePaymentCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.onlinePaymentCell)
        tableView.register(UINib(nibName: CellIdentifier.transactionDetailsCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.transactionDetailsCell)
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        addSOSButton()
        
        // configureSections
        sections.removeAll()
        sections.append(configureSection(idetifier: .walletAndRewardMode, items: 1, data: []))
        sections.append(configureSection(idetifier: .giftCardMode, items: 1, data: []))
        sections.append(configureSection(idetifier: .couponCodeMode, items: 1, data: []))
        sections.append(configureSection(idetifier: .bestPossibleDiscount, items: 1, data: []))
        sections.append(configureSection(idetifier: .cardPaymentMode, items: 1, data: []))
        sections.append(configureSection(idetifier: .otherPaymentMode, items: 1, data: []))
        sections.append(configureSection(idetifier: .cashPaymentMode, items: 1, data: []))
        sections.append(configureSection(idetifier: .pricingDetails, items: 1, data: []))
        remainingAmount = magentoAmounts?.remaining_amount?.description ?? self.grandTotal
        
        offlinePayments = OfflinePaymentDetails(cash: PaymentDetails(use: 0, amount: nil, method: nil, details: nil, status_change_cash: false), cards: [], others: [])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.navigationBar.isHidden = false
        KeyboardAnimation.sharedInstance.beginKeyboardObservation(self.view)
        self.navigationController?.addCustomBackButton(title: "Select Payment Mode")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        KeyboardAnimation.sharedInstance.endKeyboardObservation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callToCustomerWalletRewardPointsPackages()
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
    
    func populatePriceBreakUp() {
        
        arrPricingDetails.removeAll()
        
        let keysToIgnore = [TotalSegmentsCode.spendMinPoints,
                            TotalSegmentsCode.spendMaxPoints,
                            TotalSegmentsCode.rewardsCalculations,
                            TotalSegmentsCode.rewardsSpendAmount,
                            TotalSegmentsCode.taxNote,
                            TotalSegmentsCode.grandtotal]
        
        if let min = totals?.magento_totals?.first(where: {$0.code == TotalSegmentsCode.spendMinPoints}) {
            minRewardPointsLimit = min.value?.description.toDouble() ?? 0
        }
        
        if let max = totals?.magento_totals?.first(where: {$0.code == TotalSegmentsCode.spendMaxPoints}) {
            maxRewardPointsLimit = max.value?.description.toDouble() ?? 0
        }
        
        totals?.magento_totals?.forEach {
            if let code = $0.code,
                !keysToIgnore.contains(code.lowercased()),
                let value = $0.value?.description.toDouble() {
                if value != 0 {
                    
                    if code == TotalSegmentsCode.rewardsSpend {
                        arrPricingDetails.append(CartAmountCellModel(title: $0.title ?? "", price: value.cleanForPrice, code: code, showCheckBox: false, isCheckBoxSelected: false))
                    }
                    else {
                        arrPricingDetails.append(CartAmountCellModel(title: $0.title ?? "", price: getPriceText(price: value), code: code, showCheckBox: false, isCheckBoxSelected: false))
                    }
                }
            }
        }
        
        if let paymentDetails = offlinePayments {
            
            let cash = paymentDetails.cash.amount ?? "0"
            
            var cardAmount = 0.0
            var cardMethods = [String]()
            
            var otherAmount = 0.0
            var otherMethods = [String]()
            
            paymentDetails.cards.forEach {
                if $0.use == 1 {
                    cardAmount = cardAmount + ($0.amount?.toDouble() ?? 0.0)
                    cardMethods.append($0.method ?? "")
                }
            }
            
            paymentDetails.others.forEach {
                if $0.use == 1 {
                    otherAmount = otherAmount + ($0.amount?.toDouble() ?? 0.0)
                    otherMethods.append($0.method ?? "")
                }
            }
            
            if cash != "0", !cash.isEmpty {
                arrPricingDetails.append(CartAmountCellModel(title: "Cash Payment Received", price: "-₹\(cash)", code: "", showCheckBox: false, isCheckBoxSelected: false))
            }
            
            if changeCash != "0", !changeCash.isEmpty {
                arrPricingDetails.append(CartAmountCellModel(title: "Change Amount", price: "₹\(changeCash)", code: "", showCheckBox: true, isCheckBoxSelected: applyChangeToWallet))
            }
            
            if cardAmount > 0 {
                arrPricingDetails.append(CartAmountCellModel(title: "Card Payment (\(cardMethods.joined(separator: ",")))", price: "-₹\(cardAmount)", code: "", showCheckBox: false, isCheckBoxSelected: false))
            }
            if otherAmount > 0 {
                arrPricingDetails.append(CartAmountCellModel(title: "Other Payment (\(otherMethods.joined(separator: ",")))", price: "-₹\(otherAmount)", code: "", showCheckBox: false, isCheckBoxSelected: false))
            }
        }
        
        arrPricingDetails.append(CartAmountCellModel(
            title: "Remaining Amount",
            price: "₹\(remainingAmount)",
            code: TotalSegmentsCode.remainingAmount,
            showCheckBox: false,
            isCheckBoxSelected: false))
        
        if let taxNote = totals?.magento_totals?.first(where: {$0.code == TotalSegmentsCode.taxNote}),
            let value = taxNote.value, value == 0,
            let code = taxNote.code {
            arrPricingDetails.append(CartAmountCellModel(title: taxNote.title ?? "", price: "", code: code, showCheckBox: false, isCheckBoxSelected: false))
        }
        
        lblPrice.text = "₹\(self.grandTotal)"
        if remainingAmount == "0"{
            btnPayNow.isSelected = true
        }
        else {
            btnPayNow.isSelected = false
        }
        tableView.reloadData()
    }
    
    func getPriceText(price: Double) -> String {
        if price < 0 {
            return "-₹\(price.cleanForPrice.replacingOccurrences(of: "-", with: ""))"
        }
        else {
            return "₹\(price.cleanForPrice)"
        }
    }
    
    func presentOTPScreen() {
        let vc = ConfirmCustomerOTPVC.instantiate(fromAppStoryboard: .Schedule)
        self.view.alpha = screenPopUpAlpha
        vc.appointmentDetails = self.appointmentDetails
        vc.confirmationType = .paymentOTP
        vc.cardId = self.quote_id
        self.present(vc, animated: true, completion: nil)
        vc.viewDismissBlock = { [unowned self] result in
            self.view.alpha = 1.0
            if result {
                self.submitPaymentDetails()
            }
        }
    }
    
    @IBAction func actionPaymentDetails(_ sender: Any) {
        self.tableView.scrollToBottom()
    }
    
    @IBAction func actionPayNow(_ sender: UIButton) {
        if sender.isSelected {
            presentOTPScreen()
        }
    }
    
    // MARK: API Calls
    
    func makeOfflinePayment(cash: PaymentDetails?, cards: [PaymentDetails]?, others: [PaymentDetails]?) {
        EZLoadingActivity.show("Loading...", disableUI: true)
        
        var cardDetails = [PaymentMode.OfflinePayment.CardPayments]()
        cards?.forEach {
            if $0.use == 1 {
                cardDetails.append(PaymentMode.OfflinePayment.CardPayments(card_payment: $0.amount, card_details: $0.details, card_payment_method: $0.method))
            }
        }
        
        var otherDetails = [PaymentMode.OfflinePayment.OtherPayments]()
        others?.forEach {
            if $0.use == 1 {
                otherDetails.append(PaymentMode.OfflinePayment.OtherPayments(other_payment: $0.amount, other_payment_method: $0.method, other_payment_details: $0.details))
            }
        }
        
        let cashAmount = cash?.use == 1 ? cash?.amount ?? "" : ""
        
        let data = PaymentMode.OfflinePayment.RequestData(cash_payment: cashAmount, card_payments: cardDetails, other_payments: otherDetails, quote_id: quote_id, status_change_cash: cash?.status_change_cash ?? false)
        
        let request = PaymentMode.OfflinePayment.Request(data: data)
        interactor?.doPostRequestOfflinePayment(accessToken: self.getAccessToken(), request: request)
    }
    
    func submitPaymentDetails() {
        if let userData = UserDefaults.standard.value(MyProfile.GetUserProfile.UserData.self,
                                                      forKey: UserDefauiltsKeys.k_Key_LoginUser),
            let appointment = self.appointmentDetails, let id = appointment.appointment_id {
            EZLoadingActivity.show("Loading...", disableUI: true)
            let data = PaymentMode.SubmitDetails.Request(is_custom: "1", pos_request: "1",
                                                         customer_id: "\(appointment.booked_by_id ?? 0)", appointment_id: "\(id)",
                platform: "tma", salon_id: userData.salon_id ?? "", quoteId: quote_id)
            interactor?.doPostSubmitPaymentDetails(accessToken: self.getAccessToken(), request: data)
        }
    }
    
    func callApplyRewardPointsOrNotAPI(rewardPoints: String) {
        EZLoadingActivity.show("Loading...", disableUI: true)
        let request = PaymentMode.RedeemPointOrNot.Request(points: rewardPoints, pos_request: "1", is_custom: "1", quote_id: quote_id)
        interactor?.doPostRequestRedeemPointsOrNot(request: request)
    }
    
    func callToCustomerWalletRewardPointsPackages() {
        if let customerId = self.appointmentDetails?.booked_by_id {
            EZLoadingActivity.show("Loading...", disableUI: true)
            interactor?.getCustomerWalletRewardPointAndPackages(customerId: "\(customerId)", quoteId: quote_id)
        }
    }
    
    // MARK: callToApplyOrNotWalletCashAPI
    func callToApplyOrNotWalletCashAPI(walletStatus: Int) {
        EZLoadingActivity.show("Loading...", disableUI: true)
        let cartModel = PaymentMode.ApplyWalletCashOrNot.Cart_item(quote_id: quote_id, wallet_status: walletStatus)
        let amount = customerWalletRewardsPointsPackagesData?.wallet_balance?.cleanForPrice.toInt() ?? 0
        let request = PaymentMode.ApplyWalletCashOrNot.Request(cart_item: cartModel, amount: amount)
        interactor?.doPostSelectUnSelectWalletCash(request: request)
    }
    
    func changeAppointmentStatus(status: AppointmentStatus) {
        if let userData = UserDefaults.standard.value(MyProfile.GetUserProfile.UserData.self, forKey: UserDefauiltsKeys.k_Key_LoginUser) {
            EZLoadingActivity.show("Loading...", disableUI: true)
            let request = JobCard.ChangeAppointmentStatus.Request(
                status: status.rawValue,
                employee_id: userData.employee_id,
                reason: nil, is_custom: true)
            let id = "\(self.appointmentDetails?.appointment_id ?? 0)"
            interactor?.doPostUpdateAppointmentStatus(appointmentId: id, request: request)
        }
    }
    
    func callApplyGiftCardAPI(giftCardCode: String) {
        tempGiftCard = giftCardCode
        EZLoadingActivity.show("Loading...", disableUI: true)
        let request = PaymentMode.ApplyGiftCard.Request(giftcard: giftCardCode, quote_id: quote_id)
        interactor?.doPostApplyGiftCard(request: request)
    }
    
    func callApplyCouponAPI(couponCode: String) {
        tempCoupon = couponCode
        EZLoadingActivity.show("Loading...", disableUI: true)
        let request = PaymentMode.ApplyCoupon.Request(coupon: couponCode, is_custom: "1", pos_request: "1", quote_id: quote_id)
        interactor?.doPostApplyCoupon(request: request)
    }
    
    func openCouponList() {
        
        let vc = ApplyCouponViewController.instantiate(fromAppStoryboard: .Schedule)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.quote_id = quote_id
        vc.onDoneBlock = { (result, couponCode, model) in
            if result {
                self.tempCoupon = couponCode
                self.parseApplyCoupon(viewModel: model)
            }
        }
    }
}

// MARK: Web Service
extension PaymentModeVC {
    
    func displaySuccess<T: Decodable>(viewModel: T) {
        print("Response: \(viewModel)")
        EZLoadingActivity.hide()
        
        if let model = viewModel as? PaymentMode.OfflinePayment.Response {
            parseOfflinePaymentResponse(viewModel: model)
            self.showToast(alertTitle: alertTitle, message: model.message, seconds: toastMessageDuration)
        }
        else if let model = viewModel as? PaymentMode.SubmitDetails.Response {
            if model.status == true {
                orderId = model.data?.order_increment_id ?? ""
                changeAppointmentStatus(status: .completed)
            }
            else {
                self.showToast(alertTitle: alertTitle, message: model.message, seconds: toastMessageDuration)
            }
        }
        else if let model = viewModel as? PaymentMode.MyWalletRewardPointsPackages.Response {
            self.parseMyWalletRewardPointsPackages(viewModel: model)
        }
        else if let model = viewModel as? PaymentMode.ApplyWalletCashOrNot.Response {
            if model.status == true {
                self.parseApplyOrNotWalletCash(viewModel: model)
            }
            self.showToast(alertTitle: alertTitle, message: model.message ?? "", seconds: toastMessageDuration)
        }
        else if let model = viewModel as? PaymentMode.RedeemPointOrNot.Response {
            if model.status == true {
                self.parseApplyOrNotRedeemPoints(viewModel: model)
            }
            else {
                self.showToast(alertTitle: alertTitle, message: model.message ?? "", seconds: toastMessageDuration)
            }
        }
        else if let model = viewModel as? PaymentMode.ApplyGiftCard.Response {
            if model.status == true {
                self.parseApplyGiftCard(viewModel: model)
            }
            self.showToast(alertTitle: alertTitle, message: model.message ?? "", seconds: toastMessageDuration)
        }
        else if let model = viewModel as? PaymentMode.ApplyCoupon.Response {
            if model.status == true {
                self.parseApplyCoupon(viewModel: model)
            }
            self.showToast(alertTitle: alertTitle, message: model.message ?? "", seconds: toastMessageDuration)
        }
        else if let model = viewModel as? JobCard.ChangeAppointmentStatus.Response {
            if model.status == true {
                print("Appointment is completed")
                let vc = PaymentSuccessVC.instantiate(fromAppStoryboard: .Schedule)
                vc.orderId = orderId
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                self.showToast(alertTitle: alertTitle, message: model.message, seconds: toastMessageDuration)
            }
        }
    }
    
    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
    }
}

extension PaymentModeVC: ProductSelectionDelegate {
    
    func moveToCart(indexPath: IndexPath) {
        
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
}
extension PaymentModeVC: PaymentOptionsDelegate {
    
    func actionApplyPackage(cell: WalletAndRewardCell) {
        openAvailablePackages()
    }
    
    func actionApplyWallet(status: Bool) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
        let alertObj = UIAlertController(title: alertTitle, message: status ? AlertMessagesToAsk.askToUseEnrichCash : AlertMessagesToAsk.askToRemoveEnrichCash, preferredStyle: .alert)
        alertObj.addAction(UIAlertAction(title: AlertButtonTitle.yes, style: .default, handler: { (_) in
            self.applyWallet = status ? 1 : 0
            self.callToApplyOrNotWalletCashAPI(walletStatus: self.applyWallet)
        }))
        alertObj.addAction(UIAlertAction(title: AlertButtonTitle.no, style: .default, handler: { (_) in
        }))
        self.present(alertObj, animated: true, completion: nil)
    }
    
    func actionApplyRedeemPoints(redeemPoints: String) {
        
        if isRedeemPointsApplied {
            redeemPointsAlreadyAvailed = 0.0
            callApplyRewardPointsOrNotAPI(rewardPoints: "0")
            return
        }
        redeemPointsAlreadyAvailed = redeemPoints.toDouble() ?? 0.0
        if  redeemPoints.isEmpty || (redeemPoints == "0" || redeemPoints == "0.0" ) {
            showToast(alertTitle: alertTitle, message: AlertMessagesToAsk.enterReedemPoints, seconds: toastMessageDuration)
            return
        }
        if  (redeemPoints.toDouble() ?? 0.0) >= minRewardPointsLimit && (redeemPoints.toDouble() ?? 0.0) <= maxRewardPointsLimit {
            isRedeemPointsApplied == false ? callApplyRewardPointsOrNotAPI(rewardPoints: redeemPoints) : callApplyRewardPointsOrNotAPI(rewardPoints: "0")
            return
        }
        else {
            showToast(alertTitle: alertTitle, message: AlertMessagesToAsk.enterReedemPoints, seconds: toastMessageDuration)
        }
    }
    
    func reloadTableView() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func actionApplyCash(amount: String, apply: Bool) {
        
        if amount.isEmpty, apply {
            showToast(alertTitle: alertTitle, message: AlertMessagesToAsk.enterCash, seconds: toastMessageDuration)
            return
        }
        
        makeOfflinePayment(cash: PaymentDetails(use: apply ? 1 : 0, amount: amount, method: nil, details: nil, status_change_cash: false), cards: offlinePayments?.cards, others: offlinePayments?.others)
    }
}

extension PaymentModeVC: ApplyCouponCellDelegate {
    
    func actionApplyCode(code: String) {
        code.isEmpty ? showToast(alertTitle: alertTitle, message: AlertMessagesToAsk.enterCouponCode, seconds: toastMessageDuration) : callApplyCouponAPI(couponCode: code)
    }
    
    func applyCode(cell: ApplyCouponCell) {
        
        if !strAppliedCoupon.isEmpty {
            callApplyCouponAPI(couponCode: "")
        }
        else {
            if cell.imgNext.image == UIImage(named: "downArrow") {
                tableView.beginUpdates()
                cell.stackViewEnterGiftCard.isHidden = false
                cell.imgNext.image = UIImage(named: "upArrow")
                cell.txtApplyGiftCard.text = ""
                tableView.endUpdates()
            }
            else {
                tableView.beginUpdates()
                cell.stackViewEnterGiftCard.isHidden = true
                cell.imgNext.image = UIImage(named: "downArrow")
                tableView.endUpdates()
            }
        }
    }
    
    func actionCouponList() {
        openCouponList()
    }
}

extension PaymentModeVC: ApplyGiftCardCellDelegate {
    
    func applyGiftCard(cell: ApplyGiftCardCell) {
        if !strAppliedGiftCardCoupon.isEmpty {
            callApplyGiftCardAPI(giftCardCode: "")
        }
        else {
            if cell.imgNext.image == UIImage(named: "downArrow") {
                tableView.beginUpdates()
                cell.stackViewEnterGiftCard.isHidden = false
                cell.imgNext.image = UIImage(named: "upArrow")
                cell.txtApplyGiftCard.text = ""
                tableView.endUpdates()
            }
            else {
                tableView.beginUpdates()
                cell.stackViewEnterGiftCard.isHidden = true
                cell.imgNext.image = UIImage(named: "downArrow")
                tableView.endUpdates()
            }
        }
    }
    
    func actionApplyGiftCardCode(code: String) {
        code.isEmpty ? showToast(alertTitle: alertTitle, message: AlertMessagesToAsk.enterGiftCardCode, seconds: toastMessageDuration) : callApplyGiftCardAPI(giftCardCode: code)
    }
}

extension PaymentModeVC: BestDiscountCellDelegate {
    
    func actionDiscountList() {
        let vc = AutoDiscountListVC.instantiate(fromAppStoryboard: .Schedule)
        vc.quote_id = quote_id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PaymentModeVC: TransactionDetailsDelegate {
    
    func actionApply() {
        makeOfflinePayment(cash: offlinePayments?.cash, cards: offlinePayments?.cards, others: offlinePayments?.others)
    }
    
    func actionRemove() {
        makeOfflinePayment(cash: offlinePayments?.cash, cards: offlinePayments?.cards, others: offlinePayments?.others)
    }
    
    func showValidationAlert(message: String) {
        self.showToast(alertTitle: alertTitle, message: message, seconds: toastMessageDuration)
    }
    
}

extension PaymentModeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = sections[section]
        
        if data.identifier == .pricingDetails {
            return arrPricingDetails.count
        }
        else if data.identifier == .cardPaymentMode {
            return (offlinePayments?.cards.count ?? 0) + 1
        }
        else if data.identifier == .otherPaymentMode {
            return (offlinePayments?.others.count ?? 0) + 1
        }
        return data.items
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = sections[indexPath.section]
        switch data.identifier {
            
        case .walletAndRewardMode:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.walletAndRewardCell, for: indexPath) as? WalletAndRewardCell else {
                return UITableViewCell()
            }
            
            cell.delegate = self
            let walletPrice = String(format: " ₹ %@", customerWalletRewardsPointsPackagesData?.wallet_balance?.cleanForPrice ?? "0")
            let rewardPoints = (customerWalletRewardsPointsPackagesData?.reward_points ?? 0.0).cleanForPrice
            
            cell.configureCell(minLimit: minRewardPointsLimit.cleanForPrice, maxLimit: maxRewardPointsLimit.cleanForPrice,
                               isApplyReedemPointButton: isRedeemPointsApplied, enrichWalletAmount: walletPrice,
                               rewardPointsValue: rewardPoints, finalAmountToPay: magentoAmounts?.remaining_amount?.description ?? "0",
                               isWalletApplied: self.applyWallet == 0 ? false : true,
                               rewardPointsAlreadyAvailed: redeemPointsAlreadyAvailed,
                               isShowHideValuePackage: self.customerWalletRewardsPointsPackagesData?.applicable_packages != nil  ? false : true,
                               isPackageApplied: packageSelected )
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            return cell
            
        case .giftCardMode:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.applyGiftCardCell, for: indexPath) as? ApplyGiftCardCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            cell.lblTitle.text = "Redeem Gift Card"
            if !strAppliedGiftCardCoupon.isEmpty {
                cell.lblTitle.text = "\(strAppliedGiftCardCoupon) Applied"
                cell.imgNext.image = UIImage(named: "closeLogin")
                cell.stackViewEnterGiftCard.isHidden = true
            }
            else {
                if cell.imgNext.image == UIImage(named: "downArrow") {
                    cell.stackViewEnterGiftCard.isHidden = true
                }
                else {
                    cell.imgNext.image = UIImage(named: "upArrow")
                    cell.stackViewEnterGiftCard.isHidden = false
                }
            }
            return cell
            
        case .couponCodeMode:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.applyCouponCell, for: indexPath) as? ApplyCouponCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            cell.lblTitle.text = "Apply Coupon"
            if !strAppliedCoupon.isEmpty {
                cell.lblTitle.text = "\(strAppliedCoupon) Applied"
                cell.imgNext.image = UIImage(named: "closeLogin")
                cell.stackViewEnterGiftCard.isHidden = true
            }
            else {
                if cell.imgNext.image == UIImage(named: "downArrow") {
                    cell.stackViewEnterGiftCard.isHidden = true
                }
                else {
                    cell.imgNext.image = UIImage(named: "upArrow")
                    cell.stackViewEnterGiftCard.isHidden = false
                }
            }
            return cell
            
        case .bestPossibleDiscount:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.bestPossibleDiscountCell, for: indexPath) as? BestPossibleDiscountCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            return cell
            
            
        case .cashPaymentMode:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.cashPaymentCell, for: indexPath) as? CashPaymentCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            if let details = offlinePayments {
                cell.configureCell(model: details)
            }
            cell.prePopulateRemainingAmount(remaningAmount: remainingAmount)
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            return cell
            
        case .cardPaymentMode:
            
            if indexPath.row == 0 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.onlinePaymentCell, for: indexPath) as? OnlinePaymentCell else {
                    return UITableViewCell()
                }
                cell.configureCell(showTitle: true, paymentModeTitle: "Card")
                cell.selectionStyle = .none
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
                return cell
            }
            else {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.transactionDetailsCell) as? TransactionDetailsCell else {
                    return UITableViewCell()
                }
                cell.paymentModeTitle = "Select Card Type"
                cell.paymentModeOptions = self.customerWalletRewardsPointsPackagesData?.card_payment_methods ?? []
                cell.configureCell(model: offlinePayments?.cards[indexPath.row - 1])
                cell.delegate = self
                cell.indexPath = indexPath
                cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                cell.selectionStyle = .none
                return cell
            }
            
        case .otherPaymentMode:
            
            if indexPath.row == 0 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.onlinePaymentCell, for: indexPath) as? OnlinePaymentCell else {
                    return UITableViewCell()
                }
                cell.configureCell(showTitle: false, paymentModeTitle: "Others")
                cell.selectionStyle = .none
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
                return cell
            }
            else {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.transactionDetailsCell) as? TransactionDetailsCell else {
                    return UITableViewCell()
                }
                cell.paymentModeTitle = "Select Payment Method"
                cell.paymentModeOptions = self.customerWalletRewardsPointsPackagesData?.other_payment_methods ?? []
                cell.configureCell(model: offlinePayments?.others[indexPath.row - 1])
                cell.delegate = self
                cell.indexPath = indexPath
                cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                cell.selectionStyle = .none
                return cell
            }
            
        case .pricingDetails:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.cartAmountCell) as? CartAmountCell else {
                return UITableViewCell()
            }
            let model = arrPricingDetails[indexPath.row]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            cell.configureCell(model: model)
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let data = self.sections[section]
        
        if !data.showHeader {return nil}
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.headerViewWithTitleCell) as? HeaderViewWithTitleCell else {
            return UITableViewCell()
        }
        cell.configureHeader(title: data.title, hideAllButton: true)
        cell.identifier = data.identifier
        cell.backgroundColor = UIColor(red: 238 / 255, green: 249 / 255, blue: 251 / 255, alpha: 1.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let data = self.sections[section]
        return data.showHeader ? data.headerHeight : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
        
        let data = self.sections[indexPath.section]
        
        if data.identifier == .cardPaymentMode, indexPath.row == 0 {
            let emptyCards = offlinePayments?.cards.filter {$0.use == 0}
            if ((emptyCards?.count ?? 0) == 0) {
                offlinePayments?.cards.append(PaymentDetails(use: 0, amount: "", method: "", details: "", status_change_cash: false))
                tableView.reloadData()
                tableView.scrollToRow(at: IndexPath(row: offlinePayments?.cards.count ?? 0, section: indexPath.section), at: .middle, animated: true)
            }
        }
        else if data.identifier == .otherPaymentMode, indexPath.row == 0 {
            let emptyOther = offlinePayments?.others.filter {$0.use == 0}
            if ((emptyOther?.count ?? 0) == 0) {
                offlinePayments?.others.append(PaymentDetails(use: 0, amount: "", method: "", details: "", status_change_cash: false))
                tableView.reloadData()
                tableView.scrollToRow(at: IndexPath(row: offlinePayments?.others.count ?? 0, section: indexPath.section), at: .middle, animated: true)
            }
        }
        
    }
}

extension PaymentModeVC: CardAmountCellDelegate {
    
    func applyChangeToWallet(status: Bool) {
        
        let alertObj = UIAlertController(title: alertTitle, message: status ? AlertMessagesToAsk.applyChangeToWallet : AlertMessagesToAsk.removeChangeToWallet, preferredStyle: .alert)
        alertObj.addAction(UIAlertAction(title: AlertButtonTitle.yes, style: .default, handler: { (_) in
            self.applyChangeToWallet = status
            self.makeOfflinePayment(cash: PaymentDetails(use: 1, amount: self.offlinePayments?.cash.amount ?? "", method: nil, details: nil, status_change_cash: self.applyChangeToWallet), cards: self.offlinePayments?.cards, others: self.offlinePayments?.others)
        }))
        alertObj.addAction(UIAlertAction(title: AlertButtonTitle.no, style: .default, handler: { (_) in
        }))
        self.present(alertObj, animated: true, completion: nil)
    }
    
}


extension PaymentModeVC {
    
    func configureSection(idetifier: SectionIdentifier, items: Int, data: Any) -> SectionConfiguration {
        
        let headerHeight: CGFloat = is_iPAD ? 70 : 50
        let width: CGFloat = tableView.frame.size.width
        
        switch idetifier {
            
            
        case .walletAndRewardMode, .giftCardMode, .couponCodeMode, .bestPossibleDiscount, .cashPaymentMode, .cardPaymentMode, .otherPaymentMode:
            
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: width,
                                        showHeader: false, showFooter: false, headerHeight: 0, footerHeight: 0,
                                        leftMargin: 0, rightMarging: 0, isPagingEnabled: false, textFont: nil,
                                        textColor: .black, items: items, identifier: idetifier, data: data)
            
        case .pricingDetails:
            
            let height: CGFloat = is_iPAD ? 45 : 30
            
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: width,
                                        showHeader: false, showFooter: false, headerHeight: headerHeight, footerHeight: 0,
                                        leftMargin: 0, rightMarging: 0, isPagingEnabled: false, textFont: nil,
                                        textColor: .black, items: items, identifier: idetifier, data: data)
            
        default :
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: width,
                                        showHeader: false, showFooter: false, headerHeight: headerHeight, footerHeight: 0,
                                        leftMargin: 0, rightMarging: 0, isPagingEnabled: false, textFont: nil,
                                        textColor: .black, items: items, identifier: idetifier, data: data)
        }
    }
}

extension PaymentModeVC {
    
    // MARK: Response Parsing
    
    func parseOfflinePaymentResponse(viewModel: PaymentMode.OfflinePayment.Response) {
        
        if let data = viewModel.data, viewModel.status == true {
            //self.paymentDetails = data
            
            var cards = [PaymentDetails]()
            var others = [PaymentDetails]()
            
            data.card_payment?.forEach {
                cards.append(PaymentDetails(use: $0.use ?? 0, amount: $0.amount, method: $0.method, details: $0.details, status_change_cash: false))
            }
            data.others?.forEach {
                others.append(PaymentDetails(use: $0.use ?? 0, amount: $0.amount, method: $0.method, details: $0.details, status_change_cash: false))
            }
            
            changeCash = data.change_cash?.description ?? ""
            
            let cash = PaymentDetails(use: data.cash?.use ?? 0, amount: data.cash?.amount, method: data.cash?.method, details: data.cash?.details, status_change_cash: applyChangeToWallet)
            
            self.offlinePayments = OfflinePaymentDetails(cash: cash, cards: cards, others: others)
            self.remainingAmount = "\(data.remaining_amount ?? 0)"
            populatePriceBreakUp()
        }
        else {
            self.showAlert(alertTitle: alertTitle, alertMessage: viewModel.message)
        }
    }
    
    func parseMyWalletRewardPointsPackages(viewModel: PaymentMode.MyWalletRewardPointsPackages.Response) {
        
        if let status = viewModel.status, status == true // Success
        {
            self.customerWalletRewardsPointsPackagesData = viewModel.data
            let valueWallet: Double = self.customerWalletRewardsPointsPackagesData?.wallet_balance_applied_to_cart ?? 0.0
            applyWallet = valueWallet > 0.0 ? 1 : 0
            let valueReedemPoints: Double = self.customerWalletRewardsPointsPackagesData?.rewars_points_applied_to_cart ?? 0.0
            isRedeemPointsApplied = valueReedemPoints > 0.0 ? true : false
            redeemPointsAlreadyAvailed = isRedeemPointsApplied ? valueReedemPoints : 0.0
            packageSelected = self.customerWalletRewardsPointsPackagesData?.package_id_applied_to_cart ?? 0 > 0 ? true : false
            
            remainingAmount = self.customerWalletRewardsPointsPackagesData?.remaining_amount?.description ?? "0"
            self.totals?.magento_totals = self.customerWalletRewardsPointsPackagesData?.magento_totals
            
            strAppliedGiftCardCoupon = viewModel.data?.gift_card ?? ""
            strAppliedCoupon = viewModel.data?.coupon_code ?? ""
            
            populatePriceBreakUp()
        }
    }
    
    func parseApplyOrNotWalletCash(viewModel: PaymentMode.ApplyWalletCashOrNot.Response) {
        
        if let totals = viewModel.data {
            remainingAmount = totals.remaining_amount?.description ?? "0"
            self.totals = totals.totals_html
            callToCustomerWalletRewardPointsPackages()
            if let value = remainingAmount.toInt(), value < 0 {
                makeOfflinePayment(cash: nil, cards: nil, others: nil)
            }
        }
    }
    func parseApplyOrNotRedeemPoints(viewModel: PaymentMode.RedeemPointOrNot.Response) {
        
        if let totals = viewModel.data {
            remainingAmount = totals.remaining_amount?.description ?? "0"
            self.totals = totals.totals_html
            callToCustomerWalletRewardPointsPackages()
            if let value = remainingAmount.toInt(), value < 0 {
                makeOfflinePayment(cash: nil, cards: nil, others: nil)
            }
        }
    }
    
    func openAvailablePackages() {
        let vc = AvailMyPackages.instantiate(fromAppStoryboard: .Schedule)
        vc.setData(applicablePackage: self.customerWalletRewardsPointsPackagesData?.applicable_packages, package_id_applied_to_cart: self.customerWalletRewardsPointsPackagesData?.multi_package_id_applied_to_cart, grandTotal: self.remainingAmount)
        vc.cart_id = self.quote_id
        self.navigationController?.pushViewController(vc, animated: true)
        vc.viewDismissBlock = {[unowned self]  (totals, remaningAmount) in
            if let totals = totals {
                self.remainingAmount = remaningAmount
                self.totals = totals
                self.callToCustomerWalletRewardPointsPackages()
                if let value = self.remainingAmount.toInt(), value < 0 {
                    self.makeOfflinePayment(cash: nil, cards: nil, others: nil)
                }
            }
        }
    }
    
    func parseApplyGiftCard(viewModel: PaymentMode.ApplyGiftCard.Response) {
        
        if let totals = viewModel.data {
            strAppliedGiftCardCoupon = tempGiftCard
            remainingAmount = totals.remaining_amount?.description ?? "0"
            self.totals = totals.totals_html
            callToCustomerWalletRewardPointsPackages()
            
            if let value = remainingAmount.toInt(), value < 0 {
                makeOfflinePayment(cash: nil, cards: nil, others: nil)
            }
        }
    }
    
    func parseApplyCoupon(viewModel: PaymentMode.ApplyCoupon.Response) {
        if let totals = viewModel.data {
            strAppliedCoupon = tempCoupon
            remainingAmount = totals.remaining_amount?.description ?? "0"
            self.totals = totals.totals_html
            callToCustomerWalletRewardPointsPackages()
            if let value = remainingAmount.toInt(), value < 0 {
                makeOfflinePayment(cash: nil, cards: nil, others: nil)
            }
        }
    }
}
