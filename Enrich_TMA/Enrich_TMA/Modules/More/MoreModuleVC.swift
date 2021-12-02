//
//  MoreModuleViewController.swift
//  EnrichSalon
//

import UIKit

enum ProfileCellIdentifiers: String {

    // Dashboard
    case myProfile = "MyProfile"
    case myCustemers = ""
    case pettyCash = "PettyCash"
    case employees = "Employees"
    case notifications = "Notifications"
    case logout = "Logout"

}

protocol MoreModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
}

class MoreModuleVC: UIViewController, MoreModuleDisplayLogic {

    var interactor: MoreModuleBusinessLogic?

    @IBOutlet weak private var tableView: UITableView!

    var profileDashboardIdentifiers: [ProfileCellIdentifiers] = [.myProfile,
                                                                .myCustemers,
                                                                .pettyCash,
                                                                .employees,
                                                                .notifications,
                                                                .logout]

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

        //self.doSomething()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.addCustomBackButton(title: "")
    }
    // MARK: OpenLoginWindow
//    func openLoginWindow() {
//
//        let vc = DoLoginPopUpVC.instantiate(fromAppStoryboard: .Location)
//        vc.delegate = self
//        self.view.alpha = screenPopUpAlpha
//        self.appDelegate.window?.rootViewController!.present(vc, animated: true, completion: nil)
//        vc.onDoneBlock = { [unowned self] result in
//            // Do something
//            if(result) {} else {}
//            self.view.alpha = 1.0
//        }
//    }
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
        if identifier == .notifications || identifier == .myCustemers{
            guard let notificationCell: NotificationCell = tableView.dequeueReusableCell(withIdentifier: ProfileCellIdentifiers.notifications.rawValue, for: indexPath) as? NotificationCell else {
                return cell
            }
            let title = identifier == .notifications ? "NOTIFICATION" : "MY CUSTOMERS"
            notificationCell.configureCell(title: title, notificationCount: 12)
            notificationCell.updateConstraints()
            notificationCell.setNeedsDisplay()
            cell = notificationCell
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        } else {
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
            self.navigationController?.pushViewController(vc, animated: true)

        case .pettyCash : break
//            let vc = PettyCashVC.instantiate(fromAppStoryboard: .More)
//            self.navigationController?.pushViewController(vc, animated: true)
      
        case .notifications :
            let vc = NotificationsVC.instantiate(fromAppStoryboard: .More)
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .myCustemers : break
//            let vc = MyCustomersVC.instantiate(fromAppStoryboard: .More)
//            self.navigationController?.pushViewController(vc, animated: true)
//            let vc = GenericCustomerConsulationVC.instantiate(fromAppStoryboard: .Schedule)
//            self.navigationController?.pushViewController(vc, animated: true)

        case .logout:
            
            appDelegate.signOutUserFromApp()
            
        case .employees:
            let vc = EmployeeListingVC.instantiate(fromAppStoryboard: .More)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}
//extension MoreModuleViewController: LoginRegisterDelegate {
//    func doLoginRegister() {
//        // Put your code here
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {[unowned self] in
//            let vc = LoginModuleVC.instantiate(fromAppStoryboard: .Main)
//            let navigationContrl = UINavigationController(rootViewController: vc)
//            self.present(navigationContrl, animated: true, completion: nil)
//        }
//    }
//}

// MARK: Call Webservice
extension MoreModuleVC {

    func doSomething() {
        let request = MoreModule.Something.Request(name: "TestData", salary: "100000", age: "10")
        interactor?.doPostRequest(request: request, method: HTTPMethod.post)
    }

    func displaySuccess<T: Decodable>(viewModel: T) {
        let obj = viewModel as? MoreModule.Something.Response
        DispatchQueue.main.async {
        }
    }
    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        DispatchQueue.main.async { [unowned self] in
            self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
        }
    }

    func displaySuccess<T: Decodable>(responseSuccess: [T]) {
        DispatchQueue.main.async {
            var obj = responseSuccess as? [MoreModule.Something.Response]
            print("Get API Response -- \n \(obj)")
        }
    }

}
