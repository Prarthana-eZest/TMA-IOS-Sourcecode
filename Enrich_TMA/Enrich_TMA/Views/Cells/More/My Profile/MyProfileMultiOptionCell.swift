//
//  MyProfileMultiOptionCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 19/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

protocol ProfileCellDelegate: class {
    func actionViewDetails(indexPath: IndexPath, type: ListingType)
}

class MyProfileMultiOptionCell: UITableViewCell {

    @IBOutlet weak private var lblTitle: UILabel!
    weak var delegate: ProfileCellDelegate?
    var indexPath: IndexPath?
    var listingType: ListingType = .shifts

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(title: String) {
        lblTitle.text = title
    }

    @IBAction func actionViewDetails(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.actionViewDetails(indexPath: indexPath, type: listingType)
        }
    }

}
