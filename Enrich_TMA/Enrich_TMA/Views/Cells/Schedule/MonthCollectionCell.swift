//
//  MonthCollectionCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 23/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class MonthCollectionCell: UICollectionViewCell {

    @IBOutlet weak var lblWeek: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var cornerDotView: UIView!
    
    
    var indexPath = IndexPath(row: 0, section: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
