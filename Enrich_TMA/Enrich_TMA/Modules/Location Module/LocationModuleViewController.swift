//
//  LocationModuleViewController.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit
import GooglePlaces

protocol LocationModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
}

class LocationModuleViewController: UIViewController, LocationModuleDisplayLogic {
    
    let LocationListing = "LocationListingTableViewCell"
    let LocationOther = "LocationOtherTableViewCell"
    
    @IBOutlet weak private var txtPlace: CustomTextField!
    @IBOutlet weak private var tblDataObject: UITableView!
    @IBOutlet weak private var viewBack: UIView!
    
    var interactor: LocationModuleBusinessLogic?
    var modelResponse: LocationModule.Something.APIResponse?
    var location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var locationName: String = ""
    var arrFilter = [LocationModule.Something.SalonParamModel]()
    var isFilter = false
    // MARK: Object lifecycle
    
    weak var controllerComingFrom: UINavigationController?
    
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
        let interactor = LocationModuleInteractor()
        let presenter = LocationModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
        
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tblDataObject.register(UINib(nibName: LocationListing, bundle: nil), forCellReuseIdentifier: LocationListing)
        tblDataObject.register(UINib(nibName: LocationOther, bundle: nil), forCellReuseIdentifier: LocationOther)
        self.doSomething()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.addCustomBackButton(title: "")
        
        self.title = "Your Location"
        self.txtPlace.placeholder = "Salon name, Area, City, Pincode"
        clearBackgroundForPopup()
    }
    
    // MARK: OpenLoginWindow
    func openLoginWindow() {
        
        //DoLoginPopUpVC
        let vc = DoLoginPopUpVC.instantiate(fromAppStoryboard: .Location)
        vc.delegate = self
        setBackgroundForPopup()
        self.present(vc, animated: true, completion: nil)
        vc.onDoneBlock = { result in
            self.clearBackgroundForPopup()
        }
    }
    
    // MARK: Call Webservice
    func doSomething() {
        var emp1 = LocationModule.Something.Request(lat: location.latitude, long: location.longitude, customer_id: "")
        
        if isuserLoggedIn().status {
            emp1 = LocationModule.Something.Request(lat: location.latitude, long: location.longitude, customer_id: isuserLoggedIn().customerId)
        }
        interactor?.doPostRequest(request: emp1, method: .post)
    }
    
    // MARK: Call Webservice
    func removeFromFavouriteLocation(modelForUpdate: LocationModule.Something.SalonParamModel) {
        let request = MarkMyAddressModule.Something.Request(customer_id: isuserLoggedIn().customerId, salon_id: (modelForUpdate.salon_id)!, type: "", other_name: "", is_custom: true)
        
        interactor?.doPostRequestRemoveData(request: request, method: HTTPMethod.post)
    }
    
    func displaySuccess<T: Decodable>(viewModel: T) {
        if T.self == LocationModule.Something.APIResponse.self {
            DispatchQueue.main.async {
                self.modelResponse = (viewModel as! LocationModule.Something.APIResponse)
                self.tblDataObject.reloadData()
            }
        } else {
            self.doSomething()
        }
    }
    
    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        DispatchQueue.main.async { [unowned self] in
            self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
        }
    }
    
    func displaySuccess<T: Decodable>(responseSuccess: [T]) {
    }
}

extension LocationModuleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func getSectionKeyName(section: Int) -> String {
        
