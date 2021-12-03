//
//  CTCBreakUpCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 23/02/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

enum CTCCellType {
    case normal, header, final
}

class CTCBreakUpCell: UITableViewCell {
    
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblMonthly: UILabel!
    @IBOutlet weak private var lblAnnually: UILabel!
    @IBOutlet weak private var gradientView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(title: String, Monthly: String, Annually: String, cellType: CTCCellType) {
        lblTitle.text = title
        lblMonthly.text = Monthly
        lblAnnually.text = Annually
        
        switch cellType {
        case .normal: configurePlainCell()
        case .header: configureHeaderCell()
        case .final: configureFinalCell()
        }
    }
    
    func configureHeaderCell() {
        lblTitle.textColor = UIColor.white
        lblTitle.font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 16)
        lblMonthly.textColor = UIColor.white
        lblMonthly.font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 16)
        lblAnnually.textColor = UIColor.white
        lblAnnually.font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 16)
        gradientView.backgroundColor = UIColor.fromGradientWithDirection(.blue, frame: gradientView.frame, cornerRadius: 0, direction: .leftToRight)
    }
    
    func configureFinalCell() {
        lblTitle.textColor = UIColor.white
        lblTitle.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: 20)
        lblMonthly.textColor = UIColor.white
        lblMonthly.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: 20)
        lblAnnually.textColor = UIColor.white
        lblAnnually.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: 20)
        gradientView.backgroundColor = UIColor.fromGradientWithDirection(.purple, frame: gradientView.frame, cornerRadius: 0, direction: .leftToRight)
    }
    
    func configurePlainCell() {
        lblTitle.textColor = UIColor.gray
        lblTitle.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 14)
        lblMonthly.textColor = UIColor(red:0.15, green:0.15, blue:0.15, alpha:1)
        lblMonthly.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 16)
        lblAnnually.textColor = UIColor(red:0.15, green:0.15, blue:0.15, alpha:1)
        lblAnnually.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 16)
        gradientView.backgroundColor = UIColor.white
    }
    
}
