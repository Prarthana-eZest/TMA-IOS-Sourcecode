//
//  LoginModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

enum LoginModule {
    // MARK: Use cases

    enum UserLogin {

        struct Request: Codable {
            let username: String
            let password: String
            let device_id: String
            let is_custom: Bool
            let accept_terms: Bool
        }
        struct Response: Codable {
            var status: Bool = false
            let authenticated_device: Bool?
            var message: String = ""
            var data: UserData?
        }

        struct UserData: Codable {
            let access_token: String?
            let refresh_token: String?
            let username: String?
            let employee_id: String?
            let firstname: String?
            let middlename: String?
            let lastname: String?
            let nickname: String?
            let employee_code: String?
            let birthdate: String?
            let designation: String?
            let base_salon_code: String?
            let base_salon_name: String?
            let salon_id: String?
            let gender: String?
            let profile_image: String?
            let rating: AnyCodable?
        }
    }

    enum AuthenticateDevice {

        struct Request: Codable {
            let employee_id: String
            let device_id: String
            let is_custom: Bool
        }
        struct Response: Codable {
            var status: Bool = false
            var message: String = ""
        }
    }
}
