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

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var attachmentImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(model:PettyCashCellModel){
        lblTitle.text = model.title
        if !model.imageURL.isEmpty {
            let url = URL(string: model.imageURL)
            
            self.attachmentImage.kf.setImage(with: url, placeholder: UIImage(named: ""), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
