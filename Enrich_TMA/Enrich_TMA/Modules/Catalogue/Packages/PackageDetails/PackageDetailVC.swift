//
//  PackageDetailVC.swift
//  EnrichSalon
//
//  Created by Mugdha Mundhe on 07/11/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol PackageDetailModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
}

class PackageDetailVC: UIViewController {

    @IBOutlet weak var tblOfferDetails: UITableView!
    private var interactor: PackageDetailModuleBusinessLogic?

    var modelObj: PackageListing.OffersValuePackages.Package_listValues?

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
        let interactor = PackageDetailModuleInteractor()
        let presenter = PackageDetailModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.navigationBar.isHidden = false
        self.title = ""
        self.navigationController?.addCustomBackButton(title: "Packages")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func actionAddToCart(_ sender: Any) {

    }

}

extension PackageDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PackageDetailTableViewCell", for: indexPath) as? PackageDetailTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        if let model = modelObj {
            cell.configureCell(hideAndShowServiceIncludes: model.package_type_cma == ValuePackageTypes.valuePackage ?  true : false, model: model)

        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension PackageDetailVC: PackageDetailDelegate {
    func openOfferStores() {
        if let model = modelObj, let salon_data = model.salon_data, !salon_data.isEmpty {
            if let customView = ShowListingView(frame: self.view.frame).loadNib() as? ShowListingView {
                customView.setupUIInit(arrShowData: salon_data, frameObj: self.view.frame)
                UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(customView)
            }
        }
        else {
            self.showToast(alertTitle: alertTitle, message: AlertMessagesToAsk.packageApplicable, seconds: toastMessageDuration)
        }

    }

}

// Web Service response delegates
extension PackageDetailVC: PackageDetailModuleDisplayLogic {

    func displaySuccess<T: Decodable> (viewModel: T) {
        EZLoadingActivity.hide()
    }

    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage!)
    }
    func displaySuccess<T: Decodable>(responseSuccess: [T]) {

    }

}
