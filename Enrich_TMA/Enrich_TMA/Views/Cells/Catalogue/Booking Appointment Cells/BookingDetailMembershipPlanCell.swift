//
//  BookingDetailMembershipPlanCell.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 7/12/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit

class BookingDetailMembershipPlanCell: UITableViewCell {

    // MARK: IBActions
    @IBOutlet weak private var imgviewLogo: UIImageView!
    @IBOutlet weak private var lblMembershipPlanTitle: UILabel!
    @IBOutlet weak private var lblMembershipPlanDescription: UILabel!
    @IBOutlet weak private var btnMembershipPlan: UIButton!

    @IBAction func actionOurMembershipPlanClicked(_ sender: Any) {
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: MembershipPlanModel) {
        self.imgviewLogo.image = UIImage(named: model.logo!)
        self.lblMembershipPlanTitle.text = model.title
        self.lblMembershipPlanDescription.text = model.description
    }

}

struct MembershipPlanModel {
    let id: Int?
    let logo: String?
    let title: String?
    let description: String?
}
