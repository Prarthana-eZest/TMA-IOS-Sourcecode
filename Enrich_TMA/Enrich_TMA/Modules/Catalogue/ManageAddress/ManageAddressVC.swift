//
//  ManageAddressViewController.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 15/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit
import FirebaseAnalytics
protocol ManageAddressModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
}

class ManageAddressVC: UIViewController, ManageAddressModuleDisplayLogic {

    @IBOutlet weak private var addressCollectionView: UICollectionView!
    private var interactor: ManageAddressModuleBusinessLogic?

    private var arrOfAddresses: [AddressCellModel] = []
    var userSelectedAddress: ManageAddressModule.CustomerAddress.Addresses?

    private var loginUserModel: ManageAddressModule.CustomerAddress.Response?

    var customer_id = ""

    var onDoneBlock: ((Bool, ManageAddressModule.CustomerAddress.Addresses?) -> Void)? // First Bool Variable false Means user has not changed shipping address

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
        let interactor = ManageAddressModuleInteractor()
        let presenter = ManageAddressModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addressCollectionView.register(UINib(nibName: CellIdentifier.addressCollectionCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.addressCollectionCell)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        showNavigationBarRigtButtons()
        showNavigationBarLeftButtons()
        callToGetCustomerData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if self.navigationController?.viewControllers.index(of: self) == nil {
            onDoneBlock?(true, userSelectedAddress)
        }
        super.viewWillDisappear(animated)
    }

    @objc func rightButtonAction(sender: UIButton) {
        print("Add New Address")
        openAddNewAddress(isFor: false, addressModel: nil)

    }

    @objc func leftBarButtonAction(sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - Top Navigation Bar And  Actions
    func showNavigationBarLeftButtons() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40) )
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle(" Addresses", for: .normal)

        let imgBackArrow = UIImage(named: "navigationBackButton")
        button.setImage(imgBackArrow, for: .normal)
        button.titleLabel?.font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 20)
        button.addTarget(self, action: #selector(leftBarButtonAction), for: .touchUpInside)
        let leftButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = leftButtonItem
    }

    // MARK: - Top Navigation Bar And  Actions
    func showNavigationBarRigtButtons() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40) )
        button.setTitleColor(UIColor(red: 234 / 255, green: 32 / 255, blue: 25 / 255, alpha: 1), for: .normal)
        button.setTitle("Add New Address", for: .normal)
        button.titleLabel?.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 25 : 18)
        button.addTarget(self, action: #selector(rightButtonAction(sender:)), for: .touchUpInside)
        let rightButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }

    // MARK: - openAddNewAddress
    func openAddNewAddress(isFor: Bool, addressModel: AddressCellModel?) {
        let addNewAddressMVC = AddNewAddressModuleViewController.instantiate(fromAppStoryboard: .Catalogue)
        addNewAddressMVC.isForEditOrAdd = isFor
        addNewAddressMVC.loginUserAddressSelected = isFor ? addressModel : nil
        addNewAddressMVC.customer_id = customer_id
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(addNewAddressMVC, animated: true)
        addNewAddressMVC.onDoneBlock = { result in
            if result {}
else {}
        }
    }

    // MARK: - createDataForAddresses
    func createDataForAddresses() {
        arrOfAddresses.removeAll()
        if let addressess = loginUserModel?.addresses, !addressess.isEmpty {

            for (_, element) in addressess.enumerated() {
                var addressType: String = ""
                let modelObject: ManageAddressModule.CustomerAddress.Addresses = element
                if let customerAddressType = modelObject.custom_attributes?.first?.value?.description {
                    addressType = customerAddressType
                }

                let model = AddressCellModel(placeType: addressType, userName: String(format: "%@ %@", modelObject.firstname ?? "", modelObject.lastname ?? ""), address: String(format: "%@\n%@- %@\n%@", modelObject.street?.joined(separator: ",") ?? "", modelObject.city ?? "", modelObject.postcode ?? "", modelObject.region?.region ?? ""), contactNo: modelObject.telephone ?? "", addressId: element.id ?? 0, firstName: element.firstname ?? "", lastName: element.lastname ?? "", apartment: element.street?.first ?? "", pinCode: element.postcode ?? "", cityTown: element.city ?? "", landmark: element.street?.count ?? 0 > 1 ? element.street?.last ?? "" : "", state: element.region?.region ?? "")
                arrOfAddresses.append(model)
            }
            addressCollectionView.reloadData()
        }
//        else
//        {
//            openAddNewAddress(isFor:false, addressModel: nil)
//
//        }

    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}

