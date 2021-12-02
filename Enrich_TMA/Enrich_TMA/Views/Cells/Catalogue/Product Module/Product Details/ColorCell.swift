//
//  ColorCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 23/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {

    @IBOutlet weak private var colorView: UIView!
    @IBOutlet weak var selectionTick: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(color:String,isSelected:Bool){
        colorView.backgroundColor = UIColor(hexString: color)
        selectionTick.isHidden = !isSelected
    }

}
