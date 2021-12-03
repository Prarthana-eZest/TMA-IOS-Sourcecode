//
//  DependentListCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 25/11/20.
//  Copyright © 2020 e-zest. All rights reserved.
//

import UIKit

protocol DependentListDelegate: class {
    func actionSelectedRadio(indexPath: IndexPath)
    func actionRemoveDependent(indexPath: IndexPath)
}

class DependentListCell: UITableViewCell {
    
    @IBOutlet weak var btnName: UIButton!
    
    var indexPath: IndexPath?
    weak var delegate: DependentListDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(name: String, isSelected: Bool) {
        btnName.setTitle(name, for: .normal)
        btnName.isSelected = isSelected
        if isSelected {
            btnName.titleLabel?.font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 18)
        }else {
            btnName.titleLabel?.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 18)
        }
    }
    
    @IBAction func actionRemove(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.actionRemoveDependent(indexPath: indexPath)
        }
    }
    
    @IBAction func actionSelectRadio(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.actionSelectedRadio(indexPath: indexPath)
        }
    }
    
}
