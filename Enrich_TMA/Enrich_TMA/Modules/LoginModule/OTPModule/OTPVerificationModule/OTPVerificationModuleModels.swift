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

enum OTPVerificationModule
{
  // MARK: Use cases
  
  enum MobileNumberWithOTPVerification
  {
    struct Request:Codable
    {
        let otp: String
        let mobile_number: String
        let is_custom: Bool  = true // Custom API
        let platform :String = "mobile"

      
    }
    struct Response:Codable
    {
        let data: ResponseData?
        let message: String?
        let status: Bool?
    }
    struct ResponseData:Codable
    {
        let access_token: String?
        let customer_id : String?
    }
  }
}
