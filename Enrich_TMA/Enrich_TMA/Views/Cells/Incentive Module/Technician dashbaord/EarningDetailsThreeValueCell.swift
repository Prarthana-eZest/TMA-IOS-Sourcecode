//
//  EarningDetailsThreeValueCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 13/08/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit
import Charts

class EarningDetailsThreeValueCell: UITableViewCell, ChartViewDelegate {

    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var trendlineView: UIStackView!
    @IBOutlet weak private var chartParentView: UIView!
    @IBOutlet weak private var parentView: UIView!
    
    @IBOutlet weak private var graphFilterBtn: UIButton!
    @IBOutlet weak private var imageDropDown: UIImageView!
    @IBOutlet weak private var chartView: CombinedChartView!
    
    // First View
    @IBOutlet weak var firstValueView: UIView!
    @IBOutlet weak var lblFirstViewTitle: UILabel!
    @IBOutlet weak var lblFirstViewSubTitle: UILabel!
    
    // Second View
    @IBOutlet weak var secondValueView: UIView!
    @IBOutlet weak var lblSecondViewTitle: UILabel!
    @IBOutlet weak var lblSecondViewSubTitle: UILabel!
    
    // Third View
    @IBOutlet weak var thirdValueView: UIView!
    @IBOutlet weak var lblThirdViewTitle: UILabel!
    @IBOutlet weak var lblThirdViewSubTitle: UILabel!

    
    var model: EarningsCellDataModel!
        
    var dataModel: [GraphDataEntry]?
    
    weak var delegate: EarningDetailsDelegate?
    
    weak var parentVC: UIViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        parentView.clipsToBounds = true
        parentView.layer.cornerRadius = 8
        parentView.layer.masksToBounds = false
        parentView.layer.shadowRadius = 8
        parentView.layer.shadowOpacity = 0.20
        parentView.layer.shadowOffset = CGSize(width: 0, height: 10)
        parentView.layer.shadowColor = UIColor.gray.cgColor
        
        chartParentView.clipsToBounds = true
        chartParentView.layer.cornerRadius = 8
        chartParentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    @IBAction func actionViewTrendline(_ sender: UIButton) {
        model.isExpanded = !model.isExpanded
        chartParentView.isHidden = !model.isExpanded
        imageDropDown.image = chartParentView.isHidden ? UIImage(named: "downArrow") : UIImage(named: "upArrow")
        delegate?.reloadData()
    }
    
    func configureCell(model: EarningsCellDataModel, data: [GraphDataEntry]) {
        self.model = model
        self.lblTitle.text = model.title
        trendlineView.isHidden = !model.showGraph
        chartParentView.isHidden = !model.isExpanded
       // if chartView.data == nil, !model.isExpanded {
            drawGraph(graphData: data, showRightAxix: (model.earningsType == .CustomerEngagement || model.earningsType == .ResourceUtilisation))
        //}
        graphFilterBtn.setTitle(model.dateRangeType.rawValue, for: .normal)
        thirdValueView.isHidden = model.cellType == .DoubleValue
        
        switch model.cellType {
        case .SingleValue, .PackageType: break
        case .DoubleValue:
            firstValueView.backgroundColor = model.earningsType.doubleValueTileColors?.first
            secondValueView.backgroundColor = model.earningsType.doubleValueTileColors?.last
            if(model.earningsType == .PenetrationRatios){
                lblFirstViewTitle.text = model.value[0]
                lblSecondViewTitle.text = model.value[1]
               
                lblFirstViewSubTitle.text = model.subTitle[0]
                lblSecondViewSubTitle.text = model.subTitle[1]
            }
            
        case .TripleValue:
            firstValueView.backgroundColor = model.earningsType.tripleValueTileColors?.first
            secondValueView.backgroundColor = model.earningsType.tripleValueTileColors?[1]
            thirdValueView.backgroundColor = model.earningsType.tripleValueTileColors?.last
            
            if(model.earningsType == .ResourceUtilisation || model.earningsType == .PenetrationRatios){
                lblFirstViewTitle.text = model.value[0]
                lblSecondViewTitle.text = model.value[1]
                lblThirdViewTitle.text = model.value[2]
                
                lblFirstViewSubTitle.text = model.subTitle[0]
                lblSecondViewSubTitle.text = model.subTitle[1]
                lblThirdViewSubTitle.text = model.subTitle[2]
            }
        }
        
    }
    