        var strKey = ""
        switch section {
        case LocationTypes.locPreferredSalons.locationIdentifier:
            
            if let modelObj = modelResponse {
                strKey = (modelObj.data.preferred_salon!.isEmpty || isFilter == true) ? LocationTypes.locNearestSalons.rawValue : LocationTypes.locPreferredSalons.rawValue
            }
        case LocationTypes.locOtherSalons.locationIdentifier:
            if UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_Key_LoginUserSignIn) == nil {
                strKey = LocationTypes.locNearestSalons.rawValue
            } else {
                strKey = isFilter == true ? LocationTypes.locNearestSalons.rawValue : LocationTypes.locOtherSalons.rawValue
            }
        default:
            break
        }
        return strKey
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if isFilter == true {
            if arrFilter.count == 0 {
                tableView.setEmptyMessage(tableViewNoSalonAvailable)
                return 0
            } else {
                tableView.restore()
                return 1
            }
        } else {
            if let modelObj = modelResponse {
                if(modelObj.data.salon_list?.count == 0 && modelObj.data.preferred_salon?.count == 0 ) {
                    tableView.setEmptyMessage(tableViewNoSalonAvailable)
                    return 0
                } else {
                    tableView.restore()
                    return 2
                }
            }
            return 2
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilter == true {
            return arrFilter.count
        }
        
        if let modelObj = modelResponse {
            if(section == 0) {
                return modelObj.data.preferred_salon?.count ?? 0
            } else {
                return modelObj.data.salon_list?.count ?? 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isFilter == true {
            let model = arrFilter[indexPath.row]
            //LocationOtherTableViewCell
            let cellObj: LocationOtherTableViewCell = tableView.dequeueReusableCell(withIdentifier: LocationOther, for: indexPath) as! LocationOtherTableViewCell
            cellObj.delegate = self
            cellObj.btnStar.tag = indexPath.row
            cellObj.lblPlaceTitle.text = model.salon_name
            cellObj.lblPlaceAddress.text = self.getFullAddress(model: model)
            cellObj.lblPlaceDistance.text = "\(model.distance.rounded(toPlaces: 2))" + " km from your location"
            //                    cellObj.imgPlaceTypeIcon.image =  UIImage.init(named: model.type!.imgName)
            cellObj.imgBackground.isHidden = true
            cellObj.viewBackBorder.isHidden = false
            cellObj.btnStar.isSelected = false
            
            return cellObj
            
        }
        
        if(indexPath.section == 0) {
            // **************** PREFERRED CELL
            if let modelObj = modelResponse, let array = modelObj.data.preferred_salon {
                let model = array[indexPath.row]
                let cellObj: LocationListingTableViewCell = tableView.dequeueReusableCell(withIdentifier: LocationListing, for: indexPath) as! LocationListingTableViewCell
                cellObj.delegate = self
                cellObj.btnStar.tag = indexPath.row
                
                cellObj.lblPlaceNickName.text = model.other_name!.isEmpty ? model.salon_name : model.other_name
                cellObj.lblPlaceTitle.text = model.salon_name
                cellObj.lblPlaceAddress.text = self.getFullAddress(model: model)
                cellObj.lblPlaceDistance.text = "\(model.distance.rounded(toPlaces: 2))" + " km from your location"
                
                cellObj.imgPlaceTypeIcon.image = UIImage(named: model.type!.imgName)
                cellObj.btnStar.isSelected = true
                
                if(indexPath.row == 0) {
                    cellObj.imgBackground.isHidden = false
                    cellObj.viewBackBorder.isHidden = true
                } else {
                    cellObj.imgBackground.isHidden = true
                    cellObj.viewBackBorder.isHidden = false
                }
                
                return cellObj
            }
        } else {
            // **************** OTHER CELL
            if let modelObj = modelResponse, let array = modelObj.data.salon_list {
                let model = array[indexPath.row]
                //LocationOtherTableViewCell
                let cellObj: LocationOtherTableViewCell = tableView.dequeueReusableCell(withIdentifier: LocationOther, for: indexPath) as! LocationOtherTableViewCell
                cellObj.delegate = self
                cellObj.btnStar.tag = indexPath.row
                cellObj.lblPlaceTitle.text = model.salon_name
                cellObj.lblPlaceAddress.text = self.getFullAddress(model: model)
                cellObj.lblPlaceDistance.text = "\(model.distance.rounded(toPlaces: 2))" + " km from your location"
                //                    cellObj.imgPlaceTypeIcon.image =  UIImage.init(named: model.type!.imgName)
                cellObj.btnStar.isSelected = false
                
                if(indexPath.row == 0 && modelObj.data.preferred_salon?.count == 0) {
                    cellObj.imgBackground.isHidden = false
                    cellObj.viewBackBorder.isHidden = true
                } else {
                    cellObj.imgBackground.isHidden = true
                    cellObj.viewBackBorder.isHidden = false
                }
                
                return cellObj
            }
        }
        return UITableViewCell()
    }
    
    func getFullAddress(model: LocationModule.Something.SalonParamModel) -> String {
        
        var straddress = (model.address_1 ?? "")
        straddress = (model.address_2 ?? "").isEmpty ? straddress : "\(straddress),\n\( model.address_2 ?? "")"
        straddress = (model.city ?? "").isEmpty ? straddress : "\(straddress),\n\( model.city ?? "")"
        straddress = (model.state_name ?? "").isEmpty ? straddress : "\(straddress), \( model.state_name ?? "")"
        straddress = (model.pincode ?? "").isEmpty ? straddress : "\(straddress), \( model.pincode ?? "")"
        return straddress
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let modelObj = modelResponse {
            if(section == 0 && (modelObj.data.preferred_salon?.count ?? 0) > 0) {
                return 70
            } else if(section == 1 && (modelObj.data.salon_list?.count ?? 0) > 0) {
                return 70
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewObj = UIView(frame: CGRect(x: 0, y: 0, width: self.tblDataObject.frame.width, height: 70))
        let lblObj = UILabel(frame: CGRect(x: 0, y: 0, width: self.tblDataObject.frame.width, height: 70))
        lblObj.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: 30)!
        viewObj.backgroundColor = UIColor.white
        lblObj.text = getSectionKeyName(section: section)
        viewObj.addSubview(lblObj)
        return viewObj
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        if isFilter == true {
            let obj = self.arrFilter[indexPath.row]
            if((self.controllerComingFrom) != nil) {
                if self.checkSelectedAddressIsInRange(value: obj.distance) == false {
                    self.showAlert(alertTitle: alertTitle, alertMessage: AlertToWarn.selectedSalonNotInRange)
                    return
                }
            }
            UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_Key_SelectedSalon)
        } else {
            if let modelObj = modelResponse {
                if(indexPath.section == 0) {
                    var obj = modelObj.data.preferred_salon?[indexPath.row]
                    
                    if((self.controllerComingFrom) != nil) {
                        if(self.checkSelectedAddressIsInRange(value: obj?.distance ?? 0.0)) == false {
                            self.showAlert(alertTitle: alertTitle, alertMessage: AlertToWarn.selectedSalonNotInRange)
                            return
                        }
                    }
                    obj?.current_city_area = modelObj.data.current_city_area ?? "NA"
                    UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_Key_SelectedSalon)
                    
                } else {
                    var obj = modelObj.data.salon_list?[indexPath.row]
                    if((self.controllerComingFrom) != nil) {
                        if(self.checkSelectedAddressIsInRange(value: obj?.distance ?? 0.0)) == false {
                            self.showAlert(alertTitle: alertTitle, alertMessage: AlertToWarn.selectedSalonNotInRange)
                            return
                        }
                    }
                    obj?.current_city_area = modelObj.data.current_city_area ?? "NA"
                    
                    UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_Key_SelectedSalon)
                }
            }
        }
        
        if((self.controllerComingFrom) != nil) {
//            if let parentObj = self.controllerComingFrom?.parent {
//                if let parentVC = parentObj as? SelectServiceModuleViewController {
//                    parentVC.setUIValues()
//                    parentVC.removeChild()
//                }
//            } else {
                self.appDelegate.window?.rootViewController!.dismiss(animated: false, completion: nil)
            //}
        }
    }
    
    func checkSelectedAddressIsInRange(value: Double) -> Bool {
        var isCorrect: Bool = false
        if  let dummy = UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_Key_SelectedLocationFor) {
            let obj = dummy as! String
            if(obj == SalonServiceAt.Anny || obj == SalonServiceAt.Salon) {
                isCorrect = true
                
                return isCorrect
            }
        }
        
        if(value <= 5) {
            isCorrect = true
            return isCorrect
        }
        return isCorrect
        
    }
}

