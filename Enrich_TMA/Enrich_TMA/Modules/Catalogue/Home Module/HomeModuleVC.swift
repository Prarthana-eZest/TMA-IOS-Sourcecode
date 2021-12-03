//
//  HomeModuleViewController.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.

import UIKit

class HomeModuleVC: UIViewController {

    @IBOutlet weak private var tableView: UITableView!

    var sections = [SectionConfiguration]()

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetUp()
        configureSections()
        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait,
                                         andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.addCustomBackButton(title: "")
        self.view.alpha = 1.0

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: initialSetUp
    func initialSetUp() {
        tableView.register(UINib(nibName: CellIdentifier.homeHeaderCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.homeHeaderCell)
        tableView.separatorStyle = .none
        //tableView.contentInset = UIEdgeInsets(top: -45, left: 0, bottom: 0, right: 0)
        tableView.contentInsetAdjustmentBehavior = .never
    }

    // MARK: initialSetUp
    func configureSections() {
        sections.removeAll()
        sections.append(configureSection(idetifier: .homeHeader, items: 1, data: []))
        sections.append(configureSection(idetifier: .our_Products, items: 1, data: []))
        sections.append(configureSection(idetifier: .our_Services, items: 1, data: []))
        sections.append(configureSection(idetifier: .our_Packages, items: 1, data: []))

    }

    // MARK: openBookAppointment
    func openBookAppointment(HomeOrSalon: String = SalonServiceAt.Salon) {

        self.navigationController?.navigationBar.isHidden = false
        let bookAppointmentVC = BookAppointmentVC.instantiate(fromAppStoryboard: .Services)
        bookAppointmentVC.controllerToDismiss = self

        self.view.alpha = screenPopUpAlpha

        UIApplication.shared.keyWindow?.rootViewController?.present(bookAppointmentVC, animated: true, completion: {

            if HomeOrSalon == SalonServiceAt.home {
                bookAppointmentVC.clickHome(bookAppointmentVC.btnHome)
            }
            else  if HomeOrSalon == SalonServiceAt.Salon {
                bookAppointmentVC.clickSalon(bookAppointmentVC.btnSalon)
            }

        })
        bookAppointmentVC.onDoneBlock = { [unowned self] result  in
            // Do something
            if result {
                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            }
            else {}
            self.navigationController?.navigationBar.isHidden = true
            self.view.alpha = 1.0
        }
    }

    // MARK: openBookAppointment
    func openServiceCatalogue(HomeOrSalon: String = SalonServiceAt.Salon) {

        self.navigationController?.navigationBar.isHidden = false
        let selectServiceModuleViewController = SelectServiceModuleViewController.instantiate(fromAppStoryboard: .Services)
        selectServiceModuleViewController.controllerToDismiss = self

        self.view.alpha = screenPopUpAlpha
        UIApplication.shared.keyWindow?.rootViewController?.present(selectServiceModuleViewController, animated: true, completion: {

            if HomeOrSalon == SalonServiceAt.home {
                selectServiceModuleViewController.clickHome(selectServiceModuleViewController.btnHome)
            }
            else  if HomeOrSalon == SalonServiceAt.Salon {
                selectServiceModuleViewController.clickSalon(selectServiceModuleViewController.btnSalon)
            }

        })
        selectServiceModuleViewController.onDoneBlock = { [unowned self] result  in
            // Do something
            if result {
                let salonServiceModuleViewController = SalonServiceModuleViewController.instantiate(fromAppStoryboard: .Services)
                self.navigationController?.pushViewController(salonServiceModuleViewController, animated: true)
            }
            else {}
            self.navigationController?.navigationBar.isHidden = true
            self.view.alpha = 1.0
        }
    }
}

extension HomeModuleVC: ProductSelectionDelegate {

    func moveToCart(indexPath: IndexPath) {
        print("moveToCart \(indexPath)")
    }
    func actionAddOnsBundle(indexPath: IndexPath) {
        print("actionAddOnsBundle \(indexPath)")
    }

    func actionQunatity(quantity: Int, indexPath: IndexPath) {
        print("quntity:\(quantity)")
    }

    func selectedItem(indexpath: IndexPath, identifier: SectionIdentifier) {
        print("Section:\(identifier.rawValue) || item :\(indexpath.row)")

        switch identifier {
        case .always_At_Your_Service:

            switch indexpath.row {
            case 0:
                openBookAppointment()
            case 1:
                openBookAppointment(HomeOrSalon: SalonServiceAt.home)

            case 2:
                self.navigationController?.navigationBar.isHidden = false
                let productLandingModuleViewController = ProductLandingModuleViewController.instantiate(fromAppStoryboard: .Products)
                self.navigationController?.pushViewController(productLandingModuleViewController, animated: true)

            default:
                break
            }

        case .our_Products:
            self.navigationController?.navigationBar.isHidden = false
            let productLandingModuleViewController = ProductLandingModuleViewController.instantiate(fromAppStoryboard: .Products)
            self.navigationController?.pushViewController(productLandingModuleViewController, animated: true)

        case .our_Services:
            openServiceCatalogue()

        case .our_Packages:
            self.navigationController?.navigationBar.isHidden = false
            let packageListingVC = PackageListingVC.instantiate(fromAppStoryboard: .Catalogue)
            self.navigationController?.pushViewController(packageListingVC, animated: true)

        default:
            break
        }
    }

}

// MARK: HomeViewTopHeaderDelegates
extension HomeModuleVC: HomeHeaderCellDelegate {

