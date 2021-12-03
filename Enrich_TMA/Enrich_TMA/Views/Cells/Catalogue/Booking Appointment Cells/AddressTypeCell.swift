//
//  AddressTypeCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 16/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

enum AddressTypes {
    static let home = "Home"
    static let work = "Work Place"

}
protocol AddressTypeDelegate: class {
    func selectedAddressType(type: String)
    func editingChangeInTextField(_ arrayOfTextFieldValues: [String])

}

class AddressTypeCell: UITableViewCell {

    @IBOutlet weak private var btnHome: UIButton!
    @IBOutlet weak private var btnWork: UIButton!
    @IBOutlet weak private var btnOther: UIButton!
    @IBOutlet weak private var txtfOthePlace: UITextField!
    @IBOutlet weak private var otherStackView: UIStackView!
    @IBOutlet weak private var dividerLineView: UIView!
    @IBOutlet private var buttons: [UIButton]!
    var arrayofTextFieldValues = [String]()

    weak var delegate: AddressTypeDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtfOthePlace.delegate = self

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(addressType: String) {

        let addressTypeOfUser = (addressType.containsIgnoringCase(find: AddressTypes.home) && addressType.count == 4) ? AddressTypes.home : (addressType.containsIgnoringCase(find: AddressTypes.work) && addressType.count == 10) ? AddressTypes.work : addressType
        txtfOthePlace.text = (addressTypeOfUser.containsIgnoringCase(find: AddressTypes.home) && addressTypeOfUser.count == 4) ? "" : (addressTypeOfUser.containsIgnoringCase(find: AddressTypes.work) && addressTypeOfUser.count == 10) ? "" : addressType
        arrayofTextFieldValues.removeAll()
        setValuesToArray()

        (addressType.containsIgnoringCase(find: AddressTypes.home) && addressType.count == 4) ? actionAddressType(btnHome) : (addressType.containsIgnoringCase(find: AddressTypes.work) && addressType.count == 10) ? actionAddressType(btnWork) : actionAddressType(btnOther)

    }
    private func setValuesToArray() {
        arrayofTextFieldValues.append(txtfOthePlace.text ?? "")

    }

    @IBAction func actionAddressType(_ sender: UIButton) {
        buttons.forEach {$0.isSelected = false}
        sender.isSelected = true
        otherStackView.isHidden = (sender != btnOther)
        dividerLineView.isHidden = (sender != btnOther)
       // let type:AddressType = (sender == btnHome) ? .Home : (sender == btnWork) ? .Work : .Other
        txtfOthePlace.text = (sender == btnHome) ? AddressTypes.home : (sender == btnWork) ? AddressTypes.work : arrayofTextFieldValues.first
        delegate?.selectedAddressType(type: txtfOthePlace.text ?? AddressTypes.home)
    }

}
extension AddressTypeCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
}
    func textFieldDidEndEditing(_ textField: UITextField) {

        switch textField {
        case txtfOthePlace:
            arrayofTextFieldValues[0] = txtfOthePlace.text ?? ""

        default:break

        }
        delegate?.editingChangeInTextField(arrayofTextFieldValues)
    }
}
