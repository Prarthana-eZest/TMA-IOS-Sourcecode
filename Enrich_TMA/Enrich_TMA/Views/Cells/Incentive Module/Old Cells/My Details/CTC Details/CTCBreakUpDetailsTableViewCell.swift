//
//  CTCBreakUpDetailsTableViewCell.swift
//  Enrich_TMA
//
//  Created by Suraj Kumar on 04/01/22.
//  Copyright © 2022 e-zest. All rights reserved.
//

import UIKit

class CTCBreakUpDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var topBorderHideView: UIView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var parentStackView: UIStackView!
    @IBOutlet weak var lblBasicTopTitle: UILabel!
    @IBOutlet weak var lblBasicTitle: UILabel!
    @IBOutlet weak var lblBasicMonth: UILabel!
    @IBOutlet weak var lblBasicYear: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
