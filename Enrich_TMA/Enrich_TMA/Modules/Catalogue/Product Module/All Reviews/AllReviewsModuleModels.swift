//
//  AllReviewsModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

enum AllReviewsModule {
  // MARK: Use cases

  enum Something {
    struct Request: Codable {
        let name: String
        let salary: String
        let age: String
        let id: String = "0"
    }
    struct Response: Codable {
        let name: String?
        let salary: String?
        let age: String?
        let id: String?
    }
  }
}
