//
//  IncentiveDashboardCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 03/08/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit


protocol IncentiveDashboardDelegate: class {
    func actionTechnicianNext()
    func actionEarningsNext()
}

class IncentiveDashboardCell: UITableViewCell {
    
    enum IncentiveDashboardType {
        case gridView
        case listView
    }
    
    @IBOutlet weak var gridStackView: UIStackView!
    @IBOutlet weak var listStackView: UIStackView!
    
    var viewType:IncentiveDashboardType = .gridView
    weak var delegate: IncentiveDashboardDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell() {
        gridStackView.isHidden = (viewType != .gridView)
        listStackView.isHidden = (viewType != .listView)
    }

    @IBAction func actionIncentiveNext(_ sender: UIButton) {
        self.delegate?.actionTechnicianNext()
    }
    
    @IBAction func actionEarningsNext(_ sender: UIButton) {
        self.delegate?.actionEarningsNext()
    }
    
}
