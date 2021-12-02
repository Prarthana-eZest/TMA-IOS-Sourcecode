//
//  TodaysAppointmentHeaderCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 15/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class TodaysAppointmentHeaderCell: UITableViewCell {
    
    @IBOutlet weak var lblDateTime: UILabel!
    
    weak var delegate:AppointmentDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func actionViewAll(_ sender: UIButton) {
        delegate?.actionViewAllAppointments()
    }
    
    
}
