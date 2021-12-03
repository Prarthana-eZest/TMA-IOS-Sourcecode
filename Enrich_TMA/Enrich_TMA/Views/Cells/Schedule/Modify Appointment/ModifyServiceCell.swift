//
//  ModifyServiceCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 26/12/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

protocol ModifyServiceDelegates: class {
    func actionReplaceService(indexPath: IndexPath)
    func actionTimeSlotService(indexPath: IndexPath)
    func actionDeleteService(indexPath: IndexPath)
}

class ModifyServiceCell: UITableViewCell {

    @IBOutlet private weak var lblServiceStatus: UILabel!
    @IBOutlet private weak var btnDelete: UIButton!
    @IBOutlet private weak var btnReplace: UIButton!

    @IBOutlet private weak var btnStackView: UIStackView!

    @IBOutlet private weak var btnTimeslot: UIButton!

    @IBOutlet private weak var lblStartTime: UILabel!
    @IBOutlet private weak var lblEndTime: UILabel!
    @IBOutlet private weak var lblDuration: UILabel!
    @IBOutlet private weak var lblServiceName: UILabel!
    @IBOutlet private weak var lblCustomerName: UILabel!

    @IBOutlet private weak var activeRequestView: UIView!
    @IBOutlet private weak var lblRequestDescription: UILabel!
    @IBOutlet private weak var dependentIcon: UIImageView!
    

    var indexPath: IndexPath?
    weak var delegate: ModifyServiceDelegates?
    let deletionStatus = [AppointmentStatus.completed.rawValue,
                          AppointmentStatus.cancelled.rawValue,
                          AppointmentStatus.time_elapsed.rawValue]
    let modifyStatus = [AppointmentStatus.completed.rawValue,
                        AppointmentStatus.cancelled.rawValue,
                        AppointmentStatus.time_elapsed.rawValue,
                        AppointmentStatus.in_progress.rawValue]

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: ModifyServiceCellModel, serviceCount: Int) {
        lblStartTime.text = model.startTime ?? ""
        lblEndTime.text = model.endTime ?? ""
        lblDuration.text = GenericClass().getDurationTextFromSeconds(minuts: model.duration)
        lblServiceName.text = model.serviceName
        lblCustomerName.text = model.customerName
        let status = model.status
        lblServiceStatus.text = status.uppercased()
        btnStackView.isHidden = modifyStatus.contains(model.status)
        let hideDeleteOption = deletionStatus.contains(model.status)
        btnDelete.isHidden = serviceCount < 2 ? true : hideDeleteOption
        dependentIcon.isHidden = !((model.isDependant ?? 0) == 1)

        activeRequestView.isHidden = true
        if let status = model.request_status,
            (status == "no_action") {
            activeRequestView.isHidden = false
            lblRequestDescription.text = "Active Request: \(model.request_description)"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func actionDelete(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.actionDeleteService(indexPath: indexPath)
        }
    }

    @IBAction func actionReplace(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.actionReplaceService(indexPath: indexPath)
        }
    }

    @IBAction func actionTimeSlot(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.actionTimeSlotService(indexPath: indexPath)
        }
    }

}

struct ModifyServiceCellModel {
    let serviceName: String
    let serviceId: Int64
    let ref_id: Int64
    let status: String
    let startTime: String?
    let endTime: String?
    let duration: Int
    let bufferTime: Int
    let canDelete: Bool
    let request_status: String?
    let request_description: String
    let customer_id: Int64?
    let customerName: String
    let isDependant: Int?
    let dependant_id: Int?
}