extension LocationModuleViewController: StarLocationStatusDelegation, StarLocOtherStatusDelegation {
    func statusOfStarAddressLocation(btnPlaceTag: Int, isSelected: Bool) {
        
        let alertController = UIAlertController(title: alertTitle, message: "Do you want to remove this preferred salon?", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: AlertButtonTitle.yes, style: UIAlertAction.Style.cancel) { _ -> Void in
            // *********************** Unstar Data *****************************
            if let modelObj = self.modelResponse {
                let model = modelObj.data.preferred_salon![btnPlaceTag]
                self.removeFromFavouriteLocation(modelForUpdate: model)
            }
        })
        alertController.addAction(UIAlertAction(title: AlertButtonTitle.no, style: UIAlertAction.Style.default) { _ -> Void in
            // Do Nothing
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    func statusOfStarAddrOtherLocation(btnPlaceTag: Int, isSelected: Bool) {
        
        txtPlace.resignFirstResponder()
        
        // *********************** Star Data *****************************
        if isuserLoggedIn().status {
            
            if isFilter == true {
                let markMyAddressModuleViewController = MarkMyAddressModuleViewController.instantiate(fromAppStoryboard: .Location)
                let model = arrFilter[btnPlaceTag]
                markMyAddressModuleViewController.modelForUpdate = model
                markMyAddressModuleViewController.delegate = self
                setBackgroundForPopup()
                self.present(markMyAddressModuleViewController, animated: false, completion: nil)
            } else {
                if let modelObj = modelResponse {
                    let markMyAddressModuleViewController = MarkMyAddressModuleViewController.instantiate(fromAppStoryboard: .Location)
                    let model = modelObj.data.salon_list![btnPlaceTag]
                    markMyAddressModuleViewController.modelForUpdate = model
                    markMyAddressModuleViewController.delegate = self
                    setBackgroundForPopup()
                    self.present(markMyAddressModuleViewController, animated: false, completion: nil)
                }
            }
            return
        }
        
        openLoginWindow()
    }
    
    func setBackgroundForPopup() {
        self.view.backgroundColor = UIColor.darkGray
        self.viewBack.alpha = screenPopUpAlpha
    }
    
    func clearBackgroundForPopup() {
        self.view.backgroundColor = UIColor.white
        self.viewBack.alpha = 1
    }
}

extension LocationModuleViewController: LoginRegisterDelegate {
    func doLoginRegister() {
        // Put your code here
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            let vc = LoginModuleVC.instantiate(fromAppStoryboard: .Main)
            let navigationContrl = UINavigationController(rootViewController: vc)
            self.present(navigationContrl, animated: true, completion: nil)
        }
    }
}

extension LocationModuleViewController: SuccessPreferredSaloneDelegate {
    
