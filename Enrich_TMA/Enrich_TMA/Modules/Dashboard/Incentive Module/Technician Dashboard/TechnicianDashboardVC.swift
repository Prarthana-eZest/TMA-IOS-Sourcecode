//
//  TechnicianDashboardViewController.swift
//  Enrich_TMA
//
//  Created by Harshal on 03/08/21.
//  Copyright (c) 2021 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

enum CategoryTypes {
    static let services = "Services"
    static let packages = "Packages"
    static let retail = "Retail"
}

enum AppointmentType {
    static let salon = "salon"
    static let home = "home"
}

enum platform {
    static let store = "store"
    static let CMA = "CMA"
    
}

protocol TechnicianDashboardDisplayLogic: class
{
    func displaySomething(viewModel: TechnicianDashboard.Something.ViewModel)
}

class TechnicianDashboardVC: UIViewController, TechnicianDashboardDisplayLogic
{
    var interactor: TechnicianDashboardBusinessLogic?
    
    // MARK: Object lifecycle
    
    @IBOutlet private weak var tableView: UITableView!
    
    var viewType:EarningViewType = .grid
    var revenueTotal : Float = 0.0
    
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
        let interactor = TechnicianDashboardInteractor()
        let presenter = TechnicianDashboardPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        doSomething()
        tableView.register(UINib(nibName: CellIdentifier.earningHeaderCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.earningHeaderCell)
        calculateDateForTiles(startDate: Date.today.startOfMonth)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.addCustomBackButton(title: "Dashboard")
        updateData()
    }
    
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    func doSomething()
    {
        let request = TechnicianDashboard.Something.Request()
        interactor?.doSomething(request: request)
    }
    
    func displaySomething(viewModel: TechnicianDashboard.Something.ViewModel)
    {
        //nameTextField.text = viewModel.name
    }
    
    func updateData(){
        let total1 = UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_key_RevenueTotal)
        UserDefaults.standard.set(total1, forKey: UserDefauiltsKeys.k_key_RevenueTotal)
       
