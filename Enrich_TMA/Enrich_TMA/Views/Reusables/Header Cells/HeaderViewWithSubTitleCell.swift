//
//  HeaderViewWithSubTitleCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 04/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class HeaderViewWithSubTitleCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var btnViewAll: UIButton!

    var delegate: HeaderDelegate?
    var identifier: SectionIdentifier?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func actionViewAll(_ sender: Any) {
        if let identifier = identifier {
            self.delegate?.actionViewAll(identifier: identifier)
        }
    }

}
