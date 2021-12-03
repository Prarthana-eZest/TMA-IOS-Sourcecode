//
//  SubCategoryListingVC.swift
//  EnrichSalon
//
//  Created by Apple on 06/12/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class SubCategoryListingVC: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: CellIdentifier.subCategoryCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.subCategoryCell)
        addSOSButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    func addSOSButton() {
        guard let sosImg = UIImage(named: "SOS") else {
            return
        }
        let sosButton = UIBarButtonItem(image: sosImg, style: .plain, target: self, action: #selector(didTapSOSButton))
        sosButton.tintColor = UIColor.black
        navigationItem.title = ""
        if showSOS {
            navigationItem.rightBarButtonItems = [sosButton]
        }
    }

    @objc func didTapSOSButton() {
        SOSFactory.shared.raiseSOSRequest()
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

extension SubCategoryListingVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.subCategoryCell, for: indexPath) as? SubCategoryCell else {
            return UITableViewCell()
        }
        cell.lblCategoryName.text  = "Sub Category"
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let vc = SubCategoryListingVC.instantiate(fromAppStoryboard: .Services)
        self.navigationController?.pushViewController(vc, animated: true)

    }

}