// MARK: Call Webservice
extension ManageAddressVC {

    // MARK: callToGetUserData
    func callToGetCustomerData() {
        EZLoadingActivity.show("", disableUI: true)
        let request = ManageAddressModule.CustomerInformation.Request(customer_id: customer_id)
        interactor?.doGetRequestToGetInformationOfLoggedInCustomer(request: request, accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken)

    }
    // MARK: callToDeleteAddress
    func callToDeleteAddress(addressId: Int64) {
        EZLoadingActivity.show("", disableUI: true)
        interactor?.doDeleteAddress(accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken, addressId: addressId)

    }

    func displaySuccess<T: Decodable> (viewModel: T) {
        DispatchQueue.main.async {[unowned self] in
            if T.self == ManageAddressModule.CustomerAddress.Response.self {
                // LoggedInUserData
                self.parseInformationOfLoggedInCustomer(viewModel: viewModel)
            }
            else if T.self == ManageAddressModule.DeleteAddress.Response.self {
                // Delete Address
                self.parseRemoveAddress(viewModel: viewModel)
            }
        }
    }

    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage!)
    }
    func displaySuccess<T: Decodable>(responseSuccess: [T]) {

    }
    func parseInformationOfLoggedInCustomer<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ManageAddressModule.CustomerAddress.Response
        if let messageObj = obj?.message, !messageObj.isEmpty {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj?.message ?? "")
        }
        else // Success
        {
            self.loginUserModel = obj
//            UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_Key_LoginUser)
            createDataForAddresses()
        }

        EZLoadingActivity.hide()
    }

    func parseRemoveAddress<T: Decodable>(viewModel: T) {
        // DeleteAddress
        let obj = viewModel as? ManageAddressModule.DeleteAddress.Response
        if obj?.status == true {
            self.showToast(alertTitle: alertTitleSuccess, message: obj?.message ?? "", seconds: toastMessageDuration)
            callToGetCustomerData()
        }
        else {
            self.showToast(alertTitle: alertTitle, message: obj?.message ?? "", seconds: toastMessageDuration)

        }
        EZLoadingActivity.hide()

    }
}

extension ManageAddressVC: AddressCellDelegate {

    func leftButtonAction(cellType: CellType, indexPath: IndexPath) {

        let model = self.arrOfAddresses[indexPath.row]
        if model.addressId == Int64(self.loginUserModel?.default_shipping ?? "0") {
            self.showToast(alertTitle: alertTitle, message: AlertMessagesToAsk.defaultAddress, seconds: toastMessageDuration)
            return
        }
        let alertController = UIAlertController(title: alertTitle, message: AlertMessagesToAsk.askToDeleteAddress, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: AlertButtonTitle.yes, style: UIAlertAction.Style.cancel) { _ -> Void in
            self.callToDeleteAddress(addressId: model.addressId)
        })
        alertController.addAction(UIAlertAction(title: AlertButtonTitle.no, style: UIAlertAction.Style.default) { _ -> Void in
            // Do Nothing
        })
        self.present(alertController, animated: true, completion: nil)
    }

    func rightButtonAction(cellType: CellType, indexPath: IndexPath) {
        let model = arrOfAddresses[indexPath.row]
        openAddNewAddress(isFor: true, addressModel: model)
    }
}

extension ManageAddressVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if arrOfAddresses.isEmpty {
            //collectionView.setEmptyMessage(TableViewNoData.tableViewNoAddressAvailable)
            return 0
        }
        else {
           // collectionView.restore()
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrOfAddresses.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.addressCollectionCell, for: indexPath) as? AddressCollectionCell else {
            return UICollectionViewCell()
        }

        let model = arrOfAddresses[indexPath.row]
        cell.delegate = self
        cell.configureCell(model: model, cellType: .confirmation, indexPath: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 200 // 270
        let width: CGFloat = collectionView.frame.size.width
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selection")
        if let addressess = loginUserModel?.addresses, !addressess.isEmpty {
            userSelectedAddress = addressess[indexPath.row]
            onDoneBlock!(true, userSelectedAddress)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
