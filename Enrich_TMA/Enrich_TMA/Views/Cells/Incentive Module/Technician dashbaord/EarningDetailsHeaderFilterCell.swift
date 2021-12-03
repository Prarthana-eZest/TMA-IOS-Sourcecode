//
//  EarningDetailsHeaderFilterCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 05/08/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

protocol EarningsFilterDelegate: class {
    func actionDateFilter()
    func actionNormalFilter()
//    func changeFilterName(btnTitle: String)
}

class EarningDetailsHeaderFilterCell: UITableViewCell {
    
    @IBOutlet weak var dateFilterView: UIView!
    @IBOutlet weak var normalFilterView: UIView!

    @IBOutlet weak var btnDateFilter: UIButton!
    @IBOutlet weak var btnNormalFilter: UIButton!
    
    weak var delegate: EarningsFilterDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(showDateFilter: Bool, showNormalFilter: Bool, titleForDateSelection: String) {
        dateFilterView.isHidden = !showDateFilter
        normalFilterView.isHidden = !showNormalFilter
        btnDateFilter.setTitle(titleForDateSelection, for: .normal)
    }

    @IBAction func actionDateFilter(_ sender: UIButton) {
        self.delegate?.actionDateFilter()
    }
    
    @IBAction func actionNormalFilter(_ sender: UIButton) {
        self.delegate?.actionNormalFilter()
    }
    
//    func changeFilterName(btnTitle: String){
//        self.delegate?.changeFilterName(btnTitle: "")
//        btnDateFilter.setTitle(btnTitle, for: .normal)
//    }
}
