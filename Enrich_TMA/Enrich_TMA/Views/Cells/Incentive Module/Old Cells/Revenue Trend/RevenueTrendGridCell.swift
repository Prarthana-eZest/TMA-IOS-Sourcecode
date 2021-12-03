//
//  FixedPayCell.swift
//  DemoApp
//
//  Created by Harshal on 25/01/21.
//  Copyright © 2021 Harshal. All rights reserved.
//

import UIKit
import Charts

class RevenueTrendGridCell: UITableViewCell, ChartViewDelegate {
    
    @IBOutlet var chartView: BarChartView!
    
    var months: [String]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func drawGraph(dataEntries: [[Double]]) {
        // Do any additional setup after loading the view.
        months = ["PAID SERVICE REVENUE", "RETAIL PRODUCT SALE", "MEMBERSHIP SUBSCRIPTION", "PACKAGE SALE"]
        configureChartData(dataPoints: months, values: dataEntries)
    }
        
    func configureChartData(dataPoints: [String], values: [[Double]]) {
        chartView.noDataText = "You need to provide data for the chart."
        
        let barChartData = BarChartData()
        
        values.forEach { data in
            
            var dataEntries: [BarChartDataEntry] = []
                                    
            for i in 0..<dataPoints.count {
                let dataEntry = BarChartDataEntry(x: Double(i+1), y: data[i])
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "First Month")
            chartDataSet.drawValuesEnabled = false
            chartDataSet.colors = [UIColor.random()]//UIColor(red:0.2, green:0.71, blue:0.77, alpha:1)]

            barChartData.addDataSet(chartDataSet)
        }
        let barWidth = 0.15
        let barSpace = 0.05
        let groupSpace = (1 - (barWidth * Double(values.count)))
        
        barChartData.barWidth = barWidth
        chartView.data = barChartData
                        
        barChartData.groupBars(fromX: 0.55, groupSpace: groupSpace, barSpace: barSpace)
                
        // xAxis
        let xAxis = chartView.xAxis
        xAxis.enabled = true
        xAxis.labelPosition = .bottom
        xAxis.labelCount = dataPoints.count
        xAxis.wordWrapEnabled = true
        xAxis.valueFormatter = CustomValueFormatter(values: months)
        xAxis.labelTextColor = UIColor(red:0.53, green:0.6, blue:0.68, alpha:1)
        xAxis.gridColor = UIColor(red:0.5, green:0.59, blue:0.69, alpha:1)
        xAxis.axisLineColor = UIColor(red:0.53, green:0.6, blue:0.68, alpha:1)
        xAxis.drawGridLinesEnabled = true
        xAxis.axisLineWidth = 0.5
        xAxis.gridLineDashLengths = [(1.5)]

        // Right Axis
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = false
        
        // Left Axis
        let leftAxis = chartView.leftAxis
       // leftAxis.labelCount = 5
        leftAxis.labelTextColor = UIColor(red:0.53, green:0.6, blue:0.68, alpha:1)
        leftAxis.labelPosition = .outsideChart
        leftAxis.axisMinimum = 0
        leftAxis.valueFormatter = LargeValueFormatter()
        leftAxis.gridColor = UIColor(red:0.5, green:0.59, blue:0.69, alpha:1)
        leftAxis.axisLineColor = UIColor(red:0.53, green:0.6, blue:0.68, alpha:1)
        leftAxis.drawGridLinesEnabled = true
        leftAxis.axisLineWidth = 0.5
        leftAxis.gridLineDashLengths = [(1.5)]
        
        let l = chartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        l.formSize = 9
        l.textColor = UIColor(red:0.53, green:0.6, blue:0.68, alpha:1)
        l.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 11)!
        
        chartView.extraBottomOffset = 30
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }

}

extension UIColor {
    
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
