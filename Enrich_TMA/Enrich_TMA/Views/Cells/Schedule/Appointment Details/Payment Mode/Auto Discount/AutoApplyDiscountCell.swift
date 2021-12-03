//
//  AutoApplyDiscountCell.swift
//  
//
//  Created by Harshal on 31/07/20.
//

import UIKit

protocol AutoApplyDiscountDelegate: class {
    func applyOffer(indexPath: IndexPath)
    func removeOffer(indexPath: IndexPath)
}

class AutoApplyDiscountCell: UITableViewCell {
    
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblDescription: UILabel!
    @IBOutlet weak private var btnApplyRemove: UIButton!
    @IBOutlet weak private var titleStackView: UIStackView!
    
    var indexPath: IndexPath?
    var discard = 0
    weak var delegate: AutoApplyDiscountDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(model: AutoDiscountList.discountList, discard: Int) {
        titleStackView.isHidden = false
        lblTitle.text = model.name ?? ""
        lblDescription.text = model.description ?? ""
        self.discard = discard
        let btnTitle = discard == 0 ? "APPLY" : "REMOVE"
        btnApplyRemove.setTitle(btnTitle, for: .normal)
    }
    
    func loadPlaceHolder() {
        titleStackView.isHidden = true
        lblDescription.text = "No offers"
    }

   
    @IBAction func actionApplyRemove(_ sender: UIButton) {
        if let indexPath = indexPath {
            if discard == 0 {
                delegate?.applyOffer(indexPath: indexPath)
            }
            else {
                delegate?.removeOffer(indexPath: indexPath)
            }
        }
    }
    
}
