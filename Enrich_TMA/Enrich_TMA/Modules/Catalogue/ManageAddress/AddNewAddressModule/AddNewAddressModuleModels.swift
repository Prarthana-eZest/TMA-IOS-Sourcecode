//
//  AddNewAddressModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

enum AddNewAddressModule {
    // MARK: Use cases
    /// Add and Update Model for Request and Response are same
    enum AddAddress {
        struct Request: Codable {
            let address: Address?
            let is_custom: Bool = true
            let platform: String = "mobile"
        }
        struct Address: Codable {
            let customer_id: String?
            let firstname: String?
            let lastname: String?
            let street: [String]?
            let city: String?
            let telephone: Int64?
            let postcode: String?
            let region_id: Int64?
            let country_id: String?
            let default_shipping: Int?
            let default_billing: Int?
            let custom_attributes: [Custom_attributes]?
        }

        struct Response: Codable {
            let status: Bool?
            let message: String?
            let data: AddressData?
        }
        struct AddressData: Codable {
            let firstname: String?
            let lastname: String?
            let street: [String]?
            let city: String?
            let country_id: String?
            let region: Region?
            let region_id: AnyCodable?
            let postcode: String?
            let telephone: String?
            let id: Int64?
            let customer_id: String?
        }
        struct Region: Codable {
            let region: String?
            let region_code: String?
            let region_id: AnyCodable?
        }
    }
    enum UpdateAddress {
        struct Request: Codable {
            let address: UpdateAddressModel?
            let is_custom: Bool = true
            let platform: String = "mobile"
        }

        struct UpdateAddressModel: Codable {
            let id: Int64?
            let customer_id: String?
            let firstname: String?
            let lastname: String?
            let street: [String]?
            let city: String?
            let telephone: Int64?
            let postcode: String?
            let region_id: Int64?
            let country_id: String?
            let default_shipping: Int?
            let default_billing: Int?
            let custom_attributes: [Custom_attributes]?

        }

    }
    struct Custom_attributes: Codable {
        let attribute_code: String?
        let value: String?
    }
    enum GetStates {

        struct Response: Codable {
            let id: String?
            let two_letter_abbreviation: String?
            let three_letter_abbreviation: String?
            let full_name_locale: String?
            let full_name_english: String?
            let available_regions: [Available_regions]?
            let message: String?
        }
        struct Available_regions: Codable {
            let id: String?
            let code: String?
            let name: String?
        }

    }

}
