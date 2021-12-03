//
//  SelectFilterDateRangeCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 16/08/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

protocol SelectDateRangeDelegate: class {
    func actionFromDate()
    func actionToDate()
}

class SelectFilterDateRangeCell: UITableViewCell {
    
    @IBOutlet weak private var radioView: UIView!
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblFromDate: UILabel!
    @IBOutlet weak private var lblToDate: UILabel!
    @IBOutlet var btnFromDate: UIButton!
    @IBOutlet var btnToDate: UIButton!
    weak var delegate: SelectDateRangeDelegate?
    
    func configureCell(model: PackageFilterModel) {
        radioView.isHidden = !model.isSelected
        lblTitle.text = model.title
        
        if model.isSelected {
            lblTitle.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: 14)
            btnFromDate.isUserInteractionEnabled = true
            btnToDate.isUserInteractionEnabled = true
        }
        else {
            lblTitle.font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 14)
            btnFromDate.isUserInteractionEnabled = false
            btnToDate.isUserInteractionEnabled = false
        }
        
        lblFromDate.text = model.fromDate?.monthNameYearDate
        lblToDate.text = model.toDate?.monthNameYearDate
    }

    
    @IBAction func actionFrom(_ sender: UIButton) {
        delegate?.actionFromDate()
    }
    
    @IBAction func actionTo(_ sender: UIButton) {
        delegate?.actionToDate()
    }
    
}
