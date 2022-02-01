//
//  ExtentionViewcontroller.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

    func showAlert( alertTitle title: String, alertMessage msg: String ) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }

    func getAccessToken() -> String {

        if let dummy = GenericClass.sharedInstance.getUserLoggedInInfoKeyChain() {
            return dummy.access_token ?? ""
        }
        return ""
    }

    func getCustomerId() -> String {
        return "0"
    }

}

// MARK: Resign Keyboard In case touch on Screen
// How to use : Add hideKeyboardWhenTappedAround() on ViewDidLoad
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
// MARK: ADDED FOR REMOVING ANY CONTROLLER OPEN AS CONTAINER VIEW WITH NAVIGATION CONTROLLER
extension UIViewController {

    // MARK: Functions For adding any Controller in ContainerView
    func displayContentController(content: UINavigationController, selfVC: UIViewController) {
        addChild(content)
        selfVC.view.addSubview(content.view)
        content.didMove(toParent: self)
    }

    func removeChild() {
        self.children.forEach {
            $0.didMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
    }
    func isPhone(_ string: String) -> Bool {
        let result = string.isValid(regex: .phone)
        print("\(result ? "✅" : "❌") \(string) | \(string.onlyDigits()) | \(result ? "[a phone number]" : "[not a phone number]")")

        return result
    }
}

extension UIViewController {

    func addObserverForNotification(_ notificationName: Notification.Name, actionBlock: @escaping (Notification) -> Void) {
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: OperationQueue.main, using: actionBlock)
    }

    func removeObserver(_ observer: AnyObject, notificationName: Notification.Name) {
        NotificationCenter.default.removeObserver(observer, name: notificationName, object: nil)
    }
}

// MARK: - Keyboard handling
extension UIViewController {

    typealias KeyboardHeightClosure = (CGFloat) -> Void

    func addKeyboardChangeFrameObserver(willShow willShowClosure: KeyboardHeightClosure?,
                                        willHide willHideClosure: KeyboardHeightClosure?) {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil, queue: OperationQueue.main, using: { [weak self](notification) in
                                                if let userInfo = notification.userInfo,
                                                    let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
                                                    let options = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
                                                    let kFrame = self?.view.convert(frame, from: nil),
                                                    let kBounds = self?.view.bounds {

                                                    let animationType = UIView.AnimationOptions(rawValue: options)
                                                    let kHeight = kFrame.size.height
                                                    UIView.animate(withDuration: 0, delay: 0, options: animationType, animations: {
                                                        if kBounds.intersects(kFrame) { // keyboard will be shown
                                                            willShowClosure?(kHeight)
                                                        }
                                                        else { // keyboard will be hidden
                                                            willHideClosure?(kHeight)
                                                        }
                                                    }, completion: nil)

                                                }
                                                else {
                                                    print("Invalid conditions for UIKeyboardWillChangeFrameNotification")
                                                }
        })
    }

    func removeKeyboardObserver() {
        removeObserver(self, notificationName: UIResponder.keyboardWillChangeFrameNotification)
    }
}
@IBDesignable
class DesignableViewController: UIViewController {

    @IBInspectable var lightStatusBar: Bool = false

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            if lightStatusBar {
                return UIStatusBarStyle.lightContent
            }
            else {
                return UIStatusBarStyle.default
            }
        }
    }
}

// MARK: - This Added to show toast Like Android
// USAGE: showToast(controller: self, message : "This is a test", seconds: 2.0)

extension UIViewController {
    func showToast(alertTitle title: String, message: String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15

        self.present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }

