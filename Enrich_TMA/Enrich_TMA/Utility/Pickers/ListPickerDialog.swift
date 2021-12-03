//
//  ListPickerView.swift
//
//  Created by Harshal on 24/11/18.
//  Copyright © 2018 Harshal. All rights reserved.
//

import UIKit

private extension Selector {
    static let buttonTapped = #selector(ListPickerDialog.buttonTapped)
    static let cancelButtonTapped = #selector(ListPickerDialog.cancelButtonTapped)
    // static let deviceOrientationDidChange = #selector(DatePickerDialog.deviceOrientationDidChange)
}

open class ListPickerDialog: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    public typealias ListPickerCallback = ( String? ) -> Void

    // MARK: - Constants
    private let kDatePickerDialogDefaultButtonHeight: CGFloat = 90
    private let kDatePickerDialogDefaultButtonSpacerHeight: CGFloat = 1
    private let kDatePickerDialogCornerRadius: CGFloat = 7
    private let kDatePickerDialogDoneButtonTag: Int = 1

    // MARK: - Views
    private var dialogView: UIView!
    private var titleLabel: UILabel!
    open var listPicker: UIPickerView!
    private var cancelButton: UIButton!
    private var doneButton: UIButton!

    // MARK: - Variables
    private var defaultDate: Date?
    private var callback: ListPickerCallback?
    var showCancelButton: Bool = false
    private var sourceList: [String]?
    private var selectedItem: String?

    // MARK: - Dialog initialization
    public init(showCancelButton: Bool = true) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        self.showCancelButton = showCancelButton
        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupView() {
        self.dialogView = createContainerView()

        self.dialogView?.layer.shouldRasterize = true
        self.dialogView?.layer.rasterizationScale = UIScreen.main.scale

        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale

        self.dialogView?.layer.opacity = 0.5
        self.dialogView?.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)

        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)

        self.addSubview(self.dialogView ?? UIView())
    }

    /// Handle device orientation changes
    //    @objc func deviceOrientationDidChange(_ notification: NSNotification) {
    //        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    //        let screenSize = countScreenSize()
    //        let dialogSize = CGSize(width: 300, height: 230 + kDatePickerDialogDefaultButtonHeight + kDatePickerDialogDefaultButtonSpacerHeight)
    //        dialogView.frame = CGRect(x: (screenSize.width - dialogSize.width) / 2, y: (screenSize.height - dialogSize.height) / 2, width: dialogSize.width, height: dialogSize.height)
    //    }

    /// Create the dialog view, and animate opening the dialog
    open func show(_ title: String, sourceList: [String], doneButtonTitle: String = "Done", cancelButtonTitle: String = "Cancel", selectedItem: String, callback: @escaping ListPickerCallback) {
        self.titleLabel.text = title
        self.doneButton.setTitle(doneButtonTitle, for: .normal)

        if showCancelButton {
            self.cancelButton.setTitle(cancelButtonTitle, for: .normal)
        }
        self.callback = callback
        self.sourceList = sourceList
        self.selectedItem = selectedItem//self.sourceList?.last
        
        if let row = (self.sourceList ?? []).index(of: selectedItem) {
            self.listPicker.selectRow(row, inComponent: 0, animated: false)
        }

        if let font = UIFont(name: "SFUIDisplay-Regular", size: 15) {
            self.titleLabel.font = font
            self.doneButton.titleLabel?.font = font
            self.cancelButton.titleLabel?.font = font
        }

        /* Add dialog to main window */
        guard let appDelegate = UIApplication.shared.delegate else { fatalError() }
        guard let window = appDelegate.window else { fatalError() }
        window?.addSubview(self)
        window?.bringSubviewToFront(self)
        window?.endEditing(true)

        //   NotificationCenter.default.addObserver(self, selector: .deviceOrientationDidChange, name: NSNotification.name.UIDeviceOrientationDidChange, object: nil)

        /* Anim */
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                self.dialogView?.layer.opacity = 1
                self.dialogView?.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }
        )
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Dialog close animation then cleaning and removing the view from the parent
    private func close() {

        let currentTransform = self.dialogView.layer.transform

        let startRotation = (self.value(forKeyPath: "layer.transform.rotation.z") as? NSNumber) as? Double ?? 0.0
        let rotation = CATransform3DMakeRotation((CGFloat)(-startRotation + Double.pi * 270 / 180), 0, 0, 0)

        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        self.dialogView.layer.opacity = 1

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [],
            animations: {
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                self.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1))
                self.dialogView.layer.opacity = 0
            }) { (_) in
            for v in self.subviews {
                v.removeFromSuperview()
            }

            self.removeFromSuperview()
            self.setupView()
        }
    }

    /// Creates the container view here: create the dialog, then add the custom content and buttons
    private func createContainerView() -> UIView {
        let screenSize = countScreenSize()
        let dialogSize = CGSize(
            width: 300,
            height: 230
                + kDatePickerDialogDefaultButtonHeight
                + kDatePickerDialogDefaultButtonSpacerHeight)

        // For the black background
        self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)

        // This is the dialog's container; we attach the custom content and the buttons to this one
        let y: CGFloat = screenSize.height - dialogSize.height //(screenSize.height - dialogSize.height) / 2
        let x: CGFloat = 0.0//(screenSize.width - dialogSize.width) / 2
        let dialogContainer = UIView(frame: CGRect(x: x, y: y, width: screenSize.width, height: dialogSize.height))

        // First, we style the dialog to match the iOS8 UIAlertView >>>
        let gradient: CAGradientLayer = CAGradientLayer(layer: self.layer)
        gradient.frame = dialogContainer.bounds
        gradient.colors = [UIColor(red: 218 / 255, green: 218 / 255, blue: 218 / 255, alpha: 1).cgColor,
                           UIColor(red: 233 / 255, green: 233 / 255, blue: 233 / 255, alpha: 1).cgColor,
                           UIColor(red: 218 / 255, green: 218 / 255, blue: 218 / 255, alpha: 1).cgColor]

        let cornerRadius = kDatePickerDialogCornerRadius
        gradient.cornerRadius = cornerRadius
        dialogContainer.layer.insertSublayer(gradient, at: 0)

        dialogContainer.layer.cornerRadius = cornerRadius
        dialogContainer.layer.borderColor = UIColor(red: 198 / 255, green: 198 / 255, blue: 198 / 255, alpha: 1).cgColor
        dialogContainer.layer.borderWidth = 1
        dialogContainer.layer.shadowRadius = cornerRadius + 5
        dialogContainer.layer.shadowOpacity = 0.1
        dialogContainer.layer.shadowOffset = CGSize(width: 0 - (cornerRadius + 5) / 2, height: 0 - (cornerRadius + 5) / 2)
        dialogContainer.layer.shadowColor = UIColor.black.cgColor
        dialogContainer.layer.shadowPath = UIBezierPath(roundedRect: dialogContainer.bounds, cornerRadius: dialogContainer.layer.cornerRadius).cgPath

        // There is a line above the button
        let lineView = UIView(frame: CGRect(x: 0, y: kDatePickerDialogDefaultButtonHeight - kDatePickerDialogDefaultButtonSpacerHeight,
                                            width: dialogContainer.bounds.size.width,
                                            height: kDatePickerDialogDefaultButtonSpacerHeight))
        lineView.backgroundColor = UIColor(red: 198 / 255, green: 198 / 255, blue: 198 / 255, alpha: 1)
        dialogContainer.addSubview(lineView)

        //Title
        self.titleLabel = UILabel(frame: CGRect(x: 0, y: 10, width: screenSize.width, height: 30))
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        if let font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: is_iPAD ? 28 : 20) {
            self.titleLabel.font = font
        }
        dialogContainer.addSubview(self.titleLabel)

        self.listPicker = UIPickerView(frame: CGRect(x: 0, y: 70, width: 0, height: 0))
        self.listPicker.delegate = self
        self.listPicker.dataSource = self
        self.listPicker.autoresizingMask = .flexibleRightMargin
        self.listPicker.frame.size.width = screenSize.width
        self.listPicker.frame.size.height = 216
        self.listPicker.showsSelectionIndicator = true
        dialogContainer.addSubview(self.listPicker)

        // Add the buttons
        addButtonsToView(container: dialogContainer)

        return dialogContainer
    }

    /// Add buttons to container
    private func addButtonsToView(container: UIView) {
        var buttonWidth = container.bounds.size.width / 2

        var leftButtonFrame = CGRect(
            x: 0,
            y: 20,
            width: buttonWidth,
            height: kDatePickerDialogDefaultButtonHeight
        )
        var rightButtonFrame = CGRect(
            x: buttonWidth,
            y: 20,
            width: buttonWidth,
            height: kDatePickerDialogDefaultButtonHeight
        )
        if showCancelButton == false {
            buttonWidth = container.bounds.size.width
            leftButtonFrame = CGRect()
            rightButtonFrame = CGRect(
                x: 0,
                y: container.bounds.size.height - kDatePickerDialogDefaultButtonHeight,
                width: buttonWidth,
                height: kDatePickerDialogDefaultButtonHeight
            )
        }
        let interfaceLayoutDirection = UIApplication.shared.userInterfaceLayoutDirection
        let isLeftToRightDirection = interfaceLayoutDirection == .leftToRight

        if showCancelButton {
            self.cancelButton = UIButton(type: .custom) as UIButton
            self.cancelButton.frame = isLeftToRightDirection ? leftButtonFrame : rightButtonFrame
            self.cancelButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), for: .normal)
            self.cancelButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), for: .highlighted)
            if let font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: is_iPAD ? 25 : 18) {
                self.cancelButton.titleLabel?.font = font
            }
            self.cancelButton.layer.cornerRadius = kDatePickerDialogCornerRadius
            self.cancelButton.addTarget(self, action: .cancelButtonTapped, for: .touchUpInside)
            container.addSubview(self.cancelButton)
        }
        self.doneButton = UIButton(type: .custom) as UIButton
        self.doneButton.frame = isLeftToRightDirection ? rightButtonFrame : leftButtonFrame
        self.doneButton.tag = kDatePickerDialogDoneButtonTag
        self.doneButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), for: .normal)
        self.doneButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), for: .highlighted)
        if let font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: is_iPAD ? 25 : 18) {
            self.doneButton.titleLabel?.font = font
        }
        self.doneButton.layer.cornerRadius = kDatePickerDialogCornerRadius
        self.doneButton.addTarget(self, action: .buttonTapped, for: .touchUpInside)
        container.addSubview(self.doneButton)
    }
    @objc func cancelButtonTapped(sender: UIButton!) {
        close()
    }
    @objc func buttonTapped(sender: UIButton!) {
        self.callback?(self.selectedItem)

        close()
    }

    // MARK: - Helpers

    /// Count and return the screen's size
    func countScreenSize() -> CGSize {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height

        return CGSize(width: screenWidth, height: screenHeight)
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sourceList?.count ?? 0
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sourceList?[row]
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedItem = sourceList?[row]
    }
}
