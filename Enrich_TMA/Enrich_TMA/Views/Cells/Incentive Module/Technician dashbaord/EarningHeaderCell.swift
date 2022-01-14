//
//  EarningHeaderCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 29/01/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

enum EarningViewType {
    case list, grid, earnings
}

protocol EnrningsDelegate: class {
    func actionChangeViewType(type: EarningViewType)
    func actionSelectMenu(model: EarningsHeaderDataModel, indexPath: IndexPath)
}

class EarningHeaderCell: UITableViewCell {
    
    @IBOutlet private weak var btnList: UIButton!
    @IBOutlet private weak var btnGrid: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var btnStackView: UIStackView!

    
    let gridViewHeight = 180
    let listViewHeight = 70
    
    var viewType:EarningViewType = .grid
    var earningsModel = [EarningsHeaderDataModel]()
    weak var delegate: EnrningsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib(nibName: CellIdentifier.earningGridViewCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.earningGridViewCell)
        collectionView.register(UINib(nibName: CellIdentifier.earningListViewCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.earningListViewCell)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func getValue(index : Int) -> Int {
        var cellValue : Int = 0
        
        let earningsJSON = UserDefaults.standard.value(Dashboard.GetEarningsDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_EarningsDashboard)
        
        let earningsData = earningsJSON?.data?.groups
        
        
        
        switch index {
        case 0:
            let fixedEarnings = earningsData?.filter({$0.group_label == "Fixed-Earning"})
            var dataArray = [Dashboard.GetEarningsDashboard.Transaction]()
            for objParameter in fixedEarnings ?? []{
                let objParameters = objParameter.parameters
                for objTransaction in objParameters ?? [] {
                    //for objData in objTransaction.transactions ?? []{
                        
                        dataArray = objTransaction.transactions?.filter({ (data) -> Bool in
                            if data.month == 12 && data.year == 2021 {
                                return true
                            }
                            return false
                        }) ?? []
                   // }
                }
                
            }
            print("Data array \(dataArray)")

        default:
            let earningsJSON = UserDefaults.standard.value(Dashboard.GetEarningsDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_EarningsDashboard)
            
            cellValue = earningsJSON?.data?.total_earning ?? 0
        }
        

        return cellValue
    }
    
    func configureCell(viewType: EarningViewType, value : Float) {
        earningsModel.removeAll()
        

        let dateRange = DateRange(Date.today.startOfMonth, Date.today)
        let dateRangeType : DateRangeType = .mtd
        
        if(viewType == .grid || viewType == .list){
        earningsModel.append(EarningsHeaderDataModel(earningsType: .Revenue, value: ((UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_key_RevenueTotal) as? Double)!), isExpanded: false, dateRangeType: dateRangeType, customeDateRange: dateRange))
        
        earningsModel.append(EarningsHeaderDataModel(earningsType: .Sales, value: ((UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_key_SalesToatal) as? Double)!), isExpanded: false, dateRangeType: dateRangeType, customeDateRange: dateRange))
        
        earningsModel.append(EarningsHeaderDataModel(earningsType: .FreeServices, value: ((UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_key_FreeServicesToatal) as? Double)!), isExpanded: false, dateRangeType: dateRangeType, customeDateRange: dateRange))
        
