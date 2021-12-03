//
//  SelectServiceModuleViewController.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

struct UserSelectedLocation: Codable {
    var serviceType: String = SalonServiceAt.Salon
    var salon_id: String = "0"
    var salon_name: String = "Enrich Salon"
    var salon_code: String = "0"
    var salon_PhoneNumber: String = "18602663000"
    var salon_AlternativeNumber: String = "18602663000"
    var salon_Email: String = "customercare@enrichsalon.com"

    var userLocation: String = "Select your location"
    var salonAddress: String = String(format: "Nearest Salon: %@", "\(0)" + " km")
    var salonAddressUnFormated: String = ""

    var salonDistance: Double = 0.0
    var gender: String = PersonType.female // Female Or Male
    var otherGenderInclined: String = "false" // Not Selected
}

class SelectServiceModuleViewController: UIViewController {

    @IBOutlet weak var btnSalon: UIButton!
    @IBOutlet weak private var lblSalonUnderline: UILabel!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak private var lblHomeUnderline: UILabel!

    @IBOutlet weak private var btnMale: UIButton!
    @IBOutlet weak private var btnFemale: UIButton!
    @IBOutlet weak private var btnOther: UIButton!
    @IBOutlet weak private var lblSelectYourOption: UILabel!
    @IBOutlet weak private var lblNearestSalon: LabelButton!

    @IBOutlet weak private var btnCancel: UIButton!
    @IBOutlet weak private var btnSelectService: UIButton!
    @IBOutlet weak private var lblSelectedLocation: LabelButton!
    @IBOutlet weak private var lblMale: UILabel!
    @IBOutlet weak private var lblFemale: UILabel!
    @IBOutlet weak private var lblOther: UILabel!
    @IBOutlet weak private var viewSelectLocation: TouchUIView!

    @IBOutlet weak private var lblMoreInclined: UILabel!
    @IBOutlet weak private var btnOtherInclinedMale: UIButton!
    @IBOutlet weak private var btnOtherInclinedFemale: UIButton!

    // Stack View References
    @IBOutlet weak private var stackViewGender: UIStackView!
    @IBOutlet weak private var stackViewMale: UIStackView!
    @IBOutlet weak private var stackViewOther: UIStackView!
    @IBOutlet weak private var containerHeightConstraint: NSLayoutConstraint!

    weak var controllerToDismiss: UIViewController?

    var isMaleOrFemaleSelected: String = PersonType.female  // Male or Female
    var userOtherInclinedGender: String = "false"
    var serviceType: String = SalonServiceAt.Salon

    var onDoneBlock: ((Bool) -> Void)?

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        var defaultValues = UserSelectedLocation()
        if let userData = UserDefaults.standard.value(MyProfile.GetUserProfile.UserData.self, forKey: UserDefauiltsKeys.k_Key_LoginUser) {
            defaultValues.salon_id = userData.salon_id ?? "0"
            defaultValues.salon_code = userData.base_salon_code ?? "0"
            defaultValues.salon_name = userData.base_salon_name ?? "Enrich Salon"
        }

        self.isMaleOrFemaleSelected = defaultValues.gender
        self.userOtherInclinedGender = defaultValues.otherGenderInclined

        UserDefaults.standard.set(encodable: defaultValues, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService)

        self.lblHomeUnderline.isHidden = true
        self.viewSelectLocation.onClick = {
            // TODO
           // self.clickLocationEnable([:])
        }
        self.lblSelectedLocation.onClick = {
            // TODO
           // self.clickLocationEnable([:])
        }

        UserDefaults.standard.set(serviceType, forKey: UserDefauiltsKeys.k_Key_SelectedLocationFor)
        //self.hideSalonSelected()
        //self.setUIValues()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.addCustomBackButton(title: "")
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setUIValues()

    }

    // MARK: Set UI Values
    func setUIValues() {

        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
            self.lblSelectedLocation.text = userSelectionForService.salon_name
        }

        if  let dummy = UserDefaults.standard.value( LocationModule.Something.SalonParamModel.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalon) {
            if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
                var obj = userSelectionForService
                obj.salon_id = dummy.salon_id ?? "0"
                obj.salon_name = dummy.salon_name ?? "Enrich Salon"
                obj.salon_code = dummy.salon_code ?? "0"
                obj.salon_PhoneNumber = dummy.phone_no ?? "18602663000"
                obj.salon_AlternativeNumber = dummy.alternate_phone_no ?? "18602663000"
                obj.salon_Email = dummy.email ?? "customercare@enrichsalon.com"
                obj.userLocation = dummy.current_city_area ?? "NA" //dummy.city ?? "NA"
                obj.salonDistance = dummy.distance?.rounded(toPlaces: 2) ?? 0
                obj.salonAddress = String(format: "Nearest Salon: %@ (%@)", dummy.salon_name ?? "", "\(obj.salonDistance.rounded(toPlaces: 2))" + " km")
                obj.salonAddressUnFormated = String(format: "%@ (%@)", dummy.salon_name ?? "", "\(obj.salonDistance.rounded(toPlaces: 2))" + " km")
                UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService)

                self.lblSelectedLocation.text = obj.userLocation
                self.serviceType = obj.serviceType

                self.setGendersWithSelectedValues(isMaleOrFemaleSel: obj.gender, userOtherInclGender: obj.otherGenderInclined)

            }
        }

        //        if self.lblNearestSalon.isHidden == true {
        //            self.btnSelectService.isUserInteractionEnabled = false
        //            self.btnSelectService.isSelected = false
        //        }
        //        else {
        self.btnSelectService.isUserInteractionEnabled = true
        self.btnSelectService.isSelected = true
        //  }

        //        if  let isSalonTabOrHome = UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_Key_SelectedLocationFor.rawValue){
        //            let obj = isSalonTabOrHome as! String
        //            if obj == SalonServiceAt.Salon.rawValue
        //            {
        //                self.clickSalon(self.btnSalon)
        //            }
        //            else
        //            {
        //                self.clickHome(self.btnHome)
        //            }
        //        }

    }
}

