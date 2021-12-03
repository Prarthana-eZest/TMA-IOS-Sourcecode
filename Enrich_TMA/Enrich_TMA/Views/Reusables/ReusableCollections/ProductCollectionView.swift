//
//  ProductCollectionView.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 11/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit

protocol ProductDelegates: class {
    func selectedProduct(indexPath: IndexPath)
    func optionsBeTheFirstToReview()
    func actionColorSelection(indexPath: IndexPath, color: ProductConfigurableColorQuanity)
    func actionQuantitySelection(indexPath: IndexPath, quantity: ProductConfigurableColorQuanity)
}

class ProductCollectionView: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    var products = [RecommendedProduct]()
    weak var productDelegate: ProductDelegates?

    init(parentView: UIView, productList: [RecommendedProduct]) {
        super.init()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        layout.scrollDirection = .horizontal
        let height = is_iPAD ? 375 : 250
        let width = is_iPAD ? 210 : 140
        layout.itemSize = CGSize(width: width, height: height)

        self.products.append(contentsOf: productList)
        collectionView = UICollectionView(frame: parentView.frame, collectionViewLayout: layout)
        collectionView.frame.origin.y = 0
        collectionView.backgroundColor = UIColor.clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib(nibName: CellIdentifier.productCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.productCell)

        parentView.addSubview(collectionView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.productCell, for: indexPath) as? ProductCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(productDetails: products[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        productDelegate?.selectedProduct(indexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }

}
