//
//  ModifyAppointmentHeaderCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 26/12/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

protocol ModifyAppointmentDelegates: class {
    func actionTimeSlotAppointment()
    func actionDeleteAppointment()
}

class ModifyAppointmentHeaderCell: UITableViewCell {

    @IBOutlet private weak var lblDateTime: UILabel!
    @IBOutlet private weak var lblStatus: UILabel!
    @IBOutlet private weak var lblStartTime: UILabel!
    @IBOutlet private weak var lblEndTime: UILabel!

    @IBOutlet private weak var lblLocation: UILabel!
    @IBOutlet private weak var locationStackView: UIStackView!

    @IBOutlet private weak var lblTotalDuration: UILabel!
    @IBOutlet private weak var lblUserName: UILabel!
    @IBOutlet private weak var lblBookedBy: UILabel!
    @IBOutlet private weak var lblBookedFor: UILabel!
    
    @IBOutlet private weak var btnTimeSlot: UIButton!
    @IBOutlet private weak var btnDelete: UIButton!

    @IBOutlet private weak var activeRequestView: UIView!
    @IBOutlet private weak var lblRequestDescription: UILabel!
    
    @IBOutlet private weak var AddOnStackView: UIStackView!

    weak var delegate: ModifyAppointmentDelegates?

    let deletionStatus = [AppointmentStatus.completed.rawValue,
                          AppointmentStatus.cancelled.rawValue,
                          AppointmentStatus.time_elapsed.rawValue,
                          AppointmentStatus.in_progress.rawValue]

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: Schedule.GetAppointnents.Data,
                       selectedDate: Date) {
        
        // Add On Flow
        if model.booked_by_id == model.booked_for_id {
            lblUserName.isHidden = false
            AddOnStackView.isHidden = true
            lblUserName.text = model.booked_by ?? ""
        }else {
            lblUserName.isHidden = true
            AddOnStackView.isHidden = false
            lblBookedBy.text = model.booked_by ?? ""
            lblBookedFor.text = model.booked_for ?? ""
        }
        
        let status = model.status ?? "-"
        lblStatus.text = status.uppercased()
        lblTotalDuration.text = GenericClass().getDurationTextFromSeconds(minuts: model.total_duration ?? 0)
        lblStartTime.text = model.start_time ?? ""
        lblEndTime.text = model.end_time ?? ""
        
        var address = [String]()
        if let address1 = model.customer_address, !address1.isEmpty {
            address.append(address1)
        }
        if let address2 = model.customer_address2, !address2.isEmpty {
            address.append(address2)
        }
        lblLocation.text = address.joined(separator: ",")
        locationStackView.isHidden = false
        btnTimeSlot.isHidden = true
        lblDateTime.text = selectedDate.dayNameDateFormat
        btnDelete.isHidden = deletionStatus.contains(model.status ?? "")

        activeRequestView.isHidden = true
        if let status = model.approval_status,
            (status == "no_action") {
            activeRequestView.isHidden = false
            lblRequestDescription.text = "Active Request: \(model.approval_request ?? "")"
        }

        if let typeText = model.appointment_type,
            let type = ServiceType(rawValue: typeText) {
            locationStackView.isHidden = (type == .salonService)
        }

        if let statusText = model.status,
            let status = AppointmentStatus(rawValue: statusText) {

            switch status {
            case .booked, .scheduled, .delayed, .confirmed:
                btnTimeSlot.isHidden = false
            default:
                btnTimeSlot.isHidden = true
            }
        }

    }

    @IBAction func actionChangeTimeSlot(_ sender: UIButton) {
        delegate?.actionTimeSlotAppointment()
    }

    @IBAction func actionDelete(_ sender: UIButton) {
        delegate?.actionDeleteAppointment()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
