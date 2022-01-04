//
//  EarningsDateFilterViewController.swift
//  Enrich_TMA
//
//  Created by Harshal on 24/12/21.
//  Copyright (c) 2021 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol EarningsDateFilterDisplayLogic: class
{
  func displaySomething(viewModel: EarningsDateFilter.Something.ViewModel)
}

enum EarningsDateRangeType : String {
    case mtd = "MTD"
    case qtd = "QTD"
    case ytd = "YTD"
    case cutome = "Custom Date Range"
    
    var date: Date? {
        switch self {
        case .mtd:
            return Date.today.startOfMonth
        case .qtd:
            return Date.today.startOfQuarter
        case .ytd:
            return Date.today.startOfYear
        case .cutome:
            return nil
        }
    }
    
}

enum EarningsMonthNames : Int {
    case Jan = 1
    case Feb = 2
    case Mar = 3
    case Apr = 4
    case May = 5
    case Jun = 6
    case Jul = 7
    case Aug = 8
    case Sept = 9
    case Oct = 10
    case Nov = 11
    case Desc = 12
    
    var month: Int{
        switch self {
        case .Jan:
            return 1
        case .Feb:
            return 2
        case .Mar:
            return 3
        case .Apr:
            return 4
        case .May:
            return 5
        case .Jun:
            return 6
        case .Jul:
            return 7
        case .Aug:
            return 8
        case .Sept:
            return 9
        case .Oct:
            return 10
        case .Nov:
            return 11
        case .Desc:
            return 12
        }
    }
}



class EarningsDateFilterViewController: UIViewController, EarningsDateFilterDisplayLogic
{
    var interactor: EarningsDateFilterInteractor?
    var selectedRangeTypeString : String = "MTD"
    var isSelected : Bool = false
    var fromChartFilter : Bool = false
    var isFromProductivity = false
    var cutomRange:DateRange = DateRange(Date.today.lastYear(), Date.today)
    
    var selectedFilter = PackageFilterModel(title: "", isSelected: false, fromDate: nil, toDate: nil, sku: "")
    // MARK: Object lifecycle
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var parentView: UIView!
    
    var selectedData:PackageFilterModel?
    var data = [PackageFilterModel]()
    
    var viewDismissBlock: ((_ success:Bool, _ start:Date?, _ end:Date?, _ title:String?) -> Void)?
    
    //var dateRange : (start:Date, end:Date) = (Date.today, Date.today)
    
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
        let interactor = EarningsDateFilterInteractor()
        let presenter = EarningsDateFilterPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    
    // MARK: View lifecycle
    
    func isSelected(dateRangeType:DateRangeType) -> Bool {
        let selectedType = DateRangeType(rawValue: selectedRangeTypeString) ?? .cutome
        return selectedType == dateRangeType
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        doSomething()
        
        tableView.register(UINib(nibName: CellIdentifier.packageFilterCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.packageFilterCell)
        tableView.register(UINib(nibName: CellIdentifier.earningsSelectFilterDateRangeCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.earningsSelectFilterDateRangeCell)
        tableView.separatorColor = .clear
        parentView.clipsToBounds = true
        parentView.layer.cornerRadius = 8
        parentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        if fromChartFilter == false{
            data.append(PackageFilterModel(title: DateRangeType.mtd.rawValue, isSelected: isSelected(dateRangeType: .mtd), fromDate: DateRangeType.mtd.date, toDate: Date.today, sku: nil))
        }
       
        
        data.append(PackageFilterModel(title: DateRangeType.qtd.rawValue, isSelected: isSelected(dateRangeType: .qtd), fromDate: DateRangeType.qtd.date, toDate: Date.today, sku: nil))
        data.append(PackageFilterModel(title: DateRangeType.ytd.rawValue, isSelected: isSelected(dateRangeType: .ytd), fromDate: DateRangeType.ytd.date, toDate: Date.today, sku: nil))
        data.append(PackageFilterModel(title: "Select Custom Date Range", isSelected: isSelected(dateRangeType: .cutome), fromDate: cutomRange.start, toDate: cutomRange.end, sku: nil))
       
        tableView.reloadData()
        
        selectedData = data.filter({ $0.title == selectedRangeTypeString }).first
    }
    
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    func doSomething()
    {
        let request = EarningsDateFilter.Something.Request()
        interactor?.doSomething(request: request)
    }
    
    func displaySomething(viewModel: EarningsDateFilter.Something.ViewModel)
    {
        //nameTextField.text = viewModel.name
    }
    
    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        viewDismissBlock?(false, nil, nil,nil)
    }
    @IBAction func actionApplyFilter(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
        let rangeType = DateRangeType(rawValue: selectedRangeTypeString) ?? .cutome
        if rangeType == .cutome {
            selectedData = data.last
        }
        
        viewDismissBlock?(true, selectedData?.fromDate?.startOfDay, selectedData?.toDate?.endOfDay, selectedRangeTypeString)
    }
    
    
}

extension EarningsDateFilterViewController: SelectDateRangeDelegate {
    
    func actionFromDate() {
        let model = data.last
        DatePickerDialog().show("From Date", doneButtonTitle: "SELECT", cancelButtonTitle: "CANCEL", defaultDate: model?.fromDate ?? Date.today.lastYear(), minimumDate: Date.today.lastYear(), maximumDate: Date.today, datePickerMode: .dateAndTime) { (selectedDate) in
            if(selectedDate != nil){
                self.data.last?.fromDate = selectedDate
                let userDefaults = UserDefaults.standard
                userDefaults.set(selectedDate?.monthNameYearDate, forKey: UserDefauiltsKeys.k_key_FromDate)
            }
            self.tableView.reloadData()
        }
    }
    
    func actionToDate() {
        let model = data.last
        DatePickerDialog().show("To Date", doneButtonTitle: "SELECT", cancelButtonTitle: "CANCEL", defaultDate: model?.toDate ?? Date.today, minimumDate: model?.fromDate!, maximumDate: Date.today, datePickerMode: .date) { (selectedDate) in
            if(selectedDate != nil){
                self.data.last?.toDate = selectedDate
                let userDefaults = UserDefaults.standard
                userDefaults.set(selectedDate?.monthNameYearDate, forKey: UserDefauiltsKeys.k_key_ToDate)
            }
            self.tableView.reloadData()
        }
    }
    
}

extension EarningsDateFilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == data.count - 1) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.earningsSelectFilterDateRangeCell, for: indexPath) as? EarningsSelectFilterDateRangeCell else {
                return UITableViewCell()
            }
            cell.configureCell(model: data[indexPath.row])
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.packageFilterCell, for: indexPath) as? PackageFilterCell else {
                return UITableViewCell()
            }
            cell.configureCell(model: data[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == data.count - 1 ? UITableView.automaticDimension : 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
        data.forEach{$0.isSelected = false}
        data[indexPath.row].isSelected = true
        selectedData = data[indexPath.row]
        
        let rangeType = DateRangeType(rawValue: selectedData!.title) ?? .cutome
        selectedRangeTypeString = (rangeType == .cutome) ? "Custom Date Range" : selectedData!.title
        tableView.reloadData()
    }
}
