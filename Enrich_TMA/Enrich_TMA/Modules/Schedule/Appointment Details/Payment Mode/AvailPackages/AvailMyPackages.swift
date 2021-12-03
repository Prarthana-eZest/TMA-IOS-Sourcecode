//
//  AvailMyPackages.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 20/01/20.
//  Copyright © 2020 Aman Gupta. All rights reserved.
//

import UIKit

protocol AvailMyPackagesModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
}

class AvailMyPackages: UIViewController {
    
    enum sectionType {
        static let valuePackageBalance = "Value Package Balance"
        static let servicePackageBalance = "Service Package Balance"
        
    }
    private var interactor: AvailMyPackagesModuleBusinessLogic?
    
    var viewDismissBlock: ((Totals_html?, String) -> Void)?
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var btnAvailPackage: UIButton!
    @IBOutlet weak private var lblAvilableBalance: UILabel!
    
    private var serverResponseMyWalletRewardsPointsPackages: PaymentMode.MyWalletRewardPointsPackages.Applicable_packages?
    var arrayOfValuePackage = [PaymentMode.MyWalletRewardPointsPackages.Value]()
    var arrayOfServicePackage = [PaymentMode.MyWalletRewardPointsPackages.Service]()
    
    var isPackageApplied: Bool = false
    private var selectedPackageIndex: Int = 0
    private var isServiceOrValuePackage: Bool = false
    
    private var grand_Total = "0"
    
    var cart_id = ""
    
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
        let interactor = AvailMyPackagesModuleInteractor()
        let presenter = AvailMyPackagesModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: CellIdentifier.myAvailableValuePackagesCell, bundle: nil),
                           forCellReuseIdentifier: CellIdentifier.myAvailableValuePackagesCell)
        tableView.register(UINib(nibName: CellIdentifier.myAvailableServicePackagesCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.myAvailableServicePackagesCell)
        addSOSButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.addCustomBackButton(title: "Available Packages")
        updateAvailbleBalance(balance: grand_Total)
    }
    
    override  func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    override  func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    @IBAction func actionApplyPackage(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateAvailbleBalance(balance: String)
    {
        lblAvilableBalance.text = String(format: "\(k_RupeeSymbol) %@", balance)
    }
    
    private func applyPackage() {
        
        let objectValue =  isServiceOrValuePackage  == false ? selectedPackageIndex < arrayOfValuePackage.count ? arrayOfValuePackage[selectedPackageIndex] : nil : nil //arrayOfValuePackage.first(where: {$0.isSelected == true})
        let objectService = isServiceOrValuePackage  == true ? selectedPackageIndex < arrayOfServicePackage.count ? arrayOfServicePackage[selectedPackageIndex] : nil : nil //arrayOfServicePackage.first(where: {$0.isSelected == true})
        
        let isValuePackageSelected = objectValue != nil ? true : false
        
        if isValuePackageSelected {
            let packageObj = AvailMyPackagesModule.ApplyPackages.ValuePackage(packageId: objectValue?.package_id, packageDiscount: objectValue?.discount_price_to_be_use, packageQty: 1)
            callApplyValuePackagesAPI(package: packageObj)
        }
        else {
            //            var stringReq = objectService?.discount_qty ?? ""
            //            stringReq = stringReq.replacingOccurrences(of: "'\'", with: "")
            let packageObj = AvailMyPackagesModule.ApplyPackages.ServicePackage(packageId: objectService?.package_id, packageDiscount: objectService?.discount_price_to_be_use, packageQty: objectService?.discount_qty_cma)
                callApplyServicePackagesAPI(package: packageObj)
        }
    }
    
    @objc func didTapRemoveButton() {
        
        let alertObj = UIAlertController(title: alertTitle, message: AlertMessagesToAsk.askToRemovePackage, preferredStyle: .alert)
        alertObj.addAction(UIAlertAction(title: AlertButtonTitle.yes, style: .default, handler: { (_) in
            // Yes
            let package_ID = self.isServiceOrValuePackage  == false ? self.arrayOfValuePackage[self.selectedPackageIndex].package_id ?? 0 : self.arrayOfServicePackage[self.selectedPackageIndex].package_id ?? 0
                self.callRemoveValueServicePackagesAPI(package_id: package_ID)
        }))
        alertObj.addAction(UIAlertAction(title: AlertButtonTitle.no, style: .default, handler: { (_) in
            // No
        }))
        self.present(alertObj, animated: true, completion: nil)
        
    }
    
    func setData(applicablePackage: PaymentMode.MyWalletRewardPointsPackages.Applicable_packages?, package_id_applied_to_cart: [Int64]?, grandTotal: String) {
        grand_Total = grandTotal
        serverResponseMyWalletRewardsPointsPackages = applicablePackage
        
        arrayOfValuePackage.removeAll()
        arrayOfServicePackage.removeAll()
        if let dataFromServer = applicablePackage, let valuePackages = dataFromServer.Value, !valuePackages.isEmpty {
            arrayOfValuePackage.append(contentsOf: valuePackages)
            
            if let package_id_applied_to_Cart = package_id_applied_to_cart, !package_id_applied_to_Cart.isEmpty {
                for (_,element) in package_id_applied_to_Cart.enumerated()
                {
                    if let index = arrayOfValuePackage.firstIndex(where: {$0.package_id == element.self}) {
                        arrayOfValuePackage[index].isSelected = true
                    }
                }
            }
            
        }
        
        if let dataFromServer = applicablePackage, let servicePackages = dataFromServer.Service, !servicePackages.isEmpty {
            arrayOfServicePackage.append(contentsOf: servicePackages)
            
            if let package_id_applied_to_Cart = package_id_applied_to_cart, !package_id_applied_to_Cart.isEmpty {
                for (_,element) in package_id_applied_to_Cart.enumerated()
                {
                    if let index = arrayOfServicePackage.firstIndex(where: {$0.package_id == element.self}) {
                        arrayOfServicePackage[index].isSelected = true
                    }
                }
            }
            
        }
        
    }
    
}

