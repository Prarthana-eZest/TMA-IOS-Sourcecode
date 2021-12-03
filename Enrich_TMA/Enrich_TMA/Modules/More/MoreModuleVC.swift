//
//  MoreModuleViewController.swift
//  EnrichSalon
//

import UIKit

enum ProfileCellIdentifiers: String {

    // Dashboard
    case punchIn = "Punch In"
    case punchOut = "Punch Out"
    case myProfile = "MyProfile"
    case myCustemers = "MyCustomers"
    case pettyCash = "PettyCash"
    case employees = "Employees"
    case notifications = "Notifications"
    case teleConsulation = "TeleConsultation"
    case logout = "Logout"
    case version = "Version"
}

protocol MoreModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
}

class MoreModuleVC: UIViewController, MoreModuleDisplayLogic {

    var interactor: MoreModuleBusinessLogic?

    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var lblPunchInTime: UILabel!
    @IBOutlet weak private var lblPunchOutTime: UILabel!

    var userPunchedIn = false

    var profileDashboardIdentifiers: [ProfileCellIdentifiers] =
        [.punchIn,
         .myProfile,
         .myCustemers,
         .pettyCash,
         .employees,
         .teleConsulation,
         .notifications,
         .logout,
         .version]

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
        let interactor = MoreModuleInteractor()
        let presenter = MoreModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController

    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)

        LocationManager.sharedInstance.delegate = self

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserFactory.shared.checkForSignOut()
        self.navigationController?.navigationBar.isHidden = true
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.addCustomBackButton(title: "")
        print("Location:\(LocationManager.sharedInstance.location())")
        getCheckInStatus()
        getCheckInDetails()
    }

}

extension MoreModuleVC: LocationManagerDelegate {

    func locationDidFound(_ latitude: Double, longitude: Double) {
        print("Location Latitude:\(latitude) Longitude:\(longitude)")
    }

}

