//
//  FilterServicesModuleViewController.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class FilterServicesModuleViewController: UIViewController {

    @IBOutlet weak private var tblViewLeft: UITableView!
    @IBOutlet weak private var tblViewRight: UITableView!
    @IBOutlet weak private var viewFirst: UIView!
    //    var objectHeader = SalonServiceModule.Something.SalonCategoryModel()
    var arrfiltersServerDataLeftTableView  = [HairServiceModule.Something.Filters]()
    var arrfitersPassServerData = [HairServiceModule.Something.Filters]()
    var indexOfLeftTableSelected: Int = 0
    var isFiltersClear: Bool = false
    var onDoneBlock: ((Bool, [HairServiceModule.Something.Filters], Bool) -> Void)?
    // MARK: Object lifecycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        UISettings()
        if !self.arrfiltersServerDataLeftTableView.isEmpty {
            self.refreshTableOnFirstLaunch()

        }
        else {
            getFilterData()
        }
        addSOSButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.addCustomBackButton(title: "")

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

        tblViewLeft.register(UINib(nibName: CellIdentifier.filtersLeftTableViewCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.filtersLeftTableViewCell)

        tblViewRight.register(UINib(nibName: CellIdentifier.filterRightTableViewCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.filterRightTableViewCell)

    }

    @IBAction func clickClearAll(_ sender: Any) {
        isFiltersClear = true
        self.indexOfLeftTableSelected = 0
        for (index1, _) in self.arrfiltersServerDataLeftTableView.enumerated() {
            self.arrfiltersServerDataLeftTableView[index1].isParentSelected = false
            for (index2, _) in (self.arrfiltersServerDataLeftTableView[index1].values?.enumerated())! {
                self.arrfiltersServerDataLeftTableView[index1].values?[index2].isChildSelected = false
            }
        }
        self.refreshTableOnFirstLaunch()

    }

    @IBAction func clickClose(_ sender: Any) {
        self.alertControllerBackgroundTapped()
        isFiltersClear = isFilterApplied()
        onDoneBlock!(false, self.arrfiltersServerDataLeftTableView, isFiltersClear)

    }

    @IBAction func clickApply(_ sender: Any) {

        self.alertControllerBackgroundTapped()
        isFiltersClear = isFilterApplied()
        onDoneBlock!(true, self.arrfiltersServerDataLeftTableView, isFiltersClear)

    }

    @objc func alertControllerBackgroundTapped() {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
    }

    func isFilterApplied() -> Bool {
        var isApplied: Bool = true
        for (index1, _) in self.arrfiltersServerDataLeftTableView.enumerated() {
            for (_, element) in (self.arrfiltersServerDataLeftTableView[index1].values?.enumerated())! {
                let obj = element
                if obj.isChildSelected == true {
                    isApplied = false
                    break
                }
            }
        }
        return isApplied
    }

}

