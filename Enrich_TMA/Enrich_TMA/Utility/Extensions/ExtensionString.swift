//
//  ExtensionString.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/25/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit
extension String {
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }

    var isValidContact: Bool {
        let phoneNumberRegex = "^[0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        let isValidPhone = phoneTest.evaluate(with: self)
        return isValidPhone
    }

    func isNumber() -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: self)
        return allowedCharacters.isSuperset(of: characterSet)
    }

}
extension Optional where Wrapped == String {
    var nilIfEmpty: String? {
        guard let strongSelf = self else {
            return nil
        }
        return strongSelf.isEmpty ? nil : strongSelf
    }
}

extension String {
    func getFormattedDateForSpecialPrice() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // This formate is input formated .
        if let formateDate = dateFormatter.date(from: self) {
            return formateDate
        }
        else {
            dateFormatter.dateFormat = "yyyy-mm-dd hh:mm:ss" // This formate is input formated .
            if let formateDate = dateFormatter.date(from: self) {
                return formateDate
            }

        }
        return Date()
    }
    func getDateFromStringForMyBookings() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // This formate is input formated .
        if let formateDate = dateFormatter.date(from: self) {
            return formateDate
        }
        return Date()
    }
    func getDateFromStringForMyProfileScreen(dateFormat: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat // This formate is input formated .
        if let formateDate = dateFormatter.date(from: self) {
            return formateDate
        }
        return Date()
    }

    func getFormattedDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // This formate is input formated .
        if let formateDate = dateFormatter.date(from: self) {
            return formateDate
        }
        else {
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss" // This formate is input formated .
            if let formateDate = dateFormatter.date(from: self) {
                return formateDate
            }

        }
        return Date()
    }

    func getCheckInTime(dateString: String, withFormat format: String) -> String? {

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let date = inputFormatter.date(from: dateString) {

            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = format

            return outputFormatter.string(from: date)
        }
        return nil
    }

    func getFormattedDateForEditProfile() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // This formate is input formated .
        if let formateDate = dateFormatter.date(from: self) {
            return formateDate
        }
        return Date()
    }

    func getTimeInDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // This formate is input formated .
        if let formateDate = dateFormatter.date(from: self) {
            return formateDate
        }
        return Date()
    }

    func getTimeInDate24Hrs() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss" // This formate is input formated .
        if let formateDate = dateFormatter.date(from: self) {
            return formateDate
        }
        return Date()
    }

}

// MARK: ADD For Make a Call
extension String {

    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }

    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }

    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }

    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter {CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }

    func makeACall() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                }
                else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }

    func getDateFromString() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let s = dateFormatter.date(from: self)
        return s
    }

    func getDateFromTimeString() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm aa"
        let s = dateFormatter.date(from: self)
        return s
    }

    func getDateFromShortString() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MM-dd"
        let s = dateFormatter.date(from: self)
        return s
    }

    func getFormattedDatehh() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // This formate is input formated .

        if let formateDate = dateFormatter.date(from: self) {
            return formateDate
        }
        else {
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss" // This formate is input formated .
            if let formateDate = dateFormatter.date(from: self) {
                return formateDate
            }

        }
        return Date()
    }

}
// MARK: ADD For Make a Call

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    func containsIgnoringCase(find: String) -> Bool {
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    func compareIgnoringCase(find: String) -> Bool {
        let result: Bool = (self.uppercased() == find.uppercased())  ? true  : false
        return result
    }
}
extension String {
    public var withoutHtml: String {
        guard let data = self.data(using: .utf8) else {
            return self
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }

        return attributedString.string
    }
}
extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }

    func toInt() -> Int? {
        return NumberFormatter().number(from: self)?.intValue
    }
}

//How to Use
//print("lala".equalIgnoreCase("LALA"))

extension String {
    func equalsIgnoreCase(string: String) -> Bool {
        return self.uppercased() == string.uppercased()
    }
}
// Find Numbers from String
// Usage : print("3 little pigs".numbers) // "3"
//print("1, 2, and 3".numbers)   // "123"

extension String {
    var numbers: String {
        return self.filter { "0"..."9" ~= $0 }//(characters.filter { "0"..."9" ~= $0 })
    }
}
extension String {
    var unescapingUnicodeCharacters: String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, "Any-Hex/Java" as NSString, true)

        return mutableString as String
    }
}
// Usage myLabel.attributedText = "my string".strikeThrough()

extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }
}

extension String {
    //    func getFormattedDate() -> Date {
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // This formate is input formated .
    //        if let formateDate = dateFormatter.date(from: self) {
    //            return formateDate
    //        }
    //        return Date()
    //    }
}

extension StringProtocol {
    func masked(_ n: Int = 5, reversed: Bool = false) -> String {
        let mask = String(repeating: "X", count: Swift.max(0, count-n))
        return reversed ? mask + suffix(n) : prefix(n) + mask
    }
}

extension String
{
    func htmlAttributedMembership(family: String?, size: CGFloat, colorHex: String, csstextalign: String, defaultFont:String = FontName.FuturaPTBook.rawValue) -> NSAttributedString?
  {
    
    do {
        let htmlCSSString = "<style>" +
            "html *" +
            "{" +
            "font-size: \(size)pt !important;" +
             "color: " + "\(colorHex)" + " !important;" +
            "text-align: " + "\(csstextalign)" + " !important;" +
            "font-family:" + "\("\(family ?? "\(defaultFont)")" )" + " !important;" +
        "}</style> \(self)"

        guard let data = htmlCSSString.data(using: String.Encoding.utf8) else {
            return nil
        }
        
        return try NSAttributedString(data: data,
                                      options: [.documentType: NSAttributedString.DocumentType.html,
                                                .characterEncoding: String.Encoding.utf8.rawValue],
                                      documentAttributes: nil).attributedStringByTrimmingCharacterSet(charSet: .whitespacesAndNewlines)
    } catch {
        print("error: ", error)
        return nil
    }
  }
}

extension NSAttributedString {
    public func attributedStringByTrimmingCharacterSet(charSet: CharacterSet) -> NSAttributedString {
        let modifiedString = NSMutableAttributedString(attributedString: self)
        modifiedString.trimCharactersInSet(charSet: charSet)
        return NSAttributedString(attributedString: modifiedString)
    }
}

extension NSMutableAttributedString {
    public func trimCharactersInSet(charSet: CharacterSet) {
        var range = (string as NSString).rangeOfCharacter(from: charSet as CharacterSet)
        // Trim leading characters from character set.
        while range.length != 0 && range.location == 0 {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet)
        }
        // Trim trailing characters from character set.
        range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
        while range.length != 0 && NSMaxRange(range) == length {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
        }
    }
}

//MARK: - Expression Conversions
extension String {
    var expression: NSExpression {
        return NSExpression(format: self)
    }
    
    func expressionComponants() -> [String] {
        if let exps = self.expression.arguments {
            return keyPath(expressions: exps)
        }
        return []
    }
    
    private func keyPath(expressions:[NSExpression]) -> [String] {
        var result = [String]()
        for eachExp in expressions {
            if let args = eachExp.arguments, args.count > 1 {
                result.append(contentsOf: keyPath(expressions: args))
            }
            else {
                result.append(eachExp.keyPath)
            }
        }
        return result
    }
}

