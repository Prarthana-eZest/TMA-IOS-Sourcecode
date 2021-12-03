//
//  ServiceAddOnsCell.swift
//  EnrichSalon
//
//  Created by Apple on 09/05/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

//protocol ServiceAddOnsMultiCellDelegate: class
//{
//    func checkedUnChecked(indexPath:Int)
//}

class ServiceAddOnsMultiSelectionCell: UITableViewCell {

    @IBOutlet weak var btnCheckUnChecked: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var sepratorLine: UIView!
    @IBOutlet weak var lblOldPrice: UILabel!

   // weak var delegate: ServiceAddOnsMultiCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    @IBAction func addAction(_ sender: UIButton) {
//        sender.isSelected = !sender.isSelected
//        
//        if sender.isSelected {
//            
//            print(sender.isSelected)
//        }
//            
//        else {
//            
//            print(sender.isSelected)
//        }
//        delegate?.checkedUnChecked(indexPath: sender.tag)
//    }

}