extension FilterServicesModuleViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblViewLeft {
            return self.arrfiltersServerDataLeftTableView.count
        }
        else if tableView == tblViewRight {
            return self.arrfiltersServerDataLeftTableView[indexOfLeftTableSelected].values?.count ?? 0
        }
        return 0

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var returnCell = UITableViewCell()
        if tableView == tblViewLeft {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.filtersLeftTableViewCell, for: indexPath) as? FiltersLeftTableViewCell else {
                return UITableViewCell()
            }

            let model: HairServiceModule.Something.Filters = self.arrfiltersServerDataLeftTableView[indexPath.row]
            cell.lblTitle.text = model.title ?? "NA"
            tableView.separatorStyle = .singleLine

            if model.isParentSelected == true {

                cell.contentView.backgroundColor = .white
            }
            else {
                cell.contentView.backgroundColor = UIColor(red: 248 / 255, green: 248 / 255, blue: 248 / 255, alpha: 1.0)
            }

            if let isParent = model.isParentSelected {
                cell.lblTitle.font = isParent ? UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 24.0 : 16.0)!: UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 24.0 : 16.0)!
            }
            if tableView.numberOfRows(inSection: indexPath.section) - 1 == indexPath.row {
                tableView.separatorStyle = .none
            }

            returnCell = cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.filterRightTableViewCell, for: indexPath) as? FilterRightTableViewCell else {
                return UITableViewCell()
            }
            let model: HairServiceModule.Something.Values = (self.arrfiltersServerDataLeftTableView[indexOfLeftTableSelected].values?[indexPath.row])!
            cell.lblTitle.text = model.display ?? "NA"
            tableView.separatorStyle = .singleLine

            if let objectBtn: Bool = model.isChildSelected, objectBtn == true {
                cell.btnCheckUnChecked.isSelected = true
                cell.lblTitle.font = UIFont(name: FontName.NotoSansSemiBold.rawValue, size: is_iPAD ? 24.0 : 16.0)!
            }
            else {
                cell.btnCheckUnChecked.isSelected = false
                cell.lblTitle.font = UIFont(name: FontName.NotoSansRegular.rawValue, size: is_iPAD ? 24.0 : 16.0)!

            }
            if tableView.numberOfRows(inSection: indexPath.section) - 1 == indexPath.row {
                tableView.separatorStyle = .none
            }

            returnCell = cell
        }
        return returnCell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblViewLeft {
            for (index, _) in self.arrfiltersServerDataLeftTableView.enumerated() {
                self.arrfiltersServerDataLeftTableView[index].isParentSelected = false
            }
            self.arrfiltersServerDataLeftTableView[indexPath.row].isParentSelected = true

            DispatchQueue.main.async {
                self.tblViewLeft.reloadData()
                DispatchQueue.main.async {
                    self.indexOfLeftTableSelected = indexPath.row
                    self.tblViewRight.reloadData()

                }
            }
        }
        else // Right Table View
        {
            if let cell = tableView.cellForRow(at: indexPath) as? FilterRightTableViewCell {
                if cell.btnCheckUnChecked.isSelected {
                    self.arrfiltersServerDataLeftTableView[indexOfLeftTableSelected].values?[indexPath.row].isChildSelected = false
                    cell.btnCheckUnChecked.isSelected = false
                }
                else {
                    self.arrfiltersServerDataLeftTableView[indexOfLeftTableSelected].values?[indexPath.row].isChildSelected = true
                    cell.btnCheckUnChecked.isSelected = true

                }
                self.tblViewRight.reloadData()
            }

        }
    }
}

extension FilterServicesModuleViewController {
    func getFilterData() {
        self.arrfiltersServerDataLeftTableView = arrfitersPassServerData
        if !self.arrfiltersServerDataLeftTableView.isEmpty {
            self.refreshTableOnFirstLaunch()
        }
    }

}

// MARK: Left Table View Delegates
// extension FilterServicesModuleViewController:FiltersLeftCellDelegate{
// func selectedOptionLeftTable(indexPath: Int, tableViewCell: UITableViewCell) {
// print("selectedOption Left Table \(indexPath)")
// //        self.arrfiltersServerDataRightTableView = self.arrfiltersServerDataLeftTableView[indexPath].values ?? []
// //        self.arrfiltersServerDataLeftTableView[indexOfOldLeftTableSelected].isParentSelected = false
//
// }
// }
// MARK: Right Table View Delegates
// extension FilterServicesModuleViewController:FilterRightCellDelegate{
//
// func selectedOptionRightTable(indexPath: Int, tableViewCell: UITableViewCell) {
// print("selectedOption Right Table \(indexPath)")
// let cell = tableViewCell as! FilterRightTableViewCell
// if(cell.btnCheckUnChecked.isSelected) {
// self.arrfiltersServerDataLeftTableView[indexOfLeftTableSelected].values?[indexPath].isChildSelected = true
// } else {
// self.arrfiltersServerDataLeftTableView[indexOfLeftTableSelected].values?[indexPath].isChildSelected = false
//
// }
// self.tblViewRight.reloadData()
//
// }
// }
// MARK: Save Data What filters user has selected
extension FilterServicesModuleViewController {

    func refreshTableOnFirstLaunch() {
        self.tblViewLeft.delegate = self
        self.tblViewLeft.dataSource = self
        self.tblViewRight.delegate = self
        self.tblViewRight.dataSource = self
        let indexPath = IndexPath(row: 0, section: 0)
        self.tblViewLeft.selectRow(at: indexPath, animated: false, scrollPosition: .top)
        self.tblViewLeft.delegate?.tableView!(self.tblViewLeft, didSelectRowAt: indexPath)
    }

}
