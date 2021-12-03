//
//  ShiftCalendarViewController.swift
//  Enrich_TMA
//
//  Created by Harshal on 02/08/21.
//  Copyright (c) 2021 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import FSCalendar

protocol ShiftCalendarDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
}

struct EventData {
    let eventType: CalenderEvent
    let eventName: String
    let eventSubTitle: String
}

struct CalenderRosterData {
    let date: String?
    let events: [EventData]?
}

class ShiftCalendarVC: UIViewController, ShiftCalendarDisplayLogic
{
    var interactor: ShiftCalendarBusinessLogic?
    
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var infoView: UIStackView!
    
    
    private var currentPage: Date?
    private lazy var today: Date = {
        return Date()
    }()
    
    let startDate = Date().startOfMonth //Calendar.current.date(byAdding: .day, value: -14, to: Date())
    let endDate = Date().endOfMonth
    //Calendar.current.date(byAdding: .day,                                      value: 28, to: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
    
    var calenderRosterData = [CalenderRosterData]()
    
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
        let interactor = ShiftCalendarInteractor()
        let presenter = ShiftCalendarPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getRosterDetails()
        eventTableView.register(UINib(nibName: CellIdentifier.calenderEventDetailsCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.calenderEventDetailsCell)
        self.headerView.isHidden = true
        self.calendar.isHidden = true
        self.infoView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.addCustomBackButton(title: "Work Schedule")
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    func configureUI() {
        
        calendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
        calendar.appearance.weekdayTextColor = UIColor(red: 0.61, green: 0.62, blue: 0.70, alpha: 1.00)
        calendar.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 12)
        
        calendar.appearance.selectionColor = UIColor(red: 0.89, green: 0.96, blue: 1.00, alpha: 1.00)
        calendar.scrollDirection = .horizontal
        
        calendar.appearance.titleDefaultColor = .black
        calendar.appearance.titleSelectionColor = .black
        calendar.appearance.titleFont = UIFont.boldSystemFont(ofSize: 12)
        
        calendar.appearance.todaySelectionColor = UIColor(red: 0.89, green: 0.96, blue: 1.00, alpha: 1.00)
        calendar.appearance.titleTodayColor = UIColor(red: 0.22, green: 0.43, blue: 0.91, alpha: 1.00)
        calendar.appearance.todayColor = .white

        
        calendar.placeholderType = .none
        let dateString = self.formatter.string(from: today)
        lblHeaderTitle.text = dateString
        self.headerView.isHidden = false
        self.calendar.isHidden = false
        self.infoView.isHidden = false
    }
    
    // MARK: Do something
    
    @IBAction func actionPrev(_ sender: UIButton) {
        self.moveCurrentPage(moveUp: false)
    }
    
    @IBAction func actionNext(_ sender: UIButton) {
        self.moveCurrentPage(moveUp: true)
    }
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM yyyy"
        return formatter
    }()
    
}

extension ShiftCalendarVC: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance  {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        let dateString = self.formatter.string(from: date)
        print("change page to \(dateString))")
        lblHeaderTitle.text = dateString
        self.currentPage = date
        self.eventTableView.reloadData()
    }
    
    private func moveCurrentPage(moveUp: Bool) {
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = moveUp ? 1 : -1
        
        self.currentPage = calendar.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.calendar.setCurrentPage(self.currentPage!, animated: true)
    }
    
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return getEvents(date: date).count
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        return getEvents(date: date).map {($0.eventType.eventColor)}
    }
    
}

extension ShiftCalendarVC {
    
    func getRosterDetails() {
        
       // if let startDate = startDate, let endDate = endDate {
            
            if let userData = UserDefaults.standard.value(MyProfile.GetUserProfile.UserData.self, forKey: UserDefauiltsKeys.k_Key_LoginUser) {
                
                EZLoadingActivity.show("Loading...", disableUI: true)
                
                let id = userData.employee_id ?? "0"
                
                let request = MyProfile.GetRosterDetails.Request(salon_code: userData.base_salon_code ?? "", fromDate: startDate.dayYearMonthDate, toDate: endDate.dayYearMonthDate, employee_id: id)
                interactor?.doGetRosterData(request: request, method: .post)
            }
      //  }
    }
    
    func displaySuccess<T>(viewModel: T) where T: Decodable {
        print("Response: \(viewModel)")
        EZLoadingActivity.hide()
        
        if let model = viewModel as? MyProfile.GetRosterDetails.Response, model.status == true {
            self.calenderRosterData.removeAll()
            
            model.data?.forEach {
                
                var events = [EventData]()
                
                if $0.roster_id != nil , $0.shift_id != nil {
                    events.append(EventData(eventType: .shift, eventName: $0.shift_name ?? "-", eventSubTitle: "\($0.start_time ?? "-") To \($0.end_time ?? "-")"))
                }
                if let isLeave = $0.is_leave, isLeave == 1 {
                    
                    if $0.leave_type_id == 3 {
                        events.append(EventData(eventType: .halfDay, eventName: "Half Day", eventSubTitle: $0.leave_type ?? "-"))
                    }
                    else if $0.leave_type_id == 4 {
                        events.append(EventData(eventType: .weekOff, eventName: "Weekly Off", eventSubTitle: $0.leave_type ?? "-"))
                    }
                    else {
                        events.append(EventData(eventType: .leave, eventName: "Leave", eventSubTitle: $0.leave_type ?? "-"))
                    }
                }
                
                self.calenderRosterData.append(CalenderRosterData(date: $0.date, events: events))
                
                self.configureUI()
                self.eventTableView.reloadData()
            }
        }
    }
    
    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        print("Failed: \(errorMessage ?? "")")
        showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "Request Failed")
    }
    
    func getEvents(date: Date) -> [EventData]{
        if let selectedDate = self.calenderRosterData.first(where: { $0.date == date.dayYearMonthDate }) {
            return selectedDate.events ?? []
        }
        return []
    }
    
}

extension ShiftCalendarVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getEvents(date: self.currentPage ?? today).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let event = self.getEvents(date: self.currentPage ?? today)[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.calenderEventDetailsCell, for: indexPath) as? CalenderEventDetailsCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        cell.configureCell(eventType: event.eventType, eventTitle: event.eventName, eventDate: event.eventSubTitle)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}