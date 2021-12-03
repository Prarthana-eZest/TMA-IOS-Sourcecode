//
//  SelectedServicesCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 01/10/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class SelectedServicesCell: UITableViewCell {

    @IBOutlet weak var lblSelectedServices: UILabel!
    @IBOutlet weak var lblEstimatedTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(selectedServices: String, estimatedTime: String) {
        lblSelectedServices.text = selectedServices
        lblEstimatedTime.text = estimatedTime
    }

}
