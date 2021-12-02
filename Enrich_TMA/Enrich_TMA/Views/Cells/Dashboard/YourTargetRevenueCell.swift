//
//  YourTargetRevenueCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 15/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

protocol TargetRevenueDelegate:class {
    func actionDaily()
    func actionMonthly()
    func actionViewAllRevenue()
}

class YourTargetRevenueCell: UITableViewCell {

    
    // Service Revenue
    @IBOutlet weak var lblServiceRevenuePercent: UILabel!
    @IBOutlet weak var serviceRevenueProgressBar: UIProgressView!
    @IBOutlet weak var lblServiceRevenueAmount: UILabel!
    
    // Product Revenue
    @IBOutlet weak var lblProductRevenuePercent: UILabel!
    @IBOutlet weak var productRevenueProgressBar: UIProgressView!
    @IBOutlet weak var lblProductRevenueAmount: UILabel!
    
    // Membership Sold
    @IBOutlet weak var lblMembershipPercent: UILabel!
    @IBOutlet weak var membershipProgressBar: UIProgressView!
    @IBOutlet weak var lblMembershipAmount: UILabel!
    
    @IBOutlet weak var btnDaily: UIButton!
    @IBOutlet weak var btnMonthly: UIButton!
    
    @IBOutlet weak var dailySelectionView: UIView!
    @IBOutlet weak var monthlySelectionView: UIView!
    
    
    weak var delegate: TargetRevenueDelegate?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        serviceRevenueProgressBar.layer.cornerRadius = 7
        serviceRevenueProgressBar.layer.masksToBounds = true
        
        productRevenueProgressBar.layer.cornerRadius = 7
        productRevenueProgressBar.layer.masksToBounds = true
        
        membershipProgressBar.layer.cornerRadius = 7
        membershipProgressBar.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func actionViewAll(_ sender: UIButton) {
        delegate?.actionViewAllRevenue()
    }
    
    @IBAction func actionDaily(_ sender: UIButton) {
        if let font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 16){
            btnDaily.titleLabel?.font = font
        }
        if let font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 16){
            btnMonthly.titleLabel?.font = font
        }
        dailySelectionView.isHidden = false
        monthlySelectionView.isHidden = true
        
        delegate?.actionDaily()
    }
    
    @IBAction func actionMonthly(_ sender: UIButton) {
        if let font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 16){
            btnMonthly.titleLabel?.font = font
        }
        if let font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 16){
            btnDaily.titleLabel?.font = font
        }
        dailySelectionView.isHidden = true
        monthlySelectionView.isHidden = false
        
        delegate?.actionMonthly()
    }
    
}
