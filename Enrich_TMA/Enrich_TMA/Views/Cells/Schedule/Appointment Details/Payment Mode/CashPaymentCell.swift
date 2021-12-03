//
//  PaymentOptionsCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 29/08/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol PaymentOptionsDelegate: class {
    func actionApplyWallet(status: Bool)
    func actionApplyRedeemPoints(redeemPoints: String)
    func reloadTableView()
    func actionApplyPackage(cell: WalletAndRewardCell)
    func actionApplyCash(amount: String, apply: Bool)
}

class CashPaymentCell: UITableViewCell {

    // Applied Values
    @IBOutlet weak private var lblCashPaymentValue: UILabel!

    // Cash Received

    @IBOutlet weak private var cashView: UIView!
    @IBOutlet weak private var txtCashAmount: UITextField!
    @IBOutlet weak private var cashDropDownIcon: UIImageView!
    @IBOutlet weak private var btnApplyCash: UIButton!

    weak var delegate: PaymentOptionsDelegate?

    var enrichCashSelected = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtCashAmount.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: OfflinePaymentDetails) {
        txtCashAmount.text = model.cash.amount ?? ""
        lblCashPaymentValue.text = model.cash.amount ?? ""

        // Btn Apply / Remove
        if let cashAmount = model.cash.amount?.toDouble(), cashAmount > 0 {
            btnApplyCash.isSelected = true
            txtCashAmount.isUserInteractionEnabled = false
        }
        else {
            btnApplyCash.isSelected = false
            txtCashAmount.isUserInteractionEnabled = true
        }
    }

    func prePopulateRemainingAmount(remaningAmount: String) {
        // Prepopulate remaning amount
        if !remaningAmount.isEmpty,
            remaningAmount != "0" {
            if let appliedCashAmount = lblCashPaymentValue.text,
                appliedCashAmount.isEmpty {
                txtCashAmount.text = remaningAmount
            }
        }
    }

    // Hide Show UI action

    @IBAction func actionCashReceived(_ sender: UIButton) {
        cashView.isHidden = !cashView.isHidden
        cashDropDownIcon.image = UIImage(named: cashView.isHidden ? "downArrow" : "upArrow")
        delegate?.reloadTableView()
    }

    // Apply Code and Amount Action

    @IBAction func actionApplyCashPayment(_ sender: UIButton) {
        delegate?.actionApplyCash(amount: txtCashAmount.text ?? "", apply: !sender.isSelected)
    }
}

extension CashPaymentCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
