//
//  ExtensionGeneric.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/22/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit

extension Encodable {
    
    /// Converting CodableObject to Dictionary
    func convertCodableToDictionary(_ encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data)
        guard let json = object as? [String: Any] else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Deserialized object is not a dictionary")
            throw DecodingError.typeMismatch(type(of: object), context)
        }
        return json
    }
    
}

extension Double {
    func getPercentageInFive() -> Double {
        let selfObj = Double(self)
        let percent = 5 * (selfObj / 100)
        return percent
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func getPercent(price: Double) -> Double {
        if price == 0 {
            return 0
        }
        let percentage: Double = 100 * ((price - self) / price)
        return percentage
    }
}

extension Array {
    func unique<T: Hashable>(map: ((Element) -> (T))) -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        
        return arrayOrdered
    }
}

extension Double {
    /** How to use
     10000.asString(style: .positional)  // 2:46:40
     10000.asString(style: .abbreviated) // 2h 46m 40s
     10000.asString(style: .short)       // 2 hr, 46 min, 40 sec
     10000.asString(style: .full)        // 2 hours, 46 minutes, 40 seconds
     10000.asString(style: .spellOut)    // two hours, forty-six minutes, forty seconds
     10000.asString(style: .brief)       // 2hr 46min 40sec
     */
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        
        //formatter.allowedUnits = [.hour, .minute,.second]
        
        formatter.unitsStyle = .short
        guard let formattedString = formatter.string(from: self) else { return "" }
        return formattedString.replacingOccurrences(of: ",", with: "")
    }
    
}

extension Date {
    func daySuffix() -> String {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: self)
        switch dayOfMonth {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
}

// How to use
//if let date = Calendar.current.date(byAdding: .day, value: 20, to: Date()) {
//   print(Date().allDates(till: date))
//usage let weekday = Date().weekdayName
extension Date {
    
    init(day: Int,
         hour: Int = 0,
         minute: Int = 0,
         second: Int = 0,
         timeZone: TimeZone = TimeZone(abbreviation: "UTC") ?? TimeZone.current) {
        var components = DateComponents()
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        components.timeZone = timeZone
        self = Calendar.current.date(from: components) ?? Date()
    }
    
    func allDates(till endDate: Date) -> [Date] {
        var date = self
        var array: [Date] = []
        while date <= endDate {
            array.append(date)
            date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? Date()
        }
        return array
    }
    var weekdayName: String {
        let formatter = DateFormatter(); formatter.dateFormat = "E"
        return formatter.string(from: self as Date)
    }
    
    var weekdayNameFull: String {
        let formatter = DateFormatter(); formatter.dateFormat = "EEEE"
        return formatter.string(from: self as Date)
    }
    var dayDateName: String {
        let formatter = DateFormatter(); formatter.dateFormat = "dd"
        return formatter.string(from: self as Date)
    }
    
    var dayName: String {
        let formatter = DateFormatter(); formatter.dateFormat = "E"
        return formatter.string(from: self as Date)
    }
    
    var dayDateMonthYear: String {
        let formatter = DateFormatter(); formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: self as Date)
    }
    
    var dayYearMonthDate: String {
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self as Date)
    }
    
    var dayMonthYear: String {
        let formatter = DateFormatter(); formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: self as Date)
    }
    
    var checkInOutDateTime: String {
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: self as Date)
    }
    
    var monthNameFirstThree: String {
        let formatter = DateFormatter(); formatter.dateFormat = "MMM"
        return formatter.string(from: self as Date)
    }
    
    var dayYearMonthDateAndTime: String {
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self as Date)
    }
    
    var dayMonthYearDate: String {
        let formatter = DateFormatter(); formatter.dateFormat = "EEE, dd MMM yy"
        return formatter.string(from: self as Date)
    }
    
    var dayMonthDate: String {
        let formatter = DateFormatter(); formatter.dateFormat = "EEE, dd MMM"
        return formatter.string(from: self as Date)
    }
    
    
    var monthYearDate: String {
        let formatter = DateFormatter(); formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: self as Date)
    }
    
    var monthNameYearDate: String {
        let formatter = DateFormatter(); formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: self as Date)
    }
    
    var monthCommaYearDate: String {
        let formatter = DateFormatter(); formatter.dateFormat = "dd MMM, yyyy"
        return formatter.string(from: self as Date)
    }
    
    var dayNameDateFormat: String {
        let formatter = DateFormatter(); formatter.dateFormat = "EEE, dd MMM yyyy"
        return formatter.string(from: self as Date)
    }
    
    var monthName: String {
        let formatter = DateFormatter(); formatter.dateFormat = "MMMM"
        return formatter.string(from: self as Date)
    }
    var monthNameAndYear: String {
        let formatter = DateFormatter(); formatter.dateFormat = "MMMM  yyyy"
        return formatter.string(from: self as Date)
    }
    var OnlyYear: String {
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy"
        return formatter.string(from: self as Date)
    }
    var period: String {
        let formatter = DateFormatter(); formatter.dateFormat = "a"
        return formatter.string(from: self as Date)
    }
    
    var startTime: String {
        let formatter = DateFormatter(); formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self as Date)
    }
    
    var timeOnly: String {
        let formatter = DateFormatter(); formatter.dateFormat = "hh : mm"
        return formatter.string(from: self as Date)
    }
    var timeWithPeriod: String {
        let formatter = DateFormatter(); formatter.dateFormat = "hh : mm a"
        return formatter.string(from: self as Date)
    }
    
    var timeWithPeriodInSmall: String {
        let formatter = DateFormatter(); formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter.string(from: self as Date)
    }
    
    var DatewithMonth: String {
        let formatter = DateFormatter(); formatter.dateStyle = .medium ;
        return formatter.string(from: self as Date)
    }
    
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .indian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .indian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
    
