//
//  TrendingServiceCollectionView.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 12/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit

protocol TrendingServiceDelegates: class {
    func selectedService(indexPath: IndexPath)
}

class TrendingServiceCollectionView: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    var services = [TrendingService]()
    weak var trendingServiceDelegate: TrendingServiceDelegates?

    init(parentView: UIView, services: [TrendingService]) {
        super.init()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        layout.scrollDirection = .horizontal
        let height: CGFloat = is_iPAD ? 450 : 300
        layout.itemSize = CGSize(width: parentView.frame.size.width - 40, height: height)

        self.services.append(contentsOf: services)
        collectionView = UICollectionView(frame: parentView.frame, collectionViewLayout: layout)
        collectionView.frame.origin.y = 0
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib(nibName: CellIdentifier.trendingServicesCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.trendingServicesCell)
        parentView.addSubview(collectionView)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell: TrendingServicesCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.trendingServicesCell, for: indexPath) as! TrendingServicesCell

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.trendingServicesCell, for: indexPath) as? TrendingServicesCell else {
            return UICollectionViewCell()
        }

        cell.configureCell(serviceDetails: services[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        trendingServiceDelegate?.selectedService(indexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }

}
