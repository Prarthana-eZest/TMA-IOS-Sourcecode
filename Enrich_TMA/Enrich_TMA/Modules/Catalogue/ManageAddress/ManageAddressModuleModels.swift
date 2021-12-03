//
//  ManageAddressModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

enum ManageAddressModule {
    // MARK: Use cases

    enum DeleteAddress {
        struct Request: Codable {
        }
        struct Response: Codable {
            let status: Bool?
            let message: String?
            let data: Bool?
        }
    }

    enum CustomerInformation {
        struct Request: Codable {
            let customer_id: String
        }
    }

    enum CustomerAddress {
        struct Request: Codable {
            let customer: Customer?
            let extension_attributes: Extension_attributes?
            let custom_attributes: [Custom_attributes]?
            let referalcode: String?
            let is_custom: Bool = false // Custom API
        }

        struct Customer: Codable {
            let email: String?
            let firstname: String?
            let lastname: String?
            let confirmation: Bool? // False Means  confirmation not required for social registration (facebook and google)
            let gender: Int // 1 For Male and Two For Female
            let dob: String?
        }

        struct Response: Codable {
            let id: Int64?
            let group_id: Int64?
            let confirmation: String?
            let created_at: String?
            let updated_at: String?
            let created_in: String?
            let email: String?
            let firstname: String?
            let lastname: String?
            let dob: String?
            let gender: Int?
            let store_id: Int64?
            let website_id: Int64?
            let addresses: [Addresses]?
            let disable_auto_group_change: Int64?
            let extension_attributes: Extension_attributes?
            let custom_attributes: [Custom_attributes]?
            let message: String?
            let default_shipping: String?
            let default_billing: String?
        }

        struct Custom_attributes: Codable {
            let attribute_code: String?
            let value: AnyCodable?
        }

        struct Extension_attributes: Codable {
            let is_subscribed: Bool?
            // let access_token: String? Commented on 2 Nov 2019
            let profile_picture: String?
            let group_code: String? // Data For Type Of user MemberShip
            let referal_code: String?
        }

        struct Addresses: Codable {
            let id: Int64?
            let customer_id: Int64?
            let region: Region?
            let region_id: Int64?
            let country_id: String?
            let street: [String]?
            let telephone: String?
            let postcode: String?
            let city: String?
            let firstname: String?
            let lastname: String?
            let default_shipping: Bool?
            let default_billing: Bool?
            let custom_attributes: [Custom_attributes]?
        }

        struct Region: Codable {
            let region_code: String?
            let region: String?
            let region_id: Int?
        }
    }
}
