//
//  MyCustomerCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 16/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class MyCustomerCell: UITableViewCell {

    @IBOutlet weak private var lblCustomerName: UILabel!
    @IBOutlet weak private var lblLocation: UILabel!
    @IBOutlet weak private var lblMobileNumber: UILabel!
    @IBOutlet weak var statusView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCustomerCell(model: MyCustomers.GetCustomers.Customer) {
        statusView.isHidden = true
        let name = "\(model.firstname) \(model.lastname)"
        lblCustomerName.text = name.capitalized
        lblLocation.text = model.location.capitalized
        lblMobileNumber.text = model.mobile_number.masked(6)
        if let font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 16) {
            lblMobileNumber.font = font
        }
    }

    func configurePettyCashCell(model: PettyCashCellModel) {
        statusView.isHidden = false
        statusView.backgroundColor = model.status?.color
        lblCustomerName.text = model.dateTime
        lblLocation.text = model.purpose
        lblMobileNumber.text = model.amount
        if let font = UIFont(name: FontName.NotoSansRegular.rawValue, size: 16) {
            lblMobileNumber.font = font
        }
    }

    func configureServiceDetailsCell(model: ServiceDetailsModel) {
        statusView.isHidden = true
        lblCustomerName.text = model.name
        lblLocation.text = model.date.getDateFromString()?.dayMonthYear ?? ""
        lblMobileNumber.text = model.salon
        if let font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 16) {
            lblMobileNumber.font = font
        }
    }

}

struct CustomerCellModel {
    let name: String
    let location: String
    let mobileNo: String
}

enum PettyCashStatus: String {

    case approved = "Approved"
    case rejected = "Reject"
    case pending = "Pending"

    var color: UIColor {

        switch self {

        case .approved:
            return UIColor.systemGreen
        case .rejected:
            return UIColor.systemRed
        case .pending:
            return UIColor.systemYellow
        }

    }
}

struct PettyCashCellModel {
    let dateTime: String
    let purpose: String
    let amount: String
    let imageURL: String
    let status: PettyCashStatus?
    let action: String
}

struct ServiceDetailsModel {
    let name: String
    let date: String
    let salon: String
}
