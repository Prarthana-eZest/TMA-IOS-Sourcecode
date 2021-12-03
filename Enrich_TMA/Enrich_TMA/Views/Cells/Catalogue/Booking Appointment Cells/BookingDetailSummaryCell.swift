//
//  BookingDetailSummaryCell.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 7/9/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit

class BookingDetailSummaryCell: UITableViewCell {
    @IBOutlet weak private var lblSalonName: UILabel!
    @IBOutlet weak private var lblSalonAddress: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!

    @IBOutlet weak private var lblNumberOfServices: UILabel!
    @IBOutlet weak private var lblServiceTotalTime: UILabel!

    @IBOutlet weak private var btnChange: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: BookingDetailModel) {
        self.lblSalonName.text = model.salonName
        self.lblSalonAddress.text = model.salonAddress!
        self.lblDateTime.text = model.serviceDateAndTime
        self.lblNumberOfServices.text = String(model.numberOfServices!)
        self.lblServiceTotalTime.text = model.totalServiceTime!
        //self.setServiceDateTime(rangeText: model.serviceDateAndTime!)
       // self.setNumberOfServices(rangeText: String(model.numberOfServices!))
        //self.setTotalServiceTime(rangeText: model.totalServiceTime!)
    }

   /* func setCustomFont(text:String,rangeText:String) -> NSMutableAttributedString
    {
        let range = (text as NSString).range(of: rangeText)
        let attribute = NSMutableAttributedString.init(string: text)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black , range: range)
        attribute.addAttribute(NSAttributedString.Key.font, value:UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 24.0 : 16.0)! , range: range)
        return attribute
        
    }
    
    func setServiceDateTime(rangeText:String)
    {
        self.lblDateTime.attributedText = setCustomFont(text: "Date & time: " + rangeText, rangeText: rangeText)
    }
    
    func setNumberOfServices(rangeText:String)
    {
        self.lblNumberOfServices.attributedText = setCustomFont(text: "Services Selected: " + rangeText, rangeText: rangeText)
    }
    
    func setTotalServiceTime(rangeText:String)
    {
        self.lblServiceTotalTime.attributedText = setCustomFont(text: "Total Estimated Time: " + rangeText, rangeText: rangeText)
    }*/

    func showChangeButtonOnView(status: Bool) {
        btnChange.isHidden = status
    }

}

struct BookingDetailModel {
    let id: Int
    let salonName: String?
    let salonAddress: String?
    let serviceDateAndTime: String?
    let numberOfServices: String?
    let totalServiceTime: String?
}

struct Product {
    let id: Int
    let numberOfBuyers: String?
    let productName: String?
    let productType: String?
    let productCost: String?
    let numberOfProducts: String?
}
