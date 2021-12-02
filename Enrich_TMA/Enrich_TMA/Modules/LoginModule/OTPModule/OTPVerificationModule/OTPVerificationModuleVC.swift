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
protocol OTPVerificationModuleDisplayLogic: class
{
    func displaySuccess<T:Decodable> (viewModel: T)
    func displayError(errorMessage:String?)
}

class OTPVerificationModuleVC: DesignableViewController, OTPVerificationModuleDisplayLogic
{
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var txtFieldOTP: CustomTextField!
    @IBOutlet weak var lblOTPTimer: UILabel!
    @IBOutlet weak var lblMobileNumber: UILabel!
    @IBOutlet weak var btnResendCode: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var imgViewLogo: UIImageView!
    
    private  var userFirstName:String?
    private  var userLastName:String?
    private  var userMobileNumber:String?
    private  var userGender:Int = 2
    private  var userEmailFacebookOrGoogle:String?
    private  var userReferalCode:String?
    private  var userOTPCode:String?
    private  var userOtherInclinedGender:String?
    private  var userCountryCode:String?
    
    private  var loginOTPModuleViewController:LoginOTPModuleVC?

    //Timer Variables
    weak var countdownTimer: Timer!
    var totalTime = 45
    
    var interactor: OTPVerificationModuleBusinessLogic?

    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = OTPVerificationModuleInteractor()
        let presenter = OTPVerificationModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    


    // MARK: View lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "OTP Verification"
        hideKeyboardWhenTappedAround()
          lblMobileNumber.text =  (  userCountryCode ?? "") +   userMobileNumber!
          startTimer()
          txtFieldOTP.defaultTextAttributes.updateValue(10.0,
                                                    forKey: NSAttributedString.Key.kern)
        var padding: UIEdgeInsets {
                    get {
                        return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
                    }
                }
          txtFieldOTP.bounds.inset(by: padding)
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.OrientationLock.lock(to:UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
          navigationController?.addCustomBackButton(title: "")

    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideKeyboard()
    }
    
    
    //MARK: IBActions
    @IBAction func clickToChangeMobileNumber(_ sender: Any) {
          navigationController?.popViewController(animated: true)
    }
    @IBAction func clickResendCode(_ sender: Any) {
        
          startTimer()
//        guard let nc =   navigationController else { return }
//        let exists = nc.containsViewController(ofKind: UserNameViewController.self)
//
//        if exists // This Condition is for user coming for registration
//        {connectToResendOTPForSignUp()}
//        else // This Condition is for user coming for login
//        {connectToResendOTPForLogin()}
    }
    
    @IBAction func clickToSubmit(_ sender: Any) {
          txtFieldOTP.resignFirstResponder()
        connectToServerForOTPVerification()
    }
    
    //MARK : PassData
    func passData(firstName:String,lastName:String,gender:Int,mobileNumber:String,userFaceBookOrGoogleEmail:String,referalCode:String,OTPCode:String,otherInclinedGender:String,countryCode:String)
    {
          userFirstName = firstName
          userLastName = lastName
          userMobileNumber = mobileNumber
          userGender = gender
          userEmailFacebookOrGoogle = userFaceBookOrGoogleEmail
          userReferalCode =  referalCode
          userOTPCode = OTPCode
          userOtherInclinedGender = otherInclinedGender
          userCountryCode = countryCode
    }
    
    
    //MARK: Call Webservice
    func connectToServerForOTPVerification()
    {
        
        guard let nc =   navigationController else { return }
//         let dummy = UserDefaults.standard.value(MobileNumberModule.MobileNumberModuleForOTP.Response.self, forKey: UserDefauiltsKeys.k_Key_LoginUserOTPDetails)
//
//
//        else // This Condition is for user coming for login
//        {
//            if(  txtFieldOTP.text == dummy?.data?.otpcode )
//            {
//                 EZLoadingActivity.show("Loading...", disableUI: true)
//                let request = OTPVerificationModule.MobileNumberWithOTPVerification.Request(otp:  txtFieldOTP.text ?? "", mobile_number:   userMobileNumber ?? "")
//                interactor?.doPostRequest(request: request,method:HTTPMethod.post,endPoint:ConstantAPINames.validateOTPOnLogin.rawValue)
//            }
//            else
//            {
//                  showAlert(alertTitle: alertTitle, alertMessage: "OTP does not match.")
//
//            }
//        }
//
    }
    
