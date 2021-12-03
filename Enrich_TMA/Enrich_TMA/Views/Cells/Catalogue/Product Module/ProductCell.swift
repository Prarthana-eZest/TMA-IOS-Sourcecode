//
//  ProductCell.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 11/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit

struct RecommendedProduct {
    let productName: String
    let productImageURL: String
    let price: String
    let productId: String
    let sku: String
}
class ProductCell: UICollectionViewCell {

    @IBOutlet weak private var productImageView: UIImageView!
    @IBOutlet weak private var productName: UILabel!
    @IBOutlet weak private var productPrice: UILabel!

    @IBOutlet weak private var cornerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(productDetails: RecommendedProduct) {
        DispatchQueue.main.async {
            self.cornerView.isUserInteractionEnabled = false
            self.productName.text = productDetails.productName
            self.productPrice.text = "INR \(productDetails.price)"
            self.productImageView.kf.indicatorType = .activity
            if !productDetails.productImageURL.isEmpty {
                let url = URL(string: productDetails.productImageURL)

                self.productImageView.kf.setImage(with: url, placeholder: UIImage(named: "productDefault"), options: nil, progressBlock: nil, completionHandler: nil)
            }
            else {
                self.productImageView.image = UIImage(named: "productDefault")
            }
        }

    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