    @IBAction func actionDurationFilter(_ sender: UIButton) {
        delegate?.actionDurationFilter(forCell: self)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("Selected")
        guard let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] else {
            return
        }
        let entryIndex = dataSet.entryIndex(entry: entry)
        if let data = dataModel, entryIndex >= 0  {
            var text = ""
            data.forEach {
                text.append(!text.isEmpty ? "\n" : "")
                text.append("\($0.dataTitle) \($0.values[entryIndex])")
            }
            self.parentVC?.showToast(alertTitle: alertTitle, message: text, seconds: toastMessageDuration)
        }
    }
    
}

extension EarningDetailsThreeValueCell {
    
    func drawGraph(graphData: [GraphDataEntry], showRightAxix: Bool) {
        dataModel = graphData
    
        chartView.noDataText = "You need to provide data for the chart."
        
        let data = CombinedChartData()

        if let lineData = graphData.first(where: { $0.graphType == .linedGraph }) {
            data.lineData = generateLineData(graphData: lineData)
        }
        
        let barData = graphData.filter { $0.graphType == .barGraph }
        if !barData.isEmpty {
            data.barData = generateBarData(graphData: barData)
        }
        
        chartView.data = data
        chartView.notifyDataSetChanged()
        chartView.delegate = self
        
        // xAxis
        let xAxis = chartView.xAxis
        xAxis.enabled = true
        xAxis.labelPosition = .bottom
        xAxis.labelCount = graphData.first?.units.count ?? 0
        xAxis.wordWrapEnabled = true
        xAxis.valueFormatter = CustomValueFormatter(values: graphData.first?.units ?? [])
        xAxis.labelTextColor = UIColor(red: 0.17, green: 0.16, blue: 0.16, alpha: 1.00)
        if let font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 8.0) {
            xAxis.labelFont = font
        }
        xAxis.gridColor = UIColor(red: 0.61, green: 0.62, blue: 0.70, alpha: 1.00)
        xAxis.axisLineColor = UIColor(red: 0.61, green: 0.62, blue: 0.70, alpha: 1.00)
        xAxis.drawGridLinesEnabled = false
        xAxis.axisLineWidth = 0.5
        xAxis.gridLineDashLengths = [(5.0)]
        xAxis.axisMinimum = 0.5
        xAxis.axisMaximum = Double(graphData.first?.units.count ?? 0) + 1
        xAxis.spaceMin = 0.3
        xAxis.spaceMax = 0.3
        
        
        // Left Axis
        let leftAxis = chartView.leftAxis
        leftAxis.setLabelCount(6, force: true)
        leftAxis.labelTextColor = UIColor(red: 0.61, green: 0.62, blue: 0.70, alpha: 1.00)
        if let font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 8.0) {
            leftAxis.labelFont = font
        }
        leftAxis.labelPosition = .outsideChart
        leftAxis.axisMinimum = 0
        //leftAxis.valueFormatter = LargeValueFormatter()
        leftAxis.gridColor = UIColor(red: 0.61, green: 0.62, blue: 0.70, alpha: 1.00)
        leftAxis.axisLineColor = UIColor(red: 0.61, green: 0.62, blue: 0.70, alpha: 1.00)
        leftAxis.drawGridLinesEnabled = true
        leftAxis.axisLineWidth = 0.5
        leftAxis.gridLineDashLengths = [(5.0)]
        
        
        // Right Axis
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = showRightAxix
        rightAxis.setLabelCount(6, force: true)
        rightAxis.labelTextColor = UIColor(red: 0.61, green: 0.62, blue: 0.70, alpha: 1.00)
        if let font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 8.0) {
            rightAxis.labelFont = font
        }
        rightAxis.labelPosition = .outsideChart
        rightAxis.axisMinimum = 0
        //leftAxis.valueFormatter = LargeValueFormatter()
        rightAxis.gridColor = UIColor(red: 0.61, green: 0.62, blue: 0.70, alpha: 1.00)
        rightAxis.axisLineColor = UIColor(red: 0.61, green: 0.62, blue: 0.70, alpha: 1.00)
        rightAxis.drawGridLinesEnabled = false
        rightAxis.axisLineWidth = 0.5
        rightAxis.gridLineDashLengths = [(5.0)]
        
        let l = chartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.drawInside = true
        l.form = .circle
        l.formSize = 9
        l.textColor = UIColor(red: 0.17, green: 0.16, blue: 0.16, alpha: 1.00)
        if let font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 10) {
            l.font = font
        }
        l.yOffset = -48
        
