//
//  AddressTableViewCell.swift
//  EnrichSalon
//

import Foundation
import UIKit

protocol BookingAddressDelegate: class {
    func changeAddress()
}

class AddressTableViewCell: UITableViewCell {
    weak var delegate: BookingAddressDelegate?
    @IBOutlet weak private var lblSalonAddress: UILabel!
    @IBOutlet weak var lblTitleAddress: UILabel!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblName: UILabel!

    @IBAction func actionChanges(_ sender: Any) {
        delegate?.changeAddress()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(address: String) {
        self.lblSalonAddress.text = address
        self.btnChange.setTitle("CHANGE", for: .normal)
        if address == "Please select address" {
            self.btnChange.setTitle("ADD", for: .normal)
        }
    }

}
