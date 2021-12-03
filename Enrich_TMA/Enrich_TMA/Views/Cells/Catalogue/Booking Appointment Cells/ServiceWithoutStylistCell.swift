//
//  ServiceWithoutStylistCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 07/08/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol ServiceActionDelegate: class {
    func actionDelete(indexPath: IndexPath)
    func actionAddOn(indexPath: IndexPath)
    func actionChangeStylist(indexPath: IndexPath)
    func openImportantTipsOrAfterTips(indexPath: IndexPath)
}

class ServiceWithoutStylistCell: UICollectionViewCell {

    @IBOutlet weak private var lblServiceName: UILabel!
    @IBOutlet weak private var lblServiceAddon: UILabel!
    @IBOutlet weak private var lblNumberOfServiceAddons: UILabel!
    @IBOutlet weak private var btnNumberOfAdd_ons: UIButton!
    @IBOutlet weak private var lblServiceTotalTime: UILabel!
    @IBOutlet weak private var lblServicePrice: UILabel!
    @IBOutlet weak private var btnDelete: UIButton!
    @IBOutlet weak private var stackViewAddOn: UIStackView!

    weak var delegate: ServiceActionDelegate?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func actionAddOnClicked(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.actionAddOn(indexPath: indexPath)
        }
    }

    @IBAction func actionDeletelicked(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.actionDelete(indexPath: indexPath)
        }
    }

    func configureCell(model: BookedServiceModel) {
        self.lblServiceName.text = model.name
        self.lblServiceAddon.text = model.add_on
        self.btnNumberOfAdd_ons.setTitle((model.isCombo == false ? "+" : "") + model.numberOfAdd_ons!, for: .normal)
        self.btnNumberOfAdd_ons.setTitle((model.isCombo == false ? "+" : "") + model.numberOfAdd_ons!, for: .selected)
        self.lblServiceTotalTime.text = "Total estimated time: " + model.serviceTotalTime!
        self.lblServicePrice.text = model.servicePrice
        self.lblNumberOfServiceAddons.text = model.isCombo == false ? "Service add-ons " : "Services include "
    }

    func showAddOnView(status: Bool) {
        stackViewAddOn.isHidden = !status
    }
}
