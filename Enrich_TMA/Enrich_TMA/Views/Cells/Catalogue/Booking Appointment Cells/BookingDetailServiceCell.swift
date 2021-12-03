//
//  BookingDetailServiceCell.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 7/10/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit

class BookingDetailServiceCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet weak private var collectionViewService: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionViewService.register(UINib(nibName: CellIdentifier.serviceCollectionCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.serviceCollectionCell)

    }

    func configureCollectionView() {
        self.collectionViewService.isScrollEnabled = false
        collectionViewService.allowsSelection = true
        collectionViewService.showsVerticalScrollIndicator = false
        collectionViewService.showsHorizontalScrollIndicator = false
        self.collectionViewService.reloadData()
    }
}
