//
//  StylishDetailsCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 24/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit
import Cosmos

protocol StylistDetailsDelegate: class {
    func actionChangeTime(stylistId: String, indexPath: IndexPath)
    func actionChange(stylistId: String, indexPath: IndexPath)
    func actionServiceDelete(stylistId: String, indexPath: IndexPath)
    func actionOverride(sender: UIButton)
}

class StylistDetailsCell: UITableViewCell {

    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnOverride: UIButton!
    @IBOutlet weak var stackViewOverride: UIStackView!
    @IBOutlet weak var stackViewTimeSlotLabel: UIStackView!
    
    @IBOutlet weak var stackTechnician: UIStackView!
    @IBOutlet weak var lblCustomerName: UILabel!
    @IBOutlet weak var lblServiceSlot: UILabel!
    @IBOutlet weak var lblServiceTime: UILabel!
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var profilePicture: UIImageView!
    @IBOutlet weak private var lblStylistName: UILabel!
    @IBOutlet weak private var lblStylistLevel: UILabel!
    @IBOutlet weak private var lblStylistRate: UILabel!

    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var btnDelete: UIButton!

    @IBOutlet weak private var lblTitleData: UILabel!
    @IBOutlet weak private var ratingView: CosmosView!
    @IBOutlet weak private var dependentIcon: UIImageView!
    
    var indexPath: IndexPath?
    var stylistId = ""
    weak var delegate: StylistDetailsDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ratingView.settings.updateOnTouch = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: ServiceAndStylistModel) {
        lblTitleData.text = model.name ?? ""
        lblTitle.text = "₹ \(model.price ?? 0.0)"
        lblServiceTime.text = GenericClass().getDurationTextFromSeconds(minuts: Int(model.service_time ?? "0") ?? 0)
        lblServiceSlot.text = (model.startTime?.getTimeInDate24Hrs().timeWithPeriodInSmall)! + " - " + (model.endTime?.getTimeInDate24Hrs().timeWithPeriodInSmall)!
        lblCustomerName.text = (model.customer_name ?? "")
        isAvailable(status: true)
        
        // Stylist Rate
        let rate = (model.rate ?? 0.0).cleanForPrice
        lblStylistRate.text = "₹ \(rate)"
        lblStylistRate.isHidden = model.rate == nil
                
        if model.technician != nil {
            stackTechnician.isHidden = false
            ratingView.rating = model.rating ?? 0.0
            lblStylistLevel.text = model.servicing_technician_designation ?? ""
            lblStylistName.text = model.servicing_technician ?? ""
            lblStylistRate.text = "₹ \(model.rate ?? 0.0)"
            lblStylistRate.isHidden = model.rate == nil
            btnDelete.isHidden = true
        } else {
            stackTechnician.isHidden = true
            btnDelete.isHidden = false
        }
        stackViewOverride.isHidden = true
        stackViewTimeSlotLabel.isHidden = true
        let strName = (model.dependant_id == nil) ? ((model.gender == nil) ? "reviewAavatarImg" : (model.gender!.containsIgnoringCase(find: "female")) ? "female-selected" : "male-selected") : ((model.dependant_gender == nil) ? "reviewAavatarImg" : (model.gender!.containsIgnoringCase(find: "female")) ? "female-selected" : "male-selected")
        profilePicture.image = UIImage(named: strName)
        stylistId = model.service_id ?? ""
        let imgName = btnOverride.isSelected ? "checkBoxSelectedLoginScreen" : "checkBoxUnSelectedLoginScreen"
        btnOverride.setImage(UIImage(named: imgName), for: .normal)
        dependentIcon.isHidden = !((model.is_dependant_service ?? 0) == 1)
    }

    @IBAction func actionBtnDelete(_ sender: Any) {
        if let indexPath = indexPath {
            delegate?.actionChange(stylistId: stylistId, indexPath: indexPath)
        }
    }

    @IBAction func actionChange(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.actionChange(stylistId: stylistId, indexPath: indexPath)
        }
    }

    @IBAction func actionEditSingleService(_ sender: Any) {
        if let indexPath = indexPath {
            delegate?.actionChangeTime(stylistId: stylistId, indexPath: indexPath)
        }
    }
    
    func isAvailable(status: Bool = true) {
        lblStylistName.alpha = status ? 1 : 0.5
        lblStylistLevel.alpha = status ? 1 : 0.5
        ratingView.alpha = status ? 1 : 0.5
        profilePicture.alpha = status ? 1 : 0.5
        lblTitle.alpha = status ? 1 : 0.5
    }

    @IBAction func actionOverride(_ sender: UIButton) {
        let btnObj = sender
        btnObj.isSelected = !btnOverride.isSelected
        let imgName = btnObj.isSelected ? "checkBoxSelectedLoginScreen" : "checkBoxUnSelectedLoginScreen"
        btnOverride.setImage(UIImage(named: imgName), for: .normal)
        delegate?.actionOverride(sender: btnObj)
    }
}


class ServiceAndStylistModel {
    var entity_id: String?
    var type_id: String?
    var name: String?
    var price: Double?
    var taxable_price: Double?
    var buffer_time: String?
    var service_id: String?
    var service_code: String?
    var store_id: Int64?
    var min_price: Double?
    var max_price: Double?
    var service_category: String?
    var service_time: String?
    var parent_item_id: String?
    var parent_name: String?
    var parent_sku: String?
    var product_type: String?
    var is_consultation_required: String?
    var bundle_parent_id: String?
    var configurable_parent_id: String?
    var startTime: String?
    var endTime: String?
    var is_dependant_service: Int?
    var dependant_name: String?
    var dependant_gender: String?
    var dependant_age: String?
    var dependant_note: String?
    var gender: String? = nil
    var dependant_id: Int?
    var customer_name: String?
    var dictForTimes: [String: SectionConfiguration] = [:]
    var technician: Int64?
    var servicing_technician: String?
    var servicing_technician_code: String?
    var servicing_technician_gender: String?
    var servicing_technician_designation: String?
    var servicing_technician_designation_id: Int64?
    var available : Bool?
    var rating: Double?
    var rate: Double?
    var override: Int?
    var servicing_technician_available: String?

}

struct StylistDetailsCellModel {
    let title: String
    var amountAndtime: String
    let id: Int64
    let profilePictureURL: String
    let userName: String
    let level: String
    let rating: Double
    let isPreferred: Bool
    let location: String
    let isAvailable: Bool
    let isGender: Int
    var availableTimeSlots: [String]
    var gender: String
    var parentName: String?
    var showParentName: Bool?
    var parentItemId: String?
    var parentItemSKU: String?
    var technicianRate: Double?
    
    var employee_health_status : String?
    let employee_last_screening: String?
    let serviceType : String?
}