    func alertForAppUpdate(alertTitle: String, messageTo: String, buttonTitleYes: String, buttonTitleNo: String, isForceUpdate: Bool, newAppLink: String) {
        let alertObj = UIAlertController(title: alertTitle, message: messageTo, preferredStyle: .alert)
        alertObj.addAction(UIAlertAction(title: buttonTitleYes, style: .default, handler: { (_) in
            // Yes

            UserDefaults.standard.removeObject(forKey: UserDefauiltsKeys.k_key_ForceUpdateNotNow)
            if let url = URL(string: newAppLink) {
                UIApplication.shared.open(url)
            }
        }))

        if isForceUpdate == false {
            alertObj.addAction(UIAlertAction(title: buttonTitleNo, style: .default, handler: { (_) in
                // No
                if UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_key_ForceUpdateNotNow) == nil {
                    let nextDate = Calendar.current.date(byAdding: .minute, value: forceUpdateNotNowDuration, to: Date())
                    print("Not Now Date\(nextDate?.dayYearMonthDateAndTime)")
                    UserDefaults.standard.set(nextDate, forKey: UserDefauiltsKeys.k_key_ForceUpdateNotNow)
                }

            }))
        }
        self.present(alertObj, animated: true, completion: nil)

    }

}

//MARK:- Graph Common Functions
extension UIViewController {
    
    func xAxisUnits(forDateRange dateRange:DateRange, rangeType: DateRangeType) -> [String] {
        switch rangeType
        {
        case .yesterday, .today, .mtd:
            return dateRange.end.endOfMonth.dayDates(from: dateRange.start.startOfMonth, withFormat: "d")
            
        case .week:
            return dateRange.end.dayDates(from: dateRange.start, withFormat: "d")
            
        case .qtd:
            if(dateRange.start.monthName == dateRange.end.monthName){
                var dateRangeUpdate = DateRange(dateRange.start, dateRange.end)
                dateRangeUpdate.end = Date.today.nextQuarter()
                return dateRangeUpdate.end.monthNames(from: dateRangeUpdate.start,withFormat: "MMM yy")
            }
            else if(dateRange.end.monthNumber(from: dateRange.start)[0] < 3){
                var dateRangeUpdate = DateRange(dateRange.start, dateRange.end)
                dateRangeUpdate.end = Date.today.showQuarterWithThreeMonths()
                return dateRangeUpdate.end.monthNames(from: dateRangeUpdate.start,withFormat: "MMM yy")
            }
            return dateRange.end.monthNames(from: dateRange.start,withFormat: "MMM yy")
            
        case .ytd:
            return dateRange.end.monthNames(from: dateRange.start,withFormat: "MMM yy")
            
        case .cutome:
            if dateRange.end.days(from: dateRange.start) > 31
            {
                return dateRange.end.monthNames(from: dateRange.start, withFormat: "MMM yy")
            }
            else {
                return dateRange.end.dayDates(from: dateRange.start, withFormat: "d")
            }
        }
    }
    
    func xAxisUnitsEarnings(forDateRange dateRange:DateRange, rangeType: DateRangeType) -> [String] {
        switch rangeType
        {
        case .yesterday, .today, .mtd:
            return dateRange.end.monthNames(from: dateRange.start,withFormat: "MMM yy")
            
        case .week:
            return dateRange.end.dayDates(from: dateRange.start, withFormat: "d")
            
        case .qtd:
            if(dateRange.start.monthName == dateRange.end.monthName){
                var dateRangeUpdate = DateRange(dateRange.start, dateRange.end)
                dateRangeUpdate.end = Date.today.nextQuarter()
                return dateRangeUpdate.end.monthNames(from: dateRangeUpdate.start,withFormat: "MMM yy")
            }
            else if(dateRange.end.monthNumber(from: dateRange.start)[0] < 3){
                var dateRangeUpdate = DateRange(dateRange.start, dateRange.end)
                dateRangeUpdate.end = Date.today.showQuarterWithThreeMonths()
                return dateRangeUpdate.end.monthNames(from: dateRangeUpdate.start,withFormat: "MMM yy")
            }
            return dateRange.end.monthNames(from: dateRange.start,withFormat: "MMM yy")
        
        case .ytd:
                return dateRange.end.monthNames(from: dateRange.start,withFormat: "MMM yy")
            
        case .cutome:
           // if dateRange.end.days(from: dateRange.start) > 31
//            {
                return dateRange.end.monthNames(from: dateRange.start, withFormat: "MMM yy")
//            }
//            else {
//                return dateRange.end.dayDates(from: dateRange.start, withFormat: "d")
//            }
        }
    }
}
