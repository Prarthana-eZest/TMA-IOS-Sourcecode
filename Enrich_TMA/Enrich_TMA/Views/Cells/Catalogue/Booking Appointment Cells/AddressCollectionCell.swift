//
//  AddressCollectionCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 15/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

enum CellType {
    case confirmation
    case manageAddress
}

protocol AddressCellDelegate: class {
    func leftButtonAction(cellType: CellType, indexPath: IndexPath)
    func rightButtonAction(cellType: CellType, indexPath: IndexPath)
}

class AddressCollectionCell: UICollectionViewCell {

    @IBOutlet weak private var placeIcon: UIImageView!
    @IBOutlet weak private var lblPlaceType: UILabel!
    @IBOutlet weak private var lblUserName: UILabel!
    @IBOutlet weak private var lblAddress: UILabel!
    @IBOutlet weak private var lblMobileNo: UILabel!

    @IBOutlet weak private var btnLeft: UIButton!
    @IBOutlet weak private var btnRight: UIButton!

    var indexpath: IndexPath?
    weak var delegate: AddressCellDelegate?
    var type: CellType?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: AddressCellModel, cellType: CellType, indexPath: IndexPath) {

        indexpath = indexPath
        type = cellType
        if cellType == .confirmation {
            btnLeft.setTitle("REMOVE", for: .normal)
            btnLeft.borderColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
            btnLeft.borderWidth = 1
            btnLeft.backgroundColor = UIColor.white
            btnLeft.setTitleColor(UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1), for: .normal)

            btnRight.setTitle("EDIT", for: .normal)
            btnRight.borderColor = UIColor(red: 0.91, green: 0.13, blue: 0.09, alpha: 1)
            btnRight.borderWidth = 1
            btnRight.backgroundColor = UIColor.white
            btnRight.setTitleColor(UIColor(red: 0.91, green: 0.13, blue: 0.09, alpha: 1), for: .normal)
        }

        DispatchQueue.main.async {
            self.lblPlaceType.text = model.placeType
            self.lblUserName.text = model.userName
            self.lblAddress.text = model.address
            self.lblMobileNo.text = model.contactNo
        }

    }

    @IBAction func actionLeftButton(_ sender: UIButton) {
        if let indexpath = indexpath,
            let cellType = type {
           self.delegate?.leftButtonAction(cellType: cellType, indexPath: indexpath)
        }
    }

    @IBAction func actionRightButton(_ sender: UIButton) {
        if let indexpath = indexpath,
            let cellType = type {
            self.delegate?.rightButtonAction(cellType: cellType, indexPath: indexpath)
        }
    }

}

struct AddressCellModel {
    let placeType: String
    let userName: String
    let address: String
    let contactNo: String
    let addressId: Int64
    let firstName: String
    let lastName: String
    let apartment: String
    let pinCode: String
    let cityTown: String
    let landmark: String
    let state: String

}
