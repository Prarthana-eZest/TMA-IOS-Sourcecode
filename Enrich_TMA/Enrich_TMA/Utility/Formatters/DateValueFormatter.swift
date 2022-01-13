//
//  DateValueFormatter.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import Foundation
import Charts

public class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "dd MMM HH:mm"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}


public class CustomValueFormatter: NSObject, IAxisValueFormatter {
    
    var values = [String]()
    
    override init() {
        super.init()
    }
    
    public init(values: [String]) {
        self.values = values
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        var stringToReturn = ""
        
        for i in 0..<(values.count) {
            if Double(i+1) == value {
                stringToReturn = values[i]
                break
            }
        }
        return stringToReturn
    }
}

class BarChartFormatter: NSObject,IAxisValueFormatter,IValueFormatter {


    var values : [String]
    required init (values : [String]) {
        self.values = values
        super.init()
    }


    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return values[Int(value)]

    }

    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return values[Int(entry.x)]

    }
}
