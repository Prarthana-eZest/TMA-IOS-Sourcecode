//
//  CTCDetailsCells.swift
//  Enrich_TMA
//
//  Created by Prarthana on 03/01/22.
//  Copyright © 2022 e-zest. All rights reserved.
//

import UIKit

class CTCDetailsCells: UITableViewCell {

    @IBOutlet weak private var parentView: UIView!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var arrowButton: UIButton!
    @IBOutlet weak private var titleLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

