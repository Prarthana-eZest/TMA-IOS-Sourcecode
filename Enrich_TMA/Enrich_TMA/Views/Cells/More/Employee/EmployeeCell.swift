//
//  EmployeeCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 21/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit
import Cosmos

class EmployeeCell: UITableViewCell {

    @IBOutlet weak var lblEmplyeeName: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var ratingsView: CosmosView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func configureCell(model:EmployeeModel){
        lblEmplyeeName.text = model.name
        lblLevel.text = model.level
        ratingsView.rating = model.ratings
        statusView.backgroundColor = (model.status == .available) ? UIColor(red: 70/255, green: 196/255, blue: 91/255, alpha: 1) : (model.status == .unAvailable) ? UIColor(red: 238/255, green: 91/255, blue: 70/255, alpha: 1)  : UIColor(red: 83/255, green: 83/255, blue: 83/255, alpha: 1)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

enum EmployeeStatus{
    case available,unAvailable,onLeave
}

struct EmployeeModel{
    let name: String
    let level: String
    let ratings: Double
    let status: EmployeeStatus
}
