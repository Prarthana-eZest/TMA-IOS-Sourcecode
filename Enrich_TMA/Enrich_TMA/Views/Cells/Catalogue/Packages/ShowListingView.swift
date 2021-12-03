//
//  ShowListingView.swift
//  EnrichSalon
//
//  Created by Mugdha Mundhe on 18/11/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class ShowListingView: UIView {

    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var tblShowList: UITableView!
    var arrShowData: [ApplyCouponModel.GetCoupons.SalonData] = []
    @IBOutlet weak var lblTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func setupUIInit(arrShowData: [ApplyCouponModel.GetCoupons.SalonData], frameObj: CGRect ) {
        lblTitle.text = "Stores"
        self.frame = frameObj
        self.arrShowData = arrShowData
        tblShowList.delegate = self
        tblShowList.dataSource = self
        tblShowList.reloadData()
    }

    @IBAction func actionClose(_ sender: Any) {
       self.removeFromSuperview()
    }
}

extension ShowListingView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = arrShowData[indexPath.row].salon_name ?? ""
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrShowData.count
    }
}
