//
//  AddedDetailsCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 23/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol AddressDetailsCellDelegate: class {
    func editingChangedInTextField(_ arrayOfTextFieldValues: [String])
}

class AddressDetailsCell: UITableViewCell {

    @IBOutlet weak private var txtfFirstName: UITextField!
    @IBOutlet weak private var txtfLastName: UITextField!
    @IBOutlet weak private var txtfApartment: UITextField!
    @IBOutlet weak private var txtfContactNo: UITextField!
    @IBOutlet weak private var txtfLandmark: UITextField!
    @IBOutlet weak private var txtfCityTown: UITextField!
    @IBOutlet weak private var txtfPincode: UITextField!
    @IBOutlet weak private var txtfState: UITextField!

    weak var delegate: AddressDetailsCellDelegate?
    var arrayofTextFieldValues = [String]()
    var arrayOfStatesForPicker = [String]()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtfFirstName.delegate = self
        txtfLastName.delegate = self
        txtfApartment.delegate = self
        txtfLandmark.delegate = self
        txtfContactNo.delegate = self
        txtfCityTown.delegate = self
        txtfPincode.delegate = self
        txtfState.delegate = self

        [txtfFirstName, txtfLastName, txtfContactNo, txtfApartment, txtfLandmark, txtfCityTown, txtfPincode, txtfState].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })

    }

    func configureCell(model: AddressDetailsCellModel, states: [String]) {
        txtfFirstName.text = model.firstName
        txtfLastName.text = model.lastName
        txtfLandmark.text = model.landmark
        txtfApartment.text = model.apartment
        txtfContactNo.text = model.contactNo
        txtfCityTown.text = model.cityTown
        txtfPincode.text = model.pinCode
        txtfState.text = model.state
        arrayOfStatesForPicker = states
        arrayofTextFieldValues.removeAll()
        setValuesToArray()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func setValuesToArray() {
        arrayofTextFieldValues.append(txtfFirstName.text ?? "")
        arrayofTextFieldValues.append(txtfLastName.text ?? "")
        arrayofTextFieldValues.append(txtfContactNo.text ?? "")
        arrayofTextFieldValues.append(txtfApartment.text ?? "")
        arrayofTextFieldValues.append(txtfLandmark.text ?? "")
        arrayofTextFieldValues.append(txtfCityTown.text ?? "")
        arrayofTextFieldValues.append(txtfPincode.text ?? "")
        arrayofTextFieldValues.append(txtfState.text ?? "")
    }

    @IBAction func actionStateSelection(_ sender: UIButton) {
        showListPicker(title: "Select State", list: arrayOfStatesForPicker, textField: txtfState)
    }

    private func showListPicker(title: String, list: [String], textField: UITextField) {
        textField.endEditing(true)
        ListPickerDialog().show(title, sourceList: list, doneButtonTitle: "Select", cancelButtonTitle: "Cancel", selectedItem: list.first ?? "") { selectedText in
            if let selectedText = selectedText {
                textField.text = selectedText
                self.arrayofTextFieldValues[7] = self.txtfState.text ?? ""
                self.delegate?.editingChangedInTextField(self.arrayofTextFieldValues)
                textField.resignFirstResponder()

            }
        }
    }

}

struct AddressDetailsCellModel {
    let firstName: String
    let lastName: String
    let apartment: String
    let contactNo: String
    let pinCode: String
    let cityTown: String
    let landmark: String
    let state: String
}

extension AddressDetailsCell {
    @objc func editingChanged(_ textField: UITextField) {
        switch textField {
        case txtfFirstName, txtfLastName, txtfContactNo, txtfApartment, txtfLandmark, txtfCityTown:break

        case txtfPincode:
            let numberOnly = NSCharacterSet(charactersIn: "0123456789")
            let stringFromTextField = NSCharacterSet(charactersIn: textField.text ?? "")
            let strValid = numberOnly.isSuperset(of: stringFromTextField as CharacterSet)
            if strValid {
                txtfPincode.text = textField.text

            }
            else {
                textField.text?.removeLast()
            }

        case txtfState:break

        default:break

        }
    }
}

extension AddressDetailsCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField == self.txtfState {
//            showListPicker(title: "Select State", list: arrayOfStatesForPicker, textField: textField)
//        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {

        switch textField {
        case txtfFirstName:
            arrayofTextFieldValues[0] = txtfFirstName.text ?? ""
        case txtfLastName:
            arrayofTextFieldValues[1] = txtfLastName.text ?? ""
        case txtfContactNo:
            arrayofTextFieldValues[2] = txtfContactNo.text ?? ""
        case txtfApartment:
            arrayofTextFieldValues[3] = txtfApartment.text ?? ""
        case txtfLandmark:
            arrayofTextFieldValues[4] = txtfLandmark.text ?? ""
        case txtfCityTown:
            arrayofTextFieldValues[5] = txtfCityTown.text ?? ""
        case txtfPincode:
            arrayofTextFieldValues[6] = txtfPincode.text ?? ""
        case txtfState:
            arrayofTextFieldValues[7] = txtfState.text ?? ""

        default:break

        }
        delegate?.editingChangedInTextField(arrayofTextFieldValues)
    }
}
