//
//  AdditionalOffCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 03/10/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol PayNowDelegate: class {
    func payNowDelegate()
}

class AdditionalOffCell: UITableViewCell {

    weak var delegate: PayNowDelegate?
    @IBOutlet weak var btnPaynow: UIButton!
    @IBOutlet weak var lblAdditionalOffAmount: UILabel! // 91DCE4 background

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func actionPayNow(_ sender: Any) {
        delegate?.payNowDelegate()
    }
}
