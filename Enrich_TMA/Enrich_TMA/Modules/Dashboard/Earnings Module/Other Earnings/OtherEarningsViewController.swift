//
//  OtherEarningsViewController.swift
//  Enrich_TMA
//
//  Created by Harshal on 21/12/21.
//  Copyright (c) 2021 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol OtherEarningsDisplayLogic: class
{
  func displaySomething(viewModel: OtherEarnings.Something.ViewModel)
}

class OtherEarningsViewController: UIViewController, OtherEarningsDisplayLogic
{
  var interactor: OtherEarningsBusinessLogic?
  var router: (NSObjectProtocol & OtherEarningsRoutingLogic & OtherEarningsDataPassing)?
    
    @IBOutlet private weak var tableView: UITableView!
    var dateRangeType : DateRangeType = .mtd
    var otherEarningsDateRange:DateRange = DateRange(Date.today.lastYear(), Date.today)
    
    var fromFilters : Bool = false
    var fromChartFilter : Bool = false
    
    var headerModel: EarningsHeaderDataModel?
    var headerGraphData: GraphDataEntry?
    
    var dataModel = [EarningsCellDataModel]()
    
    var graphData = [GraphDataEntry]()
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
    let interactor = OtherEarningsInteractor()
    let presenter = OtherEarningsPresenter()
    let router = OtherEarningsRouter()
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
        tableView.register(UINib(nibName: CellIdentifier.earningDetailsHeaderCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.earningDetailsHeaderCell)
        tableView.register(UINib(nibName: CellIdentifier.earningDetailsHeaderFilterCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.earningDetailsHeaderFilterCell)
        tableView.register(UINib(nibName: CellIdentifier.earningDetailsCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.earningDetailsCell)
        fromChartFilter = false
        dateRangeType = .mtd
        updateOtherEarningsData(startDate: Date.today.startOfMonth)
        
      }
      
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.addCustomBackButton(title: EarningDetails.Other_Earnings.rawValue)
        }
      // MARK: Do something
      
      //@IBOutlet weak var nameTextField: UITextField!
      
        func updateOtherEarningsData(startDate: Date?, endDate: Date = Date().startOfDay) {
            
            EZLoadingActivity.show("Loading...", disableUI: true)
            otherEarningsData(startDate: startDate ?? Date.today, endDate: endDate, completion: nil)
        }
        
        func calculateTotalOtherEarnings() {
            let earningsJSON = UserDefaults.standard.value(Dashboard.GetEarningsDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_EarningsDashboard)
            var graphRangeType = dateRangeType
            var graphDateRange = otherEarningsDateRange // need to change
            var filteredFixedEarningsForGraph = [Dashboard.GetRevenueDashboard.RevenueTransaction]()
            if (dateRangeType == .yesterday || dateRangeType == .today) {
    //            filteredFixedEarningsForGraph = nil
                graphRangeType = .mtd
                graphDateRange = DateRange(graphRangeType.date!, Date().startOfDay)
            }
            
            let currentMonth = 3//Int(Date.today.string(format: "M"))
    
            let dataArray = earningsJSON?.data?.groups?.filter({EarningDetails(rawValue: $0.group_label ?? "") == EarningDetails.Other_Earnings}) ?? []
            var amount : Int = 0
            for data in dataArray {
                for parameter in data.parameters ?? [] {
                    let value = parameter.transactions?.filter({$0.month == currentMonth})
    //                value?.first?.amount
                    amount += value?.first?.amount ?? 0
                }
            }
            headerModel?.value = Double(amount)
            headerModel?.dateRangeType = graphRangeType
            headerGraphData = getTotalOtherEarningsGraphEntry(forData: filteredFixedEarningsForGraph, dateRange: graphDateRange, dateRangeType: graphRangeType)
        }
        
        func otherEarningsData(startDate : Date, endDate : Date = Date().startOfDay, completion: (() -> Void)? ) {
            dataModel.removeAll()
            graphData.removeAll()
            
                let earningsJSON = UserDefaults.standard.value(Dashboard.GetEarningsDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_EarningsDashboard)
                let currentMonth = 3//Int(Date.today.string(format: "M"))
            
            //Handle Graph Scenarios
            let dateRange = DateRange(startDate, endDate)
            var graphRangeType = dateRangeType
            var graphDateRange = dateRange
            var filteredFixedEarningsForGraph = [Dashboard.GetRevenueDashboard.RevenueTransaction]()
            
            if (dateRangeType == .yesterday || dateRangeType == .today) {
               // filteredFixedEarningsForGraph = nil
                graphRangeType = .mtd
                graphDateRange = DateRange(graphRangeType.date!, Date().startOfDay)
            }

            let dataArray = earningsJSON?.data?.groups?.filter({EarningDetails(rawValue: $0.group_label ?? "") == EarningDetails.Other_Earnings}) ?? []
            var index = 0
            for data in dataArray {
                for parameter in data.parameters ?? [] {
                    let value = parameter.transactions?.filter({$0.month == currentMonth})
    //                value?.first?.amount
                    let model = EarningsCellDataModel(earningsType: .Other_Earnings, title: parameter.name ?? "", value: [String(value?.first?.amount ?? 0)], subTitle: [parameter.comment ?? ""], showGraph: true, cellType: .SingleValue, isExpanded: false, dateRangeType: graphRangeType, customeDateRange: otherEarningsDateRange)
                    dataModel.append(model)
                    graphData.append(getGraphEntry(parameter.name ?? "", forData: parameter.transactions, atIndex: index, dateRange: otherEarningsDateRange, dateRangeType: graphRangeType))
                    
                    index += 1
                }
            }
            index = 0
            
            calculateTotalOtherEarnings()
    //        for group in earningsJSON?.data?.groups ?? []{
    //            if  (EarningDetails(rawValue: group.group_label ?? "") == EarningDetails.Fixed_Earning) {
    //                for parameter in group.parameters ?? []{
    //                    let model = EarningsCellDataModel(earningsType: group.group_label ?? "", title: parameter.name, value: "", subTitle: "", showGraph: true, cellType: .SingleValue, isExpanded: false, dateRangeType: graphRangeType, customeDateRange: fixedEarningsDateRange)
    //                    dataModel.append(model)
    //                    graphData.append(getGraphEntry(parameter.name, forData: filteredFixedEarningsForGraph, atIndex: 0, dateRange: graphRangeType, dateRangeType: fixedEarningsDateRange))
    //                }
    //            }
    //
    //        }
               //get trnacation - input gr - map
            
    //        //salon service
    //        //Data Model
    //        let salonServiceModel = EarningsCellDataModel(earningsType: .Fixed_Earning, title: "Salon Service", value: [Double(0.0).abbrevationString], subTitle: [""], showGraph: true, cellType: .SingleValue, isExpanded: false, dateRangeType: graphRangeType, customeDateRange: fixedEarningsDateRange)
    //        dataModel.append(salonServiceModel)
    //        //Graph Data
    //        graphData.append(getGraphEntry(salonServiceModel.title, forData: filteredFixedEarningsForGraph, atIndex: 0, dateRange: graphDateRange, dateRangeType: graphRangeType))
            
            tableView.reloadData()
            EZLoadingActivity.hide()
        }
        
        func getGraphEntry(_ title:String, forData data:[Dashboard.GetEarningsDashboard.Transaction]? = nil, atIndex index : Int, dateRange:DateRange, dateRangeType: DateRangeType) -> GraphDataEntry
        {
            let units = xAxisUnits(forDateRange: dateRange, rangeType: dateRangeType)
            let values = graphData(forData: data, atIndex: index, dateRange: dateRange, dateRangeType: dateRangeType)
            let graphColor = EarningDetails.Other_Earnings.graphBarColor
            
            return GraphDataEntry(graphType: .barGraph, dataTitle: title, units: units, values: values, barColor: graphColor.first!)
        }
        
        func graphData(forData data:[Dashboard.GetEarningsDashboard.Transaction]? = nil, atIndex index : Int, dateRange:DateRange, dateRangeType: DateRangeType) -> [Double] {
            
    //        var filteredFootfall = data
    //
    //        if data == nil, (data?.count ?? 0 <= 0) {
    //            let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
    //
    //
    //            filteredFootfall = technicianDataJSON?.data?.revenue_transactions?.filter({ (freeServices) -> Bool in
    //                if let date = freeServices.date?.date()?.startOfDay {
    //
    //                    return date >= dateRange.start && date <= dateRange.end
    //                }
    //                return false
    //            })
    //        }
    //
    //        let uniqueInvoices = filteredFootfall?.compactMap({$0.invoice_number}).unique(map: {$0}) ?? []
            //salon service
    //        if(index == 0){
    //            return calculateSalonService(filterArray: filteredFootfall ?? [], invoiceNumbers: uniqueInvoices, dateRange: dateRange, dateRangeType: dateRangeType)
    //        }
    //        else if(index == 1){//home service
    //            return calculateHomeService(filterArray: filteredFootfall ?? [], invoiceNumbers: uniqueInvoices, dateRange: dateRange, dateRangeType: dateRangeType)
    //        }
    //        else{ // Retail product
    //            return calculateRetailProduct(filterArray: filteredFootfall ?? [], invoiceNumbers: uniqueInvoices, dateRange: dateRange, dateRangeType: dateRangeType)
    //        }
            return [0.0]
        }
        
        func getTotalOtherEarningsGraphEntry(forData data:[Dashboard.GetRevenueDashboard.RevenueTransaction]? = nil, dateRange:DateRange, dateRangeType: DateRangeType) -> GraphDataEntry
        {
            let units = xAxisUnits(forDateRange: dateRange, rangeType: dateRangeType)
            let values = totalOtherEarningsGraphData(forData: data, dateRange: dateRange, dateRangeType: dateRangeType)
            let graphColor = EarningDetails.Other_Earnings.graphBarColor
            
            return GraphDataEntry(graphType: .barGraph, dataTitle: headerModel?.earningsType.headerTitle ?? "", units: units, values: values, barColor: graphColor.first!)
        }
        
        func totalOtherEarningsGraphData(forData data:[Dashboard.GetRevenueDashboard.RevenueTransaction]? = nil, dateRange:DateRange, dateRangeType: DateRangeType) -> [Double]
        {
    //        var totalFixedEarnings = [Double]()
    //        var filteredFootfall = data
    //
    //        //Fetch Data incase not having filtered already
    //        if data == nil, (data?.count ?? 0 <= 0) {
    //            let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
    //
    //            //Date filter applied
    //            filteredFootfall = technicianDataJSON?.data?.revenue_transactions?.filter({ (footFall) -> Bool in
    //                if let date = footFall.date?.date()?.startOfDay {
    //                    return  (date >= dateRange.start && date <= dateRange.end) &&
    //                            (((footFall.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services) && ((footFall.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.salon) || (footFall.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.home))) || (footFall.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.retail))
    //                }
    //                return false
    //            })
    //        }
    //        else {
    //            filteredFootfall = filteredFootfall?.filter({(($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services) && (($0.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.salon) || ($0.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.home))) || ($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.retail)})
    //        }
    //
    //        let saloneGraphData = graphData(forData: data, atIndex: 0, dateRange: dateRange, dateRangeType: dateRangeType)
    //
    //        let homeGraphData = graphData(forData: data, atIndex: 1, dateRange: dateRange, dateRangeType: dateRangeType)
    //
    //        let retailGraphData = graphData(forData: data, atIndex: 2, dateRange: dateRange, dateRangeType: dateRangeType)
    //
    //        if saloneGraphData.count == homeGraphData.count, homeGraphData.count == retailGraphData.count {
    //            for (index, saloneValue) in saloneGraphData.enumerated() {
    //                let totalValue = saloneValue + homeGraphData[index] + retailGraphData[index]
    //                totalFixedEarnings.append(totalValue)
    //            }
    //        }
    //
    //        return totalFixedEarnings
            return [0.0]
        }
        
        func updateOtherEarningsData(atIndex indexPath:IndexPath, withStartDate startDate: Date?, endDate: Date = Date().startOfDay, rangeType:DateRangeType) {
            let selectedIndex = indexPath.row - 1
            let dateRange = DateRange(startDate!, endDate)
            
            let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
            
    //        //Date filter applied
    //        let dateFilteredFootfall = technicianDataJSON?.data?.revenue_transactions?.filter({ (revenue) -> Bool in
    //            if let date = revenue.date?.date()?.startOfDay {
    //                return date >= dateRange.start && date <= dateRange.end
    //            }
    //            return false
    //        })
    //
    //        if(selectedIndex >= 0){
    //            let model = dataModel[selectedIndex]
    //            model.dateRangeType = rangeType
    //            if model.dateRangeType == .cutome {
    //                model.customeDateRange = dateRange
    //            }
    //
    //            update(modeData: model, withData: dateFilteredFootfall, atIndex: selectedIndex, dateRange: dateRange, dateRangeType: rangeType)
    //            graphData[selectedIndex] = getGraphEntry(model.title,forData: dateFilteredFootfall, atIndex: selectedIndex, dateRange: dateRange, dateRangeType: rangeType)
    //        }
    //        else if let _ = headerModel {
    //            headerModel?.dateRangeType = rangeType
    //            if headerModel?.dateRangeType == .cutome {
    //                headerModel?.customeDateRange = dateRange
    //            }
    //
    //            updateHeaderModel(withData: dateFilteredFootfall, dateRange: dateRange, dateRangeType: rangeType)
    //            headerGraphData = getTotalFixedEarningsGraphEntry(forData:dateFilteredFootfall, dateRange: dateRange, dateRangeType: rangeType)
    //        }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        func update(modeData:EarningsCellDataModel, withData data: [Dashboard.GetRevenueDashboard.RevenueTransaction]? = nil, atIndex index : Int, dateRange:DateRange, dateRangeType: DateRangeType) {
            
            var filteredFootfall = data
            
            //Fetch Data incase not having filtered already
            if data == nil, (data?.count ?? 0 <= 0) {
                let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
                
                //Date filter applied
                filteredFootfall = technicianDataJSON?.data?.revenue_transactions?.filter({ (revenue) -> Bool in
                    if let date = revenue.date?.date()?.startOfDay {
                        return date >= dateRange.start && date <= dateRange.end
                    }
                    return false
                })
            }
            
            var value : Double = 0.0
            switch index {
            case 0:
                //service
                let salonServiceData = filteredFootfall?.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services) && ($0.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.salon)}) ?? []
                value = Double(salonServiceData.unique(map: {$0.invoice_number}).count)
                
