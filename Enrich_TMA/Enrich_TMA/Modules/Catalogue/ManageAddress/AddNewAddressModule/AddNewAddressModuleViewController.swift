import UIKit
import FirebaseAnalytics
class AddNewAddressModuleViewController: UIViewController {

    @IBOutlet weak private var addressTableView: UITableView!
    @IBOutlet weak private var btnSave: UIButton!

    var onDoneBlock: ((Bool) -> Void)?
    var isForEditOrAdd: Bool = true  // True Means For Edit, And False For Add New Address
    var loginUserAddressSelected: AddressCellModel?
    var showCheckBox = false // This is to hide default set Address

    private var interactor: ManageAddressModuleBusinessLogic?
    private var modelPersonalDetails: PersonalDetailsCellModel?
    private var addressModel: AddressDetailsCellModel?
    private var addressType: String?
    private var arrayofTextFieldValues = [String]()
    private var arrayofStatesForPicker = [String]()
    private var statesServerResponse: AddNewAddressModule.GetStates.Response?

    var customer_id = ""

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

        // Do any additional setup after loading the view.
        initializeCells()
        createDataForPersonalAddress(editOrAdd: isForEditOrAdd)

    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.addCustomBackButton(title: isForEditOrAdd == true ? NavigationBarTitle.editAddress :  NavigationBarTitle.addNewAddress )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        KeyboardAnimation.sharedInstance.beginKeyboardObservation(self.view)
        toEnableOrDisableSaveButton(isForEditOrAdd)
        callToGetStatesAPI(region: country)

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        KeyboardAnimation.sharedInstance.endKeyboardObservation()
    }

    // MARK: - initializeCells
    func initializeCells() {
        addressTableView.register(UINib(nibName: CellIdentifier.addressTypeCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.addressTypeCell)
        addressTableView.register(UINib(nibName: CellIdentifier.addressDetailsCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.addressDetailsCell)
        addressTableView.register(UINib(nibName: CellIdentifier.billingInfoCheckboxCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.billingInfoCheckboxCell)

    }

    // MARK: - initializePersonalAddress
    func createDataForPersonalAddress(editOrAdd: Bool) {
        if editOrAdd == true // For Edit
        {
            if let modelObject = loginUserAddressSelected {

                addressModel = AddressDetailsCellModel(firstName: modelObject.firstName, lastName: modelObject.lastName, apartment: modelObject.apartment, contactNo: modelObject.contactNo, pinCode: modelObject.pinCode, cityTown: modelObject.cityTown, landmark: modelObject.landmark, state: modelObject.state)
                addressType = modelObject.placeType

            }
        }
        else // For Add New Address
        {
            addressModel = AddressDetailsCellModel(firstName: "", lastName: "", apartment: "", contactNo: "", pinCode: "", cityTown: "", landmark: "", state: "")
            addressType = "Home"

        }
    }

    // MARK: - IBAction
    @IBAction func actionSave(_ sender: UIButton) {
        isForEditOrAdd ? callToUpdateAddressAPI() : callToAddNewAddressAPI()
    }

    func toEnableOrDisableSaveButton(_ status: Bool) {
        btnSave.isSelected = status
        btnSave.isUserInteractionEnabled = status

    }

    // MARK: - createModelForAddAddressForServerRequest
    func createModelForAddAddressForServerRequest(isDefault: Int) -> AddNewAddressModule.AddAddress.Address {
        var arrayOfStreets = [String]()
        arrayOfStreets.append(arrayofTextFieldValues[3]) // Landmark
        arrayOfStreets.append(arrayofTextFieldValues[4]) // Apartments
        let isDefault_Shipping = isDefault
        let isDefault_billing = isDefault
        let addressType = AddNewAddressModule.Custom_attributes(attribute_code: "custom_address_type", value: self.addressType)

        let modelForServerRequestAddUpdateAddress = AddNewAddressModule.AddAddress.Address(customer_id: customer_id, firstname: arrayofTextFieldValues[0], lastname: arrayofTextFieldValues[1], street: arrayOfStreets, city: arrayofTextFieldValues[5], telephone: Int64(arrayofTextFieldValues[2]), postcode: arrayofTextFieldValues[6], region_id: Int64(getStateId(stateName: arrayofTextFieldValues[7])), country_id: country, default_shipping: isDefault_Shipping, default_billing: isDefault_billing, custom_attributes: [addressType])

        return modelForServerRequestAddUpdateAddress
    }
    // MARK: - createModelForEditAddressForServerRequest
    func createModelForEditAddressForServerRequest(isDefault: Int) -> AddNewAddressModule.UpdateAddress.UpdateAddressModel {
        var arrayOfStreets = [String]()
        arrayOfStreets.append(arrayofTextFieldValues[3]) // Landmark
        arrayOfStreets.append(arrayofTextFieldValues[4]) // Apartments
        let isDefault_Shipping = isDefault
        let isDefault_billing = isDefault
        let addressType = AddNewAddressModule.Custom_attributes(attribute_code: "custom_address_type", value: self.addressType)

        let modelForServerRequestUpdateAddress = AddNewAddressModule.UpdateAddress.UpdateAddressModel(id: loginUserAddressSelected?.addressId, customer_id: customer_id, firstname: arrayofTextFieldValues[0], lastname: arrayofTextFieldValues[1], street: arrayOfStreets, city: arrayofTextFieldValues[5], telephone: Int64(arrayofTextFieldValues[2]), postcode: arrayofTextFieldValues[6], region_id: Int64(getStateId(stateName: arrayofTextFieldValues[7])), country_id: country, default_shipping: isDefault_Shipping, default_billing: isDefault_billing, custom_attributes: [addressType])

        return modelForServerRequestUpdateAddress
    }

    // MARK: - createStatesDataForPicker
    func createStatesDataForPicker() {
        if let serverResponse = statesServerResponse?.available_regions {
            for(_, element) in serverResponse.enumerated() {
                if let nameState = element.name, !nameState.isEmpty {
                    arrayofStatesForPicker.append(nameState)
                }
            }
        }
        addressTableView.reloadData()
    }
    // MARK: - getStateId
    func getStateId(stateName: String) -> String {
        var regionId = ""
        if let serverResponse = statesServerResponse?.available_regions {
            if let object = serverResponse.first(where: { $0.name == stateName}) {
                regionId = object.id ?? ""
            }

        }
        return regionId
    }

    // MARK: - checkAddressIsFilled
    func checkAddressIsFilled(_ arrayOfTextFieldValues: [String]) -> Bool {
        var allIsFilled: Bool = false
        let countOfSpace = arrayOfTextFieldValues.filter {$0 == ""}.count

        if countOfSpace > 1 {
            allIsFilled = false
        }
        else if countOfSpace == 0 {
            allIsFilled = true
        }
        else {
            let indexOf = arrayOfTextFieldValues.firstIndex {$0 == ""}

            if (indexOf != nil) && indexOf != 4 {
                allIsFilled = false
            }
            else {
                allIsFilled = true
            }
        }

        if !arrayOfTextFieldValues.isEmpty {
            if arrayOfTextFieldValues[2].count != 10 || arrayOfTextFieldValues[6].count != 6 {
                allIsFilled = false
            }
        }

        return allIsFilled
    }
    // MARK: - checkAddressInCaseOfOtherTypeIsFilled
    func checkAddressInCaseOfOtherTypeIsFilled(_ addressType: String) -> Bool {
        var allIsFilled: Bool = false

        let countOfSpace = addressType.isEmpty

        if countOfSpace == false {
            allIsFilled = true
        }
        else {
            allIsFilled = false
        }

        return allIsFilled

    }

}

extension AddNewAddressModuleViewController: BillingInfoDelegate {

    func actionCheckbox(selected: Bool) {
        print("Selected:\(selected)")
    }
}

// MARK: TableView Delegates And DataSource
extension AddNewAddressModuleViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return showCheckBox ? 1 : 0
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {

        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.billingInfoCheckboxCell, for: indexPath) as? BillingInfoCheckboxCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.configureCell(checkBoxText: "Set as default")
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            cell.selectionStyle = .none
            return cell

        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.addressTypeCell, for: indexPath) as? AddressTypeCell else {
                return UITableViewCell()
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configureCell(addressType: addressType ?? "")
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.addressDetailsCell, for: indexPath) as? AddressDetailsCell else {
                return UITableViewCell()
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            cell.selectionStyle = .none
            cell.delegate = self
            if let model = addressModel {
                cell.configureCell(model: model, states: arrayofStatesForPicker)
                arrayofTextFieldValues = cell.arrayofTextFieldValues
            }

            return cell

        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension AddNewAddressModuleViewController: AddressTypeDelegate {
    func selectedAddressType(type: String) {
        print("Selected:\(type)")
        addressType = type
        addressTableView.beginUpdates()
        addressTableView.endUpdates()
        toEnableOrDisableSaveButton(false)

        if checkAddressInCaseOfOtherTypeIsFilled(self.addressType ?? "") == true && checkAddressIsFilled(self.arrayofTextFieldValues) == true {
            toEnableOrDisableSaveButton(true)
        }

    }
    func editingChangeInTextField(_ arrayOfTextFieldValues: [String]) {
        print("arrayOfTextFieldValues:\(arrayOfTextFieldValues)")
        addressType = arrayOfTextFieldValues.first
        toEnableOrDisableSaveButton(checkAddressInCaseOfOtherTypeIsFilled(self.addressType ?? ""))
    }

}
extension AddNewAddressModuleViewController: AddressDetailsCellDelegate {
    func editingChangedInTextField(_ arrayOfTextFieldValues: [String]) {
        print("arrayOfTextFieldValues:\(arrayOfTextFieldValues)")
        arrayofTextFieldValues = arrayOfTextFieldValues
        toEnableOrDisableSaveButton(checkAddressIsFilled(arrayofTextFieldValues))

    }

}

// MARK: Call Webservice
extension AddNewAddressModuleViewController: ManageAddressModuleDisplayLogic {
    func callToAddNewAddressAPI() {
        EZLoadingActivity.show("", disableUI: true)
        let request = AddNewAddressModule.AddAddress.Request(address: createModelForAddAddressForServerRequest(isDefault: 1) )
        interactor?.doPostRequestAddNewAddress(request: request, accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken)
    }
    func callToUpdateAddressAPI() {
        EZLoadingActivity.show("", disableUI: true)
        let request = AddNewAddressModule.UpdateAddress.Request(address: createModelForEditAddressForServerRequest(isDefault: 1))
        interactor?.doPutRequestToUpdateAddress(request: request, accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken)
    }
    func callToGetStatesAPI(region: String) {
        EZLoadingActivity.show("", disableUI: true)
        interactor?.doGetStatesRequest(region: region)
    }
    // MARK: callToGetUserData
    func callToGetLoggedInUserData() {
        EZLoadingActivity.show("", disableUI: true)
        let request = ManageAddressModule.CustomerInformation.Request(customer_id: customer_id)
        interactor?.doGetRequestToGetInformationOfLoggedInCustomer(request: request, accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken)

    }

    func displaySuccess<T: Decodable>(viewModel: T) {
        DispatchQueue.main.async {[unowned self] in
            if T.self == AddNewAddressModule.AddAddress.Response.self {
                self.parseNewAddressAdded(viewModel: viewModel)
            }
            else if T.self == AddNewAddressModule.GetStates.Response.self {
                self.parseStates(viewModel: viewModel)
            }
            else if T.self == ManageAddressModule.CustomerAddress.Response.self {
                // LoggedInUserData
                self.parseInformationOfLoggedInCustomer(viewModel: viewModel)
            }
        }
    }
    func displayError(errorMessage: String?) {
        DispatchQueue.main.async { [unowned self] in
            self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
            EZLoadingActivity.hide()

        }
    }

    func displaySuccess<T: Decodable>(responseSuccess: [T]) {
        //        DispatchQueue.main.async { [unowned self] in
        //            var obj = [AddNewAddressModule.Something.Response]()
        //            obj = responseSuccess as! [AddNewAddressModule.Something.Response]
        //            print("Get API Response -- \n \(obj)")
        //        }
    }

    // MARK: All Parse Methods
    func parseNewAddressAdded<T: Decodable>(viewModel: T) {
        let obj = viewModel as? AddNewAddressModule.AddAddress.Response
        if obj?.status == true {
            if isForEditOrAdd {
                self.navigationController?.popViewController(animated: false)
                self.onDoneBlock!(true)
            }
            else {
                self.callToGetLoggedInUserData()
            }
        }
        else {
            self.onDoneBlock!(false)
            self.navigationController?.popViewController(animated: false)

        }
        EZLoadingActivity.hide()

    }

    func parseInformationOfLoggedInCustomer<T: Decodable>(viewModel: T) {
        let obj = viewModel as? ManageAddressModule.CustomerAddress.Response
        if let messageObj = obj?.message, !messageObj.isEmpty {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj?.message ?? "")
        }
        else // Success
        {
//            UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_Key_LoginUser)
            self.onDoneBlock?(true)
            self.navigationController?.popViewController(animated: false)

        }

        EZLoadingActivity.hide()
    }
    func parseStates<T: Decodable>(viewModel: T) {
        let obj = viewModel as? AddNewAddressModule.GetStates.Response
        if let messageObj = obj?.message, !messageObj.isEmpty {
            self.showAlert(alertTitle: alertTitle, alertMessage: obj?.message ?? "")
        }
        else // Success
        {
            self.statesServerResponse = obj
            self.createStatesDataForPicker()

        }
        EZLoadingActivity.hide()

    }
}
