//
//  OfferDetailVC.swift
//  EnrichSalon
//
//  Created by Mugdha Mundhe on 07/11/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit
import FirebaseAnalytics
class OfferDetailVC: UIViewController {

    @IBOutlet weak private var tblOfferDetails: UITableView!

    var modelObj: ApplyCouponModel.GetCoupons.ResponseCoupons?
    var strTitle = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        addSOSButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.navigationBar.isHidden = false
        self.title = ""
        self.navigationController?.addCustomBackButton(title: strTitle)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

extension OfferDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OfferDetailTableViewCell", for: indexPath) as? OfferDetailTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        if let model = modelObj {
            cell.btnCopyCode.isHidden = false
            cell.viewShowCode.isHidden = false
            cell.lblName.text = model.name

            if !(model.code ?? "").isEmpty {
                cell.constraintCodeHt.constant = 76
                cell.btnCopyCode.setTitle(model.code, for: .normal)
            }
            else {
                cell.constraintCodeHt.constant = 0
                cell.btnCopyCode.isHidden = true
                cell.viewShowCode.isHidden = true
            }

            if let from_time = model.from_date, !from_time.isEmpty {
                let fullDate = String(format: "%@", from_time.getFormattedDate().timeWithPeriod)
                cell.lblTimingFrom.text = fullDate
            }
            else {
                cell.stackTiming.isHidden = true
            }

            if let to_time = model.to_date, !to_time.isEmpty {
                cell.lblTimingTo.text = String(format: "%@", to_time.getFormattedDate().timeWithPeriod)
            }
            else {
                cell.stackTiming.isHidden = true
            }

            if let from_date = model.from_date, !from_date.isEmpty {
//                let fullDate = String(format: "%@ %@, %@",from_date.getFormattedDate().monthNameFirstThree,from_date.getFormattedDate().dayDateName, from_date.getFormattedDate().OnlyYear)
                let date = from_date.getFormattedDate()
                let fullDate = String(format: "%@%@ %@ %@", date.dayYearMonthDate.getFormattedDateForEditProfile().dayDateName, date.dayYearMonthDate.getFormattedDateForEditProfile().daySuffix(), date.dayYearMonthDate.getFormattedDateForEditProfile().monthNameFirstThree, date.dayYearMonthDate.getFormattedDateForEditProfile().OnlyYear)

                cell.lblValidFrom.text = fullDate
            }
            else {
                cell.stackValid.isHidden = true
            }

            if let to_date = model.to_date, !to_date.isEmpty {
//                let fullDate = String(format: "%@ %@, %@",to_date.getFormattedDate().monthNameFirstThree,to_date.getFormattedDate().dayDateName, to_date.getFormattedDate().OnlyYear)
                let date = to_date.getFormattedDate()
                let fullDate = String(format: "%@%@ %@ %@", date.dayYearMonthDate.getFormattedDateForEditProfile().dayDateName, date.dayYearMonthDate.getFormattedDateForEditProfile().daySuffix(), date.dayYearMonthDate.getFormattedDateForEditProfile().monthNameFirstThree, date.dayYearMonthDate.getFormattedDateForEditProfile().OnlyYear)

                cell.lblValidTo.text = fullDate
            }
            else {
                cell.stackValid.isHidden = true
            }

            cell.lblValidOn.text = model.days?.uppercased()

            if !(model.days ?? "").isEmpty {
                if let strDays = model.days {
                    cell.lblValidOn.text = strDays.uppercased()
                }
            }
            else {
                cell.stackValidOn.isHidden = true
            }
            cell.lblDescription.text = model.description
            cell.lblOfferDescTitle.isHidden = (model.description ?? "").isEmpty ? true : false

            cell.imgShowOffer.image = UIImage(named: "OfferImage")
            let strLink = (model.cma_banner_image ?? "")
            if !strLink.isEmpty {
                if let dict = GenericClass.sharedInstance.convertToDictionary(text: strLink),
                    let urlString = dict["url"] as? String,
                    let url = URL(string: urlString) {
                    cell.imgShowOffer.kf.setImage(with: url, placeholder: UIImage(named: "OfferImage"), options: nil, progressBlock: nil, completionHandler: nil)
                }
            }

            cell.lblHappyHours.isHidden = true
            if (model.is_happy_hour ?? "") == "1" {
                cell.lblHappyHours.isHidden = false
            }

            if let salon_data = model.salon_data, !salon_data.isEmpty {
                cell.btnStores.isHidden = false
                cell.lblStores.text = AlertMessagesToAsk.offerApplicableForSelected
            }
            else {
                cell.lblStores.text = AlertMessagesToAsk.offerApplicable
                cell.btnStores.isHidden = true

            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension OfferDetailVC: OfferDelegate {
    func openOfferStores() {
        if let model = modelObj, let salon_data = model.salon_data, !salon_data.isEmpty {
            if let customView = ShowListingView(frame: self.view.frame).loadNib() as? ShowListingView {
            customView.setupUIInit(arrShowData: salon_data, frameObj: self.view.frame)
           UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(customView)
            }
        }
        else {
            self.showToast(alertTitle: alertTitle, message: AlertMessagesToAsk.offerApplicable, seconds: toastMessageDuration)
        }
    }

    func copyCodeAction() {
        if let model = modelObj, let code = model.coupon_code {
            let pasteboard = UIPasteboard.general
            pasteboard.string = code
            showToast(alertTitle: alertTitleSuccess, message: AlertMessagesSuccess.offerCodeCopied, seconds: toastMessageDuration)
        }
    }
}
