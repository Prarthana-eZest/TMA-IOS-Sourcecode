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
    @IBOutlet weak private var txtFUserName: CustomTextField!
    @IBOutlet weak private var btnProceed: UIButton!

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
        super.viewWillAppear(animated)
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.addCustomBackButton(title: "")
        KeyboardAnimation.sharedInstance.beginKeyboardObservation(self.view)
        self.txtFUserName.text = ""
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideKeyboard()
        KeyboardAnimation.sharedInstance.endKeyboardObservation()
    }
    // MARK: initialSetUp
    func initialSetUp() {
        hideKeyboardWhenTappedAround()
        btnProceed.isEnabled = false
        title = "Login"
        [txtFUserName].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
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
        txtFUserName.resignFirstResponder()
        connectToServerForMobileOTP(userName: txtFUserName.text ?? "")
    }

    @IBAction func actionBackToLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: Call Webservice
extension LoginOTPModuleVC {

    func connectToServerForMobileOTP(userName: String) {
        EZLoadingActivity.show("Loading...", disableUI: true)

        let request = LoginOTPModule.OTP.Request(username: userName)
        interactor?.doPostRequest(request: request, method: HTTPMethod.post)
    }

    func displaySuccessLoginOTPModule<T: Decodable>(viewModel: T) {
        EZLoadingActivity.hide(true, animated: false)

        if delegate != nil {
            delegate?.displaySuccessLoginOTPModule(viewModel: viewModel)
            return
        }

       if let obj = viewModel as? LoginOTPModule.OTP.Response {

            if obj.status == true {
                let vc = OTPVerificationModuleVC.instantiate(fromAppStoryboard: .Login)
                vc.userName = txtFUserName.text ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
            showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "")
        }
    }

    func displayErrorLoginOTPModule(errorMessage: String?) {
        EZLoadingActivity.hide()
        if delegate != nil {
            delegate?.displayErrorLoginOTPModule(errorMessage: errorMessage)
            return
        }
        showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
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

        let text = (txtFUserName.text ?? "").trim()

        if !text.isEmpty {
            btnProceed.isEnabled = true
            imgLogo.image = UIImage(named: ImageNames.enabledLogo.rawValue)
            btnProceed.isSelected = true
        }
    }
}
