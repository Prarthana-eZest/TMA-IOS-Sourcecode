//
//  MyCustomersHeaderCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 16/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

enum HeaderType {
    case MyCustomer, PettyCash, Services
}

enum SortBy {
    case name, location, mobileNo // my customer
    case dateTime, purpose, amount // petty cash
    case serviceName, date, salon // Customer History
}

protocol MyCustomersHeaderDelegate: class {
    func actionSort(sortBy: SortBy, sortOrder: Int)
}

class MyCustomersHeaderCell: UITableViewCell {

    @IBOutlet weak private var btnName: UIButton!
    @IBOutlet weak private var btnLocation: UIButton!
    @IBOutlet weak private var btnMobileNo: UIButton!

    weak var delegate: MyCustomersHeaderDelegate?

    var headerType: HeaderType = .MyCustomer

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    func configureCell(headerType: HeaderType, activeSort: SortBy?, sortOrder: Int) {

        self.headerType = headerType

        switch headerType {

        case .MyCustomer:
            btnName.setTitle("Name \u{2304}", for: .normal)
            btnName.setTitle("Name \u{2303}", for: .selected)

            btnLocation.setTitle("Location \u{2304}", for: .normal)
            btnLocation.setTitle("Location \u{2303}", for: .selected)

            btnMobileNo.setTitle("Mobile Number \u{2304}", for: .normal)
            btnMobileNo.setTitle("Mobile Number \u{2303}", for: .selected)

        case .PettyCash:
            btnName.setTitle("Date & Time \u{2304}", for: .normal)
            btnName.setTitle("Date & Time \u{2303}", for: .selected)

            btnLocation.setTitle("Purpose \u{2304}", for: .normal)
            btnLocation.setTitle("Purpose \u{2303}", for: .selected)

            btnMobileNo.setTitle("Amount \u{2304}", for: .normal)
            btnMobileNo.setTitle("Amount \u{2303}", for: .selected)

        case .Services:
            btnName.setTitle("Service \u{2304}", for: .normal)
            btnName.setTitle("Service \u{2303}", for: .selected)

            btnLocation.setTitle("Date \u{2304}", for: .normal)
            btnLocation.setTitle("Date \u{2303}", for: .selected)

            btnMobileNo.setTitle("Salon \u{2304}", for: .normal)
            btnMobileNo.setTitle("Salon \u{2303}", for: .selected)
        }

        if let sort = activeSort {

            btnName.isSelected = false
            btnLocation.isSelected = false
            btnMobileNo.isSelected = false

            switch sort {

            case .name, .dateTime, .serviceName:
                btnName.isSelected = sortOrder == 0 ? false : true

            case .location, .purpose, .date:
                btnLocation.isSelected = sortOrder == 0 ? false : true

            case .mobileNo, .amount, .salon:
                btnMobileNo.isSelected = sortOrder == 0 ? false : true

            }
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func actionName(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.actionSort(sortBy: headerType == .MyCustomer ? .name : headerType == .PettyCash ? .dateTime : .serviceName, sortOrder: sender.isSelected ? 1 : 0)
    }

    @IBAction func actionLocation(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.actionSort(sortBy: headerType == .MyCustomer ? .location : headerType == .PettyCash ? .purpose : .date, sortOrder: sender.isSelected ? 1 : 0)
    }

    @IBAction func btnMobileNumber(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.actionSort(sortBy: headerType == .MyCustomer ? .mobileNo : headerType == .PettyCash ? .amount : .salon, sortOrder: sender.isSelected ? 1 : 0)
    }

}
