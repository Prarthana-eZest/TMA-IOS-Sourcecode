//
//  AddNotesSingatureCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 28/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class AddNotesCell: UITableViewCell {

    @IBOutlet private weak var txtfNotesOne: CustomTextField!

    var fieldDetails: TagViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        [txtfNotesOne].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
    }

    func configureCell(model: TagViewModel) {
        fieldDetails = model
        txtfNotesOne.text = model.value
    }
}

extension AddNotesCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func editingChanged(_ textField: UITextField) {
        fieldDetails?.value = textField.text ?? ""
    }

}
