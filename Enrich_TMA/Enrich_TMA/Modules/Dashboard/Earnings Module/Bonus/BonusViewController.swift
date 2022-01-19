//
//  BonusViewController.swift
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

protocol BonusDisplayLogic: class
{
  func displaySomething(viewModel: Bonus.Something.ViewModel)
}

class BonusViewController: UIViewController, BonusDisplayLogic
{
  var interactor: BonusBusinessLogic?
  var router: (NSObjectProtocol & BonusRoutingLogic & BonusDataPassing)?

    @IBOutlet private weak var tableView: UITableView!
    var dateRangeType : DateRangeType = .mtd
    var bonusDateRange:DateRange = DateRange(Date.today.lastYear(), Date.today)
    
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
    let interactor = BonusInteractor()
    let presenter = BonusPresenter()
    let router = BonusRouter()
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
        fromChartFilter = false
      dateRangeType = .mtd
      updateBonusData(startDate: Date.today.startOfMonth)
      
    }
    
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          self.navigationController?.navigationBar.isHidden = false
          self.navigationController?.addCustomBackButton(title: "Bonus")
      }
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
      func updateBonusData(startDate: Date?, endDate: Date = Date().startOfDay) {
          
          EZLoadingActivity.show("Loading...", disableUI: true)
          bonusData(startDate: startDate ?? Date.today, endDate: endDate, completion: nil)
      }
      
    func calculateTotalBonus(dateRange: DateRange) {
          let earningsJSON = UserDefaults.standard.value(Dashboard.GetEarningsDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_EarningsDashboard)
          var graphRangeType = dateRangeType
          var graphDateRange = dateRange // need to change
          var filteredFixedEarningsForGraph = [Dashboard.GetRevenueDashboard.RevenueTransaction]()
        if (dateRangeType == .yesterday || dateRangeType == .today || dateRangeType == .mtd) {
  
              graphRangeType = .qtd
              graphDateRange = DateRange(graphRangeType.date!, Date().startOfQuarter)
          }
          
        var amount : Int = 0
        let dataArray = earningsJSON?.data?.groups?.filter({EarningDetails(rawValue: $0.group_label ?? "") == EarningDetails.Bonus}) ?? []
        
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
        headerGraphData = getTotalBonusGraphEntry(forData: dataArray, dateRange: graphDateRange, dateRangeType: graphRangeType)
      }
      
      func bonusData(startDate : Date, endDate : Date = Date().startOfDay, completion: (() -> Void)? ) {
          dataModel.removeAll()
          graphData.removeAll()
          
              let earningsJSON = UserDefaults.standard.value(Dashboard.GetEarningsDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_EarningsDashboard)
              let currentMonth = Int(Date.today.string(format: "M"))
          
          //Handle Graph Scenarios
          let dateRange = DateRange(startDate, endDate)
          var graphRangeType = dateRangeType
          var graphDateRange = dateRange
          var filteredFixedEarningsForGraph = [Dashboard.GetRevenueDashboard.RevenueTransaction]()
          
        if (dateRangeType == .yesterday || dateRangeType == .today || dateRangeType == .mtd) {
              graphRangeType = .qtd
              graphDateRange = DateRange(graphRangeType.date!, Date().startOfDay)
          }

          let dataArray = earningsJSON?.data?.groups?.filter({EarningDetails(rawValue: $0.group_label ?? "") == EarningDetails.Bonus}) ?? []
        var index = 0
        var amount = 0
        for data in dataArray {
            if(dateRangeType == .mtd){
            for parameter in data.parameters ?? [] {
                
                let value = parameter.transactions?.filter({$0.month == currentMonth})
                //                value?.first?.amount
                if(parameter.transactions == nil){
                    amount = 0
                }
                else
                {
                    amount = value?.first?.amount ?? 0
                }
                let model = EarningsCellDataModel(earningsType: .Bonus, title: parameter.name ?? "", value: [amount.roundedStringValue() ], subTitle: [parameter.comment ?? ""], showGraph: true, cellType: .SingleValue, isExpanded: false, dateRangeType: graphRangeType, customeDateRange: graphDateRange)
                dataModel.append(model)
                graphData.append(getGraphEntry(parameter.name ?? "", forData: parameter.transactions, atIndex: index, dateRange: graphDateRange, dateRangeType: graphRangeType))
                
                index += 1
                }
            }
            else {
                let months = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
                
                for parameter in data.parameters ?? [] {
                        for month in months {
                        let value = parameter.transactions?.filter({$0.month == month})
                        amount += value?.first?.amount ?? 0
                    }
                    let model = EarningsCellDataModel(earningsType: .Bonus, title: parameter.name ?? "", value: [amount.roundedStringValue()], subTitle: [parameter.comment ?? ""], showGraph: true, cellType: .SingleValue, isExpanded: false, dateRangeType: graphRangeType, customeDateRange: graphDateRange)
                    dataModel.append(model)
                    graphData.append(getGraphEntry(parameter.name ?? "", forData: parameter.transactions, atIndex: index, dateRange: graphDateRange, dateRangeType: graphRangeType))
                    
                    index += 1
                    amount = 0
                }
            }
        }
        index = 0
          
          calculateTotalBonus(dateRange: dateRange)
  //        for group in earningsJSON?.data?.groups ?? []{
  //            if  (EarningDetails(rawValue: group.group_label ?? "") == EarningDetails.Bonus) {
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
  //        let salonServiceModel = EarningsCellDataModel(earningsType: .Bonus, title: "Salon Service", value: [Double(0.0).abbrevationString], subTitle: [""], showGraph: true, cellType: .SingleValue, isExpanded: false, dateRangeType: graphRangeType, customeDateRange: fixedEarningsDateRange)
  //        dataModel.append(salonServiceModel)
  //        //Graph Data
  //        graphData.append(getGraphEntry(salonServiceModel.title, forData: filteredFixedEarningsForGraph, atIndex: 0, dateRange: graphDateRange, dateRangeType: graphRangeType))
          
          tableView.reloadData()
          EZLoadingActivity.hide()
      }
      
      func getGraphEntry(_ title:String, forData data:[Dashboard.GetEarningsDashboard.Transaction]? = nil, atIndex index : Int, dateRange:DateRange, dateRangeType: DateRangeType) -> GraphDataEntry
      {
          let units = xAxisUnitsEarnings(forDateRange: dateRange, rangeType: dateRangeType)
          let values = graphData(forData: data, atIndex: index, dateRange: dateRange, dateRangeType: dateRangeType)
          let graphColor = EarningDetails.Bonus.graphBarColor
          
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
            for month in months {
                if let data = data?.filter({($0.month == month) }).map({$0.amount}), data.count > 0
                {
                    let value = data.reduce(0) {$0 + ($1 ?? Int(0.0))}
                    values.append(Double(value))
                }
                else {
                    values.append(Double(0.0))
                }
            }
            
        case .cutome:
            let months = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
            for month in months {
                if let data = data?.filter({($0.month == month) }).map({$0.amount}), data.count > 0
                {
                    let value = data.reduce(0) {$0 + ($1 ?? Int(0.0))}
                    values.append(Double(value))
                }
                else {
                    values.append(Double(0.0))
                }
            }
        }
        return values
    }
      
      func getTotalBonusGraphEntry(forData data:[Dashboard.GetEarningsDashboard.Groups]? = nil, dateRange:DateRange, dateRangeType: DateRangeType) -> GraphDataEntry
      {
          let units = xAxisUnitsEarnings(forDateRange: dateRange, rangeType: dateRangeType)
          let values = totalBonusGraphData(forData: data, dateRange: dateRange, dateRangeType: dateRangeType)
          let graphColor = EarningDetails.Bonus.graphBarColor
          
          return GraphDataEntry(graphType: .barGraph, dataTitle: headerModel?.earningsType.headerTitle ?? "", units: units, values: values, barColor: graphColor.first!)
      }
      
    func totalBonusGraphData(forData data:[Dashboard.GetEarningsDashboard.Groups]? = nil, dateRange:DateRange, dateRangeType: DateRangeType) -> [Double]
    {
        var totalFixedEarnings = [Double]()
        var amount = 0
        switch dateRangeType {
        case .yesterday, .today, .week, .mtd:
            let currentMonth = Int(Date.today.string(format: "M"))
            for objData in data ?? [] {
                for parameter in objData.parameters ?? [] {
                    let value = parameter.transactions?.filter({$0.month == currentMonth})
                    amount += value?.first?.amount ?? 0
                    
                }
                
            }
            totalFixedEarnings.append(Double(amount))
            
//        case .qtd :
//
//            var total = 0
//            let months = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
//            for objData in data ?? []{
//                for parameter in objData.parameters ?? [] {
//                    for month in months {
//                        if let dat = parameter.transactions?.filter({($0.month == month) }).map({$0.amount}), dat.count > 0
//                        {
//                            let value = dat.reduce(0) {$0 + ($1 ?? Int(0.0))}
//                            totalFixedEarnings.append(Double(value))
//                        }
//                        else {
//                            totalFixedEarnings.append(Double(0.0))
//                        }
//                    }
//
//                }
//
//                total = 0
//            }
            
        case .qtd, .ytd, .cutome:
            let months = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
            if let group = data?.first(where: { value in
                EarningDetails(rawValue: value.group_label ?? "") == EarningDetails.Bonus
            }) {
                let parameters = group.parameters ?? []
                let number = parameters.first?.transactions?.count ?? 0

                var totalSubTransactions = [Int: Double]()
                               
                               let allData = parameters.compactMap({$0.transactions}).flatMap({$0})
                               
                               let allTransactions = Dictionary(grouping: allData) { transaction in
                                   return transaction.month
                               }
                               let allMonths = allTransactions.keys.map( { $0 ?? 0 }).sorted()
                               for month in allMonths {
                                   let transaction = (allTransactions[month] ?? []).compactMap({$0.amount}).reduce(0, +)
                                   totalSubTransactions[month] = Double(transaction)
                               }
                
                for month in months {
                    totalFixedEarnings.append(totalSubTransactions[month] ?? 0.0)
                }
                
                let total = totalFixedEarnings.reduce(0.0) { $0 + $1 }
                headerModel?.value = total
                return totalFixedEarnings
            }
            
//        case .cutome:
//            var total = 0
//            let months = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
//            for objData in data ?? []{
//                for parameter in objData.parameters ?? [] {
//                    for month in months {
//                        if let dat = parameter.transactions?.filter({($0.month == month) }).map({$0.amount}), dat.count > 0
//                        {
//                            let value = dat.reduce(0) {$0 + ($1 ?? Int(0.0))}
//                            totalFixedEarnings.append(Double(value))
//                        }
//                        else {
//                            totalFixedEarnings.append(Double(0.0))
//                        }
//                    }
//
//                }
//
//                total = 0
//            }
        }
        
        return totalFixedEarnings
    }
      
      func updateBonusData(atIndex indexPath:IndexPath, withStartDate startDate: Date?, endDate: Date?, rangeType:DateRangeType) {
        
        let selectedIndex = indexPath.row - 1
        
        
        let dateRange = DateRange(startDate!, endDate!)
       // let currentMonth = Int(endDate!.string(format: "M")) ?? 1
        
        let earningsJSON = UserDefaults.standard.value(Dashboard.GetEarningsDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_EarningsDashboard)
        
        let dataArray = earningsJSON?.data?.groups?.filter({EarningDetails(rawValue: $0.group_label ?? "") == EarningDetails.Bonus}) ?? []
        if(selectedIndex >= 0){
        for data in dataArray {
            if(rangeType == .mtd){
                for parameter in data.parameters ?? [] {
                    let arr = data.parameters?[selectedIndex]
//                    arr?.transactions
                   // let value = parameter.transactions?.filter({$0.month == currentMonth})
                    
                    if(selectedIndex >= 0){
                        let model = dataModel[selectedIndex]
                        model.dateRangeType = rangeType
                        if model.dateRangeType == .cutome {
                            model.customeDateRange = dateRange
                        }
                        
                        update(modeData: model, withData: arr?.transactions, atIndex: selectedIndex, dateRange: dateRange, dateRangeType: rangeType)
                        graphData[selectedIndex] = getGraphEntry(model.title,forData: arr?.transactions, atIndex: selectedIndex, dateRange: dateRange, dateRangeType: rangeType)
                        break
                        
                    }
                    else if let _ = headerModel {
                        headerModel?.dateRangeType = rangeType
                        if headerModel?.dateRangeType == .cutome {
                            headerModel?.customeDateRange = dateRange
                        }
                        
                        //                           updateHeaderModel(withData: parameter.transactions, dateRange: dateRange, dateRangeType: rangeType)
                        //                           headerGraphData = getTotalFixedEarningsGraphEntry(forData:parameter.transactions, dateRange: dateRange, dateRangeType: rangeType)
                    }
                }
                
                
            }
            else {
                let months = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
                var amount = 0
                for parameter in data.parameters ?? [] {
                    
                    let arr = data.parameters?[selectedIndex]
//                    arr?.transactions
                    for month in months {
                        let value = parameter.transactions?.filter({$0.month == month})
                        amount += value?.first?.amount ?? 0
                    }
                    //                let model = EarningsCellDataModel(earningsType: .Bonus, title: parameter.name ?? "", value: [amount.roundedStringValue()], subTitle: [parameter.comment ?? ""], showGraph: true, cellType: .SingleValue, isExpanded: false, dateRangeType: rangeType, customeDateRange: dateRange)
                    //                dataModel.append(model)
                    //                graphData.append(getGraphEntry(parameter.name ?? "", forData: parameter.transactions, atIndex: selectedIndex, dateRange: dateRange, dateRangeType: rangeType))
                    if(selectedIndex >= 0){
                        let model = dataModel[selectedIndex]
                        model.dateRangeType = rangeType
                        if model.dateRangeType == .cutome {
                            model.customeDateRange = dateRange
                        }
                        
                        update(modeData: model, withData: arr?.transactions, atIndex: selectedIndex, dateRange: dateRange, dateRangeType: rangeType)
                        graphData[selectedIndex] = getGraphEntry(model.title,forData: arr?.transactions, atIndex: selectedIndex, dateRange: dateRange, dateRangeType: rangeType)
                        break
                    }
                    else if let _ = headerModel {
                        headerModel?.dateRangeType = rangeType
                        if headerModel?.dateRangeType == .cutome {
                            headerModel?.customeDateRange = dateRange
                        }
                        
                        //                           updateHeaderModel(withData: parameter.transactions, dateRange: dateRange, dateRangeType: rangeType)
                        //                           headerGraphData = getTotalFixedEarningsGraphEntry(forData:parameter.transactions, dateRange: dateRange, dateRangeType: rangeType)
                    }
                }
            }
        }
            
        }
        else {//header model
        let parameters = dataArray.first?.parameters ?? []
                let number = parameters.first?.transactions?.count ?? 0
                
                var totalSubTransactions = [Double]()

                for index in 0..<number {
                    let transactions = parameters.compactMap( { Double($0.transactions?[index].amount ?? 0)})
                    totalSubTransactions.append(transactions.reduce(0, +))
                }

//        }
            
            if let _ = headerModel {
               headerModel?.dateRangeType = rangeType
               if headerModel?.dateRangeType == .cutome {
                   headerModel?.customeDateRange = dateRange
               }
               
            updateHeaderModel(withData: dataArray, dateRange: dateRange, dateRangeType: rangeType)
            headerGraphData = getTotalBonusGraphEntry(forData:dataArray, dateRange: dateRange, dateRangeType: rangeType)
           }
        }
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
      
    func update(modeData:EarningsCellDataModel, withData data: [Dashboard.GetEarningsDashboard.Transaction]? = nil, atIndex index : Int, dateRange:DateRange, dateRangeType: DateRangeType) {
        
        var value : Double = 0.0
        
        switch dateRangeType {
        case .yesterday, .today, .week, .mtd:
            let month = Int(dateRange.end.string(format: "M"))
            
            
            for objData in data ?? [] {
                if objData.month == month {
                    value = (Double(objData.amount ?? 0))
                }
            }
           
            
        case .qtd, .ytd :
            let months = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
            for month in months {
                if let data = data?.filter({($0.month == month) }).map({$0.amount}), data.count > 0
                {
                    let values = data.reduce(0) {$0 + ($1 ?? Int(0.0))}
                    value += Double(values)
                }
            }
            
        case .cutome:
            let months = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
            for month in months {
                if let data = data?.filter({($0.month == month) }).map({$0.amount}), data.count > 0
                {
                    let values = data.reduce(0) {$0 + ($1 ?? Int(0.0))}
                    value += Double(values)
                }
            }
        }
        
        dataModel[index] = EarningsCellDataModel(earningsType: modeData.earningsType, title: modeData.title, value: [value.roundedStringValue()], subTitle: modeData.subTitle, showGraph: modeData.showGraph, cellType: modeData.cellType, isExpanded: modeData.isExpanded, dateRangeType: modeData.dateRangeType, customeDateRange: modeData.customeDateRange)
    }
      
    func updateHeaderModel(withData data: [Dashboard.GetEarningsDashboard.Groups]? = nil, dateRange:DateRange, dateRangeType: DateRangeType) {
        
        
        var totalFixedEarnings = [Double]()
        var amount = 0
        switch dateRangeType {
        case .yesterday, .today, .week, .mtd:
            let currentMonth = Int(Date.today.string(format: "M"))
            for objData in data ?? [] {
                for parameter in objData.parameters ?? [] {
                    let value = parameter.transactions?.filter({$0.month == currentMonth})
                    amount += value?.first?.amount ?? 0
                    
                }
                
            }
            totalFixedEarnings.append(Double(amount))
            
//        case .qtd :
//
////            var total = 0
//            let months = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
//            for objData in data ?? []{
//                for parameter in objData.parameters ?? [] {
//                    for month in months {
//                        if let dat = parameter.transactions?.filter({($0.month == month) }).map({$0.amount}), dat.count > 0
//                        {
//                            let value = dat.reduce(0) {$0 + ($1 ?? Int(0.0))}
//                            totalFixedEarnings.append(Double(value))
//                        }
//                        else {
//                            totalFixedEarnings.append(Double(0.0))
//                        }
//                    }
//
//                }
//
////                total = 0
//            }
            
        case .qtd, .ytd, .cutome :
            let months = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
            if let group = data?.first(where: { value in
                EarningDetails(rawValue: value.group_label ?? "") == EarningDetails.Bonus
            }) {
                let parameters = group.parameters ?? []
                let number = parameters.first?.transactions?.count ?? 0

                var totalSubTransactions = [Int: Double]()
                for month in months {
                    let parameters = group.parameters ?? []
                               
                               let allData = parameters.compactMap({$0.transactions}).flatMap({$0})
                               
                               let allTransactions = Dictionary(grouping: allData) { transaction in
                                   return transaction.month
                               }
                               let allMonths = allTransactions.keys.map( { $0 ?? 0 }).sorted()
                               for month in allMonths {
                                   let transaction = (allTransactions[month] ?? []).compactMap({$0.amount}).reduce(0, +)
                                   totalSubTransactions[month] = Double(transaction)
                               }
                               
                    for dat in totalSubTransactions{
                        if(month == dat.key){
                            totalFixedEarnings.append(dat.value)
                        }
                        
                        let total = totalFixedEarnings.reduce(0.0) { $0 + $1 }
                        headerModel?.value = total
                    }
                }
              //  return totalFixedEarnings
            }
            
//        case .cutome:
////            var total = 0
//            let months = dateRange.end.monthNumber(from: dateRange.start, withFormat: "M")
//            for objData in data ?? []{
//                for parameter in objData.parameters ?? [] {
//                    for month in months {
//                        if let dat = parameter.transactions?.filter({($0.month == month) }).map({$0.amount}), dat.count > 0
//                        {
//                            let value = dat.reduce(0) {$0 + ($1 ?? Int(0.0))}
//                            totalFixedEarnings.append(Double(value))
//                        }
//                        else {
//                            totalFixedEarnings.append(Double(0.0))
//                        }
//                    }
//
//                }
//
//            }
        }
    }
    func doSomething()
    {
      let request = Bonus.Something.Request()
      interactor?.doSomething(request: request)
    }
    
    func displaySomething(viewModel: Bonus.Something.ViewModel)
    {
      //nameTextField.text = viewModel.name
    }
  }

  extension BonusViewController: EarningsFilterDelegate {
      
      func actionDateFilter() {
          print("Date Filter")
          let vc = EarningsDateFilterViewController.instantiate(fromAppStoryboard: .Earnings)
          self.view.alpha = screenPopUpAlpha
          vc.fromChartFilter = false
          vc.selectedRangeTypeString = dateRangeType.rawValue
          vc.cutomRange = bonusDateRange
          UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
          vc.viewDismissBlock = { [unowned self] (result, startDate, endDate, rangeTypeString) in
              // Do something
              self.view.alpha = 1.0
              if(result){
                  fromChartFilter = false
                  dateRangeType = DateRangeType(rawValue: rangeTypeString ?? "") ?? .cutome

                  if(dateRangeType == .cutome), let start = startDate, let end = endDate
                  {
                      bonusDateRange = DateRange(start,end)
                  }
                  updateBonusData(startDate: startDate ?? Date.today, endDate: endDate ?? Date.today)
              }
          }
      }
      
      func actionNormalFilter() {
          print("Normal Filter")
      }
  }

  extension BonusViewController: EarningDetailsDelegate {
      
      func reloadData() {
//          self.tableView.beginUpdates()
//          self.tableView.endUpdates()
        self.tableView.reloadData()
      }
      
      func actionDurationFilter(forCell cell: UITableViewCell) {
          guard let indexPath = tableView.indexPath(for: cell), dataModel.count >= indexPath.row else { return }
          
          let selectedIndex = indexPath.row - 1
          
          let vc = EarningsDateFilterViewController.instantiate(fromAppStoryboard: .Earnings)
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
                  updateBonusData(atIndex: indexPath, withStartDate: startDate, endDate: endDate!, rangeType: rangeType)
                  
                  tableView.reloadRows(at: [indexPath], with: .automatic)
                  let text = "You have selected \(rangeTypeString ?? "MTD") filter from Charts."
                  self.showToast(alertTitle: alertTitle, message: text, seconds: toastMessageDuration)
              }
          }
      }
  }

  extension BonusViewController: UITableViewDelegate, UITableViewDataSource {
      
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
        if(dateRangeType == .cutome){
            cell.configureCell(showDateFilter: true, showNormalFilter: false,  titleForDateSelection: "Custom Months")
        }
        else {
        cell.configureCell(showDateFilter: true, showNormalFilter: false,  titleForDateSelection: dateRangeType.rawValue)
        }
          cell.selectionStyle = .none
          return cell
      }
      
      func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return 60
      }
  }
