//
//  EarningsViewController.swift
//  Enrich_TMA
//
//  Created by Harshal on 13/12/21.
//  Copyright (c) 2021 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol EarningsDisplayLogic: class
{
  func displaySomething(viewModel: Earnings.Something.ViewModel)
}

class EarningsViewController: UIViewController, EarningsDisplayLogic
{
    
    @IBOutlet private weak var tableView: UITableView!
    var viewType:EarningViewType = .earnings
    var headerModel: EarningsHeaderDataModel?
    
    var dateRangeType : DateRangeType = .mtd
    var earningsCutomeDateRange:DateRange = DateRange(Date.today.lastYear(), Date.today)
    
  var interactor: EarningsBusinessLogic?
  var router: (NSObjectProtocol & EarningsRoutingLogic & EarningsDataPassing)?

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
    let interactor = EarningsInteractor()
    let presenter = EarningsPresenter()
    let router = EarningsRouter()
    viewController.interactor = interactor
    viewController.router = router
    interactor.presenter = presenter
    presenter.viewController = viewController
    router.viewController = viewController
    router.dataStore = interactor
  }
  
  // MARK: Routing
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if let scene = segue.identifier {
      let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
      if let router = router, router.responds(to: selector) {
        router.perform(selector, with: segue)
      }
    }
  }
  
  // MARK: View lifecycle
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    tableView.register(UINib(nibName: CellIdentifier.earningTotalHeaderCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.earningTotalHeaderCell)
    
    tableView.register(UINib(nibName: CellIdentifier.earningHeaderCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.earningHeaderCell)
    
    tableView.register(UINib(nibName: CellIdentifier.viewCTCCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.viewCTCCell)
    
    tableView.reloadData()
  }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.addCustomBackButton(title: "Earnings")
    }
    
  // MARK: Do something
  
  //@IBOutlet weak var nameTextField: UITextField!
  
    func getTotalEarnings() -> Int {
        var totalEarnings : Int = 0
        
        let earningsJSON = UserDefaults.standard.value(Dashboard.GetEarningsDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_EarningsDashboard)
        
        totalEarnings = earningsJSON?.data?.total_earning ?? 0

        return totalEarnings
    }
    
  func doSomething()
  {
    let request = Earnings.Something.Request()
    interactor?.doSomething(request: request)
  }
  
  func displaySomething(viewModel: Earnings.Something.ViewModel)
  {
    //nameTextField.text = viewModel.name
  }
}
extension EarningsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.earningTotalHeaderCell, for: indexPath) as? EarningTotalHeaderCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
           
            let model = EarningsHeaderDataModel(earningsType: .Incentive, value: Double(getTotalEarnings()), isExpanded: false, dateRangeType: dateRangeType, customeDateRange: earningsCutomeDateRange)
            cell.configureCell(model: model, data: [])
            return cell
        }
        else if(indexPath.row == 1){
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.earningHeaderCell, for: indexPath) as? EarningHeaderCell else {
            return UITableViewCell()
        }
        cell.delegate = self

        cell.configureCell(viewType: viewType, value: 0.0)
        cell.selectionStyle = .none
        return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.viewCTCCell, for: indexPath) as? ViewCTCCell else {
                return UITableViewCell()
            }
           // cell.delegate = self

            //cell.configureCell(viewType: viewType, value: 0.0)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0)
        {
            return 102
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
        if(indexPath.row == 2){
            //View CTC
            let vc = ViewCTCViewController.instantiate(fromAppStoryboard: .Earnings)
            //self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
extension EarningsViewController: EnrningsDelegate {

    func actionChangeViewType(type: EarningViewType) {
        self.viewType = type
        self.tableView.reloadData()
    }
    
    func actionSelectMenu(model: EarningsHeaderDataModel, indexPath: IndexPath) {
        switch model.earningsType {
        case .Revenue:
            let vc = RevenueVC.instantiate(fromAppStoryboard: .Incentive)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .Sales:
            let vc = SalesVC.instantiate(fromAppStoryboard: .Incentive)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)

        case .FreeServices:
            let vc = FreeServicesVC.instantiate(fromAppStoryboard: .Incentive)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)

        case .Footfall:
            let vc = FootfallVC.instantiate(fromAppStoryboard: .Incentive)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)

        case .CustomerFeedback:
            let vc = CustomerFeedbackVC.instantiate(fromAppStoryboard: .Incentive)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)

        case .Productivity:
            let vc = ProductivityVC.instantiate(fromAppStoryboard: .Incentive)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)

        case .PenetrationRatios:
            let vc = PenetrationRatiosVC.instantiate(fromAppStoryboard: .Incentive)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)

        case .CustomerEngagement:
            let vc = CustomerEngagementVC.instantiate(fromAppStoryboard: .Incentive)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)

        case .ResourceUtilisation:
            let vc = ResourceUtilisationVC.instantiate(fromAppStoryboard: .Incentive)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .Fixed_Earning:
            let vc = FixedEarningsViewController.instantiate(fromAppStoryboard: .Earnings)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .Incentive:
            let vc = IncentiveViewController.instantiate(fromAppStoryboard: .Earnings)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .Bonus:
            let vc = BonusViewController.instantiate(fromAppStoryboard: .Earnings)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .Other_Earnings:
            let vc = OtherEarningsViewController.instantiate(fromAppStoryboard: .Earnings)
            vc.headerModel = model
            //self.navigationController?.pushViewController(vc, animated: true)
            
        case .Awards:
            let vc = AwardsViewController.instantiate(fromAppStoryboard: .Earnings)
            vc.headerModel = model
            //self.navigationController?.pushViewController(vc, animated: true)
            
        case .Deductions:
            let vc = DeductionsViewController.instantiate(fromAppStoryboard: .Earnings)
            vc.headerModel = model
           // self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
