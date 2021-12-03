//
//  ServiceCategoryTableViewCell.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 15/05/20.
//  Copyright © 2020 Aman Gupta. All rights reserved.
//

import UIKit

protocol ServiceCategoryTableViewCellDelegate: class {
    func viewMoreDetails(indexPath: IndexPath)
}

class ServiceCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak private var viewMoreButton: UIButton!
    @IBOutlet weak private var lblCategoryName: UILabel!
    @IBOutlet weak private var imgCategory: UIImageView!
    weak var delegate: ServiceCategoryTableViewCellDelegate?
    private var indexP = IndexPath(row: 0, section: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(model: HairTreatmentModule.Something.Items, indexPath: IndexPath) {
        indexP = indexPath
        lblCategoryName.text = model.name ?? ""

        if let imageURL: String = model.media_gallery_entries?.first?.media_type, !imageURL.isEmpty {
            let url = URL(string: imageURL )
            self.imgCategory.kf.setImage(with: url, placeholder: UIImage(named: "imgCategoryProd"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            self.imgCategory.image = UIImage(named: "imgCategoryProd")
        }
    }

    @IBAction func viewMoreAction(_ sender: UIButton) {
        delegate?.viewMoreDetails(indexPath: indexP)

    }

}
