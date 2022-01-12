//
//  EarningsDateFilterCell.swift
//  Enrich_TMA
//
//  Created by Prarthana on 12/01/22.
//  Copyright © 2022 e-zest. All rights reserved.
//

import UIKit

protocol EarningsFilterDelegate: class {
    func actionDateFilter()
    func actionNormalFilter()
//    func changeFilterName(btnTitle: String)
}

class EarningsDateFilterCell: UITableViewCell {
    
    @IBOutlet weak var dateFilterView: UIView!
   

    @IBOutlet weak var btnDateFilter: UIButton!
   
    
    weak var delegate: EarningsFilterDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(showDateFilter: Bool, showNormalFilter: Bool, titleForDateSelection: String) {
        dateFilterView.isHidden = !showDateFilter
        btnDateFilter.setTitle(titleForDateSelection, for: .normal)
    }

    @IBAction func actionDateFilter(_ sender: UIButton) {
        self.delegate?.actionDateFilter()
    }
}
