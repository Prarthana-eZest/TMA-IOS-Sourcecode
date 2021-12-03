//
//  ServiceDescriptionCell.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 15/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit
import Cosmos

protocol ServiceDescriptionCellDelegate: class {
    func addOns(indexPath: Int)
    func optionsBeTheFirstToReview()
}

class ServiceDescriptionCell: UITableViewCell {

    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var dropdownText: LabelButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var lblReviews: LabelButton!
    @IBOutlet weak var viewUnderline: UIView!
    @IBOutlet weak var ratingsView: CosmosView!
    @IBOutlet weak var lblServiceTitle: UILabel!
    @IBOutlet weak var lblOldPrice: UILabel!
    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblServiceHours: UILabel!

    // Dynamic constraints outlet
    @IBOutlet weak private var lblRecommendedFor: UILabel!

    var recommendedFor =   [String]()// This Hold Recommended Info

    weak var delegate: ServiceDescriptionCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib(nibName: CellIdentifier.recommendedForCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.recommendedForCell)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.serviceImageView.setGradientToImageView()
        }

        self.dropdownText.onClick = {
            // TODO
            self.plusButtonAction(self.btnPlus)
        }
        self.lblReviews.onClick = {
//            if (self.lblReviews.text?.isEqual(noReviewsMessage))!{
//                self.delegate?.optionsBeTheFirstToReview()
//            }
            self.delegate?.optionsBeTheFirstToReview()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //  func configureCell(model:ServiceDescriptionCellModel){
    func configureCell() {
        let radius: CGFloat = is_iPAD ? 8 : 5

        dropdownText.layer.borderColor = UIColor.lightGray.cgColor
        dropdownText.layer.borderWidth = 1
        dropdownText.layer.cornerRadius = radius
    }
    // MARK: hideControls
    func hideControls(hideDropDown: Bool, hideCollection: Bool) {

        if hideDropDown {
            self.dropdownText.isHidden = true //removeFromSuperview()
            self.btnPlus.isHidden = true //removeFromSuperview()
        }

        if hideCollection {
            self.lblRecommendedFor.isHidden = true//removeFromSuperview()
            self.collectionView.isHidden = true //removeFromSuperview()
        }
    }

    @IBAction func plusButtonAction(_ sender: UIButton) {
        delegate?.addOns(indexPath: sender.tag)
    }

}

extension ServiceDescriptionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recommendedFor.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.recommendedForCell, for: indexPath) as? RecommendedForCell else {
            return UICollectionViewCell()
        }
        cell.titleLabel.text = self.recommendedFor[indexPath.row]
        cell.configureCell()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width * 0.33) - 10, height: (collectionView.frame.size.height))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

}

struct ServiceDescriptionCellModel {
    var serviceImageURL: URL?
    var descriptionText = ""
    var dropdownText = ""
    var price = ""
    var collectionViewData: [String] = []
    var hideCollection = false
    var hideDropDown = false
}