    func bookAppointmentAction() {
        openBookAppointment()
    }
    func locationUpdateAction() {

    }
    func locationDetailViewUpdate() {

    }

}

extension HomeModuleVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let data = self.sections[indexPath.section]

        if data.identifier == .homeHeader {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.homeHeaderCell, for: indexPath) as? HomeHeaderCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.delegate = self

            return cell

        }
        else {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.productsCollectionCell, for: indexPath) as? ProductsCollectionCell else {
                return UITableViewCell()
            }
            cell.tableViewIndexPath = indexPath
            cell.selectionDelegate = self

            if data.identifier == .always_At_Your_Service {
                cell.addSectionSpacing = is_iPAD ? 12 : 8
            }
            else if data.identifier == .valuePackages {
                cell.addSectionSpacing = is_iPAD ? 12 : 8
            }
            else if data.identifier == .customer_Feedback {
                cell.addSectionSpacing = 0
                // cell.pageControl = pageControl
            }
            else {
                cell.addSectionSpacing = is_iPAD ? 25 : 15
            }
            cell.configureCollectionView(configuration: data, scrollDirection: .horizontal)
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let data = self.sections[section]

        if !data.showFooter {
            return nil
        }
        if data.isPagingEnabled {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: data.footerHeight))
            let pageControl = UIPageControl(frame: CGRect(x: view.frame.origin.x, y: 0, width: view.frame.size.width, height: data.footerHeight))
            pageControl.pageIndicatorTintColor = .lightGray
            pageControl.currentPageIndicatorTintColor = .red
            if data.identifier == .customer_Feedback {
                pageControl.numberOfPages = data.items
                pageControl.backgroundColor = UIColor(red: 0.9, green: 0.96, blue: 0.97, alpha: 1)
                view.backgroundColor = UIColor(red: 0.9, green: 0.96, blue: 0.97, alpha: 1)
            }
            // self.pageControl = pageControl

            if let cell = tableView.cellForRow(at: IndexPath(item: 0, section: section)) as? ProductsCollectionCell {
                cell.pageControl = pageControl
            }
            view.backgroundColor = UIColor.white
            view.addSubview(pageControl)
            return view
        }
        return nil

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let data = self.sections[section]
        return data.headerHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let data = self.sections[section]
        return data.footerHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = self.sections[indexPath.section]
        if data.identifier == .homeHeader ||
            data.identifier == .refer_And_Earn {
            return UITableView.automaticDimension
        }

        return data.cellHeight

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.sections[indexPath.section]
        if data.identifier == .membership {

        }
    }

}

extension HomeModuleVC {

    func configureSection(idetifier: SectionIdentifier, items: Int, data: Any) -> SectionConfiguration {

        let font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 24.0 : 16.0)

        switch idetifier {

        case .homeHeader:
            let cellWidth: CGFloat = self.tableView.frame.size.width
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0,
                                        cellWidth: cellWidth, showHeader: false, showFooter: false,
                                        headerHeight: 1, footerHeight: 0, leftMargin: 0, rightMarging: 0,
                                        isPagingEnabled: false, textFont: nil, textColor: UIColor.black,
                                        items: items, identifier: idetifier, data: data)

        case .our_Products:

            let leftMargin: CGFloat = is_iPAD ? 25 : 15
            let cellHeight: CGFloat = is_iPAD ? 220 : 180
            let cellWidth: CGFloat = self.tableView.frame.size.width - (is_iPAD ? 60 : 40)
            let headerSpace: CGFloat = is_iPAD ? 45 : 30
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: cellHeight,
                                        cellWidth: cellWidth, showHeader: false, showFooter: false,
                                        headerHeight: headerSpace, footerHeight: 0, leftMargin: leftMargin,
                                        rightMarging: 0, isPagingEnabled: false,
                                        textFont: font, textColor: .black,
                                        items: items, identifier: idetifier, data: data)

        case .our_Services:

            let leftMargin: CGFloat = is_iPAD ? 25 : 15
            let cellHeight: CGFloat = is_iPAD ? 220 : 180
            let cellWidth: CGFloat = self.tableView.frame.size.width - (is_iPAD ? 60 : 40)
            let headerSpace: CGFloat = is_iPAD ? 45 : 30
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: cellHeight,
                                        cellWidth: cellWidth, showHeader: false, showFooter: false,
                                        headerHeight: headerSpace, footerHeight: 0, leftMargin: leftMargin,
                                        rightMarging: 0, isPagingEnabled: false,
                                        textFont: font, textColor: .black, items: items, identifier: idetifier, data: data)

        case .our_Packages:

            let leftMargin: CGFloat = is_iPAD ? 25 : 15
            let cellHeight: CGFloat = is_iPAD ? 220 : 180
            let cellWidth: CGFloat = self.tableView.frame.size.width - (is_iPAD ? 60 : 40)
            let headerSpace: CGFloat = is_iPAD ? 45 : 30
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: cellHeight,
                                        cellWidth: cellWidth, showHeader: false,
                                        showFooter: false, headerHeight: headerSpace,
                                        footerHeight: 0, leftMargin: leftMargin,
                                        rightMarging: 0, isPagingEnabled: false, textFont: font,
                                        textColor: .black, items: items, identifier: idetifier, data: data)

        default :
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0,
                                        cellWidth: 0, showHeader: false, showFooter: false,
                                        headerHeight: 0, footerHeight: 0, leftMargin: 0,
                                        rightMarging: 0, isPagingEnabled: false, textFont: nil,
                                        textColor: UIColor.black, items: 0, identifier: idetifier, data: data)
        }
    }
}
