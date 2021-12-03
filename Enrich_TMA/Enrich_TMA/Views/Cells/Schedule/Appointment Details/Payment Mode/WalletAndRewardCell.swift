//
//  WalletAndRewardCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 22/01/20.
//  Copyright © 2020 e-zest. All rights reserved.
//

import UIKit

class WalletAndRewardCell: UITableViewCell {

    // Enrich Wallet View
    @IBOutlet weak private var lblEnrichWalletSection: UILabel!
    @IBOutlet weak private var lblEnrichWalletAmount: UILabel!
    @IBOutlet weak private var lblEnrichWallet: UILabel!
    @IBOutlet weak private var enrichWalletIcon: UIImageView!
    @IBOutlet weak private var enrichWalletSelectionIcon: UIImageView!

    @IBOutlet weak private var btnEnrichCash: UIButton!
    @IBOutlet weak private var btnAvailedPackages: UIButton!

    @IBOutlet weak private var enrichWalletView: UIView!

    @IBOutlet weak private var redeemGiftPointViewToShowPoints: UIView!
    @IBOutlet weak private var redeemGiftPointView: UIView!
    @IBOutlet weak private var completeRedeemGiftPointView: UIView!

    @IBOutlet weak private var lblRewardPointsTitle: LabelButton!
    @IBOutlet weak private var lblRewardPointsValue: LabelButton!
    @IBOutlet weak private var imgArrowUpAndDown: UIImageView!
    @IBOutlet weak private var txtApplyRewardPoints: UITextField!
    @IBOutlet weak private var btnApplyRewardPoints: UIButton!

    @IBOutlet weak private var lblMyAvailablePackageSection: UILabel!
    @IBOutlet weak private var myAvailablePackagesView: UIView!
    @IBOutlet weak private var lblAvailablePackage: UILabel!
    @IBOutlet weak private var enrichAvailablePackageIcon: UIImageView!
    @IBOutlet weak private var enrichAvailablePackageSelectionIcon: UIImageView!

    @IBOutlet weak private var lblEnterValueBetween: UILabel!

    @IBOutlet weak private var packagesStackView: UIStackView!

    weak var delegate: PaymentOptionsDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        txtApplyRewardPoints.delegate = self

        self.lblRewardPointsTitle.onClick = {
            self.hideAndShowReedemPointsView()
        }
        self.lblRewardPointsValue.onClick = {
            self.hideAndShowReedemPointsView()
        }
        [txtApplyRewardPoints].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func actionEnrichCash(_ sender: UIButton) {
        if enrichWalletIcon.image == UIImage(named: "enrichWalletWhite") {
            delegate?.actionApplyWallet(status: false)
        }
        else {
            delegate?.actionApplyWallet(status: true)
        }
    }

    @IBAction func actionApplyRewardPoints(_ sender: Any) {
        delegate?.actionApplyRedeemPoints(redeemPoints: self.txtApplyRewardPoints.text ?? "")
    }
    @IBAction func actionAvailablePackages(_ sender: UIButton) {
        //self.availblePackagesSelected(status: enrichAvailablePackageSelectionIcon.isHidden)
        delegate?.actionApplyPackage(cell: self)
    }

    func configureCell(minLimit: String, maxLimit: String, isApplyReedemPointButton: Bool = false,
                       enrichWalletAmount: String, rewardPointsValue: String, finalAmountToPay: String,
                       isWalletApplied: Bool = false, rewardPointsAlreadyAvailed: Double = 0.0,
                       isShowHideValuePackage: Bool = true, isPackageApplied: Bool) {

        lblEnterValueBetween.text = String(format: "Reward points can be applied within %@ to %@", minLimit, maxLimit)
        btnApplyRewardPoints.isSelected = isApplyReedemPointButton
        txtApplyRewardPoints.isUserInteractionEnabled = btnApplyRewardPoints.isSelected ? false : true
        // txtApplyRewardPoints.text = btnApplyRewardPoints.isSelected ? txtApplyRewardPoints.text ?? "" : ""
        txtApplyRewardPoints.text = btnApplyRewardPoints.isSelected ?  rewardPointsAlreadyAvailed.cleanForPrice : ""

        enrichWalletSelected(status: isWalletApplied)
        lblEnrichWalletAmount.text = enrichWalletAmount
        lblRewardPointsValue.text = rewardPointsValue
        lblEnrichWalletSection.isHidden = false
        btnEnrichCash.isHidden = false
        btnApplyRewardPoints.isHidden = false

        enrichWalletView.isHidden = (enrichWalletAmount ==  " ₹ 0")
        completeRedeemGiftPointView.isHidden = ((rewardPointsValue == "0") || (maxLimit.toDouble() == 0.0))

        availblePackagesSelected(status: isPackageApplied)

        if enrichWalletAmount == " ₹ 0" && ((rewardPointsValue == "0") || (maxLimit.toDouble() == 0.0)) {
            lblEnrichWalletSection.isHidden = true
            enrichWalletView.isHidden = true
            completeRedeemGiftPointView.isHidden = true
            btnApplyRewardPoints.isHidden = true
            btnEnrichCash.isHidden = true
        }

        btnAvailedPackages.isHidden = isShowHideValuePackage
        packagesStackView.isHidden = isShowHideValuePackage

    }

    func hideAndShowReedemPointsView() {

        if self.imgArrowUpAndDown.image == UIImage(named: "downArrow") {
            self.redeemGiftPointView.isHidden = false
            self.imgArrowUpAndDown.image = UIImage(named: "upArrow")
        }
        else {
            self.redeemGiftPointView.isHidden = true
            self.imgArrowUpAndDown.image = UIImage(named: "downArrow")
        }

        delegate?.reloadTableView()
    }

    func enrichWalletSelected(status: Bool) {
        enrichWalletView.backgroundColor = status ? UIColor(red: 39 / 255, green: 37 / 255, blue: 37 / 255, alpha: 1) : UIColor.white
        lblEnrichWallet.textColor = status ? UIColor.white : UIColor(red: 39 / 255, green: 37 / 255, blue: 37 / 255, alpha: 1)
        lblEnrichWalletAmount.textColor = status ? UIColor.white : UIColor(red: 39 / 255, green: 37 / 255, blue: 37 / 255, alpha: 1)
        enrichWalletSelectionIcon.isHidden = !status
        enrichWalletIcon.image = UIImage(named: status ? "enrichWalletWhite" : "enrichCash")
    }
    func availblePackagesSelected(status: Bool) {
        myAvailablePackagesView.backgroundColor = status ? UIColor(red: 39 / 255, green: 37 / 255, blue: 37 / 255, alpha: 1) : UIColor.white
        lblAvailablePackage.textColor = status ? UIColor.white : UIColor(red: 39 / 255, green: 37 / 255, blue: 37 / 255, alpha: 1)
        enrichAvailablePackageSelectionIcon.isHidden = !status
        enrichAvailablePackageIcon.image = UIImage(named: status ? "packages_white" : "packages_black")
    }

}

extension WalletAndRewardCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func editingChanged(_ textField: UITextField) {
        switch textField {

        case txtApplyRewardPoints:
            let numberOnly = NSCharacterSet(charactersIn: "0123456789")
            let stringFromTextField = NSCharacterSet(charactersIn: textField.text ?? "")
            let strValid = numberOnly.isSuperset(of: stringFromTextField as CharacterSet)
            if strValid {
                txtApplyRewardPoints.text = textField.text
            }
            else {
                txtApplyRewardPoints.text?.removeLast()
            }

        default:
            break

        }
    }
}
