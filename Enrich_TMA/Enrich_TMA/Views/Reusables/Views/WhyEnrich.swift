//
//  WhyEnrich.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 09/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit

class WhyEnrich: UIView {
    @IBOutlet weak private var lblHolistic: UILabel!
    @IBOutlet weak private var lblCertified: UILabel!
    @IBOutlet weak private var lblLatestProduct: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupUIInit(model: SalonServiceModule.Something.WhyEnrichModel) {
        lblHolistic.text = (model.holistic_services ?? "") + "+"
        lblCertified.text = (model.certified_professional ?? "") + "+"
        lblLatestProduct.text = (model.latest_products ?? "") + "+"
    }
}
