//
//  HeaderViewWithText.swift
//  EnrichPOC
//
//  Created by Harshal Patil on 12/04/19.
//  Copyright © 2019 Harshal Patil. All rights reserved.
//

import UIKit

class HeaderViewWithText: UIView {

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var viewAllButton: UIButton!

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
        let nib = UINib(nibName: "HeaderViewWithText", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    @IBAction func viewAllAction(_ sender: Any) {

    }

}