    func connectToServerForMergeRequestIfAnyForCart()
    {
        if let object  = UserDefaults.standard.value(ProductDetailsModule.GetQuoteIDGuest.Response.self, forKey: UserDefauiltsKeys.k_key_GuestQuoteIdForCart){

        EZLoadingActivity.show("Loading...", disableUI: true)
            let request = ProductDetailsModule.MergeGuestCart.Request.init(cartId:object.data?.quote_id ?? "", customer_id: GenericClass.sharedInstance.getCustomerId().toString, storeId: 1) // Static Store ID
            interactor?.doPutRequestForMergeRequest(request: request, method: HTTPMethod.put,accessToken: isuserLoggedIn().accessToken)
        }
        
    }
    
    
    func displaySuccess<T:Decodable>(viewModel: T)
    {
        if T.self == OTPVerificationModule.MobileNumberWithOTPVerification.Response.self{
            let obj :OTPVerificationModule.MobileNumberWithOTPVerification.Response = viewModel as! OTPVerificationModule.MobileNumberWithOTPVerification.Response
            
            if(obj.status == true)
            {
                UserDefaults.standard.set(encodable:obj, forKey: UserDefauiltsKeys.k_Key_LoginUserSignIn)
                if UserDefaults.standard.value(ProductDetailsModule.GetQuoteIDGuest.Response.self, forKey: UserDefauiltsKeys.k_key_GuestQuoteIdForCart) != nil{
                    
                connectToServerForMergeRequestIfAnyForCart()
                }
                else // This is when we dont have GuestQuoteid and we need to dismissLoginView
                {
                    navigationController?.dismiss(animated: true, completion: nil)
                }
            }
            else
            {
                showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "")
                
            }
            EZLoadingActivity.hide()

        }
        else if T.self == ProductDetailsModule.MergeGuestCart.Response.self{
            let obj :ProductDetailsModule.MergeGuestCart.Response = viewModel as! ProductDetailsModule.MergeGuestCart.Response
            
            if(obj.status == true)
            {
                UserDefaults.standard.removeObject(forKey: UserDefauiltsKeys.k_key_GuestQuoteIdForCart)
                navigationController?.dismiss(animated: false, completion: nil)// This is when we  have GuestQuoteid and after succes of GuestQuoteidMergeRequest we need to dismissLoginView
            }
            else
            {
                showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "")
            }
            EZLoadingActivity.hide()
        }
    }

    func displayError(errorMessage:String?)
    {
        DispatchQueue.main.async { [unowned self] in
            EZLoadingActivity.hide()
              self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
            EZLoadingActivity.hide()
        }
    }
}

extension OTPVerificationModuleVC:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool  {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let s = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        guard !s.isEmpty else {

            return true }
        if(s.count >= 4)
        {
              btnSubmit.isEnabled = true
              btnSubmit.isSelected = true
              imgViewLogo.image = UIImage(named: "OTPVerificationLogoSelected")
        }
        else
        {
              btnSubmit.isEnabled = false
              btnSubmit.isSelected = false
              imgViewLogo.image = UIImage(named: "OTPVerificationLogoUnselected")

        }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        return numberFormatter.number(from: s)?.intValue != nil
    }
}

extension OTPVerificationModuleVC
{
    //MARK: Timer
    func startTimer() {
          btnResendCode.isUserInteractionEnabled = false
          lblOTPTimer.text = "0:00 sec"
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    @objc func updateTime() {
          lblOTPTimer.text = "\(timeFormatted(totalTime))"
        if totalTime != 0 {
            totalTime -= 1
           
        } else {
            endTimer()
        }
    }
    func endTimer() {
          lblOTPTimer.text = "0:00 sec"
        countdownTimer.invalidate()
        totalTime = 45
          btnResendCode.isUserInteractionEnabled = true
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%01d:%02d secs", minutes, seconds)
    }
}


//MARK: This is for when user comes from Login Screen and ask for resend OTP
extension OTPVerificationModuleVC:LoginOTPModuleDisplayLogic
{
    func connectToResendOTPForLogin()
    {
        loginOTPModuleViewController = LoginOTPModuleVC()
        loginOTPModuleViewController?.delegate = self
       // let finalMobileNumberWithCountryCode = (  userCountryCode ?? "") +   userMobileNumber!
        loginOTPModuleViewController?.connectToServerForMobileOTP(mobileNumber:   userMobileNumber!)
    }
    func displaySuccessLoginOTPModule<T>(viewModel: T) where T : Decodable {
        let obj :LoginOTPModule.OTP.Response = viewModel as! LoginOTPModule.OTP.Response
        if(obj.status == true)
        {
            UserDefaults.standard.set(encodable: obj, forKey: UserDefauiltsKeys.k_Key_LoginUserOTPDetails)
              userOTPCode = obj.data?.otpcode ?? ""
        }
    }
    
    func displayErrorLoginOTPModule(errorMessage: String?) {
          showAlert(alertTitle: alertTitle, alertMessage: errorMessage!)
    }
    
    func displaySuccessLoginOTPModule<T>(responseSuccess: [T]) where T : Decodable {
    }
}
