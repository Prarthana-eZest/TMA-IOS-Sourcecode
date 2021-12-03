//
//  HeaderViewWithAdCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 04/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class HeaderViewWithAdCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewAllButton: UIButton!
    @IBOutlet weak var addTextLabel: UILabel!

    weak var delegate: HeaderDelegate?
    var identifier: SectionIdentifier?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.resetOfferAmount(text: "Earn 200 points on purchase of any these products together with this head massage", rangeText: "200 points")

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

    func resetOfferAmount(text: String, rangeText: String) {
        let range = (text as NSString).range(of: rangeText)
        let attribute = NSMutableAttributedString(string: text)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: range)
        attribute.addAttribute(NSAttributedString.Key.font, value: UIFont(name: FontName.FuturaPTDemi.rawValue,
                                                                          size: is_iPAD ? 24.0 : 16.0) ?? UIFont.systemFont(ofSize: is_iPAD ? 24.0 : 16.0), range: range)
        self.addTextLabel.attributedText = attribute

    }

}
