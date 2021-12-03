//
//  OTPVerificationModuleViewController.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit
protocol OTPVerificationModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
}

class OTPVerificationModuleVC: DesignableViewController, OTPVerificationModuleDisplayLogic {

    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var txtFieldOTP: CustomTextField!
    @IBOutlet weak private var txtFNewPassword: CustomTextField!
    @IBOutlet weak private var txtFConfirmPassword: CustomTextField!

    @IBOutlet weak private var lblOTPTimer: UILabel!
    @IBOutlet weak private var btnResendCode: UIButton!
    @IBOutlet weak private var btnSubmit: UIButton!
    @IBOutlet weak private var imgViewLogo: UIImageView!

    private  var loginOTPModuleViewController: LoginOTPModuleVC?

    //Timer Variables
    weak var countdownTimer: Timer!
    var totalTime = 60
    var userName = ""

    var interactor: OTPVerificationModuleBusinessLogic?

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
        let interactor = OTPVerificationModuleInteractor()
        let presenter = OTPVerificationModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "OTP Verification"
        hideKeyboardWhenTappedAround()
        startTimer()
        [txtFieldOTP, txtFNewPassword, txtFConfirmPassword].forEach({
            $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        txtFieldOTP.delegate = self
        txtFNewPassword.delegate = self
        txtFConfirmPassword.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserFactory.shared.checkForSignOut()
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait,
                                         andRotateTo: UIInterfaceOrientation.portrait)
        navigationController?.addCustomBackButton(title: "")
        KeyboardAnimation.sharedInstance.beginKeyboardObservation(self.view)
        clearData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideKeyboard()
        KeyboardAnimation.sharedInstance.endKeyboardObservation()
    }

    func clearData() {
        self.txtFieldOTP.text = ""
        self.txtFNewPassword.text = ""
        self.txtFConfirmPassword.text = ""
    }

    // MARK: IBActions

    @IBAction func clickResendCode(_ sender: Any) {
        startTimer()
        connectToResendOTPForLogin()
    }

    @IBAction func clickToSubmit(_ sender: Any) {
        txtFieldOTP.resignFirstResponder()
        connectToServerForOTPVerification()
    }

    // MARK: PassData

    // MARK: Call Webservice
    func connectToServerForOTPVerification() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        let request =
            OTPVerificationModule.ChangePasswordWithOTPVerification.Request(username: userName,
                                                                            otp: txtFieldOTP.text ?? "",
                                                                            password: txtFConfirmPassword.text ?? "",
                                                                            confirm_password: txtFConfirmPassword.text ?? "")
        interactor?.doPostRequest(request: request, method: HTTPMethod.post,
                                  endPoint: ConstantAPINames.forgotPassword.rawValue)

    }

    func displaySuccess<T: Decodable>(viewModel: T) {
        EZLoadingActivity.hide()

        if let model = viewModel as? OTPVerificationModule.ChangePasswordWithOTPVerification.Response {
            if model.status == true {
                self.navigationController?.popToRootViewController(animated: true)
            }
            showAlert(alertTitle: alertTitle, alertMessage: model.message ?? "")
        }

    }

    func displayError(errorMessage: String?) {
        DispatchQueue.main.async { [unowned self] in
            EZLoadingActivity.hide()
            self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
        }
    }
}

extension OTPVerificationModuleVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

extension OTPVerificationModuleVC {
    @objc func editingChanged(_ textField: UITextField) {
        btnSubmit.isEnabled = false
        btnSubmit.isSelected = true
        imgViewLogo.image = UIImage(named: ImageNames.disabledLogo.rawValue)
        let otp = (txtFieldOTP.text ?? "").trim()
        let password = (txtFNewPassword.text ?? "").trim()
        let confirmPassword = (txtFConfirmPassword.text ?? "").trim()

        if otp.count >= 4,
            !password.isEmpty,
            !confirmPassword.isEmpty {
            btnSubmit.isEnabled = true
            btnSubmit.isSelected = true
            imgViewLogo.image = UIImage(named: ImageNames.enabledLogo.rawValue)
        }
    }
}

extension OTPVerificationModuleVC {
    // MARK: Timer
    func startTimer() {
        btnResendCode.isUserInteractionEnabled = false
        btnResendCode.setTitleColor(UIColor.lightGray, for: .normal)
        lblOTPTimer.text = "0:00 sec"
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    @objc func updateTime() {
        lblOTPTimer.text = "\(timeFormatted(totalTime))"
        if totalTime != 0 {
            totalTime -= 1

        }
        else {
            endTimer()
        }
    }
    func endTimer() {
        lblOTPTimer.text = "0:00 sec"
        countdownTimer.invalidate()
        totalTime = 60
        btnResendCode.isUserInteractionEnabled = true
        btnResendCode.setTitleColor(UIColor.black, for: .normal)
    }

    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%01d:%02d secs", minutes, seconds)
    }
}

// MARK: This is for when user comes from Login Screen and ask for resend OTP
extension OTPVerificationModuleVC: LoginOTPModuleDisplayLogic {
    func connectToResendOTPForLogin() {
        loginOTPModuleViewController = LoginOTPModuleVC()
        loginOTPModuleViewController?.delegate = self
        loginOTPModuleViewController?.connectToServerForMobileOTP(userName: userName)
    }
    func displaySuccessLoginOTPModule<T>(viewModel: T) where T: Decodable {

        if let model = viewModel as? LoginOTPModule.OTP.Response {
            clearData()
            self.showAlert(alertTitle: alertTitle, alertMessage: model.message ?? "OTP sent successfully")
        }
    }

    func displayErrorLoginOTPModule(errorMessage: String?) {
        showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
    }

    func displaySuccessLoginOTPModule<T>(responseSuccess: [T]) where T: Decodable {
    }
}
