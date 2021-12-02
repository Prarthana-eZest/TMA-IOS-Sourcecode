//
//  HeaderViewWithSubtitle.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 15/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit

class HeaderViewWithSubtitle: UIView {

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subTitleLabel: UILabel!

    var contentView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }

    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "HeaderViewWithSubtitle", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

}