extension SelectServiceModuleViewController {
    // MARK: IBAction

    @IBAction func clickSalon(_ sender: Any) {

        UserDefaults.standard.set(SalonServiceAt.Salon, forKey: UserDefauiltsKeys.k_Key_SelectedLocationFor)

        self.serviceType = SalonServiceAt.Salon

        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
            var obj = userSelectionForService
            obj.serviceType = self.serviceType
            UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService)
        }
        self.btnSalon.isSelected = true
        self.btnHome.isSelected = false

        self.lblSalonUnderline.isHidden = false
        self.lblHomeUnderline.isHidden = true

        self.lblSelectYourOption.text = "Select your options"
        self.lblSelectYourOption.textAlignment = .left
        self.lblSelectYourOption.textColor = .black
        self.lblSelectYourOption.font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: is_iPAD ? 30:20)!

        showWhenSalonTabSelected()

    }

    @IBAction func clickHome(_ sender: Any) {

        UserDefaults.standard.set(SalonServiceAt.home, forKey: UserDefauiltsKeys.k_Key_SelectedLocationFor)
        self.serviceType = SalonServiceAt.home
        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
            var obj = userSelectionForService
            obj.serviceType = self.serviceType
            UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService)
        }
        self.btnHome.isSelected = true
        self.btnSalon.isSelected = false
        self.lblMoreInclined.isHidden = true
        self.lblHomeUnderline.isHidden = false
        self.lblSalonUnderline.isHidden = true

        self.lblSelectYourOption.text = "Home services are available for"
        self.lblSelectYourOption.textAlignment = .center
        self.lblSelectYourOption.textColor = .black
        self.lblSelectYourOption.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 27:18)!

        hideWhenHomeTabSelected()
        hideOtherOptions()
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            self.containerHeightConstraint.constant = 420
            self.view.layoutIfNeeded()
        })

    }

    @IBAction func clickMaleOrFemaleOrOther(_ sender: Any) {
        guard let btnselected = sender as? UIButton else {
            return
        }

        if btnselected == btnFemale {
            userOtherInclinedGender = "false"
            self.isMaleOrFemaleSelected = PersonType.female
            self.btnFemale.isSelected = true
            self.btnMale.isSelected = false
            self.btnOther.isSelected = false
            self.lblFemale.textColor = .black
            self.lblMale.textColor = .lightGray
            self.lblOther.textColor = .lightGray
            self.lblFemale.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 33.0 : 22.0)
            self.lblMale.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 33.0 : 22.0)
            self.lblOther.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 33.0 : 22.0)

            hideOtherOptions()
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, animations: {
                self.containerHeightConstraint.constant = 420
                self.view.layoutIfNeeded()
            })
        }
        else if btnselected == btnMale {
            userOtherInclinedGender = "false"

            self.isMaleOrFemaleSelected = PersonType.male
            self.btnMale.isSelected = true
            self.btnFemale.isSelected = false
            self.btnOther.isSelected = false
            self.lblMale.textColor = .black
            self.lblFemale.textColor = .lightGray
            self.lblOther.textColor = .lightGray

            self.lblMale.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 33.0 : 22.0)
            self.lblFemale.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 33.0 : 22.0)
            self.lblOther.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 33.0 : 22.0)

            hideOtherOptions()
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, animations: {
                self.containerHeightConstraint.constant = 420
                self.view.layoutIfNeeded()
            })

        }
        else if btnselected == btnOther {
            userOtherInclinedGender = "true"

            self.isMaleOrFemaleSelected = PersonType.female
            self.btnOther.isSelected = true
            self.btnFemale.isSelected = false
            self.btnMale.isSelected = false
            self.lblOther.textColor = .black
            self.lblFemale.textColor = .lightGray
            self.lblMale.textColor = .lightGray

            self.lblOther.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 33.0 : 22.0)
            self.lblMale.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 33.0 : 22.0)
            self.lblFemale.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 33.0 : 22.0)

            showOtherOptions()
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, animations: {
                self.containerHeightConstraint.constant = 520
                self.view.layoutIfNeeded()
            })
        }
    }

    @IBAction func clickCancel(_ sender: Any) {
        self.alertControllerBackgroundTapped()
        onDoneBlock!(false)

    }

    @IBAction func clickSelectServices(_ sender: Any) {

        StorageType.cache.clearStorageForSubfolder(subfolder: CacheFolderNameKeys.k_folder_name_SalonService.rawValue)
        StorageType.cache.clearStorageForSubfolder(subfolder: CacheFolderNameKeys.k_folder_name_SalonHomeServiceSubCategory.rawValue)
        StorageType.cache.clearStorageForSubfolder(subfolder: CacheFolderNameKeys.k_folder_name_SalonHomeServiceSubCategoryList.rawValue)
        StorageType.cache.clearStorageForSubfolder(subfolder: CacheFolderNameKeys.k_folder_name_Testimonials.rawValue)

                if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
                    var obj = userSelectionForService
                   obj.gender = self.isMaleOrFemaleSelected
                    obj.otherGenderInclined = self.userOtherInclinedGender
                    obj.serviceType = self.serviceType

                    UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService)
                }

        self.alertControllerBackgroundTapped()
        onDoneBlock!(true)

    }

    @IBAction func clickOtherMale(_ sender: Any) {
        self.isMaleOrFemaleSelected = PersonType.male
        self.btnOtherInclinedMale.isSelected = true
        self.btnOtherInclinedFemale.isSelected = false
    }
    @IBAction func clickOtherFemale(_ sender: Any) {
        self.isMaleOrFemaleSelected = PersonType.female
        self.btnOtherInclinedFemale.isSelected = true
        self.btnOtherInclinedMale.isSelected = false

    }

    // MARK: OtherFunctions
    func setGendersWithSelectedValues(isMaleOrFemaleSel: String, userOtherInclGender: String) {

        if self.serviceType == SalonServiceAt.Salon {
            if userOtherInclGender == "true" {
                self.clickMaleOrFemaleOrOther(self.btnOther)

                if isMaleOrFemaleSel == PersonType.male {
                    self.clickOtherMale(self.btnOtherInclinedMale)
                }
                else {
                    self.clickOtherFemale(self.btnOtherInclinedFemale)
                }

            }
            else {
                if isMaleOrFemaleSel == PersonType.male {

                    self.clickMaleOrFemaleOrOther(self.btnMale)
                }
                else {

                    self.clickMaleOrFemaleOrOther(self.btnFemale)
                }

            }
        }
        else {
            self.clickHome(self.btnHome)

        }
    }

    @objc func alertControllerBackgroundTapped() {
        self.controllerToDismiss?.view.alpha = 1.0
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
    }

    // MARK: Hide Unhide Controlls
    @objc func hideWhenHomeTabSelected() {
        self.isMaleOrFemaleSelected = PersonType.female
        self.stackViewMale.isHidden = false
        self.stackViewOther.isHidden = false

        self.btnMale.isSelected = false
        self.btnOther.isSelected = false
        
        self.btnFemale.isHidden = false
        self.btnFemale.isUserInteractionEnabled = true
        self.btnFemale.isSelected = true
        
        self.lblFemale.textColor = .black
        self.lblMale.textColor = .lightGray
        self.lblOther.textColor = .lightGray

        self.lblFemale.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 33.0 : 22.0)
        self.lblMale.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 33.0 : 22.0)
        self.lblOther.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 33.0 : 22.0)
    }
    
    @objc func showWhenSalonTabSelected() {
        self.isMaleOrFemaleSelected = PersonType.female
        self.stackViewMale.isHidden = false
        self.stackViewOther.isHidden = false

        self.btnMale.isSelected = false
        self.btnOther.isSelected = false
        
        self.btnFemale.isHidden = false
        self.btnFemale.isUserInteractionEnabled = true
        self.btnFemale.isSelected = true
        
        self.lblFemale.textColor = .black
        self.lblMale.textColor = .lightGray
        self.lblOther.textColor = .lightGray

        self.lblFemale.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 33.0 : 22.0)
        self.lblMale.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 33.0 : 22.0)
        self.lblOther.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 33.0 : 22.0)

        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
            let obj = userSelectionForService
            if obj.serviceType == SalonServiceAt.Salon {
                self.setGendersWithSelectedValues(isMaleOrFemaleSel: obj.gender, userOtherInclGender: obj.otherGenderInclined)
            }
        }

    }

    // MARK: Hide Unhide Other Options
    @objc func hideOtherOptions() {
        self.lblMoreInclined.isHidden = true
        self.btnOtherInclinedMale.isHidden = true
        self.btnOtherInclinedFemale.isHidden = true

    }
    @objc func showOtherOptions() {
        self.isMaleOrFemaleSelected = PersonType.female
        self.lblMoreInclined.isHidden = false
        self.btnOtherInclinedMale.isHidden = false
        self.btnOtherInclinedFemale.isHidden = false

    }

}
