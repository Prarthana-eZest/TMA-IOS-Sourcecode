//
//  ExtensionDouble.swift
//  Enrich_TMA
//
//  Created by Firez Khan on 26/10/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import Foundation
//MARK: Number Formating
extension Double {
    
    func roundedStringValue(toFractionDigits max:Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = max
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        return formatter.string(from: NSNumber(value: self)) ?? " "
    }
    
    var percent:String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_IN")
        let result = formatter.string(from: NSNumber(value: self*100))
        return  result != nil ? "\(result!)%" : ""
    }
    
    var abbrevationString: String
    {
        let formatter = NumberFormatter()
        typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
        let abbreviations:[Abbrevation] = [(0, 1, ""),
                                           (999.0, 1000.0, "K"),
                                           (1000.0, 1000.0, "K"),
                                           (1_000_000.0, 1_000_000.0, "M"),
                                           (100_000_000.0, 1_000_000_000.0, "B")]
        
        let startValue = abs(self)
        let abbreviation:Abbrevation =
            {
                var prevAbbreviation = abbreviations[0]
                for tmpAbbreviation in abbreviations {
                    if (startValue < tmpAbbreviation.threshold) {
                        break
                    }
                    prevAbbreviation = tmpAbbreviation
                }
                return prevAbbreviation
            }()
        
        let value = Double(self) / abbreviation.divisor
        formatter.positiveSuffix = abbreviation.suffix
        formatter.negativeSuffix = abbreviation.suffix
        formatter.allowsFloats = true
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = abbreviation.suffix.count == 0 ? 0 : 1
        formatter.maximumFractionDigits = abbreviation.suffix.count == 0 ? 2 : 1
        formatter.locale = Locale(identifier: "en_IN")
        return formatter.string(from: NSNumber(value: value))!
    }
}
