//
//  PointsHeaderCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 12/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class PointsHeaderCell: UITableViewCell {

    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblPoints: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: ServiceDescriptionModel) {
        lblTitle.text = model.title
        if model.pointSeparation {
            if !model.data.isEmpty {
                let data = model.data.components(separatedBy: ",")
                let unicode = "\\u25CF".unescapingUnicodeCharacters
                let pointsString = data.map {"  \(unicode) \($0)"}.joined(separator: "\n")
                lblPoints.text = pointsString
            }

        }
        else {
            lblPoints.text = model.data
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
