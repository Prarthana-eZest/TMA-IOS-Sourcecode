//
//  SelectServiceDependentCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 23/11/20.
//  Copyright © 2020 e-zest. All rights reserved.
//

import UIKit

protocol DepedentDelegate: class {
    func actionSelectDependent(indexPath: IndexPath)
    func actionSwitchDependent(indexPath: IndexPath, onOROff: Bool)
}

class SelectServiceDependentCell: UITableViewCell {
    
    @IBOutlet private weak var lblServiceName: UILabel!
    @IBOutlet private weak var lblPrice: UILabel!
    @IBOutlet private weak var lblDuration: UILabel!
    @IBOutlet weak var switchDependent: UISwitch!
    @IBOutlet private weak var btnDependent: UIButton!
    @IBOutlet weak var lblDependentName: UILabel!
    @IBOutlet weak var lblDependentNameTitle: UILabel!
    @IBOutlet private weak var switchStackView: UIStackView!
    @IBOutlet private weak var dependentIcon: UIImageView!
    
    weak var delegate: DepedentDelegate?
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(serviceName: String, price: Double, allowedForDependent: Bool, depenedentName: String, customerName: String, serviceDuration: String) {
        btnDependent.isHidden = true
        dependentIcon.isHidden = true
        lblDependentNameTitle.isHidden = false
        lblDependentName.isHidden = false
        lblDependentName.text = ""
        lblServiceName.text = serviceName
        lblDependentName.text = customerName
        lblPrice.text = "₹ \(price.cleanForPrice)"
        lblDuration.text = GenericClass().getDurationTextFromSeconds(minuts: Int(serviceDuration) ?? 0)
        switchStackView.isHidden = !allowedForDependent
        switchDependent.isHidden = !allowedForDependent
        if switchDependent.isOn {
            btnDependent.isHidden = false
            if !depenedentName.isEmpty {
                lblDependentName.text = depenedentName
                dependentIcon.isHidden = false
            }
        }
    }

    @IBAction func actionSelectDependent(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.actionSelectDependent(indexPath: indexPath)
        }
    }
    
    @IBAction func actionSwitchDependent(_ sender: UISwitch) {
        if let indexPath = indexPath {
            delegate?.actionSwitchDependent(indexPath: indexPath, onOROff:sender.isOn )
        }
    }
}