//    var startOfMonth: Date {
//        
//        let calendar = Calendar(identifier: .gregorian)
//        let components = calendar.dateComponents([.year, .month], from: self)
//        
//        return calendar.date(from: components)!
//    }
//    
//    var endOfMonth: Date {
//        var components = DateComponents()
//        components.month = 1
//        components.second = -1
//        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
//    }
    
    var dayYearMonthDateHyphen: String {
        let formatter = DateFormatter(); formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: self as Date)
    }
    
    func getEndDateFromStart(minutes: Int) -> String {
        var dateComponent = DateComponents()
        dateComponent.month = 0
        dateComponent.day = 0
        dateComponent.year = 0
        dateComponent.minute = minutes
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: self)
        return futureDate?.startTime ?? ""
    }
    
    func getStartDateFromEnd(minutes: Int) -> Date {
        var dateComponent = DateComponents()
        dateComponent.month = 0
        dateComponent.day = 0
        dateComponent.year = 0
        dateComponent.minute = minutes
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: self)
        return futureDate ?? Date()
    }
    
    // MARK: - timeAgoSinceDate
    func timeAgoSinceDate(date: NSDate, numericDates: Bool) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date, to: latest as Date)
        
        if let year = components.year, year >= 2 {
            return "\(year) years ago"
        }
        else if let year = components.year, year >= 1 {
            if numericDates {
                return "1 year ago"
            }
            else {
                return "Last year"
            }
        }
        else if let month = components.month, month >= 2 {
            return "\(month) months ago"
        }
        else if let month = components.month, month >= 1 {
            if numericDates {
                return "1 month ago"
            }
            else {
                return "Last month"
            }
        }
        else if let week = components.weekOfYear, week >= 2 {
            return "\(week) weeks ago"
        }
        else if let week = components.weekOfYear, week >= 1 {
            if numericDates {
                return "1 week ago"
            }
            else {
                return "Last week"
            }
        }
        else if let day = components.day, day >= 2 {
            return "\(day) days ago"
        }
        else if let day = components.day, day >= 1 {
            if numericDates {
                return "1 day ago"
            }
            else {
                return "Yesterday"
            }
        }
        else if let hour = components.hour, hour >= 2 {
            return "\(hour) hours ago"
        }
        else if let hour = components.hour, hour >= 1 {
            if numericDates {
                return "1 hour ago"
            }
            else {
                return "An hour ago"
            }
        }
        else if let minute = components.minute, minute >= 2 {
            return "\(minute) minutes ago"
        }
        else if let minute = components.minute, minute >= 1 {
            if numericDates {
                return "1 minute ago"
            }
            else {
                return "A minute ago"
            }
        }
        else if let second = components.second, second >= 3 {
            return "\(second) seconds ago"
        }
        else {
            return "Just now"
        }
        
    }
}

@IBDesignable extension UIProgressView {
    
    @IBInspectable var progressBarHeight: CGFloat {
        set {
            let transform = CGAffineTransform(scaleX: 1.0, y: newValue)
            self.transform = transform
            
        }
        get {
            return self.progressBarHeight
            
        }
    }
    
}
extension UICollectionView {
    func reloadData(_ completion: @escaping () -> Void) {
        reloadData()
        DispatchQueue.main.async { completion() }
    }
}

// USAGE
//print("Value \(distanceFloat1.clean)") // 5
//print("Value \(distanceFloat2.clean)") // 5.54
//print("Value \(distanceFloat3.clean)") // 5.03
extension Double {
    var cleanForPrice: String {
        //return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.2f", self)
        
    }
    var cleanForRating: String {
        //return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.1f", self)
        
    }
}

extension UIImageView {
    func setGradientToImageView() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        let colour: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
        gradient.colors = [colour.withAlphaComponent(0.0).cgColor, colour.cgColor]
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension Bundle {
    
    var appName: String {
        if let name = infoDictionary?["CFBundleName"] as? String {
            return name
        }
        return ""
    }
    
    var bundleId: String {
        return bundleIdentifier ?? ""
    }
    
    var versionNumber: String {
        if let version = infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return ""
    }
    
    var buildNumber: String {
        if let build = infoDictionary?["CFBundleVersion"] as? String {
            return build
        }
        return ""
    }
    
}

extension String
{
    func date(format: String = "yyyy-MM-dd") -> Date?
    {
        let formatter = Utils.dateFormatter
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
}