            case 1:
                //Home
                let homeServiceRevenueData = filteredFootfall?.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services) && ($0.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.home)}) ?? []
                value = Double(homeServiceRevenueData.unique(map: {$0.invoice_number}).count)
                
            case 2:
                //Retail
                let retailData = filteredFootfall?.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.retail)})
                value = Double(retailData?.unique(map: {$0.invoice_number}).count ?? 0)
                
            default:
                print("****************** UNKNOWN ******************")
            }
            
            dataModel[index] = EarningsCellDataModel(earningsType: modeData.earningsType, title: modeData.title, value: [value.rounded().abbrevationString], subTitle: modeData.subTitle, showGraph: modeData.showGraph, cellType: modeData.cellType, isExpanded: modeData.isExpanded, dateRangeType: modeData.dateRangeType, customeDateRange: modeData.customeDateRange)
        }
        
        func updateHeaderModel(withData data: [Dashboard.GetRevenueDashboard.RevenueTransaction]? = nil, dateRange:DateRange, dateRangeType: DateRangeType) {
            
            var filteredFootfall = data
            let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
            
            //Fetch Data incase not having filtered already
            if data == nil, (data?.count ?? 0 <= 0) {
                //Date filter applied
                filteredFootfall = technicianDataJSON?.data?.revenue_transactions?.filter({ (revenue) -> Bool in
                    if let date = revenue.date?.date()?.startOfDay {
                        return date >= dateRange.start && date <= dateRange.end
                    }
                    return false
                })
            }
            
            //service
            let salonServiceData = filteredFootfall?.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services) && ($0.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.salon)}) ?? []
            let salonServiceCount : Int = salonServiceData.unique(map: {$0.invoice_number}).count
            print("serviceToatal conunt : \(salonServiceCount)")
            
            //Home
            let homeServiceRevenueData = filteredFootfall?.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services) && ($0.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.home)}) ?? []
            let homeServiceCount : Int = homeServiceRevenueData.unique(map: {$0.invoice_number}).count
            print("homeServiceTotal conunt : \(homeServiceCount)")
            
            //Retail
            let retailData = filteredFootfall?.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.retail)})
            let retailCount : Int = retailData?.unique(map: {$0.invoice_number}).count ?? 0
            print("retail conunt : \(retailCount)")
            
            headerModel?.value = Double(salonServiceCount + homeServiceCount + retailCount)
        }
      func doSomething()
      {
        let request = OtherEarnings.Something.Request()
        interactor?.doSomething(request: request)
      }
      
      func displaySomething(viewModel: OtherEarnings.Something.ViewModel)
      {
        //nameTextField.text = viewModel.name
      }
    }

    extension OtherEarningsViewController: EarningsFilterDelegate {
        
        func actionDateFilter() {
            print("Date Filter")
            let vc = DateFilterVC.instantiate(fromAppStoryboard: .Incentive)
            self.view.alpha = screenPopUpAlpha
            vc.fromChartFilter = false
            vc.selectedRangeTypeString = dateRangeType.rawValue
            vc.cutomRange = otherEarningsDateRange
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
            vc.viewDismissBlock = { [unowned self] (result, startDate, endDate, rangeTypeString) in
                // Do something
                self.view.alpha = 1.0
                if(result){
                    fromChartFilter = false
                    dateRangeType = DateRangeType(rawValue: rangeTypeString ?? "") ?? .cutome
                    
                    if(dateRangeType == .cutome), let start = startDate, let end = endDate
                    {
                        otherEarningsDateRange = DateRange(start,end)
                    }
                    updateOtherEarningsData(startDate: startDate ?? Date.today, endDate: endDate ?? Date.today)
                }
            }
        }
        
        func actionNormalFilter() {
            print("Normal Filter")
        }
        
        func calculateSalonService(filterArray: [Dashboard.GetRevenueDashboard.RevenueTransaction], invoiceNumbers: [String], dateRange: DateRange, dateRangeType: DateRangeType) -> [Double] {
            var values = [Double]()
            
            //service
            let serviceData = filterArray.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services) && ($0.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.salon) && invoiceNumbers.contains($0.invoice_number ?? "")})
            
            
            switch dateRangeType
            {
            case .yesterday, .today, .week, .mtd:
                let dates = dateRange.end.dayDates(from: dateRange.start)
                for objDt in dates {
                    let data = serviceData.filter({$0.date == objDt})
                    let invoiceCount = data.unique(map: {$0.invoice_number}).count
                    values.append(Double(invoiceCount))
                }
                
            case .qtd, .ytd:
                let months = dateRange.end.monthNames(from: dateRange.start, withFormat: "yyyy-MM")
                for month in months {
                    let uniqueInvoiceCount = serviceData.filter({($0.date?.contains(month)) ?? false}).unique(map: {$0.invoice_number}).count
                    values.append(Double(uniqueInvoiceCount))
                }
                
            case .cutome:
                if dateRange.end.days(from: dateRange.start) > 31
                {
                    let months = dateRange.end.monthNames(from: dateRange.start, withFormat: "yyyy-MM")
                    for month in months {
                        let uniqueInvoiceCount = serviceData.filter({($0.date?.contains(month)) ?? false}).unique(map: {$0.invoice_number}).count
                        values.append(Double(uniqueInvoiceCount))
                    }
                }
                else {
                    let dates = dateRange.end.dayDates(from: dateRange.start)
                    for objDt in dates {
                        let data = serviceData.filter({$0.date == objDt})
                        let invoiceCount = data.unique(map: {$0.invoice_number}).count
                        values.append(Double(invoiceCount))
                    }
                }
            }
            
            return values
        }
        
        
        func calculateHomeService(filterArray: [Dashboard.GetRevenueDashboard.RevenueTransaction], invoiceNumbers: [String], dateRange: DateRange, dateRangeType: DateRangeType) -> [Double]{
            var values = [Double]()
            
            
            
            let homeServiceRevenueData = filterArray.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services) && ($0.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.home) && invoiceNumbers.contains($0.invoice_number  ?? "")})
            
            
            switch dateRangeType
            {
            case .yesterday, .today, .week, .mtd:
                let dates = dateRange.end.dayDates(from: dateRange.start)
                for objDt in dates {
                    let data = homeServiceRevenueData.filter({$0.date == objDt})
                    let invoiceCount = data.unique(map: {$0.invoice_number}).count
                    values.append(Double(invoiceCount))
                }
                
            case .qtd, .ytd:
                let months = dateRange.end.monthNames(from: dateRange.start, withFormat: "yyyy-MM")
                for month in months {
                    let uniqueInvoiceCount = homeServiceRevenueData.filter({($0.date?.contains(month)) ?? false}).unique(map: {$0.invoice_number}).count
                    values.append(Double(uniqueInvoiceCount))
                }
                
            case .cutome:
                if dateRange.end.days(from: dateRange.start) > 31
                {
                    let months = dateRange.end.monthNames(from: dateRange.start, withFormat: "yyyy-MM")
                    for month in months {
                        let uniqueInvoiceCount = homeServiceRevenueData.filter({($0.date?.contains(month)) ?? false}).unique(map: {$0.invoice_number}).count
                        values.append(Double(uniqueInvoiceCount))
                    }
                }
                else {
                    let dates = dateRange.end.dayDates(from: dateRange.start)
                    for objDt in dates {
                        let data = homeServiceRevenueData.filter({$0.date == objDt})
                        let invoiceCount = data.unique(map: {$0.invoice_number}).count
                        values.append(Double(invoiceCount))
                    }
                }
            }
            return values
        }
        
        func calculateRetailProduct(filterArray: [Dashboard.GetRevenueDashboard.RevenueTransaction], invoiceNumbers: [String], dateRange: DateRange, dateRangeType: DateRangeType) -> [Double]{
            var values = [Double]()
            
            
            let retailData = filterArray.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.retail) && invoiceNumbers.contains($0.invoice_number ?? "")})
            
            
            switch dateRangeType
            {
            case .yesterday, .today, .week, .mtd:
                let dates = dateRange.end.dayDates(from: dateRange.start)
                for objDt in dates {
                    let data = retailData.filter({$0.date == objDt})
                    let invoiceCount = data.unique(map: {$0.invoice_number}).count
                    values.append(Double(invoiceCount))
                }
                
            case .qtd, .ytd:
                let months = dateRange.end.monthNames(from: dateRange.start, withFormat: "yyyy-MM")
                for month in months {
                    let uniqueInvoiceCount = retailData.filter({($0.date?.contains(month)) ?? false}).unique(map: {$0.invoice_number}).count
                    values.append(Double(uniqueInvoiceCount))
                }
                
            case .cutome:
                if dateRange.end.days(from: dateRange.start) > 31
                {
                    let months = dateRange.end.monthNames(from: dateRange.start, withFormat: "yyyy-MM")
                    for month in months {
                        let uniqueInvoiceCount = retailData.filter({($0.date?.contains(month)) ?? false}).unique(map: {$0.invoice_number}).count
                        values.append(Double(uniqueInvoiceCount))
                    }
                }
                else {
                    let dates = dateRange.end.dayDates(from: dateRange.start)
                    for objDt in dates {
                        let data = retailData.filter({$0.date == objDt})
                        let invoiceCount = data.unique(map: {$0.invoice_number}).count
                        values.append(Double(invoiceCount))
                    }
                }
            }
            return values
        }
    }

    extension OtherEarningsViewController: EarningDetailsDelegate {
        
        func reloadData() {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        
        func actionDurationFilter(forCell cell: UITableViewCell) {
            guard let indexPath = tableView.indexPath(for: cell), dataModel.count >= indexPath.row else { return }
            
            let selectedIndex = indexPath.row - 1
            
            let vc = DateFilterVC.instantiate(fromAppStoryboard: .Incentive)
            vc.isFromProductivity = false
            self.view.alpha = screenPopUpAlpha
            vc.fromChartFilter = true
            if(selectedIndex >= 0){
                let model = dataModel[selectedIndex]
                vc.selectedRangeTypeString = model.dateRangeType.rawValue
                vc.cutomRange = model.customeDateRange
            }
            else if let model = headerModel {
                vc.selectedRangeTypeString = model.dateRangeType.rawValue
                vc.cutomRange = model.customeDateRange
            }
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
            vc.viewDismissBlock = { [unowned self] (result, startDate, endDate, rangeTypeString) in
                // Do something
                self.view.alpha = 1.0
                if result == true, startDate != nil, endDate != nil {
                    fromFilters = false
                    fromChartFilter = true
                    
                    let rangeType  = DateRangeType(rawValue: rangeTypeString ?? "") ?? .cutome
                    updateOtherEarningsData(atIndex: indexPath, withStartDate: startDate, endDate: endDate!, rangeType: rangeType)
                    
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    let text = "You have selected \(rangeTypeString ?? "MTD") filter from Charts."
                    self.showToast(alertTitle: alertTitle, message: text, seconds: toastMessageDuration)
                }
            }
        }
    }

    extension OtherEarningsViewController: UITableViewDelegate, UITableViewDataSource {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return dataModel.count + 1
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.earningDetailsHeaderCell, for: indexPath) as? EarningDetailsHeaderCell else {
                    return UITableViewCell()
                }
                if let model = headerModel {
                    var data:[GraphDataEntry] = []
                    if let hgraphData = headerGraphData {
                        data = [hgraphData]
                    }
                    cell.configureCell(model: model, data: data)
                }
                cell.delegate = self
                cell.parentVC = self
                cell.selectionStyle = .none
                return cell
            }
            else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.earningDetailsCell, for: indexPath) as? EarningDetailsCell else {
                    return UITableViewCell()
                }
                cell.selectionStyle = .none
                cell.delegate = self
                cell.parentVC = self
                
                let index = indexPath.row - 1
                let model = dataModel[index]
                let barGraph = graphData[index]
                
                cell.configureCell(model: model, data: [barGraph])
                return cell
            }
            
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("Selection")
        }
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.earningDetailsHeaderFilterCell) as? EarningDetailsHeaderFilterCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.configureCell(showDateFilter: true, showNormalFilter: false,  titleForDateSelection: dateRangeType.rawValue)
            cell.selectionStyle = .none
            return cell
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 60
        }
    }
