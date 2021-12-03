//
//  BestPossibleDiscountCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 03/08/20.
//  Copyright © 2020 e-zest. All rights reserved.
//

import UIKit

protocol BestDiscountCellDelegate: class {
    func actionDiscountList()
}

class BestPossibleDiscountCell: UITableViewCell {

    weak var delegate: BestDiscountCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBAction func actionNext(_ sender: UIButton) {
        delegate?.actionDiscountList()
    }
    
}
