//
//  ProductivityViewController.swift
//  Enrich_TMA
//
//  Created by Harshal on 05/08/21.
//  Copyright (c) 2021 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol ProductivityDisplayLogic: class
{
    func displaySomething(viewModel: Productivity.Something.ViewModel)
}

class ProductivityVC: UIViewController, ProductivityDisplayLogic
{
    var interactor: ProductivityBusinessLogic?
    
    // MARK: Object lifecycle
    
    @IBOutlet private weak var tableView: UITableView!
    
    var headerModel: EarningsHeaderDataModel?
    var headerGraphData: GraphDataEntry?
    
    var dataModel = [EarningsCellDataModel]()
    var graphData = [GraphDataEntry]()
    
    var fromFilters : Bool = false
    
    var fromChartFilter : Bool = false
    
    var dateRangeType : DateRangeType = .mtd
    var productivityCutomeDateRange:DateRange = DateRange(Date.today.lastYear(), Date.today)
    
    
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
        let interactor = ProductivityInteractor()
        let presenter = ProductivityPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        doSomething()
        tableView.register(UINib(nibName: CellIdentifier.earningDetailsHeaderCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.earningDetailsHeaderCell)
        tableView.register(UINib(nibName: CellIdentifier.earningDetailsHeaderFilterCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.earningDetailsHeaderFilterCell)
        tableView.register(UINib(nibName: CellIdentifier.earningDetailsCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.earningDetailsCell)
        
        fromChartFilter = false
        dateRangeType = .mtd
        headerModel?.value = Double("")
        updateProductivityScreenData(startDate: Date.today.startOfMonth)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.addCustomBackButton(title: "Productivity")
    }
    
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    func updateProductivityScreenData(startDate: Date?, endDate: Date = Date().startOfDay) {
        
        EZLoadingActivity.show("Loading...", disableUI: true)
        DispatchQueue.main.async { [unowned self] () in
            productivityData(startDate:  startDate ?? Date.today, endDate: endDate)
            tableView.reloadData()
            EZLoadingActivity.hide()
        }
    }
    
    
    func updateProductivityData(atIndex indexPath:IndexPath, withStartDate startDate: Date?, endDate: Date = Date().startOfDay, rangeType:DateRangeType) {
        let selectedIndex = indexPath.row - 1
        let dateRange = DateRange(startDate!, endDate)
        
        let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
        
        //Date filter applied
        let dateFilteredProductivity = technicianDataJSON?.data?.quality_score_data?.filter({ (revenue) -> Bool in
            if let date = revenue.date?.date()?.startOfDay {
                return date >= dateRange.start && date <= dateRange.end
            }
            return false
        })
        
        if(selectedIndex >= 0){
            let model = dataModel[selectedIndex]
            model.dateRangeType = rangeType
            if model.dateRangeType == .cutome {
                model.customeDateRange = dateRange
            }
            
            update(modeData: model, withData: dateFilteredProductivity, atIndex: selectedIndex, dateRange: dateRange, dateRangeType: rangeType)
            
            graphData[selectedIndex] = getGraphEntry(model.title, atIndex: selectedIndex, dateRange: dateRange, dateRangeType: rangeType)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func getGraphEntry(_ title:String, forData data:[Dashboard.GetRevenueDashboard.QualityScoreData]? = nil, atIndex index : Int, dateRange:DateRange, dateRangeType: DateRangeType) -> GraphDataEntry
    {
        let units = xAxisUnits(forDateRange: dateRange, rangeType: dateRangeType)
        let values = graphData(forData: data, atIndex: index, dateRange: dateRange, dateRangeType: dateRangeType)
        let graphColor = EarningDetails.Productivity.graphBarColor
        
        return GraphDataEntry(graphType: .barGraph, dataTitle: title, units: units, values: values, barColor: graphColor.first!)
    }
    
    func graphData(forData data:[Dashboard.GetRevenueDashboard.QualityScoreData]? = nil, atIndex index : Int, dateRange:DateRange, dateRangeType: DateRangeType) -> [Double] {
        
        var filteredProductivity = data
        
        if data == nil, (data?.count ?? 0 <= 0) {
            let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
            
            
            filteredProductivity = technicianDataJSON?.data?.quality_score_data?.filter({ (freeServices) -> Bool in
                if let date = freeServices.date?.date()?.startOfDay {
                    
                    return date >= dateRange.start && date <= dateRange.end
                }
                return false
            })
        }
        
        
        //RM Optimization
        if(index == 0){
            return calculateRMOptimization(dateRange: dateRange, dateRangeType: dateRangeType)
        }
        else if(index == 1){ // quality and safety audit
            return calculateQualityAndSafetyAudit(filterArray: filteredProductivity!, dateRange: dateRange, dateRangeType: dateRangeType)
        }
        // TODO: check with Firoz
        else{ // Revnue multiplier
            return calculateRevenueMultipliers(dateRange: dateRange, dateRangeType: dateRangeType)
        }
    }
    
    func doSomething()
    {
        let request = Productivity.Something.Request()
        interactor?.doSomething(request: request)
    }
    
    func displaySomething(viewModel: Productivity.Something.ViewModel)
    {
        //nameTextField.text = viewModel.name
    }
    
    func productivityData(startDate : Date, endDate : Date = Date().startOfDay){
        dataModel.removeAll()
        graphData.removeAll()
        let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
        
        let filteredProductivity = technicianDataJSON?.data?.quality_score_data?.filter({ (productivity) -> Bool in
            if let date = productivity.date?.date()?.startOfDay {
                
                return date >= startDate && date <= endDate
            }
            return false
        })
        
        //Handle Graph Scenarios
        let dateRange = DateRange(startDate, endDate)
        var graphRangeType = dateRangeType
        var graphDateRange = dateRange
        var filteredProductivityForGraph = filteredProductivity
        if (dateRangeType == .yesterday || dateRangeType == .today) {
            filteredProductivityForGraph = nil
            graphRangeType = .mtd
            graphDateRange = DateRange(graphRangeType.date!, Date().startOfDay)
        }
        
        //quality and safety
        let qualityScoreData = filteredProductivity?.filter({$0.score ?? 0 > 0})
        
        var qualityScoreDataCount : Double = 0.0
        for objqualityScoreData in qualityScoreData! {
            qualityScoreDataCount = qualityScoreDataCount + Double(objqualityScoreData.score!)
        }
        var showCount = (qualityScoreDataCount / Double(qualityScoreData!.count)) / 100
        if(qualityScoreDataCount == 0 || qualityScoreData?.count == 0)
        {
            showCount = 0
        }
        
        
        //RM Optimization
        //let rmOptimization = technicianDataJSON?.data?.rm_consumption
        var rmOptimizationCount = 0
        var rmOptimizationRemaning = 0
        
        
        let filteredrmOptimization = technicianDataJSON?.data?.rm_consumption?.filter({ (productivity) -> Bool in
            if let date = productivity.consumption_date?.date()?.startOfDay {
                
                return date >= startDate && date <= endDate
            }
            return false
        })
        
        
        if let count = filteredrmOptimization?.count, count > 0 {
            
            for objData in filteredrmOptimization!
            {
                rmOptimizationCount += objData.rm_consumption ?? 0
            }
            
            rmOptimizationCount /= count
            
            if(rmOptimizationCount <= 100){
                rmOptimizationRemaning = 100 - rmOptimizationCount
            }
            else {
                rmOptimizationRemaning = rmOptimizationCount - 100
            }
        }
        
        
        //RM Optimization
        //Data Model
        let RMOptimizationModel = EarningsCellDataModel(earningsType: .Productivity, title: "RM Optimization", value: [String(rmOptimizationCount)], subTitle: ["RM Optimization Deviation Is \(rmOptimizationRemaning)"], showGraph: true, cellType: .SingleValue, isExpanded: false, dateRangeType: graphRangeType, customeDateRange: productivityCutomeDateRange)
        dataModel.append(RMOptimizationModel)
        //Graph Data
        graphData.append(getGraphEntry(RMOptimizationModel.title, forData: filteredProductivityForGraph, atIndex: 0, dateRange: graphDateRange, dateRangeType: graphRangeType))
        
        
        //Quality & Safety Audit
        //Data Model
        let qualitySafetyAuditModel = EarningsCellDataModel(earningsType: .Productivity, title: "Quality & Safety Audit", value: [showCount.percent], subTitle: [""], showGraph: true, cellType: .SingleValue, isExpanded: false, dateRangeType: graphRangeType, customeDateRange: productivityCutomeDateRange)
        dataModel.append(qualitySafetyAuditModel)
        //Graph Data
        graphData.append(getGraphEntry(qualitySafetyAuditModel.title, forData: filteredProductivityForGraph, atIndex: 1, dateRange: graphDateRange, dateRangeType: graphRangeType))
        
        
        
        //Revenue Multiplier
        //Data Model
        let revenueMulti = revenueMultiplier(dateRange: graphDateRange)
        let revenueMultiplierModel = EarningsCellDataModel(earningsType: .Productivity, title: "Revenue Multiplier", value: [revenueMulti.roundedStringValue(toFractionDigits: 2)], subTitle: [""], showGraph: true, cellType: .SingleValue, isExpanded: false, dateRangeType: graphRangeType, customeDateRange: productivityCutomeDateRange)
        dataModel.append(revenueMultiplierModel)
        //Graph Data
        graphData.append(getGraphEntry(revenueMultiplierModel.title, forData: filteredProductivityForGraph, atIndex: 2, dateRange: graphDateRange, dateRangeType: graphRangeType))
        headerModel?.value = Double("")
        tableView.reloadData()
    }
    
    func update(modeData:EarningsCellDataModel, withData data: [Dashboard.GetRevenueDashboard.QualityScoreData]? = nil, atIndex index : Int, dateRange:DateRange, dateRangeType: DateRangeType) {
        
        var filteredProductivity = data
        
        let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
        
        //Fetch Data incase not having filtered already
        if data == nil, (data?.count ?? 0 <= 0) {
            
            
            //Date filter applied
            filteredProductivity = technicianDataJSON?.data?.quality_score_data?.filter({ (revenue) -> Bool in
                if let date = revenue.date?.date()?.startOfDay {
                    return date >= dateRange.start && date <= dateRange.end
                }
                return false
            })
        }
        
        switch index {
        case 0:
            // RM Optimization
            //RM Optimization
            //let rmOptimization = technicianDataJSON?.data?.rm_consumption
            var rmOptimizationCount = 0
            var rmOptimizationRemaning = 0
            
            
            let filteredrmOptimization = technicianDataJSON?.data?.rm_consumption?.filter({ (productivity) -> Bool in
                if let date = productivity.consumption_date?.date()?.startOfDay {
                    
                    return date >= dateRange.start && date <= dateRange.end
                }
                return false
            })
            
            
            if let count = filteredrmOptimization?.count, count > 0 {
                
                for objData in filteredrmOptimization!
                {
                    rmOptimizationCount += objData.rm_consumption ?? 0
                }
                
                rmOptimizationCount /= count
                
                if(rmOptimizationCount <= 100){
                    rmOptimizationRemaning = 100 - rmOptimizationCount
                }
                else {
                    rmOptimizationRemaning = rmOptimizationCount - 100
                }
            }
            dataModel[index] = EarningsCellDataModel(earningsType: modeData.earningsType, title: modeData.title, value: [String(rmOptimizationCount)], subTitle: ["RM Optimization Deviation Is \(rmOptimizationRemaning)"], showGraph: modeData.showGraph, cellType: modeData.cellType, isExpanded: modeData.isExpanded, dateRangeType: modeData.dateRangeType, customeDateRange: modeData.customeDateRange)
            
        case 1:
            // Quality and safety
            //quality and safety
            let qualityScoreData = filteredProductivity?.filter({$0.score ?? 0 > 0})
            
            var qualityScoreDataCount : Double = 0.0
            for objqualityScoreData in qualityScoreData! {
                qualityScoreDataCount = qualityScoreDataCount + Double(objqualityScoreData.score!)
            }
            var showCount = (qualityScoreDataCount / Double(qualityScoreData!.count)) / 100
            if(qualityScoreDataCount == 0 || qualityScoreData?.count == 0)
            {
                showCount = 0
            }
            
            dataModel[index] =  EarningsCellDataModel(earningsType: .Productivity, title: "Quality & Safety Audit", value: [showCount.percent], subTitle: [""], showGraph: modeData.showGraph, cellType: .SingleValue, isExpanded: modeData.isExpanded, dateRangeType: modeData.dateRangeType, customeDateRange: modeData.customeDateRange)
            
        case 2:
            // Revenue multiplier
            let revenueMulti = revenueMultiplier(dateRange: dateRange)
            dataModel[index] = EarningsCellDataModel(earningsType: .Productivity, title: "Revenue Multiplier", value: [revenueMulti.roundedStringValue(toFractionDigits: 2)], subTitle: [""], showGraph: modeData.showGraph, cellType: .SingleValue, isExpanded: modeData.isExpanded, dateRangeType: modeData.dateRangeType, customeDateRange: modeData.customeDateRange)
            
        default:
            break
        //                continue
        }
    }
    
    func xAxisUnits(forDateRange dateRange:DateRange, rangeType: DateRangeType) -> [String] {
        switch rangeType
        {
        
        case .yesterday, .today, .mtd:
            return dateRange.end.endOfMonth.dayDates(from: dateRange.start.startOfMonth, withFormat: "dd")
            
        case .week:
            return dateRange.end.dayDates(from: dateRange.start, withFormat: "dd")
            
        case .qtd, .ytd:
            return dateRange.end.monthNames(from: dateRange.start,withFormat: "MMM yy")
            
        case .cutome:
            /*
             case .cutome:
             
             if dateRange.end.monthName != dateRange.start.monthName
             {
             return dateRange.end.monthNames(from: dateRange.start, withFormat: "MMM yy")
             }
             else {
             return dateRange.end.dayDates(from: dateRange.start, withFormat: "dd")
             }
             }
             update if condition with this extension. On true else condition should execute for this
             */
            if dateRange.start.inSameMonth(asDate: dateRange.end) != true
            {
                return dateRange.end.monthNames(from: dateRange.start, withFormat: "MMM yy")
            }
            else {
                return dateRange.end.dayDates(from: dateRange.start, withFormat: "dd")
            }
        }
    }
    
    //Calculate Revenue Multiplier
    func calculateRevenueMultipliers(forData data:[Dashboard.GetRevenueDashboard.RevenueTransaction]? = nil, dateRange:DateRange, dateRangeType:DateRangeType) -> [Double]
    {
        var revenueMultipliers = [Double]()
        var filteredRevenueTransactions = data
        if data == nil, (data?.count ?? 0 <= 0) {
            
            let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
            
            filteredRevenueTransactions = technicianDataJSON?.data?.revenue_transactions?.filter({ (revenueTransactions) -> Bool in
                if let date = revenueTransactions.date?.date()?.startOfDay {
                    return date >= dateRange.start && date <= dateRange.end
                }
                return false
            })
        }
        
        
        switch dateRangeType
        {
        case .yesterday, .today, .week, .mtd:
            let dates = dateRange.end.dayDates(from: dateRange.start)
            for objDt in dates {
                if let transactions = filteredRevenueTransactions?.filter({$0.date == objDt}), let date = objDt.date()
                {
                    let result = revenueMultiplier(forData: transactions, dateRange: DateRange(date,date))
                    revenueMultipliers.append(result)
                }
                else {
                    revenueMultipliers.append(0.0)
                }
            }
        case .qtd, .ytd:
            let monthlyDates = dateRange.end.monthNames(from: dateRange.start, withFormat: "yyyy-MM-dd")
            for (index, monthlyDate) in monthlyDates.enumerated() {
                var result = 0.0
                if let date = monthlyDate.date() {
                    let mStartDate = (index == 0) ? date : date.startOfMonth
                    let mEndDate = (index == (monthlyDates.count - 1)) ? date : date.endOfMonth
                    let monthDateRange = DateRange(mStartDate, mEndDate)
                    result = revenueMultiplier(dateRange: monthDateRange)
                }
                revenueMultipliers.append(result)
            }
            
        case .cutome:
            
            if dateRange.end.monthName != dateRange.start.monthName
            {
                let monthlyDates = dateRange.end.monthNames(from: dateRange.start, withFormat: "yyyy-MM-dd")
                for (index, monthlyDate) in monthlyDates.enumerated() {
                    var result = 0.0
                    if let date = monthlyDate.date() {
                        let mStartDate = (index == 0) ? date : date.startOfMonth
                        let mEndDate = (index == (monthlyDates.count - 1)) ? date : date.endOfMonth
                        let monthDateRange = DateRange(mStartDate, mEndDate)
                        result = revenueMultiplier(dateRange: monthDateRange)
                    }
                    revenueMultipliers.append(result)
                }
            }
            else {
                let dates = dateRange.end.dayDates(from: dateRange.start)
                for objDt in dates {
                    if let transactions = filteredRevenueTransactions?.filter({$0.date == objDt}), let date = objDt.date()
                    {
                        let result = revenueMultiplier(forData: transactions, dateRange: DateRange(date,date))
                        revenueMultipliers.append(result)
                    }
                    else {
                        revenueMultipliers.append(0.0)
                    }
                }
            }
        }
        
        return revenueMultipliers
    }
    
    func revenueMultiplier(forData data:[Dashboard.GetRevenueDashboard.RevenueTransaction]? = nil, dateRange:DateRange) -> Double {
        
        let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
        let formula = technicianDataJSON?.data?.configuration?.revenue_multiplier_formula
        let configuration = technicianDataJSON?.data?.configuration?.dictionary
        
        var filteredRevenueTransactions:[[String:Any]]? = data?.compactMap({$0.dictionary})
        if data == nil, (data?.count ?? 0 <= 0) {
            filteredRevenueTransactions = technicianDataJSON?.data?.revenue_transactions?.filter({ (revenueTransactions) -> Bool in
                if let date = revenueTransactions.date?.date()?.startOfDay {
                    return date >= dateRange.start && date <= dateRange.end
                }
                return false
            }).map({$0.dictionary}) as? [[String:Any]]
        }
        
        
        guard let _ = formula, filteredRevenueTransactions?.count ?? 0 > 0
        else { return 0.0 }
        
        var revenueMultiExpressionData = [String:Double]()
        let revenueTransactionsKeys = filteredRevenueTransactions?.first?.keys
        for comp in formula!.expressionComponants() {
            if revenueTransactionsKeys != nil, revenueTransactionsKeys!.contains(comp) {
                let sum = filteredRevenueTransactions?.map({(($0[comp] as? Double) ?? 0.0)}).reduce(0) {$0 + $1}
                revenueMultiExpressionData[comp] = sum
            }
            else if let keys = configuration?.keys, keys.contains(comp), var value = configuration?[comp] as? Double {
                if  comp.lowercased() == "ctc" ||
                        comp.lowercased() == "fix_pay" ||
                        comp.lowercased() == "take_home_salary"
                {
                    let perDay = value/Double(dateRange.end.daysInMonth())
                    value = perDay * Double(dateRange.end.days(from: dateRange.start) + 1) //Considering days till today
                }
                revenueMultiExpressionData[comp] = value
            }
        }
        
        return formula!.expression.expressionValue(with: revenueMultiExpressionData, context: nil) as? Double ?? 0.0
    }
    
    //calculate RMOptimization
    func calculateRMOptimization(dateRange:DateRange, dateRangeType: DateRangeType) -> [Double]{
        var rmOptimizationValues = [Double]()
        
        let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
        
        let filteredrmOptimization = technicianDataJSON?.data?.rm_consumption?.filter({ (productivity) -> Bool in
            if let date = productivity.consumption_date?.date()?.startOfDay {
                
                return date >= dateRange.start && date <= dateRange.end
            }
            return false
        })
        
        switch dateRangeType
        {
        case .yesterday, .today, .week, .mtd:
            let dates = dateRange.end.dayDates(from: dateRange.start)
            for objDt in dates {
                if let data = filteredrmOptimization?.filter({$0.consumption_date == objDt}).first{
                    rmOptimizationValues.append(Double(data.rm_consumption ?? Int(0.0)))
                }
                else {
                    rmOptimizationValues.append(Double(0.0))
                }
            }
        case .qtd, .ytd:
            let months = dateRange.end.monthNames(from: dateRange.start, withFormat: "MMM yy")
            for qMonth in months {
                let value = filteredrmOptimization?.map ({ (rmOptimization) -> Double in
                    if let rMonth = rmOptimization.consumption_date?.date()?.string(format: "MMM yy"),
                       rMonth == qMonth
                    {
                        return Double(rmOptimization.rm_consumption ?? Int(0.0))
                    }
                    return 0.0
                }).reduce(0) {$0 + $1} ?? 0.0
                
                rmOptimizationValues.append(value)
            }
            
        case .cutome:
            
            if dateRange.end.monthName != dateRange.start.monthName
            {
                let months = dateRange.end.monthNames(from: dateRange.start, withFormat: "MMM yy")
                for qMonth in months {
                    let value = filteredrmOptimization?.map ({ (rmOptimization) -> Double in
                        if let rMonth = rmOptimization.consumption_date?.date()?.string(format: "MMM yy"),
                           rMonth == qMonth
                        {
                            return Double(rmOptimization.rm_consumption ?? Int(0.0))
                        }
                        return 0.0
                    }).reduce(0) {$0 + $1} ?? 0.0
                    
                    rmOptimizationValues.append(value)
                }
            }
            else {
                let dates = dateRange.end.dayDates(from: dateRange.start)
                for objDt in dates {
                    if let data = filteredrmOptimization?.filter({$0.consumption_date == objDt}).first
                    {
                        rmOptimizationValues.append(Double(data.rm_consumption ?? Int(0.0)))
                    }
                    else {
                        rmOptimizationValues.append(Double(0.0))
                    }
                }
            }
        }
        
        return rmOptimizationValues
    }
    
    //calculate data for quality and safety for graphs
    func calculateQualityAndSafetyAudit(filterArray: [Dashboard.GetRevenueDashboard.QualityScoreData] , dateRange:DateRange, dateRangeType: DateRangeType) -> [Double]{
        
        var qualityAndSafetyValues = [Double]()
        
        //quality and safety
        let qualityScoreData = filterArray.filter({$0.score ?? 0 > 0})
        
        switch dateRangeType
        {
        case .yesterday, .today, .week, .mtd:
            let dates = dateRange.end.dayDates(from: dateRange.start)
            for objDt in dates {
                if let data = qualityScoreData.filter({$0.date == objDt}).first{
                    qualityAndSafetyValues.append(Double(data.score ?? Int(0.0)))
                }
                else {
                    qualityAndSafetyValues.append(Double(0.0))
                }
            }
        case .qtd, .ytd:
            let months = dateRange.end.monthNames(from: dateRange.start, withFormat: "MMM yy")
            for qMonth in months {
                let value = qualityScoreData.map ({ (quality) -> Double in
                    if let rMonth = quality.date?.date()?.string(format: "MMM yy"),
                       rMonth == qMonth
                    {
                        return Double(quality.score ?? Int(0.0))
                    }
                    return 0.0
                }).reduce(0) {$0 + $1}
                
                qualityAndSafetyValues.append(value)
            }
            
        case .cutome:
            
            if dateRange.end.monthName != dateRange.start.monthName
            {
                let months = dateRange.end.monthNames(from: dateRange.start, withFormat: "MMM yy")
                for qMonth in months {
                    let value = qualityScoreData.map ({ (quality) -> Double in
                        if let rMonth = quality.date?.date()?.string(format: "MMM yy"),
                           rMonth == qMonth
                        {
                            return Double(quality.score ?? Int(0.0))
                        }
                        return 0.0
                    }).reduce(0) {$0 + $1}
                    
                    qualityAndSafetyValues.append(value)
                }
            }
            else {
                let dates = dateRange.end.dayDates(from: dateRange.start)
                for objDt in dates {
                    if let data = qualityScoreData.filter({$0.date == objDt}).first
                    {
                        qualityAndSafetyValues.append(Double(data.score ?? Int(0.0)))
                    }
                    else {
                        qualityAndSafetyValues.append(Double(0.0))
                    }
                }
            }
        }
        
        return qualityAndSafetyValues
    }
    
}

extension ProductivityVC: EarningsFilterDelegate {
    
    func actionDateFilter() {
        let vc = DateFilterVC.instantiate(fromAppStoryboard: .Incentive)
        self.view.alpha = screenPopUpAlpha
        vc.fromChartFilter = false
        vc.selectedRangeTypeString = dateRangeType.rawValue
        vc.cutomRange = productivityCutomeDateRange
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
        vc.viewDismissBlock = { [unowned self] (result, startDate, endDate, rangeTypeString) in
            // Do something
            self.view.alpha = 1.0
            if(result){
                
                self.view.alpha = 1.0
                if(result){
                    dateRangeType = DateRangeType(rawValue: rangeTypeString ?? "") ?? .cutome
                    
                    if(dateRangeType == .cutome), let start = startDate, let end = endDate
                    {
                        productivityCutomeDateRange = DateRange(start,end)
                    }
                    updateProductivityScreenData(startDate: startDate ?? Date.today, endDate: endDate ?? Date.today)
                    
                    tableView.reloadData()
                }
            }
        }
    }
    
    func actionNormalFilter() {
        print("Normal Filter")
    }
}

extension ProductivityVC: EarningDetailsDelegate {
    
    func reloadData() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func actionDurationFilter(forCell cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell), dataModel.count >= indexPath.row else { return }
        
        let selectedIndex = indexPath.row - 1
        
        let vc = DateFilterVC.instantiate(fromAppStoryboard: .Incentive)
        vc.isFromProductivity = true
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
                updateProductivityData(atIndex: indexPath, withStartDate: startDate, endDate: endDate!, rangeType: rangeType)
                
                tableView.reloadRows(at: [indexPath], with: .automatic)
                let text = "You have selected \(rangeTypeString ?? "MTD") filter from Charts."
                self.showToast(alertTitle: alertTitle, message: text, seconds: toastMessageDuration)
            }
        }
    }
}


extension ProductivityVC: UITableViewDelegate, UITableViewDataSource {
    
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
                cell.configureCell(model: model, data: [])
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
            
            cell.delegate = self
            cell.parentVC = self
            cell.selectionStyle = .none
            
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
        cell.configureCell(showDateFilter: true, showNormalFilter: false, titleForDateSelection: dateRangeType.rawValue)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}
