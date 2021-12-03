//
//  EnterCouponCodeCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 05/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol ApplyCouponCodeDelegate: class {
    func actionApplyManualCode(couponCode: String)
}

class EnterCouponCodeCell: UITableViewCell {

    @IBOutlet weak var txtFCouponCode: UITextField!

    weak var delegate: ApplyCouponCodeDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func actionApply(_ sender: UIButton) {
        if let code = txtFCouponCode.text {
            delegate?.actionApplyManualCode(couponCode: code)
        }
    }

}
