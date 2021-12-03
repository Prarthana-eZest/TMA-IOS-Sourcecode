//
//  HorizontalListingCollectionViewCell.swift
//  EnrichSalon
//
//  Created by Rahul on 26/04/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit
enum CustomCollectionCellEnum: Int {
    case customerCell = 0
    case whyEnrich
}

extension UICollectionViewCell {

    struct TypeCustomCell {
        static var _Type: CustomCollectionCellEnum = CustomCollectionCellEnum.customerCell
        static var _SubView: UIView?
    }
    var typeCell: CustomCollectionCellEnum {
        get {
            return TypeCustomCell._Type
        }
        set(newValue) {
            TypeCustomCell._Type = newValue
        }
    }

    var subViewObj: UIView {
        get {
            return TypeCustomCell._SubView ?? UIView()
        }
        set(newValue) {
            TypeCustomCell._SubView = newValue
        }
    }

    func addSubViewObject<T: UIView>(Screen: T) {

        var isSubViewPresent = false
        for subview in self.contentView.subviews {
            if subview.isKind(of: T.self) {
                isSubViewPresent = true
            }
        }

        if isSubViewPresent == false {
            self.contentView.addSubview(Screen)
        }
    }
}

class HorizontalListingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var viewObj: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
