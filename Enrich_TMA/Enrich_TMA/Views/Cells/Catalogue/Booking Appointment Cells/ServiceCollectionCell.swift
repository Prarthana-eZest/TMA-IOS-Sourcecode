//
//  ServiceCollectionCell.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 7/15/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class ServiceCollectionCell: UICollectionViewCell {
    @IBOutlet weak private var lblServiceName: UILabel!
    @IBOutlet weak private var lblServiceAddon: UILabel!
    @IBOutlet weak private var lblNumberOfServiceAddons: UILabel!
    @IBOutlet weak private var btnNumberOfAdd_ons: UIButton!
    @IBOutlet weak private var lblServiceTotalTime: UILabel!
    @IBOutlet weak private var lblServicePrice: UILabel!

    @IBOutlet weak private var btnDelete: UIButton!

    @IBOutlet weak private var imgviewStylistProfile: UIImageView!
    @IBOutlet weak private var lblStylistName: UILabel!
    @IBOutlet weak private var lblStylistLevel: UILabel!
    @IBOutlet weak private var cosmosViewRating: CosmosView!

    @IBOutlet weak private var stackViewAddOn: UIStackView!
    @IBOutlet weak private var stackViewImportantTips: UIStackView!
    @IBOutlet weak private var stackViewChangeButton: UIStackView!

    weak var delegate: ServiceActionDelegate?
    var indexPath: IndexPath?

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

    @IBAction func actionChangeStylistClicked(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.actionChangeStylist(indexPath: indexPath)
        }
    }

    @IBAction func actionImportantTips(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.openImportantTipsOrAfterTips(indexPath: indexPath)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureCell(model: BookedServiceModel) {
        self.lblServiceName.text = model.name
        self.lblServiceAddon.text = model.add_on
        self.btnNumberOfAdd_ons.setTitle("+" + model.numberOfAdd_ons!, for: .normal)
        self.btnNumberOfAdd_ons.setTitle("+" + model.numberOfAdd_ons!, for: .selected)

        self.lblServiceTotalTime.text = "Total estimated time: " + model.serviceTotalTime!
        self.lblServicePrice.text = "₹ " + model.servicePrice!
        self.imgviewStylistProfile.layer.cornerRadius = self.imgviewStylistProfile.frame.size.width * 0.5
        self.imgviewStylistProfile.layer.masksToBounds = true
        if !model.stylist.profileImageUrl.isEmpty {
            let url = URL(string: model.stylist.profileImageUrl)
            self.imgviewStylistProfile.kf.setImage(with: url, placeholder: UIImage(named: "reviewAavatarImg"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            self.imgviewStylistProfile.image = model.gender.isEmpty ? UIImage(named: "reviewAavatarImg") : (model.gender.containsIgnoringCase(find: "female") ? UIImage(named: "female-selected") : UIImage(named: "male-selected"))
        }
        self.lblStylistName.text = model.stylist.name
        self.lblStylistLevel.text = model.stylist.level
        self.cosmosViewRating.rating = model.stylist.rating
    }

    func setDeleteCellView(show: Bool) {
        self.btnDelete.isHidden = show
    }

    func showAddOnView(status: Bool) {
        stackViewAddOn.isHidden = !status
    }

    func showImportantTips(status: Bool) {
        stackViewImportantTips.isHidden = !status
    }

    func showChangeButton(status: Bool) {
        stackViewChangeButton.isHidden = !status
    }

}

struct BookedServiceModel {
    let id: Int64
    let name: String?
    let sku: String?
    let add_on: String?
    let numberOfAdd_ons: String?
    let serviceTotalTime: String?
    let servicePrice: String?
    let stylist: StylistModel
    let arrayOfAddons: [BookingDetailsAddOnsModel]?
    var isCombo: Bool = false
    var gender: String = ""
}

struct StylistModel {
    let id: Int64
    let profileImageUrl: String
    let name: String?
    let level: String?
    let rating: Double
}

/*Static data: Temporary added*/
let arrBookedServices: [BookedServiceModel] = [BookedServiceModel(id: 1, name: "Head massage", sku: "", add_on: "with shampoo", numberOfAdd_ons: "2", serviceTotalTime: "1 hr", servicePrice: "₹100", stylist: StylistModel(id: 1, profileImageUrl: "female-unselected", name: "Rohit Joshi", level: "Graduate level", rating: 0), arrayOfAddons: [], isCombo: false, gender: ""),
                                               BookedServiceModel(id: 1, name: "Hair Spa", sku: "", add_on: "with conditioning", numberOfAdd_ons: "3", serviceTotalTime: "1 hr 30 min", servicePrice: "₹150", stylist: StylistModel(id: 1, profileImageUrl: "female-unselected", name: "Rohit Joshi2", level: "Graduate level2", rating: 4.5), arrayOfAddons: [], isCombo: false, gender: "")]
