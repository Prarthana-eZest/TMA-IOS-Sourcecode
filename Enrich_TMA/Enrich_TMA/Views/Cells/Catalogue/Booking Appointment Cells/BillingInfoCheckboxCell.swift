//
//  BillingInfoCheckboxCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 18/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol BillingInfoDelegate: class {
    func actionCheckbox(selected: Bool)
}

class BillingInfoCheckboxCell: UITableViewCell {

    @IBOutlet weak private var btnCheckbox: UIButton!
    @IBOutlet weak private var lblTitle: UILabel!

    weak var delegate: BillingInfoDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(checkBoxText: String) {
        lblTitle.text = checkBoxText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func actionCheckbox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.actionCheckbox(selected: sender.isSelected)
        lblTitle.textColor = sender.isSelected ? UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1) : UIColor.gray
        if let font = UIFont(name: (sender.isSelected ? FontName.FuturaPTDemi.rawValue : FontName.FuturaPTBook.rawValue), size: is_iPAD ? 20.0 : 16.0) {
            lblTitle.font = font
        }
    }
}
