//
//  ViewCTCCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 21/12/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

class ViewCTCCell: UITableViewCell {
    
    @IBOutlet weak private var parentView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        parentView.clipsToBounds = true
        parentView.layer.cornerRadius = 8
        parentView.layer.masksToBounds = false
        parentView.layer.shadowRadius = 8
        parentView.layer.shadowOpacity = 0.20
        parentView.layer.shadowOffset = CGSize(width: 0, height: 10)
        parentView.layer.shadowColor = UIColor.gray.cgColor
        
        self.contentView.backgroundColor = .clear
        backgroundColor = .clear
        self.parentView.layer.cornerRadius = 8
        self.parentView.clipsToBounds = true

        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.20
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
