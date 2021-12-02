//
//  PettyCashCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 11/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class PettyCashCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtFValue: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(model:PettyCashCellModel){
        lblTitle.text = model.title
        txtFValue.text = model.value
        txtFValue.isUserInteractionEnabled = model.canEdit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
struct PettyCashCellModel{
    let title: String
    let value: String
    let imageURL: String
    let canEdit: Bool
}
