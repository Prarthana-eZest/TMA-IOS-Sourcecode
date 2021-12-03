//
//  LocationModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

enum TypeOfPlace: String, Codable {

    case home = "home"
    case workplace = "workplace"
    case other = "other"
    case blank = ""

    var imgName: String {
        return rawValue + "IconImg"
    }
}

enum LocationModule {
  // MARK: Use cases

  enum Something {
    struct Request: Codable {
        var lat: Double?
        var long: Double?
        let is_custom: Bool = true // Custom API
        var customer_id: String = ""
        let platform: String = "mobile"
        let type_of_service: String = "salon"

    }

    struct APIResponse: Codable {
        var status: Bool = false
        var message: String = ""
        var data: SalonListModel
    }

    struct SalonListModel: Codable {
        var current_city_area: String?
        var salon_list: [SalonParamModel]?
        var preferred_salon: [SalonParamModel]?
    }

    struct SalonParamModel: Codable {
        var salon_id: String?
        var salon_name: String?
        var salon_code: String?
        var status: String?
        var is_warehouse: String?
        var company_name: String?
        var address_1: String?
        var address_2: String?
        var city: String?
        var country_id: String?
        var country_code: String?
        var state_id: String?
        var state_name: String?
        var pincode: String?
        var phone_no: String?
        var alternate_phone_no: String?
        var email: String?
        var latitude: String?
        var longitude: String?
        var distance: Double? = 0
        var current_city_area: String?
        var is_preferred: Bool?
        var type: TypeOfPlace? = TypeOfPlace.other
        var other_name: String?

    }
  }
}
