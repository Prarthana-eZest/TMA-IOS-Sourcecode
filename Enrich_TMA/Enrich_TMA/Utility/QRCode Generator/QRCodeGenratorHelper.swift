//
//  QRCodeGenratorHelper.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/13/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit
protocol QRCodeGenratorHelperDelegate: class {
    func qrCodeGenratedSuccess(_ qrImage: UIImage)
    func qrCodeGenratedError(error: String?)
}
class QRCodeGenratorHelper: NSObject {
    static var sharedInstance = QRCodeGenratorHelper()
    weak var viewController: UIViewController?
    weak var delegate: QRCodeGenratorHelperDelegate?

    func generateQRCode(from string: String?) {

        if let textData = string {
            if(textData.isEmpty) {
               delegate?.qrCodeGenratedError(error: QRCodeGeneratorError.QRTextNotProvided.description)

            } else {

                if let qrImage = genratedQRCodeImage(from: ((string?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!)) {
                    delegate?.qrCodeGenratedSuccess(qrImage)
                } else {
                    delegate?.qrCodeGenratedError(error: QRCodeGeneratorError.QRCodeNotCreated.description)

                }

            }
        }

    }

    private func genratedQRCodeImage(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}