        earningsModel.append(EarningsHeaderDataModel(earningsType: .Footfall, value: ((UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_key_FootfallToatal) as? Double)!), isExpanded: false, dateRangeType: dateRangeType, customeDateRange: dateRange))
        
        earningsModel.append(EarningsHeaderDataModel(earningsType: .CustomerEngagement, value: 0.0, isExpanded: false, dateRangeType: dateRangeType, customeDateRange: dateRange))
        
        earningsModel.append(EarningsHeaderDataModel(earningsType: .Productivity, value: 0.0, isExpanded: false, dateRangeType: dateRangeType, customeDateRange: dateRange))
        
        earningsModel.append(EarningsHeaderDataModel(earningsType: .PenetrationRatios, value: 0.0, isExpanded: false, dateRangeType: dateRangeType, customeDateRange: dateRange))
        
        earningsModel.append(EarningsHeaderDataModel(earningsType: .ResourceUtilisation, value: 0.0, isExpanded: false, dateRangeType: dateRangeType, customeDateRange: dateRange))
        }
        else{
            let earningsJSON = UserDefaults.standard.value(Dashboard.GetEarningsDashboard.Response.self, forKey: UserDefauiltsKeys.k_key_EarningsDashboard)
            let currentMonth = Int(Date.today.string(format: "M"))
            for group in earningsJSON?.data?.groups ?? []{
                if let earningType = EarningDetails(rawValue: group.group_label ?? ""){
                    let transactions = group.parameters?.map({ (parameter) -> Dashboard.GetEarningsDashboard.Transaction? in
                        let filterTransaction = parameter.transactions?.filter({$0.month == currentMonth})
                        return filterTransaction?.first
                    })
                    let value = transactions?.compactMap({$0?.amount}).reduce(0){$0 + $1} ?? 0
                    
                    earningsModel.append(EarningsHeaderDataModel(earningsType: earningType, value: Double(value), isExpanded: false, dateRangeType: dateRangeType, customeDateRange: dateRange))
                }
            }
           //get trnacation - input gr - map
        }
        self.viewType = viewType
        if(viewType == .earnings){//for earnings
            btnList.isHidden = true
            btnGrid.isHidden = true
            btnStackView.isHidden = true
            let count = (earningsModel.count % 2 == 0) ? earningsModel.count / 2 : (earningsModel.count / 2 + 1)
            collectionViewHeight.constant = CGFloat((count * (gridViewHeight)))
        }
        else if viewType == .grid {
            let count = (earningsModel.count % 2 == 0) ? earningsModel.count / 2 : (earningsModel.count / 2 + 1)
            collectionViewHeight.constant = CGFloat((count * (gridViewHeight)))
            btnList.isHidden = false
            btnGrid.isHidden = false
            btnStackView.isHidden = false
            
            btnGrid.isSelected = true
            btnGrid.backgroundColor = UIColor(red: 0.87, green: 0.32, blue: 0.32, alpha: 1.00)

            btnList.isSelected = false
            btnList.backgroundColor = UIColor.white
        }else {
            collectionViewHeight.constant = CGFloat((earningsModel.count * (listViewHeight)))
            btnList.isSelected = true
            btnList.backgroundColor = UIColor(red: 0.87, green: 0.32, blue: 0.32, alpha: 1.00)
            btnList.isHidden = false
            btnGrid.isHidden = false
            btnStackView.isHidden = false
            
            btnGrid.isSelected = false
            btnGrid.backgroundColor = UIColor.white

        }
        collectionView.reloadData()
    }
    
    
    @IBAction func actionListView(_ sender: UIButton) {
        delegate?.actionChangeViewType(type: .list)
    }
    
    @IBAction func actionGridView(_ sender: UIButton) {
        delegate?.actionChangeViewType(type: .grid)
    }
    
}

extension EarningHeaderCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return earningsModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewType == .grid || viewType == .earnings {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.earningGridViewCell, for: indexPath) as? EarningGridViewCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(details: earningsModel[indexPath.row])
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.earningListViewCell, for: indexPath) as? EarningListViewCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(details: earningsModel[indexPath.row])
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if viewType == .grid || viewType == .earnings {
            return CGSize(width: (collectionView.bounds.width / 2) - 1, height: CGFloat(gridViewHeight))
        }else {
            return CGSize(width: collectionView.bounds.width, height: CGFloat(listViewHeight))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // Animation of UICollectionViewCell
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromTop, .showHideTransitionViews]
        
        UIView.transition(with:cell , duration: 1.0, options: transitionOptions, animations: {
            cell.isHidden = true
        })
        
        UIView.transition(with: cell, duration: 1.0, options: transitionOptions, animations: {
            cell.isHidden = false
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.actionSelectMenu(model: earningsModel[indexPath.row], indexPath: indexPath)
    }

}
