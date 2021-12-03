//
//  OurProductsCell.swift
//  EnrichSalon
//

import UIKit

class OurProductsCell: UICollectionViewCell {

    @IBOutlet weak private var productImage: UIImageView!
    @IBOutlet weak private var lbltitle: UILabel!
    @IBOutlet weak private var lblSubtitle: UILabel!
    @IBOutlet weak private var btnAction: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: OurProductsCellModel) {
        self.lbltitle.text = model.title
        self.lblSubtitle.text = model.subTitle
        self.btnAction.setTitle(model.buttonTitle, for: .normal)

        productImage.image = model.defaultImage
//        if !model.imageURL.isEmpty {
//            self.productImage.kf.setImage(with: URL(string: model.imageURL), placeholder: UIImage(named: "ourProductsDefault"), options: nil, progressBlock: nil, completionHandler: nil)
//        }
    }

}

struct OurProductsCellModel {
    let title: String
    let subTitle: String
    let buttonTitle: String
    let defaultImage: UIImage?
}
