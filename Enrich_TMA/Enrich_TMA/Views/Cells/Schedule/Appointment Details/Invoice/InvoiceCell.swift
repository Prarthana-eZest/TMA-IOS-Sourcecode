//
//  InvoiceCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 12/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class InvoiceCell: UITableViewCell {

    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblSubTitle: UILabel!
    @IBOutlet weak private var lblPrice: UILabel!
    @IBOutlet weak private var lblProductCount: UILabel!
    @IBOutlet weak private var btnMinus: UIButton!
    @IBOutlet weak private var btnPlus: UIButton!
    @IBOutlet weak private var stepperView: UIStackView!
    @IBOutlet weak private var dependentIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: InvoiceCellModel) {
        lblTitle.text = model.title
        lblSubTitle.text = model.subTitle
        let price = model.price.toDouble() ?? 0
        if price < 0 {
            lblPrice.text = "-₹\(price.cleanForPrice.replacingOccurrences(of: "-", with: ""))"
        }
        else {
            lblPrice.text = "₹\(price.cleanForPrice)"
        }
        lblProductCount.text = "\(model.quantity)"
        stepperView.isHidden = !model.canEditQuantity
        dependentIcon.isHidden = !model.isDependent
    }

    @IBAction func actionCountPlus(_ sender: UIButton) {
        if let value = lblProductCount.text, let count = Int(value) {
            lblProductCount.text = "\(count + 1)"
            btnMinus.setImage(UIImage(named: "minus"), for: .normal)
        }
    }

    @IBAction func actionCountMinus(_ sender: UIButton) {
        if let value = lblProductCount.text,
            let count = Int(value),
            count > 1 {
            let newValue = count - 1
            lblProductCount.text = "\(newValue)"
            if newValue > 1 {
                sender.setImage(UIImage(named: "minus"), for: .normal)
            }
            else {
                sender.setImage(UIImage(named: "minus-disabled"), for: .normal)
            }
        }
        else {
            sender.setImage(UIImage(named: "minus-disabled"), for: .normal)
        }
    }

}

struct InvoiceCellModel {
    let title: String
    let subTitle: String
    let price: String
    let quantity: Int
    let canEditQuantity: Bool
    let isDependent: Bool
}
