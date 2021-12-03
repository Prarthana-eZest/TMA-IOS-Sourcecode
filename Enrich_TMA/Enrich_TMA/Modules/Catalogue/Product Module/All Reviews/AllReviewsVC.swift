//
//  AllReviewsVC.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 19/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol AllReviewsModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
}
class AllReviewsVC: UIViewController {

    var interactor: AllReviewsModuleBusinessLogic?
    var serverDataProductReviews = [ServiceDetailModule.ServiceDetails.ReviewItem]() // ProductReviewResponse

    @IBOutlet weak private var tableView: UITableView!
    var productId: String = ""

    // Variables for Laod More Data Start
    var totalLoadedRecord: Int64 = 0
    var recordsPerPage: Int64 = 0
    var pageNumber: Int = 0
    // Variables for Laod More Data End

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
        let interactor = AllReviewsModuleInteractor()
        let presenter = AllReviewsModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: CellIdentifier.reviewThumpsUpDownCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.reviewThumpsUpDownCell)
        addSOSButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.addCustomBackButton(title: "All Ratings & Reviews")
        self.tableView.separatorColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setObject()
        callProductReviewsAPI()
    }

    func addSOSButton() {
        guard let sosImg = UIImage(named: "SOS") else {
            return
        }
        let sosButton = UIBarButtonItem(image: sosImg, style: .plain, target: self, action: #selector(didTapSOSButton))
        sosButton.tintColor = UIColor.black
        navigationItem.title = ""
        if showSOS {
            navigationItem.rightBarButtonItems = [sosButton]
        }
    }

    @objc func didTapSOSButton() {
        SOSFactory.shared.raiseSOSRequest()
    }

    @IBAction func actionSortReviews(_ sender: UIButton) {
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}

extension AllReviewsVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if serverDataProductReviews.isEmpty {
            tableView.setEmptyMessage(TableViewNoData.tableViewNoReviewsAvailable)
            return 0
        }
        else {
            tableView.restore()
            return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverDataProductReviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.reviewThumpsUpDownCell, for: indexPath) as? ReviewThumpsUpDownCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        setValuesForCutomerFeedBack(indexPath: indexPath, cell: cell)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if indexPath.row == totalLoadedRecord - 1 {
           loadMoreTableData()
        }

    }
    func setValuesForCutomerFeedBack(indexPath: IndexPath, cell: ReviewThumpsUpDownCell) {

        let model = serverDataProductReviews[indexPath.row]
        cell.lblCustomerComments.text = model.detail ?? ""
        cell.lblcustomerName.text = String(format: "- %@ | %@%@ %@", model.nickname ?? "", (model.created_at ?? "").getFormattedDate().dayDateName, (model.created_at ?? "").getFormattedDate().daySuffix(), (model.created_at ?? "").getFormattedDate().monthNameAndYear)
        cell.lblRating.text = String(format: "%@/5", ((model.rating_votes?.first?.percent ?? 0.0) / 100 * 5).cleanForRating)

    }

}

extension AllReviewsVC { // Pagination Methods
    // MARK: - Methods for Pagination Start
    func setObject() {
        totalLoadedRecord = 0
        recordsPerPage = maxlimitToReviewProducts
        pageNumber = 1
    }

    func setProductReviewsDataModel (obj: ServiceDetailModule.ServiceDetails.ProductReviewResponse) {

        if pageNumber == 1 {
            if let reviewitems = obj.data?.review_items, !reviewitems.isEmpty {
                self.serverDataProductReviews = reviewitems
            }
        }
        else {
        if let reviewitems = obj.data?.review_items, !reviewitems.isEmpty {
            let newDataFromServer: [ServiceDetailModule.ServiceDetails.ReviewItem] = reviewitems
            var originalArray: [ServiceDetailModule.ServiceDetails.ReviewItem] = self.serverDataProductReviews
            originalArray.append(contentsOf: newDataFromServer)
            self.serverDataProductReviews.removeAll()
            self.serverDataProductReviews = originalArray
        }
        }
        self.updateRecordInfo()
        self.tableView.reloadData()

    }

    func updateRecordInfo() {

        if pageNumber == 1 {
            pageNumber = 2
            totalLoadedRecord = recordsPerPage
        }
        else {
            totalLoadedRecord += recordsPerPage
            pageNumber += 1
        }
    }
    // MARK: - Methods for Pagination End
    func loadMoreTableData() {
        callProductReviewsAPI()
    }
}

extension AllReviewsVC: AllReviewsModuleDisplayLogic {
    // MARK: Call Webservice
    func callProductReviewsAPI() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        let request = ServiceDetailModule.ServiceDetails.ProductReviewRequest(product_id: productId, limit: recordsPerPage, page: pageNumber)
        interactor?.doPostRequestProductReviews(request: request, method: HTTPMethod.post)
    }

    func displaySuccess<T: Decodable>(viewModel: T) {

        DispatchQueue.main.async {[unowned self] in

            if T.self == ServiceDetailModule.ServiceDetails.ProductReviewResponse.self {
                // Products Reviews
                if let obj = viewModel as? ServiceDetailModule.ServiceDetails.ProductReviewResponse {
                if obj.status == true {
                    self.setProductReviewsDataModel(obj: obj)

                }
                else {
                    self.showAlert(alertTitle: alertTitle, alertMessage: obj.message ?? "" )
                }
                }
            }
            EZLoadingActivity.hide()

        }
    }
    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        DispatchQueue.main.async { [unowned self] in
            self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
        }

    }

    func displaySuccess<T: Decodable>(responseSuccess: [T]) {
//        DispatchQueue.main.async {
//            var obj = [AllReviewsModule.Something.Response]()
//            obj = responseSuccess as! [AllReviewsModule.Something.Response]
//            print("Get API Response -- \n \(obj)")
//        }
    }
}
