//
//  SelectGenderCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 24/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol SelectGenderDelegate:class{
    func actionGender(gender:Gender)
}

enum Gender{
    case male,female,otherMale,otherFemale
}

class SelectGenderCell: UITableViewCell {
    
    @IBOutlet private var iconButtons: [UIButton]!
    @IBOutlet weak private var btnMaleTitle: UIButton!
    @IBOutlet weak private var btnFemaleTitle: UIButton!
    @IBOutlet weak private var btnOtherTitle: UIButton!
    @IBOutlet private var titleButtons: [UIButton]!
    
    
    @IBOutlet weak var otherGenderStackView: UIStackView!
    @IBOutlet weak private var btnOtherInclinedMale: UIButton!
    @IBOutlet weak private var btnOtherInclinedFemale: UIButton!
    
    weak var delegate: SelectGenderDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func actionMale(_ sender: UIButton) {
        iconButtons.forEach{$0.isSelected = false}
        setSelectedButton(button: btnMaleTitle)
        sender.isSelected = true
        otherGenderStackView.isHidden = true
        delegate?.actionGender(gender: .male)
    }
    
    @IBAction func actionFemale(_ sender: UIButton) {
        iconButtons.forEach{$0.isSelected = false}
        setSelectedButton(button: btnFemaleTitle)
        sender.isSelected = true
        otherGenderStackView.isHidden = true
        delegate?.actionGender(gender: .female)
    }
    
    @IBAction func actionOther(_ sender: UIButton) {
        iconButtons.forEach{$0.isSelected = false}
        setSelectedButton(button: btnOtherTitle)
        sender.isSelected = true
        otherGenderStackView.isHidden = false
    }
    
    @IBAction func clickOtherMale(_ sender: Any) {
        self.btnOtherInclinedMale.isSelected = true
        self.btnOtherInclinedFemale.isSelected = false
        delegate?.actionGender(gender: .otherMale)
        
    }
    @IBAction func clickOtherFemale(_ sender: Any) {
        self.btnOtherInclinedFemale.isSelected = true
        self.btnOtherInclinedMale.isSelected = false
        delegate?.actionGender(gender: .otherFemale)
    }
    
    func setSelectedButton(button: UIButton){
        titleButtons.forEach{
            $0.setTitleColor(UIColor.lightGray, for: .normal)
            if let font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 25 : 18){
                $0.titleLabel?.font = font
            }
        }
        button.setTitleColor(UIColor(red:0.15, green:0.15, blue:0.15, alpha:1), for: .normal)
        if let font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 25 : 18){
            button.titleLabel?.font = font
        }
    }
}
