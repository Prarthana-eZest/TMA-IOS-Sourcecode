//
//  LoginOTPModuleViewController.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.

import UIKit
protocol LoginOTPModuleDisplayLogic: class {
    func displaySuccessLoginOTPModule<T: Decodable> (viewModel: T)
    func displayErrorLoginOTPModule(errorMessage: String?)
}

class LoginOTPModuleVC: DesignableViewController, LoginOTPModuleDisplayLogic {
    @IBOutlet weak private var imgLogo: UIImageView!
    @IBOutlet weak private var txtFieldCustomObj: CustomTextField!
    @IBOutlet weak private var btnProceed: UIButton!
    @IBOutlet weak private var lblDescription: UILabel!
    @IBOutlet weak private var txtCountryCode: CustomTextField!

    private  var userFirstName: String?
    private  var userLastName: String?
    private  var userGender: Int = 2
    private  var userReferalCode: String?
    private  var userOtherInclinedGender: String?

    weak var delegate: LoginOTPModuleDisplayLogic?

    var interactor: LoginOTPModuleBusinessLogic?

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
        let interactor = LoginOTPModuleInteractor()
        let presenter = LoginOTPModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.addCustomBackButton(title: "")

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hideKeyboard()
    }
    // MARK: initialSetUp
    func initialSetUp() {
        hideKeyboardWhenTappedAround()
        btnProceed.isEnabled = false
        title = "Login"
        [txtFieldCustomObj, txtCountryCode].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
    }

    // MARK: PassData
    func passData(firstName: String, lastName: String, gender: Int, referalCode: String, otherInclinedGender: String) {
        userFirstName = firstName
        userLastName = lastName
        userGender = gender
        userReferalCode = referalCode
        userOtherInclinedGender = otherInclinedGender
    }

    // MARK: IBActions
    @IBAction func actionBtnProceed(_ sender: Any) {
        txtCountryCode.resignFirstResponder()
        txtFieldCustomObj.resignFirstResponder()
        connectToServerForMobileOTP(mobileNumber: self.txtFieldCustomObj.text ?? "")
    }
    
    @IBAction func actionBackToLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated:true)
    }
    
}

// MARK: Call Webservice
extension LoginOTPModuleVC {
    func connectToServerForMobileOTP(mobileNumber: String) {
        EZLoadingActivity.show("Loading...", disableUI: true)
        if((delegate) != nil) {
            let request = LoginOTPModule.OTP.Request(mobile_number: mobileNumber)
            interactor?.doPostRequest(request: request, method: HTTPMethod.post)
        } else {
            let request = LoginOTPModule.OTP.Request(mobile_number: mobileNumber)
            interactor?.doPostRequest(request: request, method: HTTPMethod.post)
        }
    }

    func displaySuccessLoginOTPModule<T: Decodable>(viewModel: T) {
        EZLoadingActivity.hide(true, animated: false)
        let obj: LoginOTPModule.OTP.Response = viewModel as! LoginOTPModule.OTP.Response

        if((delegate) != nil) {
            if(obj.status == true) {
                UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_Key_LoginUserOTPDetails)
            }

            delegate?.displaySuccessLoginOTPModule(viewModel: viewModel)
            return
        }
        if(obj.status == true) {
            UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_Key_LoginUserOTPDetails)

            let vc = OTPVerificationModuleVC.instantiate(fromAppStoryboard: .Login)
            vc.passData(firstName: userFirstName ?? "", lastName: userLastName ?? "", gender: userGender, mobileNumber: txtFieldCustomObj.text ?? "", userFaceBookOrGoogleEmail: "", referalCode: userReferalCode ?? "", OTPCode: obj.data?.otpcode ?? "", otherInclinedGender: userOtherInclinedGender ?? "", countryCode: txtCountryCode.text ?? "" )
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func displayErrorLoginOTPModule(errorMessage: String?) {
        EZLoadingActivity.hide()
        if((delegate) != nil) {
            delegate?.displayErrorLoginOTPModule(errorMessage: errorMessage)
            return
        }
        showAlert(alertTitle: alertTitle, alertMessage: errorMessage!)
    }
}

// MARK: Text field Delegates
extension LoginOTPModuleVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LoginOTPModuleVC {
    @objc func editingChanged(_ textField: UITextField) {
        btnProceed.isEnabled = false
        btnProceed.isSelected = false
        imgLogo.image = UIImage(named: ImageNames.disabledLogo.rawValue)

        if textField.text?.count == 1 {
            if textField.text?.first == " "{
                textField.text = ""
                return
            }
        }
        guard
            let mobileNumber = self.txtFieldCustomObj.text?.trim(), !mobileNumber.isEmpty, mobileNumber.count > 9,
            let countryCode = self.txtCountryCode.text?.trim(), !countryCode.isEmpty

            else {
                btnProceed.isEnabled = false
                btnProceed.isSelected = false
                imgLogo.image = UIImage(named: ImageNames.disabledLogo.rawValue)
                return
        }
        btnProceed.isEnabled = true
        imgLogo.image = UIImage(named: ImageNames.enabledLogo.rawValue)
        btnProceed.isSelected = true
    }
}