//        let marker:BalloonMarker = BalloonMarker(color: UIColor.white, font: UIFont(name: FontName.FuturaPTBook.rawValue, size: 10)!, textColor: UIColor.black, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0))
//        marker.minimumSize = CGSize(width: 75.0, height: 35.0)
//        chartView.marker = marker
        
        chartView.extraBottomOffset = 10
        chartView.extraTopOffset = 50
        chartView.doubleTapToZoomEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        chartView.fitScreen()
    }
    
    func generateBarData(graphData: [GraphDataEntry]) -> BarChartData{
        
        let barChartData = BarChartData()
        
        graphData.forEach { data in
            var dataEntries: [BarChartDataEntry] = []
            
            for i in 0..<data.values.count {
                let dataEntry = BarChartDataEntry(x: Double(i+1), y: data.values[i])
                dataEntries.append(dataEntry)
            }
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: data.dataTitle)
            chartDataSet.drawValuesEnabled = false
            chartDataSet.colors = [data.barColor]
            chartDataSet.highlightColor = UIColor.clear
            barChartData.addDataSet(chartDataSet)
        }
        var barWidth = 0.3
        let barSpace = 0.0
        let groupSpace = (1 - (barWidth * Double(graphData.count)))
        
        if let barCount = barChartData.dataSets.first?.entryCount, barCount <= 5 { barWidth = 0.05 * Double(barCount) }
        barChartData.barWidth = barWidth        
        return barChartData
    }
    
    func generateLineData(graphData: GraphDataEntry) -> LineChartData {
        // MARK: ChartDataEntry
        
        var entries = [ChartDataEntry]()
        
        for i in 0..<graphData.values.count {
            let dataEntry = BarChartDataEntry(x: Double(i+1), y: graphData.values[i])
            entries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: entries, label: graphData.dataTitle)
        chartDataSet.drawValuesEnabled = false
        chartDataSet.colors = [graphData.barColor]
        
        // MARK: LineChartDataSet
        let set = LineChartDataSet(entries: entries, label: graphData.dataTitle)
        set.colors = [graphData.barColor]
        set.lineWidth = 1.5
        set.circleColors = [graphData.barColor]
        set.circleRadius = 6
        set.circleHoleRadius = 4.5
        //set.fillColor = graphData.barColor
        set.circleColors = [UIColor.white]
        set.circleHoleColor = graphData.barColor
        set.mode = .linear
        set.drawValuesEnabled = false
        
        if let font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 10) {
            set.valueFont = font
        }
        set.valueTextColor = graphData.barColor
        set.axisDependency = .right
        
        // MARK: LineChartData
        let data = LineChartData()
        data.addDataSet(set)
        return data
    }
    
}
