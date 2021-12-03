//
//  ExtensionTextField.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/25/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit
private var __maxLengths = [UITextField: Int]()

extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.safelyLimitedTo(length: maxLength)
    }

}
extension String {
    func safelyLimitedTo(length n: Int) -> String {
        if self.count <= n {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
}
extension UITextField {
    func setBottomBorder() {
        //self.borderStyle = .none
        //self.layer.backgroundColor = UIColor.white.cgColor

        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.white.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
        //
        //        let bottomLine = CALayer()
        //        bottomLine.frame = CGRect(origin: CGPoint(x: 0, y:self.frame.height+10), size: CGSize(width: self.frame.size.width
        //            , height:  0.5))
        //        bottomLine.backgroundColor = UIColor.white.cgColor
        //        self.layer.addSublayer(bottomLine)

    }
}
class CustomTextField: UITextField {

    var bottomBorder = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Setup Bottom-Border

        self.translatesAutoresizingMaskIntoConstraints = false

        bottomBorder = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        bottomBorder.backgroundColor = UIColor(red: 74 / 255.0, green: 74 / 255.0, blue: 74 / 255.04, alpha: 1.0) // Set Border-Color
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false

        addSubview(bottomBorder)

        bottomBorder.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomBorder.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bottomBorder.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottomBorder.heightAnchor.constraint(equalToConstant: 0.3).isActive = true // Set Border-Strength

    }
    @IBInspectable var hasError: Bool = false {
        didSet {

            if hasError {

                bottomBorder.backgroundColor = UIColor.red

            }
            else {

                bottomBorder.backgroundColor = UIColor(red: 74 / 255.0, green: 74 / 255.0, blue: 74 / 255.04, alpha: 1.0)

            }

        }
    }

    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }

    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }

    @IBInspectable var leftPadding: CGFloat = 0

    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }

    func updateView() {
        if let image = leftImage {

            leftViewMode = UITextField.ViewMode.always
            let viewObj = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            viewObj.addSubview(imageView)
            leftView = viewObj
        }
        else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }

        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: color])
    }

//    var padding: UIEdgeInsets {
//        get {
//            return UIEdgeInsets(top: 0, left: 0, bottom: paddingValue, right: 0)
//        }
//    }
//    
//    override open func textRect(forBounds bounds: CGRect) -> CGRect {
//        return bounds.inset(by: padding)
//    }
//    
//    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
//        return bounds.inset(by: padding)
//    }
//    
//    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
//        return bounds.inset(by: padding)
//    }
//    @IBInspectable var paddingValue: CGFloat = 0

}
