//
//  AppointmentDetailsCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 07/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class AppointmentDetailsCell: UITableViewCell {

    //Appointment Details
    @IBOutlet weak private var lblDateTime: UILabel!
    @IBOutlet weak private var userProfile: UIImageView!
    @IBOutlet weak private var lblUserName: UILabel!
    @IBOutlet weak private var lblBookedBy: UILabel!
    @IBOutlet weak private var lblBookedFor: UILabel!
    
    @IBOutlet weak private var lblAppointmentStatus: UILabel!
    @IBOutlet weak private var lblLastVisit: UILabel!
    @IBOutlet weak private var lblRatings: UILabel!

    @IBOutlet weak private var iconMembership: UIImageView!
    @IBOutlet weak private var lblMembershipType: UILabel!
    
    @IBOutlet weak private var dividerView: UIView!

    @IBOutlet weak private var iconHighSpending: UIImageView!
    @IBOutlet weak private var stackViewMemAndHighS: UIStackView!
    @IBOutlet weak private var stackViewAddOnName: UIStackView!
    
    // Status
    @IBOutlet weak private var lblStatus: UILabel!
    @IBOutlet weak private var lblStartTime: UILabel!
    @IBOutlet weak private var lblEndTime: UILabel!
    @IBOutlet weak private var lblTotalDuration: UILabel!
    @IBOutlet weak private var lblLocation: UILabel!
    @IBOutlet weak private var lblLandmark: UILabel!

    @IBOutlet weak private var locationStackView: UIStackView!

    var appointmentDetails: Schedule.GetAppointnents.Data?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: Schedule.GetAppointnents.Data, date: Date) {
        appointmentDetails = model
        
        // Add On Flow
        if model.booked_by_id == model.booked_for_id {
            lblUserName.isHidden = false
            stackViewAddOnName.isHidden = true
            lblUserName.text = model.booked_by ?? ""
        }else {
            lblUserName.isHidden = true
            stackViewAddOnName.isHidden = false
            lblBookedBy.text = model.booked_by ?? ""
            lblBookedFor.text = model.booked_for ?? ""
        }
        
        lblStartTime.text = model.start_time ?? ""
        lblEndTime.text = model.end_time ?? ""
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
        lblDateTime.text = date.dayNameDateFormat
        lblLastVisit.text = model.last_visit ?? ""

        let ratingText = model.avg_rating ?? 0
        let rating = ratingText.cleanForRating
        lblRatings.text = "\(rating)/5"

        lblStatus.text = status.uppercased()
        lblTotalDuration.text = GenericClass().getDurationTextFromSeconds(minuts: model.total_duration ?? 0)

        locationStackView.isHidden = true
        if let typeText = model.appointment_type,
            let type = ServiceType(rawValue: typeText) {
            locationStackView.isHidden = (type == .salonService)
        }

        lblLandmark.text = model.landmark ?? "-"

        userProfile.layer.cornerRadius = userProfile.frame.size.height * 0.5
        userProfile.kf.indicatorType = .activity

        let defaultImage = UIImage(named: "defaultProfile")
        if let url = model.profile_picture,
            let imageurl = URL(string: url) {
            userProfile.kf.setImage(with: imageurl, placeholder: defaultImage,
                                    options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            userProfile.image = defaultImage
        }

        // Memebership

        var isMember = false
        dividerView.isHidden = true
        stackViewMemAndHighS.isHidden = false

        if let membership = model.membership, !membership.isEmpty,
            let iconImage = model.membership_default_image,
            !iconImage.isEmpty, let imageurl = URL(string: iconImage) {
                isMember = true
            iconMembership.kf.setImage(with: imageurl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
            lblMembershipType.text = model.membership ?? ""
        }

        iconMembership.isHidden = !isMember
        lblMembershipType.isHidden = !isMember

        if let highSpending = model.high_expensive, highSpending == true {
            iconHighSpending.isHidden = false
        }
        else {
            iconHighSpending.isHidden = true
            if !isMember {
                stackViewMemAndHighS.isHidden = true
            }
        }

    }

    @IBAction func actionFindAddress(_ sender: UIButton) {
        if let model = appointmentDetails,
            let lat = model.customer_latitude,
            let long = model.customer_longitude {
            ApplicationFactory.shared.openGoogleMaps(lat: lat, long: long)
        }
    }
}
