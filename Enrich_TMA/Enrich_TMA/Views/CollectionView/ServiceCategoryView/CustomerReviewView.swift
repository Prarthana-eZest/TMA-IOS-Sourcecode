//
//  CustomerReviewView.swift
//  EnrichSalon
//
//  Created by Mugdha Mundhe on 4/25/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class CustomerReviewView: UIView {

    @IBOutlet weak private var paginationObj: UIPageControl!
    @IBOutlet weak private var lblDescription: UILabel!
    @IBOutlet weak private var collectionObj: UICollectionView!
    var arrReviewsData: [SalonServiceModule.Something.TestimonialModel] = []

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func setupUIInit(arrReviewsData: [SalonServiceModule.Something.TestimonialModel], frameObj: CGRect ) {
        collectionObj.register(UINib(nibName: "CustomerReviewCell", bundle: nil), forCellWithReuseIdentifier: "CustomerReviewCell")
        paginationObj.tintColor = UIColor.lightGray
        paginationObj.numberOfPages = arrReviewsData.count
        self.arrReviewsData = arrReviewsData
        lblDescription.text = "What our customers say"
        collectionObj.delegate = self
        collectionObj.dataSource = self
        collectionObj.reloadData()
    }
}

extension CustomerReviewView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrReviewsData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = arrReviewsData[indexPath.row]
        let cell: CustomerReviewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomerReviewCell", for: indexPath) as! CustomerReviewCell
        cell.customerName.text = model.name
        cell.reviewText.text = model.desc
        let url = URL(string: model.profile_img ?? "")
        cell.profilePicture.kf.indicatorType = .activity

        if let imageurl = model.profile_img, !imageurl.isEmpty {
            cell.profilePicture.kf.setImage(with: url, placeholder: UIImage(named: "reviewAavatarImg"), options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            cell.profilePicture.image = UIImage(named: "reviewAavatarImg")
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionObj.bounds.width, height: self.collectionObj.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.paginationObj.currentPage = indexPath.row
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0

    }
}