extension AvailMyPackages: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numberOfSectionCount: Int = 0
        if !arrayOfValuePackage.isEmpty && !arrayOfServicePackage.isEmpty {
            numberOfSectionCount = 2
        }
        else if !arrayOfValuePackage.isEmpty && arrayOfServicePackage.isEmpty {
            numberOfSectionCount = 1
            
        }
        else if arrayOfValuePackage.isEmpty && !arrayOfServicePackage.isEmpty {
            numberOfSectionCount = 1
            
        }
        
        return numberOfSectionCount
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRowsSectionCount: Int = 0
        if !arrayOfValuePackage.isEmpty && !arrayOfServicePackage.isEmpty {
            if section == 0 {
                numberOfRowsSectionCount = arrayOfValuePackage.count
            }
            else {
                numberOfRowsSectionCount = arrayOfServicePackage.count
            }
        }
        else if !arrayOfValuePackage.isEmpty && arrayOfServicePackage.isEmpty {
            if section == 0 {
                numberOfRowsSectionCount = arrayOfValuePackage.count
            }
            
        }
        else if arrayOfValuePackage.isEmpty && !arrayOfServicePackage.isEmpty {
            if section == 0 {
                numberOfRowsSectionCount = arrayOfServicePackage.count
            }
            
        }
        
        return numberOfRowsSectionCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !arrayOfValuePackage.isEmpty && !arrayOfServicePackage.isEmpty {
            if indexPath.section == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.myAvailableValuePackagesCell, for: indexPath) as? MyAvailableValuePackagesCell else {
                    return UITableViewCell()
                }
                let model = arrayOfValuePackage[indexPath.row]
                cell.configureCell(model: model, indexPath: indexPath)
                cell.selectionStyle = .none
                return cell
                
            }
            else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.myAvailableServicePackagesCell, for: indexPath) as? MyAvailableServicePackagesCell else {
                    return UITableViewCell()
                }
                let model = arrayOfServicePackage[indexPath.row]
                cell.configureCell(model: model, indexPath: indexPath)
                
                cell.selectionStyle = .none
                return cell
                
            }
        }
        else if !arrayOfValuePackage.isEmpty && arrayOfServicePackage.isEmpty {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.myAvailableValuePackagesCell, for: indexPath) as? MyAvailableValuePackagesCell else {
                return UITableViewCell()
            }
            let model = arrayOfValuePackage[indexPath.row]
            cell.configureCell(model: model, indexPath: indexPath)
            cell.selectionStyle = .none
            return cell
            
        }
        else if arrayOfValuePackage.isEmpty && !arrayOfServicePackage.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.myAvailableServicePackagesCell, for: indexPath) as? MyAvailableServicePackagesCell else {
                return UITableViewCell()
            }
            let model = arrayOfServicePackage[indexPath.row]
            cell.configureCell(model: model, indexPath: indexPath)
            
            cell.selectionStyle = .none
            return cell
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.backgroundView?.backgroundColor = .white
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPackageIndex = indexPath.row
        // arrayOfValuePackage.indices.forEach { arrayOfValuePackage[$0].isSelected = false }
        //arrayOfServicePackage.indices.forEach { arrayOfServicePackage[$0].isSelected = false }
        
        if !arrayOfValuePackage.isEmpty && !arrayOfServicePackage.isEmpty {
            
            if indexPath.section == 0 {
                if arrayOfValuePackage[indexPath.row].isSelected == nil || arrayOfValuePackage[indexPath.row].isSelected == false
                {
                    isServiceOrValuePackage = false
                    //arrayOfValuePackage[indexPath.row].isSelected = true
                    applyPackage()
                }
                else
                {
                    isServiceOrValuePackage = false
                    didTapRemoveButton()
                    
                }
            }
            else {
                if arrayOfServicePackage[indexPath.row].isSelected == nil || arrayOfServicePackage[indexPath.row].isSelected == false
                {
                    isServiceOrValuePackage = true
                    //arrayOfServicePackage[indexPath.row].isSelected = true
                    applyPackage()
                    
                }
                else
                {
                    isServiceOrValuePackage = true
                    didTapRemoveButton()
                    
                }
            }
        }
        else if !arrayOfValuePackage.isEmpty && arrayOfServicePackage.isEmpty {
            isServiceOrValuePackage = false
            
            if indexPath.section == 0 {
                if arrayOfValuePackage[indexPath.row].isSelected == nil || arrayOfValuePackage[indexPath.row].isSelected == false
                {
                    // arrayOfValuePackage[indexPath.row].isSelected = true
                    applyPackage()
                    
                }
                else
                {
                    didTapRemoveButton()
                    
                }
                
            }
        }
        else if arrayOfValuePackage.isEmpty && !arrayOfServicePackage.isEmpty {
            isServiceOrValuePackage = true
            
            if indexPath.section == 0 {
                if arrayOfServicePackage[indexPath.row].isSelected == nil || arrayOfServicePackage[indexPath.row].isSelected == false
                {
                    // arrayOfServicePackage[indexPath.row].isSelected = true
                    applyPackage()
                    
                }
                else
                {
                    didTapRemoveButton()
                }
            }
            
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension AvailMyPackages: AvailMyPackagesModuleDisplayLogic {
    
    func callApplyValuePackagesAPI(package: AvailMyPackagesModule.ApplyPackages.ValuePackage) {
        EZLoadingActivity.show("Loading...", disableUI: true)
        let request = AvailMyPackagesModule.ApplyPackages.RequestValuePackage(package: package, cart_id: self.cart_id, use_package: 1, packageId: package.packageId)
        interactor?.applyValuePackages(request: request)
        
    }
    func callApplyServicePackagesAPI(package: AvailMyPackagesModule.ApplyPackages.ServicePackage) {
        EZLoadingActivity.show("Loading...", disableUI: true)
        let request = AvailMyPackagesModule.ApplyPackages.RequestServicePackage(package: package, cart_id: self.cart_id, use_package: 1, packageId: package.packageId)
        interactor?.applyServicePackages(request: request)
        
    }
    func callRemoveValueServicePackagesAPI(package_id :Int64) {
        EZLoadingActivity.show("Loading...", disableUI: true)
        let request = AvailMyPackagesModule.RemovePackages.RequestRemovePackages(cart_id: self.cart_id, use_package: 0, package_id: package_id)
        interactor?.removeValueOrServicePackage(request: request)
        
    }
    
    func displaySuccess<T: Decodable>(viewModel: T) {
        
        if let model = viewModel as? AvailMyPackagesModule.ApplyPackages.Response, model.status == true {
            self.parseAppliedPackage(viewModel: viewModel)
        }
        else if let model = viewModel as? AvailMyPackagesModule.RemovePackages.Response, model.status == true {
            self.parseRemovedPackage(viewModel: viewModel)
        }
    }
    
    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
        
    }
    
    func displaySuccess<T: Decodable>(responseSuccess: [T]) {
        EZLoadingActivity.hide()
        
    }
    func parseAppliedPackage<T: Decodable>(viewModel: T) {
        if let obj = viewModel as? AvailMyPackagesModule.ApplyPackages.Response {
            if let status = obj.status, status == true {
                
                self.showToast(alertTitle: alertTitle, message: obj.message ?? "", seconds: toastMessageDuration)
                
                setData(applicablePackage: obj.data?.applicable_packages, package_id_applied_to_cart: obj.data?.multi_package_id_applied_to_cart, grandTotal: "\(obj.data?.grand_total ?? 0)")
                
                self.updateAvailbleBalance(balance: "\(obj.data?.grand_total ?? 0)")

                if isServiceOrValuePackage == false && selectedPackageIndex < arrayOfValuePackage.count{
                    arrayOfValuePackage[selectedPackageIndex].isSelected = true
                }
                else if isServiceOrValuePackage == true && selectedPackageIndex < arrayOfServicePackage.count{
                    arrayOfServicePackage[selectedPackageIndex].isSelected = true
                }
            }
            else {
                self.showToast(alertTitle: alertTitle, message: obj.message ?? "", seconds: toastMessageDuration)
            }
            self.tableView.reloadData()
        }
        EZLoadingActivity.hide()
        
    }
    
    func parseRemovedPackage<T: Decodable>(viewModel: T) {
        if let obj = viewModel as? AvailMyPackagesModule.RemovePackages.Response {
            if let status = obj.status, status == true {
                
                self.showToast(alertTitle: alertTitle, message: obj.message ?? "", seconds: toastMessageDuration)
                
                setData(applicablePackage: obj.data?.applicable_packages, package_id_applied_to_cart: obj.data?.multi_package_id_applied_to_cart, grandTotal: "\(obj.data?.grand_total ?? 0)")
                
                self.updateAvailbleBalance(balance: "\(obj.data?.grand_total ?? 0)")

                if isServiceOrValuePackage == false && selectedPackageIndex < arrayOfValuePackage.count{
                    arrayOfValuePackage[selectedPackageIndex].isSelected = false
                }
                else if isServiceOrValuePackage == true && selectedPackageIndex < arrayOfServicePackage.count{
                    arrayOfServicePackage[selectedPackageIndex].isSelected = false
                }
            }
            else {
                self.showToast(alertTitle: alertTitle, message: obj.message ?? "", seconds: toastMessageDuration)
            }
            self.tableView.reloadData()
        }
        EZLoadingActivity.hide()
    }
    
}
