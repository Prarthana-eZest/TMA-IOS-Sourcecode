//
//  AddOnListingViewController.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 12/08/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class AddOnListingViewController: UIViewController {

    @IBOutlet  weak var imgViewObj: UIImageView!
    @IBOutlet  weak var tableView: UITableView!
    @IBOutlet  weak var lblTitle: UILabel!
    @IBOutlet  weak var lblSubTitle: UILabel!

    private var addOnList = [String]()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        addOnList.append("test1")
        addOnList.append("test2")
        addOnList.append("test3")
        tableView.reloadData()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imgViewObj.alpha = 1
    }

    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddOnListingViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addOnList.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SortCell", for: indexPath) as? SortCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.lblTitle.text = self.addOnList[indexPath.row]
        cell.lblTitle.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 24.0 : 16.0)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return is_iPAD ? 60 : 45
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
    }

}
