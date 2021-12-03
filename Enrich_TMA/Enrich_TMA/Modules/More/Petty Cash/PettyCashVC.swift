//
//  PettyCashVC.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 11/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class PettyCashVC: UIViewController {

    @IBOutlet weak private var tableView: UITableView!

    var pettyCash: PettyCashCellModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        tableView.register(UINib(nibName: CellIdentifier.pettyCashCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.pettyCashCell)
        tableView.register(UINib(nibName: CellIdentifier.pettyCashAttachementCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.pettyCashAttachementCell)

        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        addSOSButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserFactory.shared.checkForSignOut()
        self.navigationController?.navigationBar.isHidden = false
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait,
                                         andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.addCustomBackButton(title: "Petty Cash")
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

}

extension PettyCashVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 4 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.pettyCashAttachementCell,
                                                           for: indexPath) as? PettyCashAttachementCell else {
                                                            return UITableViewCell()
            }
            cell.configureCell(attachementURL: pettyCash?.imageURL ?? "")
            cell.selectionStyle = .none
            return cell
        }
        else {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.pettyCashCell,
                                                           for: indexPath) as? PettyCashCell else {
                                                            return UITableViewCell()
            }

            switch indexPath.row {
            case 0:
                if let font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 18) {
                    cell.configureCell(title: "Date & time", value: pettyCash?.dateTime ?? "", valueFont: font)
                }
            case 1:
                if let font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 18) {
                    cell.configureCell(title: "Action", value: pettyCash?.action ?? "", valueFont: font)
                }
            case 2:
                if let font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 18) {
                    cell.configureCell(title: "Purpose", value: pettyCash?.purpose ?? "", valueFont: font)
                }
            case 3:
                if let font = UIFont(name: FontName.NotoSansRegular.rawValue, size: 18) {
                    cell.configureCell(title: "Amount", value: pettyCash?.amount ?? "", valueFont: font)
                }

            default:
                break
            }

            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            return cell

        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
