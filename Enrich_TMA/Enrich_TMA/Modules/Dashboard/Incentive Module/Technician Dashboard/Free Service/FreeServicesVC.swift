//
//  FreeServicesViewController.swift
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

protocol FreeServicesDisplayLogic: class
{
    func displaySomething(viewModel: FreeServices.Something.ViewModel)
}

class FreeServicesVC: UIViewController, FreeServicesDisplayLogic
{
    var interactor: FreeServicesBusinessLogic?
    
    // MARK: Object lifecycle
    
    @IBOutlet private weak var tableView: UITableView!
    
    var headerModel: EarningsHeaderDataModel?
    var headerGraphData: GraphDataEntry?
    
    var dataModel = [EarningsCellDataModel]()
    var graphData = [GraphDataEntry]()
    
    var dateSelectedTitle = ""
    var fromFilters : Bool = false
    
    var fromChartFilter : Bool = false
    
    var dateRangeType : DateRangeType = .mtd
    var freeServicesCutomeDateRange:DateRange = DateRange(Date.today.lastYear(), Date.today)

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
        let interactor = FreeServicesInteractor()
        let presenter = FreeServicesPresenter()
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
        updateFreeServiceScreenData(startDate: Date.today.startOfMonth)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.addCustomBackButton(title: "Free Services")
    }
    
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    func updateFreeServiceScreenData(startDate: Date?, endDate: Date = Date().startOfDay) {
        
        EZLoadingActivity.show("Loading...", disableUI: true)
//        DispatchQueue.main.async { [unowned self] () in
            freeServicesScreen(startDate:  startDate ?? Date.today, endDate: endDate)
//            tableView.reloadData()
//            EZLoadingActivity.hide()
//        }
    }
    
    func updateFreeServiceScreenData(atIndex indexPath:IndexPath, withStartDate startDate: Date?, endDate: Date = Date().startOfDay, rangeType:DateRangeType) {
        let selectedIndex = indexPath.row - 1
        let dateRange = DateRange(startDate!, endDate)
        
        if(selectedIndex >= 0){
            let model = dataModel[selectedIndex]
            model.dateRangeType = rangeType
            if model.dateRangeType == .cutome {
                model.customeDateRange = dateRange
            }
            
            graphData[selectedIndex] = getGraphEntry(model.title, atIndex: selectedIndex, dateRange: dateRange, dateRangeType: rangeType)
        }
        else if let _ = headerModel {
            headerModel?.dateRangeType = rangeType
            if headerModel?.dateRangeType == .cutome {
                headerModel?.customeDateRange = dateRange
            }
            
            headerGraphData = getTotalFreeServiceGraphEntry(dateRange: dateRange, dateRangeType: rangeType)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    

    func freeServicesScreen(startDate : Date, endDate : Date = Date().startOfDay) {
        //Handled Wrong function calling to avoid data mismatch
        guard fromChartFilter == false else {
            print("******* Wrong Function Called **********")
            return
        }
    
        dataModel.removeAll()
        graphData.removeAll()
        
        let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
        
        
        let filteredFreeServices = technicianDataJSON?.data?.revenue_transactions?.filter({ (freeServices) -> Bool in
            if let date = freeServices.date?.date()?.startOfDay {
                
                return date >= startDate && date <= endDate
            }
            return false
        })
        
        //Handle Graph Scenarios
        let dateRange = DateRange(startDate, endDate)
        var graphRangeType = dateRangeType
        var graphDateRange = dateRange
        var filteredFreeServiceForGraph = filteredFreeServices
        if (dateRangeType == .yesterday || dateRangeType == .today) {
            filteredFreeServiceForGraph = nil
            graphRangeType = .mtd
            graphDateRange = DateRange(graphRangeType.date!, Date().startOfDay)
        }
        
        var freeServiceRevenueCount : Double = 0.0
        var complimentaryGiftcardCount : Double = 0.0
        var groomingGiftcardCount : Double = 0.0
        
        for freeService in filteredFreeServices ?? [] {
            // Reward points
            if let fsRevenue = freeService.free_service_revenue, fsRevenue > 0 {
                freeServiceRevenueCount += fsRevenue
            }
            
            // complimentary_giftcard
            if let cGiftCard = freeService.complimentary_giftcard, cGiftCard > 0, (freeService.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services) {
                complimentaryGiftcardCount += cGiftCard
            }
            
            // grooming_giftcard
            if let gGiftCard = freeService.grooming_giftcard, gGiftCard > 0, (freeService.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services) {
                groomingGiftcardCount += gGiftCard
            }
        }
        
        print("reward points \(freeServiceRevenueCount)")
        print("complimentaryGiftcardCount \(complimentaryGiftcardCount)")
        print("groomingGiftcardCount \(groomingGiftcardCount)")
        
        //Reward points
        //Data Model
        let rewardPointsModel = EarningsCellDataModel(earningsType: .FreeServices, title: "Reward Points", value: [freeServiceRevenueCount.abbrevationString], subTitle: [""], showGraph: true, cellType: .SingleValue, isExpanded: false, dateRangeType: graphRangeType, customeDateRange: freeServicesCutomeDateRange)
        dataModel.append(rewardPointsModel)
        //Graph Data
        graphData.append(getGraphEntry(rewardPointsModel.title, forData: filteredFreeServiceForGraph, atIndex: 0, dateRange: graphDateRange, dateRangeType: graphRangeType))

        //complimentary_giftcard
        //Data Model
        let cGiftVoucherModel = EarningsCellDataModel(earningsType: .FreeServices, title: "Complimentary Gift Voucher", value: [complimentaryGiftcardCount.abbrevationString], subTitle: [""], showGraph: true, cellType: .SingleValue, isExpanded: false, dateRangeType: graphRangeType, customeDateRange: freeServicesCutomeDateRange)
        dataModel.append(cGiftVoucherModel)
        //Graph Data
        graphData.append(getGraphEntry(cGiftVoucherModel.title, forData: filteredFreeServiceForGraph, atIndex: 1, dateRange: graphDateRange, dateRangeType: graphRangeType))

        //grooming_giftcard
        //Data Model
        let gGiftCardModel = EarningsCellDataModel(earningsType: .FreeServices, title: "Grooming Gift Card", value: [groomingGiftcardCount.abbrevationString], subTitle: [""], showGraph: true, cellType: .SingleValue, isExpanded: false, dateRangeType: graphRangeType, customeDateRange: freeServicesCutomeDateRange)
        dataModel.append(gGiftCardModel)
        //Graph Data
        graphData.append(getGraphEntry(gGiftCardModel.title, forData: filteredFreeServiceForGraph, atIndex: 2, dateRange: graphDateRange, dateRangeType: graphRangeType))
       
        var freeServicesCount = Double(freeServiceRevenueCount + groomingGiftcardCount + complimentaryGiftcardCount)
        freeServicesCount = 0.8 * freeServicesCount
        headerModel?.value = freeServicesCount
        headerModel?.dateRangeType = graphRangeType
        headerGraphData = getTotalFreeServiceGraphEntry(forData: filteredFreeServiceForGraph, dateRange: graphDateRange, dateRangeType: graphRangeType)
        
        tableView.reloadData()
        EZLoadingActivity.hide()
    }
    
    func getGraphEntry(_ title:String, forData data:[Dashboard.GetRevenueDashboard.RevenueTransaction]? = nil, atIndex index : Int, dateRange:DateRange, dateRangeType: DateRangeType) -> GraphDataEntry
    {
        let units = xAxisUnits(forDateRange: dateRange, rangeType: dateRangeType)
        let values = graphData(forData: data, atIndex: index, dateRange: dateRange, dateRangeType: dateRangeType)
        let graphColor = EarningDetails.FreeServices.graphBarColor
        
        return GraphDataEntry(graphType: .barGraph, dataTitle: title, units: units, values: values, barColor: graphColor.first!)
    }
    
    func getTotalFreeServiceGraphEntry(forData data:[Dashboard.GetRevenueDashboard.RevenueTransaction]? = nil, dateRange:DateRange, dateRangeType: DateRangeType) -> GraphDataEntry
    {
        let units = xAxisUnits(forDateRange: dateRange, rangeType: dateRangeType)
        let values = totalFreeServiceGraphData(forData: data, dateRange: dateRange, dateRangeType: dateRangeType)
        let graphColor = EarningDetails.FreeServices.graphBarColor
        
        return GraphDataEntry(graphType: .barGraph, dataTitle: "Total Free Service", units: units, values: values, barColor: graphColor.first!)
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
    
    func graphData(forData data:[Dashboard.GetRevenueDashboard.RevenueTransaction]? = nil, atIndex index : Int, dateRange:DateRange, dateRangeType: DateRangeType) -> [Double] {
       
        var filteredFreeServices = data
        
        if data == nil, (data?.count ?? 0 <= 0) {
            let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
            
            
            filteredFreeServices = technicianDataJSON?.data?.revenue_transactions?.filter({ (freeServices) -> Bool in
                if let date = freeServices.date?.date()?.startOfDay {
                    
                    return date >= dateRange.start && date <= dateRange.end
                }
                return false
            })
        }

        
        //reward points
        if(index == 0){
            return calculateRewardPoints(filterArray: filteredFreeServices ?? [], dateRange: dateRange, dateRangeType: dateRangeType)
        }
        else if(index == 1){//complimentory gidt vouchers
            return calculateComplimentoryGiftVouchers(filterArray: filteredFreeServices ?? [], dateRange: dateRange, dateRangeType: dateRangeType)
        }
        else{ // Grooming gift cards
            return calculateGroomingGiftCards(filterArray: filteredFreeServices ?? [], dateRange: dateRange, dateRangeType: dateRangeType)
        }
    }
    
    func totalFreeServiceGraphData(forData data:[Dashboard.GetRevenueDashboard.RevenueTransaction]? = nil, dateRange:DateRange, dateRangeType: DateRangeType) -> [Double]
    {
        var totalFreeService = [Double]()
        var filteredFreeService = data
        
        //Fetch Data incase not having filtered already
        if data == nil, (data?.count ?? 0 <= 0) {
            let technicianDataJSON = UserDefaults.standard.value(Dashboard.GetRevenueDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_RevenueDashboard)
            
            //Date filter applied
            filteredFreeService = technicianDataJSON?.data?.revenue_transactions?.filter({ (freeService) -> Bool in
                if let date = freeService.date?.date()?.startOfDay {
                    return  (date >= dateRange.start && date <= dateRange.end) &&
                            ((freeService.free_service_revenue ?? 0 > 0) ||
                            (freeService.complimentary_giftcard ?? 0 > 0 &&
                            (freeService.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services)) ||
                            (freeService.grooming_giftcard ?? 0 > 0 &&
                            (freeService.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services)))
                }
                return false
            })
        }
        else {
            filteredFreeService = filteredFreeService?.filter({($0.free_service_revenue ?? 0 > 0) || ($0.complimentary_giftcard ?? 0 > 0 && ($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services)) || ($0.grooming_giftcard ?? 0 > 0 && ($0.product_category_type ?? "").containsIgnoringCase(find:CategoryTypes.services))})
        }
        
        switch dateRangeType
        {
        
        case .yesterday, .today, .week, .mtd:
            let dates = dateRange.end.dayDates(from: dateRange.start)
            for objDt in dates {
                if let data = filteredFreeService?.filter({$0.date == objDt}).map({$0.total}), data.count > 0
                {
                    let value = data.reduce(0) {$0 + ($1 ?? 0.0)}
                    totalFreeService.append(Double(value))
                }
                else {
                    totalFreeService.append(Double(0.0))
                }
            }
            
        case .qtd, .ytd:
            let months = dateRange.end.monthNames(from: dateRange.start, withFormat: "-MM-")
            for month in months {
                if let data = filteredFreeService?.filter({($0.date?.contains(month)) ?? false}).map({$0.total}), data.count > 0
                {
                    let value = data.reduce(0) {$0 + ($1 ?? 0.0)}
                    totalFreeService.append(Double(value))
                }
                else {
                    totalFreeService.append(Double(0.0))
                }
            }
            
        case .cutome:
            
            if dateRange.end.monthName != dateRange.start.monthName
            {
                let months = dateRange.end.monthNames(from: dateRange.start, withFormat: "-MM-")
                for month in months {
                    if let data = filteredFreeService?.filter({($0.date?.contains(month)) ?? false}).map({$0.total}), data.count > 0
                    {
                        let value = data.reduce(0) {$0 + ($1 ?? 0.0)}
                        totalFreeService.append(Double(value))
                    }
                    else {
                        totalFreeService.append(Double(0.0))
                    }
                }
            }
            else {
                let dates = dateRange.end.dayDates(from: dateRange.start)
                for objDt in dates {
                    if let data = filteredFreeService?.filter({$0.date == objDt}).first
                    {
                        totalFreeService.append(Double(data.total ?? 0.0))
                    }
                    else {
                        totalFreeService.append(Double(0.0))
                    }
                }
            }
        }
        
        return totalFreeService
    }
    
    
    
    //Calculate rewards points
    func calculateRewardPoints(filterArray: [Dashboard.GetRevenueDashboard.RevenueTransaction] , dateRange:DateRange, dateRangeType: DateRangeType) -> [Double]{
        var freeServicesValues = [Double]()
        let rewardPoints = filterArray.filter({$0.free_service_revenue ?? 0 > 0})
        
        switch dateRangeType
        {
        case .yesterday, .today, .week, .mtd:
            let dates = dateRange.end.dayDates(from: dateRange.start)
            for objDt in dates {
                if let data = rewardPoints.filter({$0.date == objDt}).first{
                    freeServicesValues.append(Double(data.free_service_revenue ?? 0.0))
                   }
                   else {
                    freeServicesValues.append(Double(0.0))
                   }
            }
        case .qtd, .ytd:
            let months = dateRange.end.monthNames(from: dateRange.start)
            for qMonth in months {
                let value = rewardPoints.map ({ (rewards) -> Double in
                    if let rMonth = rewards.date?.date()?.string(format: "MMM"),
                       rMonth == qMonth
                    {
                        return Double(rewards.free_service_revenue ?? 0.0)
                    }
                    return 0.0
                }).reduce(0) {$0 + $1}

                freeServicesValues.append(value)
            }
            
        case .cutome:
            
            if dateRange.end.monthName != dateRange.start.monthName
            {
                let months = dateRange.end.monthNames(from: dateRange.start)
                for qMonth in months {
                    let value = rewardPoints.map ({ (rewards) -> Double in
                        if let rMonth = rewards.date?.date()?.string(format: "MMM"),
                           rMonth == qMonth
                        {
                            return Double(rewards.free_service_revenue ?? 0.0)
                        }
                        return 0.0
                    }).reduce(0) {$0 + $1}

                    freeServicesValues.append(value)
                }
            }
            else {
                let dates = dateRange.end.dayDates(from: dateRange.start)
                for objDt in dates {
                    if let data = rewardPoints.filter({$0.date == objDt}).first
                    {
                        freeServicesValues.append(Double(data.free_service_revenue ?? 0.0))
                    }
                    else {
                        freeServicesValues.append(Double(0.0))
                    }
                }
            }
        }
        return freeServicesValues
    }
    
    //complimentory gift voucher
    func calculateComplimentoryGiftVouchers(filterArray: [Dashboard.GetRevenueDashboard.RevenueTransaction] , dateRange:DateRange, dateRangeType: DateRangeType) -> [Double]{
        var freeServicesValues = [Double]()
        
        let complimentoryGiftVoucher = filterArray.filter({$0.complimentary_giftcard ?? 0 > 0})
        
        switch dateRangeType
        {
        
        case .yesterday, .today, .week, .mtd:
            let dates = dateRange.end.dayDates(from: dateRange.start)
            for objDt in dates {
                if let data = complimentoryGiftVoucher.filter({$0.date == objDt}).first{
                    freeServicesValues.append(Double(data.complimentary_giftcard ?? 0.0))
                   }
                   else {
                    freeServicesValues.append(Double(0.0))
                   }
            }
        case .qtd, .ytd:
            let months = dateRange.end.monthNames(from: dateRange.start)
            for qMonth in months {
                let value = complimentoryGiftVoucher.map ({ (complimentory) -> Double in
                    if let rMonth = complimentory.date?.date()?.string(format: "MMM"),
                       rMonth == qMonth
                    {
                        return Double(complimentory.complimentary_giftcard ?? 0.0)
                    }
                    return 0.0
                }).reduce(0) {$0 + $1}

                freeServicesValues.append(value)
            }
            
        case .cutome:
            
            if dateRange.end.monthName != dateRange.start.monthName
            {
                let months = dateRange.end.monthNames(from: dateRange.start)
                for qMonth in months {
                    let value = complimentoryGiftVoucher.map ({ (complimentory) -> Double in
                        if let rMonth = complimentory.date?.date()?.string(format: "MMM"),
                           rMonth == qMonth
                        {
                            return Double(complimentory.complimentary_giftcard ?? 0.0)
                        }
                        return 0.0
                    }).reduce(0) {$0 + $1}

                    freeServicesValues.append(value)
                }
            }
            else {
                let dates = dateRange.end.dayDates(from: dateRange.start)
                for objDt in dates {
                    if let data = complimentoryGiftVoucher.filter({$0.date == objDt}).first
                    {
                        freeServicesValues.append(Double(data.complimentary_giftcard ?? 0.0))
                    }
                    else {
                        freeServicesValues.append(Double(0.0))
                    }
                }
            }
        }
        return freeServicesValues
    }
    
    func calculateGroomingGiftCards(filterArray: [Dashboard.GetRevenueDashboard.RevenueTransaction] , dateRange:DateRange, dateRangeType: DateRangeType) -> [Double]{
        var freeServicesValues = [Double]()
        
        let groomingGiftCards = filterArray.filter({$0.grooming_giftcard ?? 0 > 0})
        
        switch dateRangeType
        {
        case .yesterday, .today, .week, .mtd:
            let dates = dateRange.end.dayDates(from: dateRange.start)
            for objDt in dates {
                if let data = groomingGiftCards.filter({$0.date == objDt}).first{
                    freeServicesValues.append(Double(data.grooming_giftcard ?? 0.0))
                   }
                   else {
                    freeServicesValues.append(Double(0.0))
                   }
            }
        case .qtd, .ytd:
            let months = dateRange.end.monthNames(from: dateRange.start)
            for qMonth in months {
                let value = groomingGiftCards.map ({ (grooming) -> Double in
                    if let rMonth = grooming.date?.date()?.string(format: "MMM"),
                       rMonth == qMonth
                    {
                        return Double(grooming.grooming_giftcard ?? 0.0)
                    }
                    return 0.0
                }).reduce(0) {$0 + $1}

                freeServicesValues.append(value)
            }
            
        case .cutome:
            
            if dateRange.end.monthName != dateRange.start.monthName
            {
                let months = dateRange.end.monthNames(from: dateRange.start)
                for qMonth in months {
                    let value = groomingGiftCards.map ({ (grooming) -> Double in
                        if let rMonth = grooming.date?.date()?.string(format: "MMM"),
                           rMonth == qMonth
                        {
                            return Double(grooming.grooming_giftcard ?? 0.0)
                        }
                        return 0.0
                    }).reduce(0) {$0 + $1}

                    freeServicesValues.append(value)
                }
            }
            else {
                let dates = dateRange.end.dayDates(from: dateRange.start)
                for objDt in dates {
                    if let data = groomingGiftCards.filter({$0.date == objDt}).first
                    {
                        freeServicesValues.append(Double(data.grooming_giftcard ?? 0.0))
                    }
                    else {
                        freeServicesValues.append(Double(0.0))
                    }
                }
            }
        }
        return freeServicesValues
    }
    
    func doSomething()
    {
        let request = FreeServices.Something.Request()
        interactor?.doSomething(request: request)
    }
    
    func displaySomething(viewModel: FreeServices.Something.ViewModel)
    {
        //nameTextField.text = viewModel.name
    }
}

extension FreeServicesVC: EarningsFilterDelegate {
    
    func actionDateFilter() {
       print("Date Filter")
        let vc = DateFilterVC.instantiate(fromAppStoryboard: .Incentive)
        self.view.alpha = screenPopUpAlpha
        vc.fromChartFilter = false
        vc.selectedRangeTypeString = dateRangeType.rawValue
        vc.cutomRange = freeServicesCutomeDateRange
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
        vc.viewDismissBlock = { [unowned self] (result, startDate, endDate, rangeTypeString) in
            // Do something
            self.view.alpha = 1.0
            if(result){
                fromChartFilter = false
                dateRangeType = DateRangeType(rawValue: rangeTypeString ?? "") ?? .cutome
                
                if(dateRangeType == .cutome), let start = startDate, let end = endDate
                {
                    freeServicesCutomeDateRange = DateRange(start,end)
                }
                updateFreeServiceScreenData(startDate: startDate ?? Date.today, endDate: endDate ?? Date.today)
            }
        }
    }
    
    func actionNormalFilter() {
        print("Normal Filter")
    }
}

extension FreeServicesVC: EarningDetailsDelegate {
    
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
                updateFreeServiceScreenData(atIndex: indexPath, withStartDate: startDate, endDate: endDate!, rangeType: rangeType)
                
                tableView.reloadRows(at: [indexPath], with: .automatic)
                let text = "You have selected \(rangeTypeString ?? "MTD") filter from Charts."
                self.showToast(alertTitle: alertTitle, message: text, seconds: toastMessageDuration)
            }
        }
    }
}


extension FreeServicesVC: UITableViewDelegate, UITableViewDataSource {
    
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
        cell.configureCell(showDateFilter: true, showNormalFilter: false, titleForDateSelection: dateRangeType.rawValue)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}
