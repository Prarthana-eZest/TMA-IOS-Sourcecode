//
//  ExtensionDate.swift
//  Enrich_TMA
//
//  Created by Harshal on 27/10/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import Foundation

struct ScheduleDates {
    var month: String
    var dates: [Date]
    
    init(month: String, dates: [Date]) {
        self.month = month
        self.dates = dates
    }
}
var sections = [ScheduleDates]()

extension Date
{
    var ddMMyyyy: String { Formatter.ddMMyyyy.string(from: self) }
    
    static var today: Date
    {
        return Date().startOfDay
    }
    
    func yesterday() -> Date
    {
        return Utils.calendar.date(byAdding: .day, value: -1, to: self)!
    }
    
    func next() -> Date {
        return Utils.calendar.date(byAdding: .day, value: 1, to: self)!
    }
    
    func lastWeek() -> Date
    {
        return Utils.calendar.date(byAdding: .weekOfMonth, value: -1, to: self)!
    }
    
    func lastMonth() -> Date
    {
        return Utils.calendar.date(byAdding: .month, value: -1, to: self)!
    }
    
    func lastQuarter() -> Date
    {
        return Utils.calendar.date(byAdding: .month, value: -3, to: self)!
    }
    
    func nextQuarter() -> Date
    {
        return Utils.calendar.date(byAdding: .month, value: +2, to: self)!
    }
    func showQuarterWithThreeMonths() -> Date
    {
        return Utils.calendar.date(byAdding: .month, value: +1, to: self)!
    }
    func lastYear() -> Date
    {
        return Utils.calendar.date(byAdding: .year, value: -1, to: self)!
    }
    
    var startOfMonth: Date {
        
        let calendar = Utils.calendar
        let components = calendar.dateComponents([.year, .month], from: self)
        
        return calendar.date(from: components)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    var startOfQuarter: Date {
        var components = Calendar.current.dateComponents([.month, .year], from: self)

        let quarterMonth: Int
        switch components.month! {
            case 1,2,3: quarterMonth = 1 //first Quarter
            case 4,5,6: quarterMonth = 4 //second Quarter
            case 7,8,9: quarterMonth = 7 //third Quarter
            case 10,11,12: quarterMonth = 10 //last Quarter
            default: quarterMonth = 1
        }
        components.month = quarterMonth
        let quarterStartDate = Calendar.current.date(from: components)!
        return Calendar.current.startOfDay(for: quarterStartDate)
    }
    
    var startOfYear: Date {
        var components = Calendar.current.dateComponents([.month, .year], from: self)
        
        //Handled first 3 months not a part of current financial year
        components.year = components.month! < 4 ? components.year! - 1 : components.year!
        
        //financial year starts from April
        components.month = 4
        let quarterStartDate = Calendar.current.date(from: components)!
        return Calendar.current.startOfDay(for: quarterStartDate)
    }
    
    var startOfDay: Date
    {
        return Utils.calendar.startOfDay(for: self)
    }
    
    var endOfDay: Date
    {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Utils.calendar.date(byAdding: components, to: startOfDay)!
    }
    
    func string(format:String = "yyyy-MM-dd") -> String {
        let formatter = Utils.dateFormatter
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func months(from date: Date) -> Double {
        let components = Calendar.current.dateComponents([.month, .day], from: date, to: self)
        let monthCount = Double(components.month ?? 0)
        let dayCount = Double(components.day ?? 0)
        let daysInMonth = Double(self.daysInMonth())
        return monthCount + (dayCount / daysInMonth)
    }
    
    func daysInMonth() -> Int {
        let range = Calendar.current.range(of: .day, in: .month, for: self)
        return range?.count ?? 30
    }
    
    func days(from date: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: date, to: self)
        return components.day ?? 0
    }
    
    
    func byAdding(component: Calendar.Component, value: Int, wrappingComponents: Bool = false, using calendar: Calendar = .current) -> Date? {
        calendar.date(byAdding: component, value: value, to: self, wrappingComponents: wrappingComponents)
    }
    func dateComponents(_ components: Set<Calendar.Component>, using calendar: Calendar = .current) -> DateComponents {
        calendar.dateComponents(components, from: self)
    }
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        calendar.date(from: dateComponents([.yearForWeekOfYear, .weekOfYear], using: calendar))!
    }
    var noon: Date {
        Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    func daysOfWeek(using calendar: Calendar = .current) -> [Date] {
        let startOfWeek = self.startOfWeek(using: calendar).noon
        return (0...6).map { startOfWeek.byAdding(component: .day, value: $0, using: calendar)! }
    }
    
    func getMonthAndYearBetween(from start: Date, to end: Date) -> [String] {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(Set([.month]), from: start, to: end)
        
        var allDates: [String] = []
        let dateRangeFormatter = DateFormatter()
        dateRangeFormatter.dateFormat = "MMM yy"
        
        for i in 0 ... (components.month!) {
            guard let date = calendar.date(byAdding: .month, value: i, to: start) else {
                continue
            }
            
            let formattedDate = dateRangeFormatter.string(from: date)
            allDates += [formattedDate]
        }
        return allDates
    }
    
    func dayDates(from:Date, withFormat format: String = "yyyy-MM-dd") -> [String] {
        var array = [String]()
        if from > self { return array }
        
        var date = from
        while date <= self {
            array.append(date.string(format: format))
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        }
        return array
    }
    
    func monthNames(from:Date, withFormat format: String = "MMM") -> [String] {
        var array = [String]()
        if from > self { return array }
        
        var date = from
        while date <= self {
            array.append(date.string(format: format))
            date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
        }
        return array
    }
    
    func monthNumber(from:Date, withFormat format: String = "M") -> [Int] {
        var array = [Int]()
        if from > self { return array }
        
        var date = from
        while date <= self {
            array.append(Int(date.string(format: format)) ?? 0)
            date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
        }
        return array
    }
    
    
    func inSameMonth(asDate date: Date) -> Bool
    {
        return Utils.calendar.isDate(self, equalTo: date, toGranularity: .month)
    }
}

extension Formatter {
    static let ddMMyyyy: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()
    
}