        let total2 = UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_key_SalesToatal)
        UserDefaults.standard.set(total2, forKey: UserDefauiltsKeys.k_key_SalesToatal)
        
        
        let total3 = UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_key_FreeServicesToatal)
        UserDefaults.standard.set(total3, forKey: UserDefauiltsKeys.k_key_FreeServicesToatal)
        
        let total4 = UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_key_FootfallToatal)
        UserDefaults.standard.set(total4, forKey: UserDefauiltsKeys.k_key_FootfallToatal)
        
        
        tableView.reloadData()
        
    }
    
    func calculateDateForTiles(startDate : Date, endDate : Date = Date().startOfDay) {
        let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
        
        let filteredRevenue = technicianDataJSON?.data?.revenue_transactions?.filter({ (revenue) -> Bool in
            if let date = revenue.date?.date()?.startOfDay {
                
                return date >= startDate && date <= endDate
            }
            return false
        })
        // Revenue Screen
        let serviceData = filteredRevenue?.filter({($0.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.salon)}) ?? []
        var serviceToatal : Double = 0.0
        
        let homeServiceRevenueData = filteredRevenue?.filter({($0.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.home)}) ?? []
        var homeServiceTotal : Double = 0.0
        
        let retailData = filteredRevenue?.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.retail)}) ?? []
        var retailTotal : Double = 0.0
        
        
        for objService in serviceData {
            serviceToatal = serviceToatal + objService.total!
        }
        print("serviceToatal conunt : \(serviceToatal)")
        
        for objService in homeServiceRevenueData {
            homeServiceTotal = homeServiceTotal + objService.total!
        }
        print("homeServiceTotal conunt : \(homeServiceTotal)")
        
        
        for objRetail in retailData {
            retailTotal = retailTotal + objRetail.total!
        }
        print("retail conunt : \(retailTotal)")
        let revenueTotal = serviceToatal + homeServiceTotal + retailTotal
        UserDefaults.standard.set(revenueTotal, forKey: UserDefauiltsKeys.k_key_RevenueTotal)
        
        print("Total Revenue \(revenueTotal)")
        
        //membership revenue
        let membershipRevenue = filteredRevenue?.filter({$0.membership_revenue ?? 0 > 0}) ?? []
        var membershipRevenueCount : Double = 0.0
        for objMembershipRevenueCount in membershipRevenue {
            membershipRevenueCount = membershipRevenueCount + objMembershipRevenueCount.membership_revenue!
        }
        print("membershipRevenueCount \(membershipRevenueCount)")
        
        
        //value package revenue
        let valuePackageRevenue = filteredRevenue?.filter({$0.value_package_revenue ?? 0 > 0}) ?? []
        var valuePackageRevenueCount : Double = 0.0
        for objValuePackageRevenueCount in valuePackageRevenue {
            valuePackageRevenueCount = valuePackageRevenueCount + objValuePackageRevenueCount.value_package_revenue!
        }
        print("valuePackageRevenueCount \(valuePackageRevenueCount)")
        
        //service_package_revenue
        let servicePackageRevenue = filteredRevenue?.filter({$0.service_package_revenue ?? 0 > 0}) ?? []
        
        var servicePackageRevenueCount : Double = 0.0
        for objServicePackageRevenue in servicePackageRevenue {
            servicePackageRevenueCount = servicePackageRevenueCount + objServicePackageRevenue.service_package_revenue!
        }
        print("servicePackageRevenueCount \(servicePackageRevenueCount)")
        
        let salesCount = membershipRevenueCount + valuePackageRevenueCount + servicePackageRevenueCount
        
        //let intValSales : Int = (Int(salesCount))
        UserDefaults.standard.set(salesCount.rounded(), forKey: UserDefauiltsKeys.k_key_SalesToatal)
        //print("Sales count \(intValSales)")
        
        //Free services
        //free_service_revenue
        let freeServiceRevenue = filteredRevenue?.filter({$0.free_service_revenue ?? 0 > 0}) ?? []
        
        var freeServiceRevenueCount : Double = 0.0
        for objfreeServiceRevenue in freeServiceRevenue {
            freeServiceRevenueCount = freeServiceRevenueCount + objfreeServiceRevenue.free_service_revenue!
        }
        
        //grooming_giftcard
        let groomingGiftcard = filteredRevenue?.filter({$0.grooming_giftcard ?? 0 > 0}) ?? []
        
        var groomingGiftcardCount : Double = 0.0
        for objGroomingGiftcard in groomingGiftcard {
            groomingGiftcardCount = groomingGiftcardCount + objGroomingGiftcard.grooming_giftcard!
        }
        print("groomingGiftcardCount \(groomingGiftcardCount)")
        
        //complimentary_giftcard
        let complimentaryGiftcard = filteredRevenue?.filter({$0.complimentary_giftcard ?? 0 > 0}) ?? []
        
        var complimentaryGiftcardCount : Double = 0.0
        for objComplimentaryGiftcard in complimentaryGiftcard {
            complimentaryGiftcardCount = complimentaryGiftcardCount + objComplimentaryGiftcard.complimentary_giftcard!
        }
        print("complimentaryGiftcardCount \(complimentaryGiftcardCount)")
        
        var freeServicesCount = freeServiceRevenueCount + groomingGiftcardCount + complimentaryGiftcardCount
        freeServicesCount = 0.8 * freeServicesCount
        
       //let intValFreeServices : Int = (Int(freeServicesCount))
        UserDefaults.standard.set(freeServicesCount.rounded(), forKey: UserDefauiltsKeys.k_key_FreeServicesToatal)
       // print("Sales count \(intValSales)")
        
        
        
        //footfall screen
        let invoiceNumber = filteredRevenue?.filter({($0.invoice_number ?? "") != ""})
        let updateUniqueData = invoiceNumber?.unique(map: {$0.invoice_number}) ?? []
        
        
       //service
        let serviceDataFootfall = filteredRevenue?.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services) && ($0.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.salon)})
        
        
        //add condition for product category type
        var serviceToatalFootfall : Int = 0 //= serviceData?.count ?? 0
        let serviceDataUniqueInvoice = serviceDataFootfall?.unique(map: {$0.invoice_number}) ?? []
        for objInvoice in updateUniqueData {
            for objServiceData in serviceDataUniqueInvoice {
                if(objInvoice.invoice_number == objServiceData.invoice_number){
                    serviceToatalFootfall = serviceToatalFootfall + 1
                }
            }
        }
        
        print("serviceToatal conunt : \(serviceToatal)")
        //123
        let homeServiceRevenueDataFootfall = filteredRevenue?.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services) && ($0.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.home)})
        //add condition for product category type
        
        let homeInvoiceUnique = homeServiceRevenueDataFootfall?.unique(map: {$0.invoice_number}) ?? []
        var homeServiceTotalFootfall : Int = 0
        
        for objInvoice in updateUniqueData {
            for objHomeData in homeInvoiceUnique {
                if(objInvoice.invoice_number == objHomeData.invoice_number){
                    homeServiceTotalFootfall = homeServiceTotalFootfall + 1
                }
            }
        }
        
        print("homeServiceTotal conunt : \(homeServiceTotal)")
        
        let retailDataFootfall = filteredRevenue?.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.retail)})
        let retialInvoiceUnique = retailDataFootfall?.unique(map: {$0.invoice_number}) ?? []
        var retailCountFootfall : Int = 0
        
        for objInvoice in updateUniqueData {
            for objRetail in retialInvoiceUnique {
                if (objInvoice.invoice_number == objRetail.invoice_number){
                    retailCountFootfall = retailCountFootfall + 1
                }
            }
        }
        
        let footfallCount = serviceToatalFootfall + homeServiceTotalFootfall + retailCountFootfall
        UserDefaults.standard.set(footfallCount, forKey: UserDefauiltsKeys.k_key_FootfallToatal)
    }
    
}

extension TechnicianDashboardVC: EnrningsDelegate {

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
            let vc = RevenueVC.instantiate(fromAppStoryboard: .Incentive)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .Incentive:
            let vc = RevenueVC.instantiate(fromAppStoryboard: .Incentive)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .Bonus:
            let vc = RevenueVC.instantiate(fromAppStoryboard: .Incentive)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .Other_Earnings:
            let vc = RevenueVC.instantiate(fromAppStoryboard: .Incentive)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .Awards:
            let vc = RevenueVC.instantiate(fromAppStoryboard: .Incentive)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .Deductions:
            let vc = RevenueVC.instantiate(fromAppStoryboard: .Incentive)
            vc.headerModel = model
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension TechnicianDashboardVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.earningHeaderCell, for: indexPath) as? EarningHeaderCell else {
            return UITableViewCell()
        }
        cell.delegate = self

        cell.configureCell(viewType: viewType, value: 0.0)
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
    }
}
