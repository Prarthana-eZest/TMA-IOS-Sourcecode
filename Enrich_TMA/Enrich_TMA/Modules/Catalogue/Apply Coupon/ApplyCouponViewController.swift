//
//  ApplyCouponViewController.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 05/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class ApplyCouponViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView!

    var sections = [SectionConfiguration]()
    var onDoneBlock: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        tableView.register(UINib(nibName: "HeaderViewWithTitleCell", bundle: nil), forCellReuseIdentifier: "HeaderViewWithTitleCell")
        tableView.register(UINib(nibName: "EnterCouponCodeCell", bundle: nil), forCellReuseIdentifier: "EnterCouponCodeCell")

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.addCustomBackButton(title: "Apply Coupon")
        self.tableView.separatorColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // configureSections
        sections.removeAll()
        sections.append(configureSection(idetifier: .enterCouponCode, items: 1, data: []))
        sections.append(configureSection(idetifier: .availableCoupons, items: 5, data: []))
        tableView.reloadData()
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

extension ApplyCouponViewController: ProductSelectionDelegate {

    func actionQunatity(quantity: Int, indexPath: IndexPath) {
        print("quntity:\(quantity)")
    }

    func selectedItem(indexpath: IndexPath, identifier: SectionIdentifier) {
        print("Section:\(identifier.rawValue) || item :\(indexpath.row)")
        switch identifier {
        case .category:
            //
            break
        default:
            break
        }

    }

    func wishlistStatus(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {
        print("WishList:\(status) || \(identifier.rawValue) || item :\(indexpath.row)")
    }

    func checkBoxSelection(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {
        print("CheckBox:\(status) || \(identifier.rawValue) || item :\(indexpath.row)")
    }
}

extension ApplyCouponViewController: ApplyCouponCodeDelegate {

    func actionApplyManualCode(couponCode: String) {
        print("Code:\(couponCode)")
    }
}

extension ApplyCouponViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let data = sections[indexPath.section]

        switch data.identifier {

        case .enterCouponCode:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EnterCouponCodeCell", for: indexPath) as? EnterCouponCodeCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            return cell

        case .availableCoupons:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductsCollectionCell", for: indexPath) as? ProductsCollectionCell else {
                return UITableViewCell()
            }
            cell.tableViewIndexPath = indexPath
            cell.selectionDelegate = self
            cell.hideCheckBox = true
            cell.productCollectionView.isScrollEnabled = false
            cell.configureCollectionView(configuration: data, scrollDirection: .vertical)
            cell.selectionStyle = .none
            return cell

        default: return UITableViewCell()

        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let data = sections[indexPath.section]

        let bottomMargin: CGFloat = is_iPAD ? 15 : 10
        let margin: CGFloat = is_iPAD ? 30 : 20

        if data.identifier == .enterCouponCode {
            return UITableView.automaticDimension

        } else if data.identifier == .availableCoupons {

            if !is_iPAD {
                return (data.cellHeight + bottomMargin) * CGFloat((Int(data.items))) + margin
            } else {
                let height: CGFloat

                if data.items % 2 == 0 {
                    height = (data.cellHeight + bottomMargin) * CGFloat((Int(data.items / 2)))
                } else {
                    height = (data.cellHeight + bottomMargin) * (CGFloat((Int(data.items / 2) + 1)))
                }
                return height + margin
            }
        }

        return data.cellHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let data = self.sections[section]

        if !data.showHeader {
            return nil
        }

        guard let cell: HeaderViewWithTitleCell = tableView.dequeueReusableCell(withIdentifier: "HeaderViewWithTitleCell") as? HeaderViewWithTitleCell else {
            return UITableViewCell()
        }
        cell.titleLabel.text = data.title
        cell.viewAllButton.isHidden = true
        cell.identifier = data.identifier
        cell.backgroundColor = .white

        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let data = self.sections[section]
        return data.showHeader ? data.headerHeight : 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
    }
}

extension ApplyCouponViewController {

    func configureSection(idetifier: SectionIdentifier, items: Int, data: Any) -> SectionConfiguration {

        let headerHeight: CGFloat = is_iPAD ? 70 : 50
        let width: CGFloat = tableView.frame.size.width
        let margin: CGFloat = is_iPAD ? 25 : 15

        switch idetifier {

        case .enterCouponCode:

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: 0, showHeader: false, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: margin, rightMarging: margin, isPagingEnabled: false, textFont: nil, textColor: .black, items: items, identifier: idetifier, data: data)

        case .availableCoupons:

            let height: CGFloat = is_iPAD ? 150 : 120
            let cellWidth: CGFloat = is_iPAD ? ((tableView.frame.size.width - 75) / 2) + 10: (tableView.frame.size.width - 30)

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: height, cellWidth: cellWidth, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: margin, rightMarging: margin, isPagingEnabled: false, textFont: nil, textColor: .black, items: items, identifier: idetifier, data: data)

        default :
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: width, showHeader: false, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: false, textFont: nil, textColor: .black, items: items, identifier: idetifier, data: data)
        }
    }
}
