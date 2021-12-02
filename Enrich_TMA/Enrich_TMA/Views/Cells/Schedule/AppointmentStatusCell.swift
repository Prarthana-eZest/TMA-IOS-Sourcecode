//
//  AppointmentStatusCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 07/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

protocol AppointmentDelegate:class {
    func actionDelete(indexPath:IndexPath)
    func actionModify(indexPath:IndexPath)
    func actionViewAllAppointments()
}

class AppointmentStatusCell: UITableViewCell {

    @IBOutlet private weak var lblAppointmentStatus: UILabel!
    @IBOutlet private weak var btnDelete: UIButton!
    @IBOutlet private weak var btnModify: UIButton!
    
    @IBOutlet private weak var lblStartTime: UILabel!
    @IBOutlet private weak var lblEndTime: UILabel!
    @IBOutlet private weak var lblTotalDuration: UILabel!
    @IBOutlet private weak var lblUserName: UILabel!
    @IBOutlet private weak var lblServiceName: UILabel!
    @IBOutlet private weak var btnServiceCount: UIButton!
    
    weak var delegate:AppointmentDelegate?
    var indexPath:IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(model:AppointmentStatusModel){
        lblUserName.text = model.userName
        lblStartTime.text = model.startTimr
        lblEndTime.text = model.endTime
        lblTotalDuration.text = model.totalDuration
        btnDelete.isHidden = !model.canDelete
        btnModify.isHidden = !model.canModify
        lblServiceName.text = model.services.first
        btnServiceCount.setTitle("+\(model.services.count - 1)", for: .normal)
    }
    
    @IBAction func actionDelete(_ sender: UIButton) {
        if let indexPath = indexPath{
            self.delegate?.actionDelete(indexPath: indexPath)
        }
    }
    
    @IBAction func actionModify(_ sender: UIButton) {
        if let indexPath = indexPath{
            self.delegate?.actionModify(indexPath: indexPath)
        }
    }
    
    @IBAction func actionServiceCount(_ sender: UIButton) {
    }
    
    
}

struct AppointmentStatusModel{
    let userName: String
    let services: [String]
    let appointmentStatus: String
    let startTimr: String
    let endTime: String
    let totalDuration: String
    let canModify: Bool
    let canDelete: Bool
}
