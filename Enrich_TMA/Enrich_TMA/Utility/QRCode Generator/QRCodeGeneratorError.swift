//
//  QRCodeGeneratorError.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/13/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

public enum QRCodeGeneratorError: CustomStringConvertible {
    case QRTextNotProvided
    case QRCodeNotCreated
    public var description: String {
        switch self {
        // Use Internationalization, as appropriate.
        case.QRTextNotProvided: return "QrCode text not provided."
        case.QRCodeNotCreated: return "QrImage not created.Please try again."
        }
    }
}
