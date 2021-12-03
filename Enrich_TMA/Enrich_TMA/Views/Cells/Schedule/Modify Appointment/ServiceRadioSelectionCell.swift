//
//  ServiceRadioSelectionCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 07/01/20.
//  Copyright © 2020 e-zest. All rights reserved.
//

import UIKit

protocol ServiceListingDelegate: class {
    func actionPlusMinusCount(quantity: Int, indexPath: IndexPath)
    func actionShowAlert(message: String)
}


class ServiceRadioSelectionCell: UITableViewCell {
    
    @IBOutlet private weak var lblTitle: UILabel!
    @IBOutlet private weak var lblPrice: UILabel!
    @IBOutlet private weak var btnRadio: UIButton!
    @IBOutlet private weak var lblDuration: UILabel!
    
    // Counter
    
    @IBOutlet private weak var counterStackView: UIStackView!
    
    @IBOutlet private weak var lblCounter: UILabel!
    @IBOutlet private weak var btnMinus: UIButton!
    @IBOutlet private weak var btnPlus: UIButton!
    
    var indexPath: IndexPath!
    
    weak var delegate: ServiceListingDelegate?
    
    var maxQuantity = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(serviceName: String, price: Double, duration: String, isSelected: Bool, allowMultiSelect: Bool, allowedForDependant: Bool) {
        lblTitle.text = serviceName
        lblPrice.text = "₹\(price.cleanForPrice)"
                
        lblDuration.text = "Duration : \(GenericClass().getDurationTextFromSeconds(minuts: Int(duration) ?? 0))"
        btnRadio.isSelected = isSelected

        counterStackView.isHidden = allowedForDependant ? !isSelected : true
        
        if let value = lblCounter.text,
        let count = Int(value) {
            if count > 1 {
                btnMinus.setImage(UIImage(named: "minus"), for: .normal)
            }else {
                btnMinus.setImage(UIImage(named: "minus-disabled"), for: .normal)
            }
        }
        
        if allowMultiSelect {
            btnRadio.setBackgroundImage(UIImage(named: "checkBoxSelectedLoginScreen"), for: .selected)
            btnRadio.setBackgroundImage(UIImage(named: "checkBoxUnSelectedLoginScreen"), for: .normal)
        }
        else {
            btnRadio.setBackgroundImage(UIImage(named: "addonradiobutton-selected"), for: .selected)
            btnRadio.setBackgroundImage(UIImage(named: "addonradiobutton-unselected"), for: .normal)
        }
    }
    
    @IBAction func radioAction(_ sender: UIButton) {
        //btnRadio.isSelected = !btnRadio.isSelected
    }
    
    
    @IBAction func actionMinus(_ sender: UIButton) {
        if let value = lblCounter.text,
            let count = Int(value),
            count > 1 {
            let newValue = count - 1
            lblCounter.text = "\(newValue)"
            if newValue > 1 {
                sender.setImage(UIImage(named: "minus"), for: .normal)
            }
            else {
                sender.setImage(UIImage(named: "minus-disabled"), for: .normal)
            }
            if let indexPath = indexPath {
                delegate?.actionPlusMinusCount(quantity: newValue, indexPath: indexPath)
            }
        }
        else {
            sender.setImage(UIImage(named: "minus-disabled"), for: .normal)
        }
    }
    
    @IBAction func actionPlus(_ sender: UIButton) {
        if let value = lblCounter.text, let count = Int(value), count < maxQuantity {
            lblCounter.text = "\(count + 1)"
            btnMinus.setImage(UIImage(named: "minus"), for: .normal)
            if let indexPath = indexPath {
                delegate?.actionPlusMinusCount(quantity: count + 1, indexPath: indexPath)
            }
        }
        else {
            delegate?.actionShowAlert(message: "Maximum allowed service quantity is \(maxQuantity).")
        }
    }
    
    
}
