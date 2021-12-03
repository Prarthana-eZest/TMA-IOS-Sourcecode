//
//  AddServiceInYourCartCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 01/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol AddServiceInYourCartCellCellDelegate: class {
    func addAdditionalService(indexPath: IndexPath)

}

class AddServiceInYourCartCell: UITableViewCell {

    @IBOutlet weak private var lblItem: UILabel!
    @IBOutlet weak private var lblPlus: UILabel!
    @IBOutlet weak var lblAddons: UILabel!
    @IBOutlet weak private var lblEqualSymbol: UILabel!
    @IBOutlet weak private var lblTotal: UILabel!

    @IBOutlet weak var lblItemValue: UILabel!
    @IBOutlet weak private var lblPlusValue: UILabel!
    @IBOutlet weak var lblAddonsValue: UILabel!
    @IBOutlet weak private var lblEqualSymbolValue: UILabel!
    @IBOutlet weak var lblTotalValue: UILabel!
    @IBOutlet weak var btnAddService: UIButton!

    @IBOutlet weak private var parentView: UIView!

    var indexPath = IndexPath(row: 0, section: 0)
    weak var delegate: AddServiceInYourCartCellCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.parentView.layer.borderColor = UIColor.lightGray.cgColor
        self.parentView.layer.borderWidth = 0.5
    }

    @IBAction func actionAddService(_ sender: Any) {

        delegate?.addAdditionalService(indexPath: self.indexPath)

    }
}
