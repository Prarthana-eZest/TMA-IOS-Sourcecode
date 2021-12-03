//
//  QuantityCell.swift
//  EnrichSalon
//
//  Created by Harshal on 28/06/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol QuantityDelegate: class {
    func selectedQuantity(text: String)
}

class ProductQuantityCell: UITableViewCell {

    @IBOutlet var radioButtons: [UIButton]!
    @IBOutlet weak private var lblFirstQuantity: UILabel!
    @IBOutlet weak private var lblSecondQuantity: UILabel!
    @IBOutlet weak private var lblThirdQuantity: UILabel!

    weak var delegate: QuantityDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: ProductQuantityModel) {
        self.lblFirstQuantity.text = model.firstQuantity
        self.lblSecondQuantity.text = model.secondQuantity
        self.lblThirdQuantity.text = model.thirdQuantity
    }

    @IBAction func actionFirstQuantity(_ sender: UIButton) {
        self.radioButtons.forEach {
            $0.setImage(UIImage(named: "radioUnselected"), for: .normal)
        }
        sender.setImage(UIImage(named: "radioSelected"), for: .normal)
        self.delegate?.selectedQuantity(text: lblFirstQuantity.text ?? "")
    }

    @IBAction func actionSecondQuantity(_ sender: UIButton) {
        self.radioButtons.forEach {
            $0.setImage(UIImage(named: "radioUnselected"), for: .normal)
        }
        sender.setImage(UIImage(named: "radioSelected"), for: .normal)
        self.delegate?.selectedQuantity(text: lblSecondQuantity.text ?? "")
    }

    @IBAction func actionThirdQuantity(_ sender: UIButton) {
        self.radioButtons.forEach {
            $0.setImage(UIImage(named: "radioUnselected"), for: .normal)
        }
        sender.setImage(UIImage(named: "radioSelected"), for: .normal)
        self.delegate?.selectedQuantity(text: lblThirdQuantity.text ?? "")
    }

}

struct ProductQuantityModel {
    let firstQuantity: String
    let secondQuantity: String
    let thirdQuantity: String
}
