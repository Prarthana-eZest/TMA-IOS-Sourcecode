//
//  OnlinePaymentCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 08/02/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

class OnlinePaymentCell: UITableViewCell {
    
    @IBOutlet weak private var lblPaymentTypeTitle: LabelButton!
    @IBOutlet weak private var lblPaymentOption: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(showTitle: Bool, paymentModeTitle: String) {
        lblPaymentOption.isHidden = !showTitle
        lblPaymentTypeTitle.text = paymentModeTitle
    }
        
}
