//
//  ProductivityGridViewCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 16/02/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit
import Charts

enum LineChartViewMode {
    case day,week,month,year
}

class ProductivityGridViewCell: UITableViewCell {
    
    @IBOutlet var chartView: LineChartView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var viewMode:LineChartViewMode = .month
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 2
    }
    
    @IBAction func actionSegmentControl(_ sender: UISegmentedControl) {
        segmentControl.layer.cornerRadius = segmentControl.bounds.height / 2
        segmentControl.layer.borderColor = UIColor(red: 250/255, green: 250/255, blue: 252/255, alpha: 1.0).cgColor
        segmentControl.layer.borderWidth = 1
        segmentControl.layer.masksToBounds = true
        segmentControl.backgroundColor = UIColor.white
    }
    
    func drawGraph() {
        // Do any additional setup after loading the view.
        configureSegmentControl()
        
        let yValues = [500.0, 150.0, 650.0, 1200, 550, 900, 900, 500.0, 150.0, 650.0, 1200, 550, 900, 900]
        let xValues = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0]
        
        switch viewMode {
        case .day:
            setDataCount(xValues: [1], yValues: [(yValues.last ?? 1)])
        case .week:
            setDataCount(xValues: xValues, yValues: yValues)
        case .month:
            setDataCount(xValues: xValues, yValues: yValues)
        case .year:
            setDataCount(xValues: xValues, yValues: yValues)
        }
    }
    
    func setDataCount(xValues: [Double],yValues: [Double]) {
        var entries = [ChartDataEntry]()
        
        for i in 0..<(xValues.count) {
            entries.append(ChartDataEntry(x: xValues[i], y: yValues[i]))
        }
        
        let set1 = LineChartDataSet(entries: entries, label: "DataSet 1")
        set1.drawIconsEnabled = false
        setup(set1)
        
        let gradientColors = [UIColor(red: 250/255, green: 250/255, blue: 252/255, alpha: 1.0).cgColor,
                              UIColor(red: 224/255, green: 230/255, blue: 253/255, alpha: 1.0).cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        
        set1.fillAlpha = 1
        set1.fill = Fill.init(linearGradient: gradient, angle: 90)
        set1.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: set1)
        
        // xAxis
        let xAxis = chartView.xAxis
        xAxis.enabled = true
        xAxis.labelPosition = .bottom
        xAxis.labelCount = yValues.count
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        
        // Right Axis
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = false
        
        // Left Axis
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 5
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 1
        leftAxis.axisMinimum = 0
        leftAxis.drawLabelsEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.axisMaximum = 1500
        leftAxis.drawAxisLineEnabled = false
        
        chartView.extraBottomOffset = 20
        chartView.data = data
    }
    
    private func setup(_ dataSet: LineChartDataSet) {
        dataSet.highlightLineDashLengths = nil
        dataSet.setColors(UIColor(red: 103/255, green: 115/255, blue: 142/255, alpha: 1.0))
        dataSet.setCircleColor(UIColor(red: 103/255, green: 115/255, blue: 142/255, alpha: 1.0))
        dataSet.lineWidth = 1
        dataSet.circleRadius = 4
        dataSet.drawCircleHoleEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.formLineWidth = 1
        dataSet.formSize = 15
        dataSet.mode = .horizontalBezier
    }
    
}

extension ProductivityGridViewCell {
    
    func gradient(size:CGSize,color:[UIColor]) -> UIImage?{
        //turn color into cgcolor
        let colors = color.map{$0.cgColor}
        //begin graphics context
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        // From now on, the context gets ended if any return happens
        defer {UIGraphicsEndImageContext()}
        //create core graphics context
        let locations:[CGFloat] = [0.0,1.0]
        guard let gredient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as NSArray as CFArray, locations: locations) else {
            return nil
        }
        //draw the gradient
        context.drawLinearGradient(gredient, start: CGPoint(x:0.0,y:size.height), end: CGPoint(x:size.width,y:size.height), options: [])
        // Generate the image (the defer takes care of closing the context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    func configureSegmentControl() {
        
        if let font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 12) {
            let titleTextSelected = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: font]
            let titleTextNormal = [
                NSAttributedString.Key.foregroundColor: UIColor(red:0.45, green:0.51, blue:0.62, alpha:1),
                NSAttributedString.Key.font: font]
            segmentControl.setTitleTextAttributes(titleTextNormal, for: .normal)
            segmentControl.setTitleTextAttributes(titleTextSelected, for: .selected)
        }
        segmentControl.layer.cornerRadius = segmentControl.bounds.height / 2
        segmentControl.layer.borderColor = UIColor(red: 250/255, green: 250/255, blue: 252/255, alpha: 1.0).cgColor
        segmentControl.layer.borderWidth = 1
        segmentControl.layer.masksToBounds = true
        segmentControl.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 252/255, alpha: 1.0)
    }
}
