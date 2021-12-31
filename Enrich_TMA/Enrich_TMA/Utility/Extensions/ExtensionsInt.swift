//
//  ExtensionsInt.swift
//  Enrich_TMA
//
//  Created by Prarthana on 31/12/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import Foundation
//MARK: Number Formating
extension Int {
    
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
}
