//
//  TeleMarketingCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 12/05/20.
//  Copyright © 2020 e-zest. All rights reserved.
//

import UIKit

protocol TeleMarketingDelegate: class {
    func actionCallCustomer(indexPath: IndexPath)
    func actionSelectAction(indexPath: IndexPath)
    func actionSave(indexPath: IndexPath)
    func actionHistory(indexPath: IndexPath)
}

class TeleMarketingCell: UITableViewCell {

    @IBOutlet weak private var lblCustomerName: UILabel!
    @IBOutlet weak private var btnCall: UIButton!
    @IBOutlet weak private var notesTextView: UITextView!
    @IBOutlet weak private var btnSelectAction: UIButton!
    @IBOutlet weak private var btnSave: UIButton!

    weak var delegate: TeleMarketingDelegate?
    var indexPath: IndexPath?

    var model: TeleMarketingModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        notesTextView.delegate = self
        notesTextView.text = AddNewNoteVC.TextViewPlaceHolder
        notesTextView.textColor = UIColor.lightGray
        btnSelectAction.setTitle("Select Action", for: .normal)
    }

    func configureCell(model: TeleMarketingModel) {
        self.model = model
        lblCustomerName.text = model.customerName
        if model.noteText.isEmpty {
            notesTextView.text = AddNewNoteVC.TextViewPlaceHolder
            notesTextView.textColor = UIColor.lightGray
        }
        else {
            notesTextView.text = model.noteText
            notesTextView.textColor = UIColor.darkGray
        }
        btnSave.isEnabled = !model.noteText.isEmpty
        btnSelectAction.setTitle(model.status_label, for: .selected)
        btnSelectAction.isSelected = !model.status_label.isEmpty
    }

    @IBAction func actionCall(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.actionCallCustomer(indexPath: indexPath)
        }
    }

    @IBAction func actionSelectAction(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.actionSelectAction(indexPath: indexPath)
        }
    }

    @IBAction func actionSave(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.actionSave(indexPath: indexPath)
        }
    }

    @IBAction func actionHistory(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.actionHistory(indexPath: indexPath)
        }
    }
}

class TeleMarketingModel {
    let customerName: String
    let contactNo: String
    var noteText: String
    var status: String
    var status_label: String
    let isEditable: Bool
    let call_id: String
    let date: String
    let employee: String
    let history: [TeleMarketingModel]

    init(customerName: String, contactNo: String,
         noteText: String, status: String,
         isEditable: Bool, status_label: String,
         call_id: String, date: String, employee: String,
         history: [TeleMarketingModel]) {
        self.customerName = customerName
        self.contactNo = contactNo
        self.noteText = noteText
        self.isEditable = isEditable
        self.status = status
        self.status_label = status_label
        self.call_id = call_id
        self.date = date
        self.employee = employee
        self.history = history
    }
}

extension TeleMarketingCell: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.darkGray
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = AddNewNoteVC.TextViewPlaceHolder
            textView.textColor = UIColor.lightGray
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        model?.noteText = textView.text ?? ""
        btnSave.isEnabled = !textView.text!.isEmpty
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"  // Recognizes enter key in keyboard
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
