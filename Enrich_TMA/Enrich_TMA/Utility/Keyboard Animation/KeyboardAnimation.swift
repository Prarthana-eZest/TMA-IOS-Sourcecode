//
//  KeyboardAnimation.swift
//  GoVida
//
//  Created by Harshal Patil on 18/04/19.
//  Copyright © 2019 e-Zest. All rights reserved.
//

import UIKit

private let SharedInstance = KeyboardAnimation()

class KeyboardAnimation: NSObject {

    fileprivate var kbHeight: CGFloat!
    fileprivate var controlFrame: CGRect! = CGRect.zero
    fileprivate var exestingInfo: Foundation.Notification!
    fileprivate var view: UIView?
    fileprivate var keyboardSize = CGRect.zero
    var extraBottomSpace: CGFloat = 0.0
    var isKeyboardOpen = false

    class var sharedInstance: KeyboardAnimation {
        return SharedInstance
    }

    func beginKeyboardObservation(_ view: UIView) {
        self.view = view
        let tap = UITapGestureRecognizer(target: self, action: #selector(KeyboardAnimation.onTap(_:)))
        //        tap.delegate = self
        tap.cancelsTouchesInView = false
        self.view?.addGestureRecognizer(tap)
        addKeyboardObserver()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func endKeyboardObservation() {
        removeKeyboardObserver()
        self.view = nil
        kbHeight = nil
        controlFrame = nil
        exestingInfo = nil
        extraBottomSpace = 0.0
    }

    fileprivate func addKeyboardObserver() {

        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardAnimation.textFieldDidBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardAnimation.textViewDidBeginEditing(_:)), name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardAnimation.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardAnimation.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    fileprivate func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc internal func onTap(_ sender: UITapGestureRecognizer) {
        if let view = view {
            let location = sender.location(in: view)
            let hitView = view.hitTest(location, with: nil)
            if hitView is UIButton {
                return
            }

            view.endEditing(true)
        }
    }

    @objc func textViewDidBeginEditing(_ notification: Foundation.Notification) {
        if let textView = notification.object as? UITextView {
            controlFrame = view?.convert(textView.frame, from: textView.superview)

            if exestingInfo != nil {
                keyboardWillShow(exestingInfo)
            }
        }
    }

    @objc func textFieldDidBeginEditing(_ notification: Foundation.Notification) {
        if let textField = notification.object as? UITextField {
            controlFrame = view?.convert(textField.frame, from: textField.superview)

            if exestingInfo != nil {
                keyboardWillShow(exestingInfo)
            }
        }
    }

    fileprivate func getControlFrame() {

        if let firstResponder = view?.firstResponder() {
            controlFrame = view?.convert(firstResponder.frame, from: firstResponder.superview)
        }
        else if controlFrame == nil {
            controlFrame = CGRect.zero
        }
    }

    @objc func keyboardWillShow(_ notification: Foundation.Notification) {

        isKeyboardOpen = true
        getControlFrame()

        exestingInfo = notification

        if let userInfo = (notification as NSNotification).userInfo {

            if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.keyboardSize = keyboardSize
                let maxY = (view?.frame.size.height ?? 0) - (keyboardSize.height + controlFrame.size.height + 5)

                if (controlFrame.origin.y + extraBottomSpace) > maxY {

                    kbHeight = (view?.frame.origin.y ?? 0) + (controlFrame.origin.y - maxY)
                    kbHeight += extraBottomSpace
                    self.animateView(true)

                }
                else {

                    self.keyboardWillHide(exestingInfo)
                }
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Foundation.Notification) {

        //        isKeyboardOpen = false
        kbHeight = abs(view?.frame.origin.y ?? 0)
        self.animateView(false)
    }

    fileprivate func animateView(_ up: Bool) {
        if (view?.frame.origin.y ?? 0) <= 0 {
            if up {
                //Get Current out of frame y position
                let absY = abs(view?.frame.origin.y ?? 0)
                //Get Max allowed size to go out of screen from current position
                let maxHeight = self.keyboardSize.height - absY
                kbHeight = (absY + kbHeight) > self.keyboardSize.height ? maxHeight : kbHeight
            }

            let movement = (up ? -kbHeight : kbHeight)
            UIView.animate(withDuration: 0.3, animations: {
                self.view?.frame = self.view?.frame.offsetBy(dx: 0, dy: movement ?? 0) ?? UIView().frame
            })
        }
    }
}
//extension KeyboardAnimation:UIGestureRecognizerDelegate {
//
//    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
//        if touch.view is UITableView {
//            return false
//        }
//        return true
//    }
//}

extension UIView {

    func firstResponder() -> UIView? {

        if self.isFirstResponder {
            return self
        }

        for view in (self.subviews.filter { $0.isFirstResponder }) {
            return view
        }
        return nil
    }
}