extension MoreModuleVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileDashboardIdentifiers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let identifier = profileDashboardIdentifiers[indexPath.row]

        var cell = UITableViewCell()
        if identifier == .notifications {
            guard let notificationCell = tableView.dequeueReusableCell(withIdentifier: ProfileCellIdentifiers.notifications.rawValue, for: indexPath) as? NotificationCell else {
                return cell
            }
            let title = "NOTIFICATION"
            notificationCell.configureCell(title: title, notificationCount: 12)
            notificationCell.icon.image = UIImage(named: "notificationMenu")
            notificationCell.updateConstraints()
            notificationCell.setNeedsDisplay()
            cell = notificationCell
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        else if identifier == .myCustemers {
            guard let notificationCell = tableView.dequeueReusableCell(withIdentifier: ProfileCellIdentifiers.notifications.rawValue, for: indexPath) as? NotificationCell else {
                return cell
            }
            let title = "MY CUSTOMERS"
            notificationCell.configureCell(title: title, notificationCount: 12)
            notificationCell.icon.image = UIImage(named: "myCustomerMenu")
            notificationCell.updateConstraints()
            notificationCell.setNeedsDisplay()
            cell = notificationCell
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        }
        else if identifier == .punchIn {
            let identifier = userPunchedIn ? ProfileCellIdentifiers.punchOut.rawValue : identifier.rawValue
            cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        else if identifier == .version {
            guard let versionCell = tableView.dequeueReusableCell(withIdentifier: ProfileCellIdentifiers.version.rawValue, for: indexPath) as? AppVersionCell else {
                return cell
            }
            versionCell.configureCell(version: Bundle.main.versionNumber)
            cell = versionCell

            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath)
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let identifier = profileDashboardIdentifiers[indexPath.row]
        print("Selection: \(identifier.rawValue)")

        switch identifier {

        case .myProfile:
            let vc = MyProfileVC.instantiate(fromAppStoryboard: .More)
            vc.profileType = .selfUser
            self.navigationController?.pushViewController(vc, animated: true)

        case .pettyCash :
            let vc = PettyCashListingVC.instantiate(fromAppStoryboard: .More)
            self.navigationController?.pushViewController(vc, animated: true)

        case .notifications :
            let vc = NotificationsVC.instantiate(fromAppStoryboard: .More)
            self.navigationController?.pushViewController(vc, animated: true)

        case .myCustemers :
            let vc = MyCustomersVC.instantiate(fromAppStoryboard: .More)
            self.navigationController?.pushViewController(vc, animated: true)

        case .logout:
            let alertController = UIAlertController(title: alertTitle, message: AlertMessagesToAsk.askToLogout, preferredStyle: UIAlertController.Style.alert)

            alertController.addAction(UIAlertAction(title: AlertButtonTitle.no, style: UIAlertAction.Style.cancel) { _ -> Void in
                // Do Nothing
            })
            alertController.addAction(UIAlertAction(title: AlertButtonTitle.yes, style: UIAlertAction.Style.default) { _ -> Void in
                UserFactory.shared.signOutUserFromApp()
            })
            self.present(alertController, animated: true, completion: nil)

        case .employees:
            let vc = EmployeeListingVC.instantiate(fromAppStoryboard: .More)
            self.navigationController?.pushViewController(vc, animated: true)

        case .punchIn:

            let message = userPunchedIn ? AlertMessagesToAsk.askToPunchOut : AlertMessagesToAsk.askToPunchIn
            let alertController = UIAlertController(title: alertTitle, message: message, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: AlertButtonTitle.yes, style: UIAlertAction.Style.cancel) { _ -> Void in
                self.markCheckInOut()
            })
            alertController.addAction(UIAlertAction(title: AlertButtonTitle.no, style: UIAlertAction.Style.default) { _ -> Void in
                // Do Nothing
            })
            self.present(alertController, animated: true, completion: nil)

        case .punchOut, .version:
            break
        case .teleConsulation:
            let vc = TeleConsultationVC.instantiate(fromAppStoryboard: .More)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

// MARK: Call Webservice
extension MoreModuleVC {

    func getCheckInDetails() {
        if let userData = UserDefaults.standard.value(MyProfile.GetUserProfile.UserData.self, forKey: UserDefauiltsKeys.k_Key_LoginUser) {
            let date = Date().dayYearMonthDate

            EZLoadingActivity.show("Loading...", disableUI: true)
            let request = MoreModule.CheckInOutDetails.Request(date: date, emp_code: userData.employee_code ?? "", is_custom: true)
            interactor?.doPostCheckInOutDetailsRequest(request: request, method: .post)
        }
    }

    func getCheckInStatus() {
        if let userData = UserDefaults.standard.value(MyProfile.GetUserProfile.UserData.self, forKey: UserDefauiltsKeys.k_Key_LoginUser) {
            EZLoadingActivity.show("Loading...", disableUI: true)
            let request = MoreModule.GetCheckInStatus.Request(emp_code: userData.employee_code ?? "", date: Date().dayYearMonthDate, is_custom: true)
            interactor?.doPostGetStatusRequest(request: request, method: .post)
        }
    }

    func markCheckInOut() {
        if let userData = UserDefaults.standard.value(MyProfile.GetUserProfile.UserData.self, forKey: UserDefauiltsKeys.k_Key_LoginUser) {
            EZLoadingActivity.show("Loading...", disableUI: true)
            let lat = "\(LocationManager.sharedInstance.location().latitude)" // "22.997"
            let long = "\(LocationManager.sharedInstance.location().longitude)" // "72.608"

            EZLoadingActivity.show("Loading...", disableUI: true)
            let request = MoreModule.MarkCheckInOut.Request(
                emp_code: userData.employee_code ?? "",
                emp_name: userData.username ?? "", branch_code: userData.base_salon_code ?? "",
                checkinout_time: Date().checkInOutDateTime, checkin: userPunchedIn ? "0" : "1",
                employee_latitude: lat, employee_longitude: long, is_custom: true,
                emp_fname: userData.firstname ?? "",
                emp_lname: userData.lastname ?? "")

            interactor?.doPostMarkCheckInOutRequest(request: request, method: .post)
        }
    }

    func displaySuccess<T: Decodable>(viewModel: T) {
        EZLoadingActivity.hide()
        if let model = viewModel as? MoreModule.GetCheckInStatus.Response,
            model.status == true, let checkin = model.checkin {
            userPunchedIn = checkin
            self.tableView.reloadData()
        }
        else if let model = viewModel as? MoreModule.MarkCheckInOut.Response {

            if model.status == true {
                userPunchedIn = !userPunchedIn
                self.tableView.reloadData()
                getCheckInDetails()
            }
            DispatchQueue.main.async { [unowned self] in
                self.showAlert(alertTitle: alertTitle, alertMessage: model.message )
            }
        }
        else if let model = viewModel as? MoreModule.CheckInOutDetails.Response {
            if model.status == true {
                if let checkIn = model.data?.first(where: {$0.checkin == "1"}),
                    let dateTime = checkIn.checkinout_time,
                    let time = dateTime.getCheckInTime(dateString: dateTime, withFormat: "hh:mm aaa") {
                    lblPunchInTime.text = time
                }
                else {
                    lblPunchInTime.text = "-"
                }

                if let checkOut = model.data?.last(where: {$0.checkin == "0"}),
                    let dateTime = checkOut.checkinout_time,
                    let time = dateTime.getCheckInTime(dateString: dateTime, withFormat: "hh:mm aaa") {
                    lblPunchOutTime.text = time
                }
                else {
                    lblPunchOutTime.text = "-"
                }
            }
        }
        else if let model = viewModel as? MoreModule.RaiseSOS.Response {
            DispatchQueue.main.async { [unowned self] in
                self.showAlert(alertTitle: alertTitle, alertMessage: model.message )
            }
        }
    }
    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        DispatchQueue.main.async { [unowned self] in
            self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
        }
    }

    func displaySuccess<T: Decodable>(responseSuccess: [T]) {
        //        var obj = responseSuccess as? [MoreModule.Something.Response]
        //        print("Get API Response -- \n \(obj)")
    }

}
