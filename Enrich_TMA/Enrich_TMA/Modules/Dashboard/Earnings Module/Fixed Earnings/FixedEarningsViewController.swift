//
//  FixedEarningsViewController.swift
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

protocol FixedEarningsDisplayLogic: class
{
    func displaySomething(viewModel: FixedEarnings.Something.ViewModel)
}

class FixedEarningsViewController: UIViewController, FixedEarningsDisplayLogic, EarningDetailsDelegate
{
    var interactor: FixedEarningsBusinessLogic?
    var router: (NSObjectProtocol & FixedEarningsRoutingLogic & FixedEarningsDataPassing)?
    var selectedIndx = IndexPath()
    @IBOutlet private weak var tableView: UITableView!
    var dateRangeType : DateRangeType = .mtd
    var fixedEarningsDateRange:DateRange = DateRange(Date.today.lastYear(), Date.today)
    var fromDidSelect : Bool = false
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
        let interactor = FixedEarningsInteractor()
        let presenter = FixedEarningsPresenter()
        let router = FixedEarningsRouter()
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
        tableView.register(UINib(nibName: CellIdentifier.earningDetailsTViewTrendHeaderCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.earningDetailsTViewTrendHeaderCell)
        
        tableView.register(UINib(nibName: CellIdentifier.earningDetailsHeaderFilterCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.earningDetailsHeaderFilterCell)
        tableView.register(UINib(nibName: CellIdentifier.earningDetailsViewTrendCellTableViewCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.earningDetailsViewTrendCellTableViewCell)
        fromDidSelect = false
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        fromChartFilter = false
        dateRangeType = .mtd
        updateFixedEarningsData(startDate: Date.today.startOfMonth)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.addCustomBackButton(title: "Fixed Earnings")
    }
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    func updateFixedEarningsData(startDate: Date?, endDate: Date = Date().startOfDay) {
        
        EZLoadingActivity.show("Loading...", disableUI: true)
        fixedEarningsData(startDate: startDate ?? Date.today, endDate: endDate, completion: nil)
    }
    
    func calculateTotalFixedEarnings(dateRange : DateRange) {
        let earningsJSON = UserDefaults.standard.value(Dashboard.GetEarningsDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_EarningsDashboard)
        var graphRangeType = dateRangeType
        var graphDateRange = fixedEarningsDateRange // need to change
        let filteredFixedEarningsForGraph = [Dashboard.GetRevenueDashboard.RevenueTransaction]()
        if (dateRangeType == .yesterday || dateRangeType == .today) {
            //            filteredFixedEarningsForGraph = nil
            graphRangeType = .mtd
            graphDateRange = DateRange(graphRangeType.date!, Date().startOfDay)
        }
        var amount : Int = 0
        let dataArray = earningsJSON?.data?.groups?.filter({EarningDetails(rawValue: $0.group_label ?? "") == EarningDetails.Fixed_Earning}) ?? []
        
        if(dateRangeType == .mtd){
        let currentMonth = Int(Date.today.string(format: "M"))
            for data in dataArray {
            for parameter in data.parameters ?? [] {
                let value = parameter.transactions?.filter({$0.month == currentMonth})
                //                value?.first?.amount
                amount += value?.first?.amount ?? 0
            }
        }
        
        }
        else {
            let months = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
            //var amount = 0
            for data in dataArray {
            for parameter in data.parameters ?? [] {
                    for month in months {
                    let value = parameter.transactions?.filter({$0.month == month})
                    amount += value?.first?.amount ?? 0
                }
            }
        }
        }
        
        headerModel?.value = Double(amount)
        headerModel?.dateRangeType = graphRangeType
        headerGraphData = getTotalFixedEarningsGraphEntry(forData: filteredFixedEarningsForGraph, dateRange: graphDateRange, dateRangeType: graphRangeType)
    }
    
    func fixedEarningsData(startDate : Date, endDate : Date = Date().startOfDay, completion: (() -> Void)? ) {
        dataModel.removeAll()
        graphData.removeAll()
        
        let earningsJSON = UserDefaults.standard.value(Dashboard.GetEarningsDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_EarningsDashboard)
        
        let dateRange = DateRange(startDate, endDate)

        fromDidSelect = false
        var graphRangeType = dateRangeType
        var graphDateRange = dateRange
        
        let currentMonth = Int(endDate.string(format: "M")) ?? 1
        
        if (dateRangeType == .mtd) {
            //filteredFixedEarningsForGraph = nil
            graphRangeType = .qtd
            graphDateRange = DateRange(graphRangeType.date!, Date().startOfDay)
        }
        
        let dataArray = earningsJSON?.data?.groups?.filter({EarningDetails(rawValue: $0.group_label ?? "") == EarningDetails.Fixed_Earning}) ?? []
        var index = 0
        for data in dataArray {
            if(dateRangeType == .mtd){
            for parameter in data.parameters ?? [] {
                
                let value = parameter.transactions?.filter({$0.month == currentMonth})
                //                value?.first?.amount
                let model = EarningsCellDataModel(earningsType: .Fixed_Earning, title: parameter.name ?? "", value: [value?.first?.amount?.roundedStringValue() ?? ""], subTitle: [parameter.comment ?? ""], showGraph: true, cellType: .SingleValue, isExpanded: false, dateRangeType: graphRangeType, customeDateRange: graphDateRange)
                dataModel.append(model)
                graphData.append(getGraphEntry(parameter.name ?? "", forData: parameter.transactions, atIndex: index, dateRange: graphDateRange, dateRangeType: graphRangeType))
                
                index += 1
                }
            }
            else {
                let months = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
                var amount = 0
                for parameter in data.parameters ?? [] {
                        for month in months {
                        let value = parameter.transactions?.filter({$0.month == month})
                        amount += value?.first?.amount ?? 0
                    }
                    let model = EarningsCellDataModel(earningsType: .Fixed_Earning, title: parameter.name ?? "", value: [amount.roundedStringValue()], subTitle: [parameter.comment ?? ""], showGraph: true, cellType: .SingleValue, isExpanded: false, dateRangeType: graphRangeType, customeDateRange: graphDateRange)
                    dataModel.append(model)
                    graphData.append(getGraphEntry(parameter.name ?? "", forData: parameter.transactions, atIndex: index, dateRange: graphDateRange, dateRangeType: graphRangeType))
                    
                    index += 1
                    amount = 0
                }
            }
            index = 0
        }
        calculateTotalFixedEarnings(dateRange: dateRange)
        tableView.reloadData()
        EZLoadingActivity.hide()
    }
    
    func getGraphEntry(_ title:String, forData data:[Dashboard.GetEarningsDashboard.Transaction]? = nil, atIndex index : Int, dateRange:DateRange, dateRangeType: DateRangeType) -> GraphDataEntry
    {
        let units = xAxisUnitsEarnings(forDateRange: dateRange, rangeType: dateRangeType)
        let values = graphData(forData: data, atIndex: index, dateRange: dateRange, dateRangeType: dateRangeType)
        let graphColor = EarningDetails.Fixed_Earning.graphBarColor
        
        return GraphDataEntry(graphType: .barGraph, dataTitle: title, units: units, values: values, barColor: graphColor.first!)
    }
    
    func graphData(forData data:[Dashboard.GetEarningsDashboard.Transaction]? = nil, atIndex index : Int, dateRange:DateRange, dateRangeType: DateRangeType) -> [Double] {
        var values = [Double]()
        switch dateRangeType {
        case .yesterday, .today, .week, .mtd:
            let month = Int(dateRange.end.string(format: "M"))
            
            
                for objData in data ?? [] {
                    if objData.month == month {
                        values.append(Double(objData.amount ?? 0))
                    }
                }
            return values
            
        case .qtd, .ytd :
            let months = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
            for month in months{
//                let data = filteredRevenue?.filter({($0.date?.contains(month)) ?? false}).map({$0.total})
//                let value = data?.reduce(0) {$0 + ($1 ?? 0.0)} ?? 0.0
                let val = data?.filter({($0.month == month) }).map({$0.amount})
                let vals = val?.reduce(0) {$0 + ($1 ?? Int(0.0))}
                values.append(Double(vals ?? Int(0.0)))
            }
       
        case .cutome:
            break
        }
        return values
    }
    
    


func getTotalFixedEarningsGraphEntry(forData data:[Dashboard.GetRevenueDashboard.RevenueTransaction]? = nil, dateRange:DateRange, dateRangeType: DateRangeType) -> GraphDataEntry
{
    let units = xAxisUnits(forDateRange: dateRange, rangeType: dateRangeType)
    let values = totalFixedEarningsGraphData(forData: data, dateRange: dateRange, dateRangeType: dateRangeType)
    let graphColor = EarningDetails.Fixed_Earning.graphBarColor
    
    return GraphDataEntry(graphType: .barGraph, dataTitle: headerModel?.earningsType.headerTitle ?? "", units: units, values: values, barColor: graphColor.first!)
}

func totalFixedEarningsGraphData(forData data:[Dashboard.GetRevenueDashboard.RevenueTransaction]? = nil, dateRange:DateRange, dateRangeType: DateRangeType) -> [Double]
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

func updateFixedEarningsData(atIndex indexPath:IndexPath, withStartDate startDate: Date?, endDate: Date = Date().startOfDay, rangeType:DateRangeType) {
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

func update(modeData:EarningsCellDataModel, withData data: [Dashboard.GetEarningsDashboard.Transaction]? = nil, atIndex index : Int, dateRange:DateRange, dateRangeType: DateRangeType) {
    
    var filteredFootfall = data
    
//    //Fetch Data incase not having filtered already
//    if data == nil, (data?.count ?? 0 <= 0) {
//        let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
//
//        //Date filter applied
//        filteredFootfall = technicianDataJSON?.data?.revenue_transactions?.filter({ (revenue) -> Bool in
//            if let date = revenue.date?.date()?.startOfDay {
//                return date >= dateRange.start && date <= dateRange.end
//            }
//            return false
//        })
//    }
    
    var value : Double = 0.0
//    switch index {
//    case 0:
//        //service
//        let salonServiceData = filteredFootfall?.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services) && ($0.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.salon)}) ?? []
//        value = Double(salonServiceData.unique(map: {$0.invoice_number}).count)
//        
//    case 1:
//        //Home
//        let homeServiceRevenueData = filteredFootfall?.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services) && ($0.appointment_type ?? "").containsIgnoringCase(find:AppointmentType.home)}) ?? []
//        value = Double(homeServiceRevenueData.unique(map: {$0.invoice_number}).count)
//        
//    case 2:
//        //Retail
//        let retailData = filteredFootfall?.filter({($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.retail)})
//        value = Double(retailData?.unique(map: {$0.invoice_number}).count ?? 0)
//        
//    default:
//        print("****************** UNKNOWN ******************")
//    }
    
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
    let request = FixedEarnings.Something.Request()
    interactor?.doSomething(request: request)
}

func displaySomething(viewModel: FixedEarnings.Something.ViewModel)
{
    //nameTextField.text = viewModel.name
}
}

extension FixedEarningsViewController: EarningsFilterDelegate {
    
    func actionDateFilter() {
        print("Date Filter")
        let vc = EarningsDateFilterViewController.instantiate(fromAppStoryboard: .Earnings)
        self.view.alpha = screenPopUpAlpha
        vc.fromChartFilter = false
        vc.selectedRangeTypeString = dateRangeType.rawValue
        vc.cutomRange = fixedEarningsDateRange
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
        vc.viewDismissBlock = { [unowned self] (result, startDate, endDate, rangeTypeString) in
            // Do something
            self.view.alpha = 1.0
            if(result){
                fromChartFilter = false
                dateRangeType = DateRangeType(rawValue: rangeTypeString ?? "") ?? .cutome

                if(dateRangeType == .cutome), let start = startDate, let end = endDate
                {
                    fixedEarningsDateRange = DateRange(start,end)
                }
                updateFixedEarningsData(startDate: startDate ?? Date.today, endDate: endDate ?? Date.today)
            }
        }
    }
    
    func actionNormalFilter() {
        print("Normal Filter")
    }
    func calculateData(filterArray: [Dashboard.GetEarningsDashboard.Transaction], dateRange: DateRange, dateRangeType: DateRangeType) -> [Double]{
        var value = [Double]()
        
        
        switch dateRangeType
        {
        case .yesterday, .today, .week, .mtd:
            let dates = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
            for objDt in dates {
                let amount = filterArray.filter({$0.month == objDt}).first
                value.append(Double(amount?.amount ?? 0))
            }
            
            
            
        case .qtd, .ytd:
            let months = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
            var amount = 0
            for month in months {
                let amt = filterArray.filter({$0.month == month}).first
                amount += amt?.amount ?? 0
                value.append(Double(amount))
            }
            
        case .cutome:
            value.append(0.0)
//            if dateRange.end.days(from: dateRange.start) > 31
//            {
//                let months = dateRange.end.monthNames(from: dateRange.start, withFormat: "yyyy-MM")
//                for month in months {
//                    let uniqueInvoiceCount = serviceData.filter({($0.date?.contains(month)) ?? false}).unique(map: {$0.invoice_number}).count
//                    values.append(Double(uniqueInvoiceCount))
//                }
//            }
//            else {
//                let dates = dateRange.end.dayDates(from: dateRange.start)
//                for objDt in dates {
//                    let data = serviceData.filter({$0.date == objDt})
//                    let invoiceCount = data.unique(map: {$0.invoice_number}).count
//                    values.append(Double(invoiceCount))
//                }
//            }
        }
        
        return value
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

extension FixedEarningsViewController: EarningDetailsViewTrendDelegate {
    
    func reloadData() {
//        self.tableView.beginUpdates()
//        self.tableView.endUpdates()
        self.tableView.reloadData()
    }
    
    func actionDurationFilter(forCell cell: UITableViewCell) {
//        guard let indexPath = tableView.indexPath(for: cell), dataModel.count >= indexPath.row else { return }
//
//        let selectedIndex = indexPath.row - 1
//
//        let vc = EarningsDateFilterViewController.instantiate(fromAppStoryboard: .Earnings)
//        vc.isFromProductivity = false
//        self.view.alpha = screenPopUpAlpha
//        vc.fromChartFilter = true
//        if(selectedIndex >= 0){
//            let model = dataModel[selectedIndex]
//            vc.selectedRangeTypeString = model.dateRangeType.rawValue
//            vc.cutomRange = model.customeDateRange
//        }
//        else if let model = headerModel {
//            vc.selectedRangeTypeString = model.dateRangeType.rawValue
//            vc.cutomRange = model.customeDateRange
//        }
//        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
//        vc.viewDismissBlock = { [unowned self] (result, startDate, endDate, rangeTypeString) in
//            // Do something
//            self.view.alpha = 1.0
//            if result == true, startDate != nil, endDate != nil {
//                fromFilters = false
//                fromChartFilter = true
//
//                let rangeType  = DateRangeType(rawValue: rangeTypeString ?? "") ?? .cutome
//                updateFixedEarningsData(atIndex: indexPath, withStartDate: startDate, endDate: endDate!, rangeType: rangeType)
//                
//                tableView.reloadRows(at: [indexPath], with: .automatic)
//                let text = "You have selected \(rangeTypeString ?? "MTD") filter from Charts."
//                self.showToast(alertTitle: alertTitle, message: text, seconds: toastMessageDuration)
//            }
//        }
    }
}

extension FixedEarningsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.earningDetailsTViewTrendHeaderCell, for: indexPath) as? EarningDetailsTViewTrendHeaderCell else {
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.earningDetailsViewTrendCellTableViewCell, for: indexPath) as? EarningDetailsViewTrendCellTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.delegate = self
            cell.parentVC = self
            
            let index = indexPath.row - 1
            let model = dataModel[index]
            let barGraph = graphData[index]
            cell.dateRangeType = dateRangeType
            cell.configureCell(model: model, data: [barGraph])
            return cell
        }
        
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        fromDidSelect = true
        selectedIndx = indexPath
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
