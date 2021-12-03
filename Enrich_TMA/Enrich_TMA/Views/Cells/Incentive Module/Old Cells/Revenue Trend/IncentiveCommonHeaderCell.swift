//
//  RevenueTrendHeaderCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 16/02/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

protocol IncentiveHeaderDelegate: class {
    func actionViewAll(identifier: SectionIdentifier)
}

class IncentiveCommonHeaderCell: UITableViewCell {
    
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var btnViewAll: UIButton!
    
    var identifier: SectionIdentifier = .incentiveEarnings
    
    weak var delegate: IncentiveHeaderDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setTitle(title: String, identifier: SectionIdentifier, showViewAll: Bool) {
        lblTitle.text = title
        self.identifier = identifier
        self.btnViewAll.isHidden = !showViewAll
    }
    
    @IBAction func actionViewAll(_ sender: UIButton) {
        delegate?.actionViewAll(identifier: self.identifier)
    }
    
}
