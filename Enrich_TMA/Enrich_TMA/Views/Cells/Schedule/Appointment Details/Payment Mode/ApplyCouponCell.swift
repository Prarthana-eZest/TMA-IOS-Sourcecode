//
//  ApplyCouponCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 11/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol ApplyCouponCellDelegate: class {
    func applyCode(cell: ApplyCouponCell)
    func actionApplyCode(code: String)
    func actionCouponList()
}

class ApplyCouponCell: UITableViewCell {

    weak var delegate: ApplyCouponCellDelegate?
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var imgNext: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtApplyGiftCard: UITextField!
    @IBOutlet weak var stackViewEnterGiftCard: UIStackView!
    @IBOutlet weak var btnCouponList: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtApplyGiftCard.delegate = self
        stackViewEnterGiftCard.isHidden = true
        imgNext.image = UIImage(named: "downArrow")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func actionApplyCoupon(_ sender: Any) {
        delegate?.actionApplyCode(code: self.txtApplyGiftCard.text ?? "")
    }

    @IBAction func actionBtnCross(_ sender: Any) {
        delegate?.applyCode(cell: self)
    }

    @IBAction func actionCouponList(_ sender: UIButton) {
        delegate?.actionCouponList()
    }

}

extension ApplyCouponCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
