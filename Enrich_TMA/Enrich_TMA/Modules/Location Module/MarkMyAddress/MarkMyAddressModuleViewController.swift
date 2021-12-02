//
//  MarkMyAddressModuleViewController.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit
protocol MarkMyAddressModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
}

protocol SuccessPreferredSaloneDelegate: class {
    func displaySuccess()
    func displayCancel()

}

class MarkMyAddressModuleViewController: UIViewController, MarkMyAddressModuleDisplayLogic {

    var interactor: MarkMyAddressModuleBusinessLogic?
    var modelForUpdate: LocationModule.Something.SalonParamModel?

    var delegate: SuccessPreferredSaloneDelegate?

    @IBOutlet weak private var txtFieldOtherNameYourFavourite: CustomTextField!
    @IBOutlet weak private var lblOtherExample: UILabel!
    @IBOutlet weak private var btnHome: UIButton!
    @IBOutlet weak private var btnWorkPlace: UIButton!
    @IBOutlet weak private var btnOther: UIButton!
    @IBOutlet weak private var lblSalonName: UILabel!
    @IBOutlet weak private var lblSalonAddress: UILabel!
    @IBOutlet weak private var lblSalonDistance: UILabel!
    @IBOutlet weak private var btnSave: UIButton!

    weak var controllerfromDismiss: UIViewController?

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
        let interactor = MarkMyAddressModuleInteractor()
        let presenter = MarkMyAddressModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController

    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        addKeyboardChangeFrameObserver(willShow: { [weak self](height) in
            //Update constraints here
            self!.view.frame.origin.y -= height
            self?.view.setNeedsUpdateConstraints()
            }, willHide: { [weak self](height) in
                //Reset constraints here
                self!.view.frame.origin.y += height
                self?.view.setNeedsUpdateConstraints()
        })
        setUIData()
    }

    func setUIData() {

        [txtFieldOtherNameYourFavourite].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })

        if let modelObj = modelForUpdate {
            self.lblSalonName.text = modelObj.salon_name
            self.lblSalonAddress.text = (modelObj.address_1 ?? "") + "\n" + (modelObj.address_2 ?? "")
            self.lblSalonDistance.text = "\(modelObj.distance.rounded())" + " km from your location"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.addCustomBackButton(title: "")

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }

    override func viewWillLayoutSubviews() {
        lblSalonName.sizeToFit()
        lblSalonAddress.sizeToFit()
    }

    // MARK: IBActions
    @IBAction func clickToHome(_ sender: Any) {
        hideOthersOptions()
        self.btnHome.isSelected = true
        self.btnWorkPlace.isSelected = false
        self.btnOther.isSelected = false
        self.btnSave.isSelected = true
        self.btnSave.isEnabled = true

    }

    @IBAction func clickToWorkPlace(_ sender: Any) {
        hideOthersOptions()
        self.btnWorkPlace.isSelected = true
        self.btnHome.isSelected = false
        self.btnOther.isSelected = false
        self.btnSave.isSelected = true
        self.btnSave.isEnabled = true

    }
    @IBAction func clickToOther(_ sender: Any) {
        unHideOthersOptions()
        self.btnOther.isSelected = true
        self.btnWorkPlace.isSelected = false
        self.btnHome.isSelected = false

        if txtFieldOtherNameYourFavourite.text?.count == 1 {
            if txtFieldOtherNameYourFavourite.text?.first == " " {
                txtFieldOtherNameYourFavourite.text = ""
                return
            }
        }
        guard
            let referalCode = self.txtFieldOtherNameYourFavourite.text, !referalCode.isEmpty
            else {
                self.btnSave.isEnabled = false
                self.btnSave.isSelected = false
                return
        }
        self.btnSave.isEnabled = true
        self.btnSave.isSelected = true

    }
    @IBAction func clickToCancel(_ sender: Any) {
        delegate!.displayCancel()
        self.txtFieldOtherNameYourFavourite.resignFirstResponder()
        self.controllerfromDismiss?.view.alpha = 1.0
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func clickToSave(_ sender: Any) {
        self.doSomething()
    }

    // MARK: Hide And UnHide Other section
    func hideOthersOptions() {
        lblOtherExample.isHidden = true
        txtFieldOtherNameYourFavourite.isHidden = true

    }
    func unHideOthersOptions() {
        lblOtherExample.isHidden = false
        txtFieldOtherNameYourFavourite.isHidden = false
    }

    // MARK: Call Webservice
    func doSomething() {
        let strType = btnHome.isSelected ? TypeOfPlace.home.rawValue : ((btnWorkPlace.isSelected ? TypeOfPlace.workplace.rawValue : (btnOther.isSelected ? TypeOfPlace.other.rawValue : "" )))
        let strOther = btnOther.isSelected ? txtFieldOtherNameYourFavourite.text! : ""

        let request = MarkMyAddressModule.Something.Request(customer_id: isuserLoggedIn().customerId, salon_id: (modelForUpdate?.salon_id)!, type: strType, other_name: strOther, is_custom: true)

        interactor?.doPostRequest(request: request, method: HTTPMethod.post)
    }

    func displaySuccess<T: Decodable>(viewModel: T) {
        delegate?.displaySuccess()
        self.txtFieldOtherNameYourFavourite.resignFirstResponder()
        self.controllerfromDismiss?.view.alpha = 1.0
        self.dismiss(animated: true, completion: nil)
    }

    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        DispatchQueue.main.async { [unowned self] in
            self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
        }
    }

    func displaySuccess<T: Decodable>(responseSuccess: [T]) {
        delegate?.displaySuccess()
        self.txtFieldOtherNameYourFavourite.resignFirstResponder()
        self.controllerfromDismiss?.view.alpha = 1.0
        self.dismiss(animated: true, completion: nil)
    }
}
extension MarkMyAddressModuleViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension MarkMyAddressModuleViewController {
    @objc func editingChanged(_ textField: UITextField) {
        self.btnSave.isEnabled = false
        self.btnSave.isSelected = false

        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let referalCode = self.txtFieldOtherNameYourFavourite.text?.trim(), !referalCode.isEmpty
            else {
                self.btnSave.isEnabled = false
                self.btnSave.isSelected = false

                return
        }
        self.btnSave.isEnabled = true
        self.btnSave.isSelected = true

    }
}
