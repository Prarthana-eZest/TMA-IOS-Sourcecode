//
//  FilterRightTableViewCell.swift
//  EnrichSalon
//
//  Created by Apple on 14/05/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol FilterRightCellDelegate: class {
    func selectedOptionRightTable(indexPath: Int, tableViewCell: UITableViewCell)

}

class FilterRightTableViewCell: UITableViewCell {

    @IBOutlet weak var btnCheckUnChecked: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    weak var delegate: FilterRightCellDelegate?
    var index = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        if let  indexPath = tableView?.indexPath(for: self)
//        {
//            index = indexPath.row
//            let cell = tableView?.cellForRow(at: (tableView?.indexPath(for: self))!) as! FilterRightTableViewCell
//           // self.addAction(cell.btnCheckUnChecked)
//
//        }
//        // Configure the view for the selected state
//        //delegate?.selectedOptionRightTable(indexPath: index, tableViewCell: self)
//    }
//    @IBAction func addAction(_ sender: UIButton) {
//        sender.isSelected = !sender.isSelected
//        delegate?.selectedOptionRightTable(indexPath: sender.tag, tableViewCell: self)
//
//    }
}
