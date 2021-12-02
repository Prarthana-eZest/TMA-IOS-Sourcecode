//
//  SearchCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 25/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var btnCheckbox: UIButton!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblEmailAddress: UILabel!
    @IBOutlet weak var lblContactNo: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(model:SearchCellModel){
        btnCheckbox.isSelected = model.isSelected
        lblUserName.text = model.userName
        lblEmailAddress.text = model.email
        lblContactNo.text = model.contactNo
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

struct SearchCellModel{
    let userName: String
    let contactNo: String
    let email: String
    var isSelected: Bool = false
}
