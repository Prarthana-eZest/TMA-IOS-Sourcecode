//
//  CustomerDetailsVC.swift
//  Enrich_TMA
//
//  Created by Harshal on 31/03/20.
//  Copyright © 2020 e-zest. All rights reserved.
//

import UIKit

class CustomerDetailsVC: UIViewController, ClientInformationDisplayLogic {

    var interactor: ClientInformationBusinessLogic?

    @IBOutlet weak private var tableView: UITableView!

    @IBOutlet weak private var lblRatings: UILabel!
    @IBOutlet weak private var profilePicture: UIImageView!
    @IBOutlet weak private var lblUserName: UILabel!
    @IBOutlet weak private var membershipIcon: UIImageView!
    @IBOutlet weak private var lblMembershipType: UILabel!
    @IBOutlet weak private var highSpendingIcon: UIImageView!
    @IBOutlet weak private var lblLastVisit: UILabel!

    @IBOutlet weak private var dividerView: UIView!
    @IBOutlet weak private var stackViewMemAndHighS: UIStackView!

    @IBOutlet weak var lblMobileNo: UILabel!
    @IBOutlet weak var lblEmailId: UILabel!
    @IBOutlet weak var lblAddress: UILabel!

    var customerDetails: MyCustomers.GetCustomers.Customer?
    var services = [ServiceDetailsModel]()

    var activeSort: SortBy?
    var sortOrder = 0

    var page_no = 1
    var limit = 100

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
        let interactor = ClientInformationInteractor()
        let presenter = ClientInformationPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        tableView.register(UINib(nibName: CellIdentifier.myCustomersHeaderCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.myCustomersHeaderCell)
        tableView.register(UINib(nibName: CellIdentifier.myCustomerCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.myCustomerCell)

        tableView.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)

        configureUI()
        addSOSButton()
        getAppointmentHistory()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.addCustomBackButton(title: "Customer Details")
        KeyboardAnimation.sharedInstance.beginKeyboardObservation(self.view)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardAnimation.sharedInstance.endKeyboardObservation()
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

    func configureUI() {

        guard let data = customerDetails else {
            return
        }

        lblMobileNo.text = data.mobile_number.masked(6)
        lblEmailId.text = data.email ?? ""

        var addressString = ["\(data.address?.street ?? "" )",
            "\(data.address?.city ?? "" )",
            "\(data.address?.region ?? "" )",
            "\(data.address?.country ?? "" )"]
        addressString.removeAll(where: {$0.isEmpty})
        let address = addressString.joined(separator: ", ")
        lblAddress.text = address

        let name = "\(data.firstname) \(data.lastname)"
        lblUserName.text = name.capitalized
        lblLastVisit.text = ""
        let ratingText = data.ratings?.description.toDouble() ?? 0
        let rating = ratingText.cleanForRating
        lblRatings.text = "\(rating)/5"

        profilePicture.layer.cornerRadius = profilePicture.frame.size.height * 0.5
        profilePicture.kf.indicatorType = .activity

        let defaultImage = UIImage(named: "defaultProfile")
        if let url = data.profile_pic,
            let imageurl = URL(string: url) {
            profilePicture.kf.setImage(with: imageurl, placeholder: defaultImage, options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            profilePicture.image = defaultImage
        }

       // Memebership

        var isMember = false
        dividerView.isHidden = true
        stackViewMemAndHighS.isHidden = false

        if let membership = data.membership, !membership.isEmpty,
            let iconImage = data.membership_default_image, !iconImage.isEmpty,
            let imageurl = URL(string: iconImage) {
                isMember = true
            membershipIcon.kf.setImage(with: imageurl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
            lblMembershipType.text = data.membership ?? ""
        }

        membershipIcon.isHidden = !isMember
        lblMembershipType.isHidden = !isMember

        if let highSpending = data.high_expensive, highSpending == true {
            highSpendingIcon.isHidden = false
        }
        else {
            highSpendingIcon.isHidden = true
            if !isMember {
                stackViewMemAndHighS.isHidden = true
            }
        }

    }

}

extension CustomerDetailsVC: MyCustomersHeaderDelegate {

    func actionSort(sortBy: SortBy, sortOrder: Int) {

        self.activeSort = sortBy
        self.sortOrder = sortOrder

        switch sortBy {

        case .serviceName:
            services.sort {
                if sortOrder == 0 {
                    return $0.name < $1.name
                }
                return $0.name > $1.name
            }

        case .date:
            services.sort {
                if sortOrder == 0 {
                    return ($0.date.getDateFromString() ?? Date()) < ($1.date.getDateFromString() ?? Date())
                }
                return ($0.date.getDateFromString() ?? Date()) > ($1.date.getDateFromString() ?? Date())
            }

        case .salon:
            services.sort {
                if sortOrder == 0 {
                    return $0.salon < $1.salon
                }
                return $0.salon > $1.salon
            }

        default:
            break
        }

        self.tableView.reloadData()
    }

}

extension CustomerDetailsVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return services.isEmpty ? 0 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.myCustomerCell, for: indexPath) as? MyCustomerCell else {
            return UITableViewCell()
        }
        let serviceData = services[indexPath.row]
        cell.configureServiceDetailsCell(model: serviceData)
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.myCustomersHeaderCell) as? MyCustomersHeaderCell else {
            return UITableViewCell()
        }
        cell.configureCell(headerType: .Services, activeSort: activeSort, sortOrder: sortOrder)
        cell.delegate = self
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension CustomerDetailsVC {

    func getAppointmentHistory() {

        if let customerId = customerDetails?.id,
            let userData = UserDefaults.standard.value(MyProfile.GetUserProfile.UserData.self, forKey: UserDefauiltsKeys.k_Key_LoginUser) {

            EZLoadingActivity.show("Loading...", disableUI: true)

            let request = Schedule.GetAppointnents.AppointnentHistoryRequest(
                salon_code: userData.base_salon_code ?? "",
                customer_id: customerId,
                limit: limit, page_no: page_no)
            interactor?.doGetAppointmentHistory(request: request, method: .post)
        }
    }

    func displaySuccess<T>(viewModel: T) where T: Decodable {
        EZLoadingActivity.hide()
        print("Response: \(viewModel)")

        if let model = viewModel as? Schedule.GetAppointnents.Response,
            let data = model.data {
            self.services.removeAll()
            var appointments = data
            appointments.sort {return ($0.appointment_date ?? "") > ($1.appointment_date ?? "")}

            if let dateString = appointments.first?.appointment_date,
                let date = dateString.getDateFromString() {
                lblLastVisit.text = date.dayNameDateFormat
            }
            else {
                lblLastVisit.text = ""
            }

            appointments.forEach { appointment in
                if let services = appointment.services {
                    services.forEach { service in
                        if let dateString = appointment.appointment_date {
                            let model = ServiceDetailsModel(
                                name: service.service_name ?? "",
                                date: dateString,
                                salon: appointment.salon_name ?? "NA")
                            self.services.append(model)
                        }
                    }
                }
            }
            services.sort {return $0.date > $1.date}
            self.tableView.reloadData()
        }

    }

    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        print("Failed: \(errorMessage ?? "")")
        showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "Request Failed")
    }
}
