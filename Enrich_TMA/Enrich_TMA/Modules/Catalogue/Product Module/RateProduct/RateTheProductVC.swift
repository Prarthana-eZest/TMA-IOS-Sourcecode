//
//  RateTheServiceListViewController.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 25/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit
import Cosmos


protocol RateTheProductModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
    
}
class RateTheProductVC: UIViewController,RateTheProductModuleDisplayLogic {

    var interactor: RateTheProductModuleBusinessLogic?
    @IBOutlet weak private var ratingView: CosmosView!
    @IBOutlet weak private var productImage: UIImageView!
    @IBOutlet weak var lblProductName: UILabel!
    var productImageURL: String = ""
    var product_id: Int64 = 0
    @IBOutlet weak var txtfSuggestion: UITextField!

    var onDoneBlock: ((Bool) -> Void)?
    
    
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
        let interactor = RateTheProductModuleInteractor()
        let presenter = RateTheProductModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if !productImageURL.isEmpty {
            let url = URL(string: productImageURL)
            productImage.kf.setImage(with: url, placeholder: UIImage(named: "productDefault"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        KeyboardAnimation.sharedInstance.beginKeyboardObservation(self.view)
        KeyboardAnimation.sharedInstance.extraBottomSpace = 50
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        KeyboardAnimation.sharedInstance.endKeyboardObservation()
    }

    @IBAction func actionClose(_ sender: Any) {
        onDoneBlock!(false)
        self.dismiss(animated: false, completion: nil)

    }
    @IBAction func actionSubmit(_ sender: Any) {
        callRateTheProduct()

    }

}

extension RateTheProductVC:UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Call Webservice
extension RateTheProductVC {

    func callRateTheProduct() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        let request = RateTheProductModule.RateTheProduct.Request.init(product_id: product_id, rating: ratingView.rating, summary: self.txtfSuggestion.text ?? "", message: self.txtfSuggestion.text ?? "") // For Product Summary and Message is same not for rateservice both would be different as per user entered
        interactor?.doPostRateTheProduct(request: request, accessToken: self.isuserLoggedIn().accessToken )

    }

    func displaySuccess<T: Decodable>(viewModel: T) {

        DispatchQueue.main.async { [unowned self] in
            if T.self == RateTheProductModule.RateTheProduct.Response.self {

                let obj = viewModel as? RateTheProductModule.RateTheProduct.Response
                if(obj?.status == true) {
                    self.onDoneBlock!(true)
                    self.showToast(alertTitle: alertTitle, message: obj?.message ?? "", seconds: toastMessageDuration)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                        self.dismiss(animated: false, completion: nil)
                    }

                } else {
                    self.showToast(alertTitle: alertTitle, message: obj?.message ?? "", seconds: toastMessageDuration)
                }

            }
        }
        EZLoadingActivity.hide()
    }
    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage!)

    }
    func displaySuccess<T>(responseSuccess: [T]) where T: Decodable {

    }
}




