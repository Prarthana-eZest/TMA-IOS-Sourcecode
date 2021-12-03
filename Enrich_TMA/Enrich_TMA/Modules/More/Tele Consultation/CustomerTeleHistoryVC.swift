//
//  CustomerTeleHistoryVC.swift
//  Enrich_TMA
//
//  Created by Harshal on 14/05/20.
//  Copyright © 2020 e-zest. All rights reserved.
//

import UIKit

class CustomerTeleHistoryVC: UIViewController {

    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var lblNoRecords: UILabel!

    var records = [TeleMarketingModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: CellIdentifier.teleMarketingCompletedCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.teleMarketingCompletedCell)

        tableView.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        self.navigationController?.addCustomBackButton(title: "History")
    }
}

extension CustomerTeleHistoryVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        lblNoRecords.isHidden = !records.isEmpty
        return records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.teleMarketingCompletedCell, for: indexPath) as? TeleMarketingCompletedCell else {
            return UITableViewCell()
        }
        cell.configureCell(model: records[indexPath.row])

        cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection: \(indexPath.row)")
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
