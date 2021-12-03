//
//  RateTheProductModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

enum RateTheProductModule {

    enum RateTheProduct {
    struct Request: Codable {
        let is_custom: Bool = true // Custom API
        let platform: String = "mobile"
        let product_id: Int64?
        let rating: Double?
        let summary: String?
        let message: String?

    }
    struct Response: Codable {
        let status: Bool?
        let message: String?
        let data: [String]?
    }
  }
}
