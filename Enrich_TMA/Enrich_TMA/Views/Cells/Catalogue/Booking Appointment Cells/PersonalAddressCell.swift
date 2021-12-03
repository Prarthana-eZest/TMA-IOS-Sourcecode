//
//  PerosnalAddressCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 16/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class PersonalAddressCell: UITableViewCell {

    @IBOutlet weak private var txtfApartment: UITextField!
    @IBOutlet weak private var txtfLandmark: UITextField!
    @IBOutlet weak private var txtfCityTown: UITextField!
    @IBOutlet weak private var txtfPincode: UITextField!
    @IBOutlet weak private var txtfState: UITextField!

    var states = [String]()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtfApartment.delegate = self
        txtfCityTown.delegate = self
        txtfLandmark.delegate = self
        txtfPincode.delegate = self
        txtfState.delegate = self
    }

    func configureCell(model: PersonalAddressCellModel) {
        self.txtfApartment.text = model.apartment
        self.txtfCityTown.text = model.cityTown
        self.txtfLandmark.text = model.landmark
        self.txtfPincode.text = model.pinCode
        self.txtfState.text = model.state.first
        self.states.removeAll()
        self.states.append(contentsOf: model.state)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func showListPicker(title: String, list: [String], textField: UITextField) {
        textField.endEditing(true)
        ListPickerDialog().show(title, sourceList: list, doneButtonTitle: "Select", cancelButtonTitle: "Cancel", selectedItem: list.first ?? "") { selectedText in
            if let selectedText = selectedText {
                textField.text = selectedText
            }
        }
    }
}

struct PersonalAddressCellModel {
    let apartment: String
    let pinCode: String
    let cityTown: String
    let landmark: String
    let state: [String]
}

extension PersonalAddressCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txtfState {
            showListPicker(title: "Select Locations", list: self.states, textField: textField)
        }
    }
}
