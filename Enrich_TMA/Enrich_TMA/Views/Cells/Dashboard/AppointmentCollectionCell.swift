//
//  AppointmentCollectionCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 18/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class AppointmentCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var lblAppointmentStatus: UILabel!
    @IBOutlet private weak var btnDelete: UIButton!

    @IBOutlet private weak var btnModify: UIButton!
    @IBOutlet private weak var btnLeavingNow: UIButton!

    @IBOutlet private weak var lblLocation: UILabel!
    @IBOutlet private weak var locationStackView: UIStackView!

    @IBOutlet private weak var lblStartTime: UILabel!
    @IBOutlet private weak var lblEndTime: UILabel!
    @IBOutlet private weak var lblTotalDuration: UILabel!
    @IBOutlet private weak var lblUserName: UILabel!
    @IBOutlet private weak var lblBookedBy: UILabel!
    @IBOutlet private weak var lblBookedFor: UILabel!
    
    @IBOutlet private weak var lblServiceName: UILabel!
    @IBOutlet private weak var btnServiceCount: UIButton!

    @IBOutlet private weak var stackViewServiceCount: UIStackView!

    @IBOutlet private weak var lblPaymentStatus: UILabel!
    
    @IBOutlet private weak var addOnStackView: UIStackView!
    

    weak var delegate: AppointmentDelegate?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell1(model: Schedule.GetAppointnents.Data) {
        
        // Add On Flow
        if model.booked_by_id == model.booked_for_id {
            lblUserName.isHidden = false
            addOnStackView.isHidden = true
            lblUserName.text = model.booked_by ?? ""
        }else {
            lblUserName.isHidden = true
            addOnStackView.isHidden = false
            lblBookedBy.text = model.booked_by ?? ""
            lblBookedFor.text = model.booked_for ?? ""
        }
        
        lblStartTime.text = model.start_time ?? ""
        lblEndTime.text = model.end_time ?? ""
        lblTotalDuration.text = GenericClass().getDurationTextFromSeconds(minuts: model.total_duration ?? 0)
        lblServiceName.text = model.services?.first?.service_name ?? "Not available"
        btnServiceCount.setTitle("+\((model.services?.count ?? 1) - 1)", for: .normal)
        stackViewServiceCount.isHidden = ((model.services?.count ?? 1) < 2)
        let status = "\(model.status ?? "")"
        lblAppointmentStatus.text = status.uppercased()
        
        var address = [String]()
        if let address1 = model.customer_address, !address1.isEmpty {
            address.append(address1)
        }
        if let address2 = model.customer_address2, !address2.isEmpty {
            address.append(address2)
        }
        lblLocation.text = address.joined(separator: ", ")
        if let paymentStatus = PaymentStatus(rawValue: model.payment_status ?? "unpaid") {
            lblPaymentStatus.text = paymentStatus.rawValue.uppercased()
            lblPaymentStatus.textColor = paymentStatus.color
        }

        if let statusText = model.status,
            let typeText = model.appointment_type,
            let status = AppointmentStatus(rawValue: statusText),
            let type = ServiceType(rawValue: typeText) {
            setupUI(status: status, serviceType: type, is_customer_rated: model.is_customer_rated)
        }

    }

    @IBAction func actionDelete(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.appointmentAction(actionType: .Delete, indexPath: indexPath)
        }
    }

    @IBAction func actionModify(_ sender: UIButton) {
        if let indexPath = indexPath {
            if sender.titleLabel?.text == "MODIFY"{
                delegate?.appointmentAction(actionType: .Modify, indexPath: indexPath)
            }
            else {
                delegate?.appointmentAction(actionType: .RateTheCustomer, indexPath: indexPath)
            }
        }
    }

    @IBAction func actionLeavingNow(_ sender: UIButton) {
        if let indexPath = indexPath {
            if sender.titleLabel?.text == "REACHED"{
                delegate?.appointmentAction(actionType: .ShowOTPScreen, indexPath: indexPath)
            }
            else {
                delegate?.appointmentAction(actionType: .LeavingNow, indexPath: indexPath)
            }
        }
    }

    @IBAction func actionServiceCount(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.appointmentAction(actionType: .ServiceListing, indexPath: indexPath)
        }
    }

    func setupUI(status: AppointmentStatus, serviceType: ServiceType, is_customer_rated: Bool?) {

        btnModify.isHidden = false
        btnLeavingNow.isHidden = false

        // Service Specific UI setup
        switch serviceType {
        case .salonService:
            btnModify.isHidden = false
            btnLeavingNow.isHidden = true
            locationStackView.isHidden = true
        default:
            btnModify.isHidden = false
            btnLeavingNow.isHidden = false
            locationStackView.isHidden = false
        }

        // Status specific UI setup
        switch status {

        case .booked, .scheduled:
            btnModify.setTitle("MODIFY", for: .normal)
            btnModify.isHidden = hideModifyFlow
            btnDelete.isHidden = false
            btnLeavingNow.isHidden = true

        case .delayed, .confirmed:
            btnModify.setTitle("MODIFY", for: .normal)
            btnModify.isHidden = hideModifyFlow
            btnDelete.isHidden = false

        case .leaveNow:
            btnModify.setTitle("MODIFY", for: .normal)
            btnLeavingNow.setTitle("REACHED", for: .normal)

        case .in_progress, .checked_in:
            btnModify.setTitle("MODIFY", for: .normal)
            btnModify.isHidden = hideModifyFlow
            btnLeavingNow.isHidden = true
            btnDelete.isHidden = true

        case .completed:
            btnModify.setTitle("RATE THE CUSTOMER", for: .normal)
            btnLeavingNow.isHidden = true
            btnDelete.isHidden = true
            btnModify.isHidden = is_customer_rated ?? false

        default:
            btnModify.isHidden = true
            btnLeavingNow.isHidden = true
            btnDelete.isHidden = true
        }

    }

}
