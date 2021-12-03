//
//  BillOfMaterialCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 11/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class BillOfMaterialCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak private var lblMaterialName: UILabel!
    @IBOutlet weak private var txtfQuantity: UITextField!
    @IBOutlet weak private var lblQuantity: UILabel!
    @IBOutlet weak private var imgIsRequired: UIImageView!

    var bomData: BillOfMaterialCellModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtfQuantity.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: BillOfMaterialCellModel) {
        self.bomData = model
        lblMaterialName.text = model.productName
        lblQuantity.text = model.unit
        txtfQuantity.text = model.quantity
        imgIsRequired.isHidden = !model.isRequired
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.bomData?.quantity = textField.text ?? "0"
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }

        let newText = oldText.replacingCharacters(in: r, with: string)
        let isNumeric = newText.isEmpty || (Double(newText) != nil)
        let numberOfDots = newText.components(separatedBy: ".").count - 1

        let numberOfDecimalDigits: Int
        if let dotIndex = newText.index(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        }
        else {
            numberOfDecimalDigits = 0
        }
        if (isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2) {
            self.bomData?.quantity = newText
        }

        return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
    }

}

class BillOfMaterialCellModel {
    var productName: String
    var quantity: String
    var unit: String
    var productCode: String
    var isRequired: Bool

    init(productName: String, quantity: String, unit: String, productCode: String, isRequired: Bool) {
        self.productCode = productCode
        self.quantity = quantity
        self.unit = unit
        self.productName = productName
        self.isRequired = isRequired
    }
}
