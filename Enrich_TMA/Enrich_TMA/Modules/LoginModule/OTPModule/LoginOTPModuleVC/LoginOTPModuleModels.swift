//
//  LoginOTPModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.

import UIKit

enum LoginOTPModule {
  // MARK: Use cases

    enum OTP {
        struct Request: Codable {
            let mobile_number: String
            let is_custom: Bool = true // Custom API
            let platform: String = "mobile"

        }
        struct Response: Codable {
            let message: String?
            let data: OTPCode?
            let status: Bool?

        }
        struct OTPCode: Codable {
            let otpcode: String?
        }
    }
}
