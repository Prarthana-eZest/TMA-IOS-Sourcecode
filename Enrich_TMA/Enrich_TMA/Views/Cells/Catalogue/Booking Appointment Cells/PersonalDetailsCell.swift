//
//  PersonalDetailsCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 16/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

struct PersonalDetails {
    var name: String = ""
    var lastname: String = ""
    var contactNo: String = ""
    var emailAddress: String = ""
    var relation: String = ""
    var gender: Gender = Gender.otherFemale
}

struct PersonalDetailsCellModel {
    let firstName: String
    let lastName: String
    let contactNumber: String
    let emailId: String
}

protocol GetPersonalDetailsDelegate: class {
    func getAllPersonalDetails(details: PersonalDetails)
}

class PersonalDetailsCell: UITableViewCell {

    let TAG_NAME = 101
    let TAG_LASTNAME = 102
    let TAG_CONTACT = 103
    let TAG_EMAIL = 104
    let TAG_RELATION = 105

    weak var delegate: GetPersonalDetailsDelegate?
    var modelDetails = PersonalDetails()

    @IBOutlet weak var txtfFirstName: UITextField!
    @IBOutlet weak var txtfLastName: UITextField!
    @IBOutlet weak var txtfContactNumber: UITextField!
    @IBOutlet weak var txtfEmailAddress: UITextField!
    @IBOutlet weak var txtfRelation: UITextField!

    @IBOutlet weak var relationStackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtfFirstName.delegate = self
        txtfLastName.delegate = self
        txtfContactNumber.delegate = self
        txtfEmailAddress.delegate = self
        txtfRelation.delegate = self

        txtfFirstName.tag = TAG_NAME
        txtfLastName.tag = TAG_LASTNAME
        txtfContactNumber.tag = TAG_CONTACT
        txtfEmailAddress.tag = TAG_EMAIL
        txtfRelation.tag = TAG_RELATION
    }

    func configureCell(model: PersonalDetailsCellModel) {
        self.txtfFirstName.text = model.firstName
        self.txtfLastName.text = model.firstName
        self.txtfContactNumber.text = model.contactNumber
        self.txtfEmailAddress.text = model.emailId
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func hideRelationStack(hideStack: Bool) {
        relationStackView.isHidden = hideStack
    }
}

extension PersonalDetailsCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == TAG_CONTACT {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            if updatedText.isNumber() && updatedText.count <= 10 {
                return true
            }
            return false
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == TAG_NAME {
            modelDetails.name = textField.text ?? ""
        }
        else if textField.tag == TAG_LASTNAME {
            modelDetails.lastname = textField.text ?? ""
        }
        else if textField.tag == TAG_CONTACT {
            modelDetails.contactNo = textField.text ?? ""
        }
        else if textField.tag == TAG_EMAIL {
            modelDetails.emailAddress = textField.text ?? ""
        }
        else if textField.tag == TAG_RELATION {
            modelDetails.relation = textField.text ?? ""
        }
        delegate?.getAllPersonalDetails(details: modelDetails)
    }
}