    func displaySuccess() {
        clearBackgroundForPopup()
        self.doSomething()
        txtPlace.text = ""
        isFilter = false
    }
    
    func displayCancel() {
        clearBackgroundForPopup()
    }
}

extension LocationModuleViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let strObj = updatedText
        
        if strObj.isEmpty {
            isFilter = false
        } else {
            
            let arrSortedData = modelResponse?.data.salon_list?.filter({ (model) -> Bool in
                if (model.address_1 ?? "").localizedCaseInsensitiveContains(strObj) || (model.address_2 ?? "").localizedCaseInsensitiveContains(strObj) || (model.salon_name ?? "").localizedCaseInsensitiveContains(strObj) || (model.city ?? "").localizedCaseInsensitiveContains(strObj) || (model.pincode ?? "").localizedCaseInsensitiveContains(strObj) {
                    return true
                }
                return false
            })
            print("salon_list : \(arrSortedData ?? [])")
            
            //            let arrData = modelResponse?.data.preferred_salon?.filter({ (model) -> Bool in
            //                if model.address_1!.localizedCaseInsensitiveContains(strObj) {
            //                    return true
            //                }
            //                return false
            //            })
            //            print("preferred_salon : \(arrData ?? [])")
            
            arrFilter = arrSortedData ??  [] // + arrData!
            print("arrFilter : \(arrFilter )")
            isFilter = true
        }
        self.tblDataObject.reloadData()
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.tblDataObject.reloadData()
        return true
    }
    
    func hideContentController(content: UINavigationController) {
        content.willMove(toParent: nil)
        content.view.removeFromSuperview()
        content.removeFromParent()
        
    }
    
}
