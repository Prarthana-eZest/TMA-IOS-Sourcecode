//
//  ServiceAddOnsCell.swift
//  EnrichSalon
//
//  Created by Apple on 09/05/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class ServiceAddOnsRadioSelectionCell: UITableViewCell {

    @IBOutlet weak var btnCheckUnChecked: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var sepratorLine: UIView!
    @IBOutlet weak var lblOldPrice: UILabel!

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
//        delegate?.checkedUnCheckedRadio(indexPath: sender.tag)
//    }

}

//struct ServiceAddOnsRadioSelectionModel {
//    let productId: Int64
//    let productName: String
//    let sku: String
//    let price: Double
//    let specialPrice: Double
//    var isProductSelected: Bool
//
//}
