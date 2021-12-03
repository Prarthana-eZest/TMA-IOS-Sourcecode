//
//  CashPaymentCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 05/02/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

protocol TransactionDetailsDelegate: class {
    func actionApply()
    func actionRemove()
    func showValidationAlert(message: String)
}

class TransactionDetailsCell: UITableViewCell {
    @IBOutlet weak private var txtfAmount: UITextField!
    @IBOutlet weak private var txtfTransactionId: UITextField!
    @IBOutlet weak private var txtfPaymentMode: UITextField!
    @IBOutlet weak private var btnApply: UIButton!
    @IBOutlet weak private var btnPaymentMode: UIButton!
    
    
    weak var delegate: TransactionDetailsDelegate?
    var indexPath: IndexPath?
    var model: PaymentDetails?
    var paymentModeOptions = [String]()
    var paymentModeTitle = ""
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(model: PaymentDetails?) {
        self.model = model
        txtfAmount.text = model?.amount ?? ""
        txtfTransactionId.text = model?.details ?? ""
        txtfPaymentMode.text = model?.method ?? ""
        btnApply.isSelected = (model?.use ?? 0) == 1
        allowEdit(status: (model?.use ?? 0) == 0)
        txtfPaymentMode.placeholder = paymentModeTitle
    }
    
    func allowEdit(status: Bool) {
        txtfAmount.isUserInteractionEnabled = status
        txtfTransactionId.isUserInteractionEnabled = status
        btnPaymentMode.isUserInteractionEnabled = status
    }

    @IBAction func actionApply(_ sender: UIButton) {
        if btnApply.isSelected {
            model?.amount = txtfAmount.text
            model?.details = txtfTransactionId.text
            model?.method = txtfPaymentMode.text
            model?.use = 0
            delegate?.actionRemove()
        }
        else {
            if checkForValidations() {
                model?.amount = txtfAmount.text
                model?.details = txtfTransactionId.text
                model?.method = txtfPaymentMode.text
                model?.use = 1
                delegate?.actionApply()
            }
            else {
                delegate?.showValidationAlert(message: "Please enter details")
            }
        }
    }
    
    @IBAction func actionRemove(_ sender: UIButton) {
        model?.use = 0
        delegate?.actionRemove()
    }
    
    @IBAction func actionPaymentMode(_ sender: UIButton) {
        let text = self.txtfPaymentMode.text ?? ""
        let selectedItem = !text.isEmpty ? text : (paymentModeOptions.first ?? "")
        ListPickerDialog().show(paymentModeTitle, sourceList: paymentModeOptions, doneButtonTitle: "Select", cancelButtonTitle: "Cancel", selectedItem: selectedItem) { selectedText in
            self.txtfPaymentMode.text = selectedText
        }
    }
    
    func checkForValidations() -> Bool{
        
        let amount = txtfAmount.text ?? ""
        let transactionId = txtfTransactionId.text ?? ""
        let method = txtfPaymentMode.text ?? ""
        
        if amount.isEmpty || transactionId.isEmpty || method.isEmpty {
            return false
        }
        return true
    }
    
}
