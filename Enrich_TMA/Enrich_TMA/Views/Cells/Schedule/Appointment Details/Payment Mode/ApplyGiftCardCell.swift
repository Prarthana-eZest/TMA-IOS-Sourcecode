//
//  ApplyCouponCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 11/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol ApplyGiftCardCellDelegate: class {
    func applyGiftCard(cell: ApplyGiftCardCell)
    func actionApplyGiftCardCode(code: String)
}

class ApplyGiftCardCell: UITableViewCell {

    weak var delegate: ApplyGiftCardCellDelegate?
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var imgNext: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtApplyGiftCard: UITextField!
    @IBOutlet weak var stackViewEnterGiftCard: UIStackView!

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

    @IBAction func actionApplyGiftCard(_ sender: Any) {
        delegate?.actionApplyGiftCardCode(code: self.txtApplyGiftCard.text ?? "")
    }

    @IBAction func actionBtnCross(_ sender: Any) {
        delegate?.applyGiftCard(cell: self)
    }
}

extension ApplyGiftCardCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
