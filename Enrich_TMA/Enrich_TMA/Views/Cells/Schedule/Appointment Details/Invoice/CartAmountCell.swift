//
//  CartAmountCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 11/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol CardAmountCellDelegate: class {
    func applyChangeToWallet(status: Bool)
}

class CartAmountCell: UITableViewCell {

    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblPrice: UILabel!
    @IBOutlet weak private var btnCheckBox: UIButton!
    
    weak var delegate: CardAmountCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func actionCheckBox(_ sender: UIButton) {
        delegate?.applyChangeToWallet(status: !sender.isSelected)
    }
    

    func configureCell(model: CartAmountCellModel) {

        self.lblPrice.isHidden = false
        self.btnCheckBox.isHidden = !model.showCheckBox
        self.btnCheckBox.isSelected = model.isCheckBoxSelected

        if model.code == TotalSegmentsCode.grandtotal {
            self.lblTitle.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: 20.0)
            self.lblPrice.font = UIFont(name: FontName.NotoSansSemiBold.rawValue, size: 20.0)
            self.lblTitle.textColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
            self.lblPrice.textColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        }
        else {

            if model.code == TotalSegmentsCode.subtotal {
                self.lblTitle.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: 17.0)
                self.lblPrice.font = UIFont(name: FontName.NotoSansSemiBold.rawValue, size: 16.0)
            }
            else {
                self.lblTitle.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 17.0)
                self.lblPrice.font = UIFont(name: FontName.NotoSansRegular.rawValue, size: 16.0)
            }

            if model.code == TotalSegmentsCode.remainingAmount {
                self.lblPrice.textColor = UIColor(red: 232 / 255, green: 34 / 255, blue: 25 / 255, alpha: 1)
                self.lblTitle.textColor = UIColor(red: 232 / 255, green: 34 / 255, blue: 25 / 255, alpha: 1)
            }
            else {
                self.lblPrice.textColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
                self.lblTitle.textColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
            }

        }
        self.lblTitle.text = model.title
        self.lblPrice.text = model.price

        if model.code.compareIgnoringCase(find: TotalSegmentsCode.taxNote) {
            self.lblPrice.isHidden = true
        }
    }

}

struct CartAmountCellModel {
    let title: String
    let price: String
    let code: String
    let showCheckBox: Bool
    let isCheckBoxSelected: Bool
}
