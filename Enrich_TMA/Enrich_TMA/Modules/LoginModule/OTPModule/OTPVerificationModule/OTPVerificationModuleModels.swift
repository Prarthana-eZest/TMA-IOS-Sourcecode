//
//  OTPVerificationModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

enum OTPVerificationModule {
    // MARK: Use cases

    enum ChangePasswordWithOTPVerification {
        struct Request: Codable {
            let username: String
            let otp: String
            let password: String
            let confirm_password: String
            let is_custom: String  = "1"
        }

        struct Response: Codable {
            //let data: Any?
            let message: String?
            let status: Bool?
        }
    }

    enum MobileNumberWithOTPVerification {
      struct Request: Codable {
          let otp: String
          let mobile_number: String
          let is_custom: Bool = true // Custom API
          let platform: String = "mobile"
          let device_id: String = GenericClass.sharedInstance.getDeviceUUID()  // Unique Device ID
          let device_notification_token: String? // Push Notification Token Needs to send in this
          let device_type: String = "ios_token"

      }
      struct Response: Codable {
          let data: ResponseData?
          let message: String?
          let status: Bool?
      }
      struct ResponseData: Codable {
          let access_token: String?
          let refresh_token: String?
          let customer_id: String?
          let first_name: String?
          let last_name: String?
          let gender: Gender?

      }
      struct Gender: Codable {
          let gender_id: String?
          let gender_name: String?
      }

    }
}
