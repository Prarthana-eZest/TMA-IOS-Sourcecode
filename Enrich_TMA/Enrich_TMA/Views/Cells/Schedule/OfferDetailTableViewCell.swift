//
//  OfferDetailTableViewCell.swift
//  EnrichSalon
//
//  Created by Mugdha Mundhe on 07/11/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol OfferDelegate: class {
    func openOfferStores()
    func copyCodeAction()
}

class OfferDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var viewShowCode: UIView!
    @IBOutlet weak var lblCopy: UILabel!
    @IBOutlet weak var btnCopyCode: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStores: UILabel!
    @IBOutlet weak var btnStores: UIButton!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblOfferDescTitle: UILabel!
    @IBOutlet weak var imgShowOffer: UIImageView!
    @IBOutlet weak var constraintCodeHt: NSLayoutConstraint!

    @IBOutlet weak var lblHappyHours: UILabel!
    @IBOutlet weak var lblTimingFrom: UILabel!
    @IBOutlet weak var lblTimingTo: UILabel!
    @IBOutlet weak var lblValidFrom: UILabel!
    @IBOutlet weak var lblValidTo: UILabel!
    @IBOutlet weak var lblValidOn: UILabel!

    @IBOutlet weak var stackValidOn: UIStackView!
    @IBOutlet weak var stackValid: UIStackView!
    @IBOutlet weak var stackTiming: UIStackView!

    weak var delegate: OfferDelegate?

    @IBAction func actionOpenStores(_ sender: Any) {
        delegate?.openOfferStores()
    }
    @IBAction func actionCopyCode(_ sender: Any) {
        delegate?.copyCodeAction()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
