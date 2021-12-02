//
//  PointsCell.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 15/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit

class PointsCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
struct PointsCellData {
    let title: String
    let points: [String]
}
