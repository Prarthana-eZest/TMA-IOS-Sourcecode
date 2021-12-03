//
//  AddOnsModuleViewController.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class AddOnsModuleViewController: UIViewController {

    @IBOutlet var tblView: UITableView!
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblDiscription: UILabel!
    @IBOutlet weak private var btnAdd: UIButton!

    var onDoneBlock: ((Bool, [HairTreatmentModule.Something.Items]?) -> Void)?
    var serverData: [HairTreatmentModule.Something.Items] = []
    var serverDataOriginal: [HairTreatmentModule.Something.Items] = [] // This is for Incase user clicks cancel

    var cellType: String = SalonServiceTypes.configurable
    var selectedIndex: Int = 0

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.UISettings()
        //self.doSomething()

    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }

    func UISettings() {

        self.serverDataOriginal = self.serverData
        self.lblTitle.text = self.serverData[selectedIndex].name
        self.lblDiscription.text = "with the selected add-ons"
        self.cellType = self.serverData[selectedIndex].type_id ?? SalonServiceTypes.configurable

        tblView.register(UINib(nibName: CellIdentifier.serviceAddOnsMultiSelectionCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.serviceAddOnsMultiSelectionCell)

        tblView.register(UINib(nibName: CellIdentifier.serviceAddOnsRadioSelectionCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.serviceAddOnsRadioSelectionCell)
        tblView.register(UINib(nibName: CellIdentifier.serviceAddOnsMultiSelectionHeaderCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.serviceAddOnsMultiSelectionHeaderCell)

//        if self.cellType.equalsIgnoreCase(string: SalonServiceTypes.bundle.rawValue)
//        {
//            self.tblView = UITableView(frame: CGRect.zero, style: .grouped)
//
//        }
//        else
//        {
//            self.tblView = UITableView(frame: CGRect.zero, style: .plain)
//
//        }

        updateAddButtonState()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tblView.reloadData()
        }

    }
    @IBAction func clickCancel(_ sender: Any) {
        self.alertControllerBackgroundTapped()
        onDoneBlock?(false, self.serverDataOriginal)

    }

    @IBAction func clickAdd(_ sender: Any) {
        self.alertControllerBackgroundTapped()

        onDoneBlock?(true, self.serverData)

    }

    @objc func alertControllerBackgroundTapped() {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
    }
     func updateAddButtonState() {
        self.btnAdd.isSelected = false

        if self.cellType.equalsIgnoreCase(string: SalonServiceTypes.bundle) {

            if let bundle_product_options = self.serverData[selectedIndex].extension_attributes?.bundle_product_options {
                for (_, element) in bundle_product_options.enumerated() {
                    if let product_links = element.product_links {
                        for (_, element2) in product_links.enumerated() {
                            let obj = element2
                            if obj.isBundleProductOptionsSelected == true {
                                self.btnAdd.isSelected = true
                                break
                            }
                        }
                    }

                }
            }

        }
        else // Radio button
        {
            if let configurable_subproduct_options = self.serverData[selectedIndex].extension_attributes?.configurable_subproduct_options {
                for (_, element) in configurable_subproduct_options.enumerated() {
                               let obj = element
                               if obj.isSubProductConfigurableSelected == true {
                                   self.btnAdd.isSelected = true
                                   break
                               }
                           }
            }

        }

    }

    func isHavingSpecialPrice(element: HairTreatmentModule.Something.Items) -> Bool {
        var isSpecialDateInbetweenTo = false

        if let specialFrom = element.custom_attributes?.filter({ $0.attribute_code == "special_from_date" }), let strDateFrom = specialFrom.first?.value.description, !strDateFrom.isEmpty, !strDateFrom.compareIgnoringCase(find: "null") {
            let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
            let fromDateInt: Int = Int(strDateFrom.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

            if currentDateInt >= fromDateInt {
                isSpecialDateInbetweenTo = true
                if let specialTo = element.custom_attributes?.filter({ $0.attribute_code == "special_to_date" }), let strDateTo = specialTo.first?.value.description, !strDateTo.isEmpty, !strDateTo.compareIgnoringCase(find: "null") {
                    let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
                    let toDateInt: Int = Int(strDateTo.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

                    if currentDateInt <= toDateInt {
                        isSpecialDateInbetweenTo = true
                    }
                    else {
                        isSpecialDateInbetweenTo = false
                    }
                }
            }
            else {
                isSpecialDateInbetweenTo = false
            }
        }

        return isSpecialDateInbetweenTo
    }

    func calculateSpecialPriceForBundle(element: HairTreatmentModule.Something.Items, indexPath: IndexPath) -> (specialPrice: Double, offerPercentage: Double ) {

        // ****** Check for special price
        var specialPrice: Double = 0.0
        var offerPercentage: Double = 0
        let actualPrice = self.serverData[selectedIndex].extension_attributes?.bundle_product_options?[indexPath.section].product_links?[indexPath.row].price

        if let specialPriceValue = element.custom_attributes?.first(where: { $0.attribute_code == "special_price"}) {
                let responseObject = specialPriceValue.value.description
            specialPrice = (actualPrice ?? 0) * (responseObject.toDouble() ?? 0.0) / 100
            }

        if  specialPrice != 0 {
            offerPercentage = specialPrice.getPercent(price: element.price ?? 0)
            offerPercentage = offerPercentage.rounded(toPlaces: 1)

        }
        else {
            specialPrice = element.price ?? 0
        }

        return (specialPrice, offerPercentage)
    }
}

extension AddOnsModuleViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {

        if self.cellType.equalsIgnoreCase(string: SalonServiceTypes.bundle) {

            if let options = self.serverData[selectedIndex].extension_attributes?.bundle_product_options,
                options.isEmpty {
                tableView.setEmptyMessage(TableViewNoData.tableViewNoAddOnsAvailable)
                return 0
            }
            else {
                tableView.restore()
                return self.serverData[selectedIndex].extension_attributes?.bundle_product_options?.count ?? 1
            }

        }
        else // Radio button
        {

            if let options = self.serverData[selectedIndex].extension_attributes?.configurable_subproduct_options, options.isEmpty {
                tableView.setEmptyMessage(TableViewNoData.tableViewNoAddOnsAvailable)
                return 0
            }
            else {
                tableView.restore()
                return 1
            }

        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.cellType.equalsIgnoreCase(string: SalonServiceTypes.bundle) {
            return self.serverData[selectedIndex].extension_attributes?.bundle_product_options?[section].product_links?.count ?? 0

        }
        else // Radio button
        {
            return self.serverData[selectedIndex].extension_attributes?.configurable_subproduct_options?.count ?? 0

        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var returnCell = UITableViewCell()
        if self.cellType.equalsIgnoreCase(string: SalonServiceTypes.bundle) {
            returnCell = cellMulti(tableView, cellForRowAt: indexPath)

        }
        else // Radio button
        {
            returnCell = cellRadio(tableView, cellForRowAt: indexPath)

        }

        return returnCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.cellType.equalsIgnoreCase(string: SalonServiceTypes.bundle) // Multi Cell
        {

            guard let cell = tableView.cellForRow(at: indexPath) as? ServiceAddOnsMultiSelectionCell else {
                return
            }
            if cell.btnCheckUnChecked.isSelected {
                self.serverData[selectedIndex].extension_attributes?.bundle_product_options?[indexPath.section].product_links?[indexPath.row].isBundleProductOptionsSelected = false
                cell.btnCheckUnChecked.isSelected = false
            }
            else {
                self.serverData[selectedIndex].extension_attributes?.bundle_product_options?[indexPath.section].product_links?[indexPath.row].isBundleProductOptionsSelected = true
                cell.btnCheckUnChecked.isSelected = true

            }
        }
        else // Radio Cell
        {
            guard let cell = tableView.cellForRow(at: indexPath) as? ServiceAddOnsRadioSelectionCell else {
                return
            }

            if let configurable_subproduct_options = self.serverData[selectedIndex].extension_attributes?.configurable_subproduct_options {
                    for (index, _) in configurable_subproduct_options.enumerated() {
                        self.serverData[selectedIndex].extension_attributes?.configurable_subproduct_options?[index].isSubProductConfigurableSelected = false
                               }
            }

            self.serverData[selectedIndex].extension_attributes?.configurable_subproduct_options?[indexPath.row].isSubProductConfigurableSelected = true

            cell.btnCheckUnChecked.isSelected = true

        }
        updateAddButtonState()
        tableView.reloadData()

    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.cellType.equalsIgnoreCase(string: SalonServiceTypes.bundle) {
    let model = self.serverData[selectedIndex].extension_attributes?.bundle_product_options?[section]
        return model?.title
             }
        return ""
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.contentView.backgroundColor = UIColor.white
    }

    // Bundle Cell
    func cellMulti(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.serviceAddOnsMultiSelectionCell, for: indexPath) as? ServiceAddOnsMultiSelectionCell  else {
            return UITableViewCell()
        }
        cell.sepratorLine.isHidden = false
        cell.lblOldPrice.isHidden = true

        let model = self.serverData[selectedIndex].extension_attributes?.bundle_product_options?[indexPath.section].product_links?[indexPath.row]

        let doubleVal: Double = (model?.extension_attributes?.service_time?.toDouble() ?? 0 ) * 60

        cell.lblTitle.text = String(format: "%@ (%@)", model?.sku ?? "", doubleVal.asString(style: .brief))
        cell.lblPrice.text = String(format: " ₹ %@", model?.price?.cleanForPrice ?? "0")

        // ****** Check for special price
         let modelObj = self.serverData[selectedIndex]
            cell.lblOldPrice.isHidden = self.isHavingSpecialPrice(element: modelObj) ? false : true
            let isHavingSpecialPrice = cell.lblOldPrice.isHidden ? false : true

            if isHavingSpecialPrice {
                let specialPriceobj = self.calculateSpecialPriceForBundle(element: modelObj, indexPath: indexPath)
                self.serverData[selectedIndex].extension_attributes?.bundle_product_options?[indexPath.section].product_links?[indexPath.row].specialPrice = specialPriceobj.specialPrice

                let strPrice = String(format: " ₹ %@", model?.price?.cleanForPrice ?? "0")
                let strSpecialPrice = String(format: " ₹ %@", specialPriceobj.specialPrice.cleanForPrice )

                let attributeString = NSMutableAttributedString(string: "")
                attributeString.append(strPrice.strikeThrough())
                cell.lblOldPrice.attributedText = attributeString

                cell.lblPrice.text = strSpecialPrice

                if model?.price == specialPriceobj.specialPrice {
                    cell.lblOldPrice.isHidden = true
                    self.serverData[selectedIndex].extension_attributes?.bundle_product_options?[indexPath.section].product_links?[indexPath.row].specialPrice = 0

                }

            }

        // ****** Check for special price

        if (model?.isBundleProductOptionsSelected ?? false)! {
            cell.btnCheckUnChecked.isSelected = true
        }
        else {
            cell.btnCheckUnChecked.isSelected = false
        }

        cell.lblTitle.font = (model?.isBundleProductOptionsSelected ?? false)! ? UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 24.0 : 16.0)!: UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 24.0 : 16.0)!
        cell.lblPrice.font = (model?.isBundleProductOptionsSelected ?? false)! ? UIFont(name: FontName.NotoSansSemiBold.rawValue, size: is_iPAD ? 24.0 : 16.0)!: UIFont(name: FontName.NotoSansRegular.rawValue, size: is_iPAD ? 24.0 : 16.0)!

        if indexPath.row == tableView.lastIndexpath().row {
            cell.sepratorLine.isHidden = true
        }
        return cell
    }

    // radio - configrable
    func cellRadio(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.serviceAddOnsRadioSelectionCell, for: indexPath) as? ServiceAddOnsRadioSelectionCell else {
            return UITableViewCell()
        }
        cell.sepratorLine.isHidden = false
        cell.lblOldPrice.isHidden = true

        if let model = self.serverData[selectedIndex].extension_attributes?.configurable_subproduct_options?[indexPath.row] {
            let doubleVal: Double = (model.service_time?.toDouble() ?? 0 ) * 60

            var strTitle = ""
            if let title = model.option_title {
                strTitle = title.description
            }
             cell.lblTitle.text = String(format: "%@ (%@)", strTitle, doubleVal.asString(style: .brief))

            cell.lblPrice.text = String(format: " ₹ %@", model.price?.cleanForPrice ?? "0")
            if (model.isSubProductConfigurableSelected ?? false)! {
                cell.btnCheckUnChecked.isSelected = true
            }
            else {
                cell.btnCheckUnChecked.isSelected = false
            }
            cell.lblTitle.font = (model.isSubProductConfigurableSelected ?? false)! ? UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 24.0 : 16.0)!: UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 24.0 : 16.0)!
            cell.lblPrice.font = (model.isSubProductConfigurableSelected ?? false)! ? UIFont(name: FontName.NotoSansSemiBold.rawValue, size: is_iPAD ? 24.0 : 16.0)!: UIFont(name: FontName.NotoSansRegular.rawValue, size: is_iPAD ? 24.0 : 16.0)!

            // ****** Check for special price
             let specialPriceobj = GenericClass.sharedInstance.calculateSpecialPriceForConfigurable(element: model)
                cell.lblOldPrice.isHidden = specialPriceobj.isHavingSpecialPrice ? false : true
                let isHavingSpecialPrice = cell.lblOldPrice.isHidden ? false : true

                if isHavingSpecialPrice {
                    self.serverData[selectedIndex].extension_attributes?.configurable_subproduct_options?[indexPath.row].special_price = specialPriceobj.specialPrice

                    let strPrice = String(format: " ₹ %@", model.price?.cleanForPrice ?? "0")
                    let strSpecialPrice = String(format: " ₹ %@", specialPriceobj.specialPrice.cleanForPrice )

                    let attributeString = NSMutableAttributedString(string: "")
                    attributeString.append(strPrice.strikeThrough())
                    cell.lblOldPrice.attributedText = attributeString

                    cell.lblPrice.text = strSpecialPrice
                }
        }
        return cell
    }
}
