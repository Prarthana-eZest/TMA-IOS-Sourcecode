//
//  MarkMyAddressModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

enum MarkMyAddressModule {
  // MARK: Use cases

  enum Something {
    struct Request: Codable {
        let customer_id: String
        let salon_id: String
        let type: String
        let other_name: String?
        var is_custom: Bool = true // Custom API
        let platform: String = "mobile"

    }
    struct Response: Codable {
        var status: Bool = false
        var message: String = ""
    }
  }
}
