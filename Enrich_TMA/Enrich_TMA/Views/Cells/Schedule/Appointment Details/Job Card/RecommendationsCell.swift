//
//  RecommendationsCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 11/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class RecommendationsCell: UITableViewCell {

    @IBOutlet weak private var btnProducts: UIButton!
    @IBOutlet weak private var btnValuePackages: UIButton!
    @IBOutlet weak private var productsSelectionView: UIView!
    @IBOutlet weak private var valueForPackagesSelectionView: UIView!

    @IBOutlet weak private var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func actionProducts(_ sender: UIButton) {

        if let font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 16) {
            btnProducts.titleLabel?.font = font
        }
        if let font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 16) {
            btnValuePackages.titleLabel?.font = font
        }
        productsSelectionView.isHidden = false
        valueForPackagesSelectionView.isHidden = true
    }

    @IBAction func actionValuePackages(_ sender: UIButton) {

        if let font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 16) {
            btnValuePackages.titleLabel?.font = font
        }

        if let font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 16) {
            btnProducts.titleLabel?.font = font
        }

        productsSelectionView.isHidden = true
        valueForPackagesSelectionView.isHidden = false
    }

}

// MARK: - UICollectionViewDelegate and UICollectionViewDataSource
extension RecommendationsCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

       // guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.trendingProductsCell, for: indexPath) as? TrendingProductsCell else {
            return UICollectionViewCell()
       // }
       // return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 400
        let width: CGFloat = (collectionView.frame.size.width / 2) - 5
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return is_iPAD ? 25 : 15
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

}
