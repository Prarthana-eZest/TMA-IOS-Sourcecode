//
//  BookingDetailsAddOnsViewController.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class BookingDetailsAddOnsViewController: UIViewController {
    @IBOutlet var tblView: UITableView!
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblDiscription: UILabel!
    var onDoneBlock: ((Bool) -> Void)?

    var arrOfAddOnsData = [BookingDetailsAddOnsModel]()
    var strTitleAddonsHeader: String?
    var isCombo: Bool = false
    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.UISettings()
        addSOSButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
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

    func UISettings() {

        lblTitle.text = strTitleAddonsHeader
        lblDiscription.text = isCombo == false ? "with the selected add-ons" : ""

        tblView.register(UINib(nibName: CellIdentifier.bookingDetailsAddOnsCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.bookingDetailsAddOnsCell)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tblView.reloadData()
        }

    }
    @IBAction func clickClose(_ sender: Any) {
        onDoneBlock!(true)
        self.alertControllerBackgroundTapped()
    }

    @objc func alertControllerBackgroundTapped() {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
    }

}

extension BookingDetailsAddOnsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {

            if arrOfAddOnsData.isEmpty {
                tableView.setEmptyMessage(TableViewNoData.tableViewNoAddOnsAvailable)
                return 0
            }
            else {
                tableView.restore()
                return 1
            }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfAddOnsData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.bookingDetailsAddOnsCell, for: indexPath) as? BookingDetailsAddOnsCell else {
            return UITableViewCell()
        }
        cell.configureCell(model: arrOfAddOnsData[indexPath.row])
        cell.sepratorLine.isHidden = false
        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}

}
