//
//  PettyCashAttachementCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 11/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit
import Kingfisher

class PettyCashAttachementCell: UITableViewCell {

    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var attachmentImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(attachementURL: String) {
        lblTitle.text = "Attachement"
        if !attachementURL.isEmpty ,
            let url = URL(string: attachementURL) {
            self.attachmentImage.isHidden = false
            self.attachmentImage.kf.setImage(with: url, placeholder: UIImage(named: ""),
                                             options: nil, progressBlock: nil,
                                             completionHandler: nil)
        }
        else {
            self.attachmentImage.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
