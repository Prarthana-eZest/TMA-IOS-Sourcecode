//
//  FiltersLeftTableViewCell.swift
//  EnrichSalon
//
//  Created by Apple on 14/05/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit
protocol FiltersLeftCellDelegate: class {
    func selectedOptionLeftTable(indexPath: Int, tableViewCell: UITableViewCell)
}

class FiltersLeftTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak private var viewBackground: UIView!
    weak var delegate: FiltersLeftCellDelegate?
    var index = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        self.lblTitle.font = selected ? UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 24.0 : 16.0)!: UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 24.0 : 16.0)!
//        self.contentView.backgroundColor = selected ? .white : UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
//        
//          if let  indexPath = tableView?.indexPath(for: self)
//          {
//            index = indexPath.row
//          }
////        delegate?.selectedOptionLeftTable(indexPath: index, tableViewCell: self)
//        // Configure the view for the selected state
//    }

}
