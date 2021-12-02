//
//  GetInsightfulCollectionView.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 12/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit

protocol GetInsightfulDelegates {
    func selectedItem(indexPath: IndexPath)
}

class GetInsightfulCollectionView: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    var items = [GetInsightFulDetails]()
    var getInsightfulDelegate: GetInsightfulDelegates?

    init(parentView: UIView, items: [GetInsightFulDetails]) {
        super.init()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        layout.scrollDirection = .horizontal
        let height = is_iPAD ? 510 : 340
        let width = is_iPAD ? 360 : 240
        layout.itemSize = CGSize(width: width, height: height)

        self.items.append(contentsOf: items)
        collectionView = UICollectionView(frame: parentView.frame, collectionViewLayout: layout)
        collectionView.frame.origin.y = 0
        collectionView.backgroundColor = UIColor.clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib(nibName: "GetInsightfulCell", bundle: nil), forCellWithReuseIdentifier: "GetInsightfulCell")
        parentView.addSubview(collectionView)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GetInsightfulCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GetInsightfulCell", for: indexPath) as! GetInsightfulCell
//        cell.configureCell(details: items[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        getInsightfulDelegate?.selectedItem(indexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }

}
