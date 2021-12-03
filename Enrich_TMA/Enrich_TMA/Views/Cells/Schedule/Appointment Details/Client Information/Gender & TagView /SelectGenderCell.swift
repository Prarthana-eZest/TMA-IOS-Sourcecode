//
//  SelectGenderCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 24/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol SelectGenderDelegate: class {
    func actionGender(gender: Gender)
}

enum Gender {
    case male, female, other, otherMale, otherFemale
}

class SelectGenderCell: UITableViewCell {

    @IBOutlet private var iconButtons: [UIButton]!

    // Male
    @IBOutlet weak private var btnMaleTitle: UIButton!
    @IBOutlet weak private var btnMaleIcon: UIButton!

    // Female
    @IBOutlet weak private var btnFemaleTitle: UIButton!
    @IBOutlet weak private var btnFemaleIcon: UIButton!

    // Other
    @IBOutlet weak private var btnOtherTitle: UIButton!
    @IBOutlet weak private var btnOtherIcon: UIButton!

    @IBOutlet private var titleButtons: [UIButton]!

    @IBOutlet weak private var otherGenderStackView: UIStackView!
    @IBOutlet weak private var btnOtherInclinedMale: UIButton!
    @IBOutlet weak private var btnOtherInclinedFemale: UIButton!

    @IBOutlet weak private var lblTitle: UILabel!

    weak var delegate: SelectGenderDelegate?

    var isEditable = true

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(isEditable: Bool, selectedGender: Gender?) {
        self.isEditable = isEditable
        if let selectedGender = selectedGender {
            selectGender(gender: selectedGender, callDelegate: false)
        }
        lblTitle.text = isEditable ? "Select the gender" : "Gender"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func actionMale(_ sender: UIButton) {
        if isEditable {
            selectGender(gender: .male, callDelegate: true)
        }
    }

    @IBAction func actionFemale(_ sender: UIButton) {
        if isEditable {
            selectGender(gender: .female, callDelegate: true)
        }
    }

    @IBAction func actionOther(_ sender: UIButton) {
        if isEditable {
            selectGender(gender: .other, callDelegate: true)
        }
    }

    @IBAction func clickOtherMale(_ sender: Any) {
        if isEditable {
            selectGender(gender: .otherMale, callDelegate: true)
        }

    }
    @IBAction func clickOtherFemale(_ sender: Any) {
        if isEditable {
            selectGender(gender: .otherFemale, callDelegate: true)
        }
    }

    func selectGender(gender: Gender, callDelegate: Bool) {

        switch gender {
        case .male:
            iconButtons.forEach {$0.isSelected = false}
            setSelectedButton(button: btnMaleTitle)
            btnMaleIcon.isSelected = true
            otherGenderStackView.isHidden = true
            if callDelegate {
                delegate?.actionGender(gender: .male)
            }

        case .female:
            iconButtons.forEach {$0.isSelected = false}
            setSelectedButton(button: btnFemaleTitle)
            btnFemaleIcon.isSelected = true
            otherGenderStackView.isHidden = true
            if callDelegate {
                delegate?.actionGender(gender: .female)
            }

        case .other:
            iconButtons.forEach {$0.isSelected = false}
            setSelectedButton(button: btnOtherTitle)
            btnOtherIcon.isSelected = true
            otherGenderStackView.isHidden = false
            if callDelegate {
                delegate?.actionGender(gender: .other)
            }

        case .otherMale:
            otherGenderStackView.isHidden = false
            btnOtherIcon.isSelected = true
            setSelectedButton(button: btnOtherTitle)
            self.btnOtherInclinedMale.isSelected = true
            self.btnOtherInclinedFemale.isSelected = false
            if callDelegate {
                delegate?.actionGender(gender: .otherMale)
            }

        case .otherFemale:
            otherGenderStackView.isHidden = false
            btnOtherIcon.isSelected = true
            setSelectedButton(button: btnOtherTitle)
            self.btnOtherInclinedFemale.isSelected = true
            self.btnOtherInclinedMale.isSelected = false
            if callDelegate {
                delegate?.actionGender(gender: .otherFemale)
            }
        }
    }

    func setSelectedButton(button: UIButton) {
        titleButtons.forEach {
            $0.setTitleColor(UIColor.lightGray, for: .normal)
            if let font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 18) {
                $0.titleLabel?.font = font
            }
        }
        button.setTitleColor(UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1), for: .normal)
        if let font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: 18) {
            button.titleLabel?.font = font
        }
    }
}
