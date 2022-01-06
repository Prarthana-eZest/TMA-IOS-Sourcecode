//
//  EN_VC_CardTableViewCell.swift
//  PaytmCustomUI
//
//  Created by Suraj on 05/10/21.
//

import UIKit

class CTCBreakUpTableViewCell: UITableViewCell {

    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var imgDropDownView: UIView!
    @IBOutlet weak var imgDropDownIcon: UIImageView!
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var lblMonthly: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblMonthlyTitle: UILabel!
    @IBOutlet weak var lblYearTitle: UILabel!
    @IBOutlet weak var buttomBorderHideView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.lbltitle.textColor = UIColor(hexString: "#2B2A29")
        self.lblMonthly.textColor = UIColor(hexString: "#14B28D")
        self.lblYear.textColor = UIColor(hexString: "#14B28D")
        self.lblMonthlyTitle.textColor = UIColor(hexString: "#7D7D7C")
        self.lblYearTitle.textColor = UIColor(hexString: "#7D7D7C")
        
        self.imgDropDownView.isHidden = false
        self.parentView.backgroundColor = UIColor.white

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }
    
}
