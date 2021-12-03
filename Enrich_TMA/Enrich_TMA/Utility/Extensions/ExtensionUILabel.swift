//
//  ExtensionUILabel.swift
//  EnrichSalon
//
//  Created by Apple on 06/05/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

extension UILabel {
    func underlineMyText(range1: String, font: UIFont, underLineColor: UIColor = .red) {
        if let textString = self.text {
            let labelAtributes: [NSAttributedString.Key: Any]  = [
                NSAttributedString.Key.underlineColor: underLineColor,
                NSAttributedString.Key.font: font
            ]
            let underlineAttributedString = NSMutableAttributedString(string: textString,
                                                                      attributes: labelAtributes)
            let str = NSString(string: textString)
            let firstRange = str.range(of: range1)
            underlineAttributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: firstRange)
            attributedText = underlineAttributedString
        }
    }
}

extension UILabel {
    func resetServiceTime(text: String, rangeText: String) {
        let range = (text as NSString).range(of: rangeText)
        let attribute = NSMutableAttributedString(string: text)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: range)
        attribute.addAttribute(NSAttributedString.Key.font,
                               value: UIFont(name: FontName.FuturaPTDemi.rawValue,
                                             size: is_iPAD ? 24.0 : 16.0) ?? UIFont.systemFont(ofSize: is_iPAD ? 24.0 : 16.0), range: range)
        self.attributedText = attribute
    }
}
// Line Spacing Between text
extension UILabel {
    func setLineHeight(lineHeight: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.0
        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.alignment = self.textAlignment
        let attrString = NSMutableAttributedString()
        if self.attributedText != nil {
            attrString.append( self.attributedText ?? NSAttributedString(string: ""))
        }
        else {
            attrString.append( NSMutableAttributedString(string: self.text ?? ""))
            attrString.addAttribute(NSAttributedString.Key.font, value: self.font, range: NSRange(location: 0, length: attrString.length))
        }
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attrString.length))
        self.attributedText = attrString
    }
}
