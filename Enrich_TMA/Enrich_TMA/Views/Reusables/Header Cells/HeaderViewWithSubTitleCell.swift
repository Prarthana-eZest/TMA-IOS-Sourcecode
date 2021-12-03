//
//  HeaderViewWithSubTitleCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 04/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class HeaderViewWithSubTitleCell: UITableViewCell {

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subTitleLabel: UILabel!
    @IBOutlet weak private var btnViewAll: UIButton!

    weak var delegate: HeaderDelegate?
    var identifier: SectionIdentifier?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureHeader(title: String, subTitle: String, hideAllButton: Bool) {
        titleLabel.text = title
        subTitleLabel.text = subTitle
        btnViewAll.isHidden = hideAllButton
    }

    func setFont(titleFont: UIFont, subtitleFont: UIFont) {
        titleLabel.font = titleFont
        subTitleLabel.font = subtitleFont
    }

    @IBAction func actionViewAll(_ sender: Any) {
        if let identifier = identifier {
            self.delegate?.actionViewAll(identifier: identifier)
        }
    }

}
