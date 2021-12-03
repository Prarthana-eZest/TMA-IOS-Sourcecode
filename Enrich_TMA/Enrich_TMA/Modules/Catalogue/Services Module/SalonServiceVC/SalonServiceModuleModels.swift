//
//  SalonServiceModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

enum SalonServiceModule {
  // MARK: Use cases

  enum Something {
        struct Request: Codable {
            let category_id: String
            let salon_id: String
            let gender: String
            let is_custom: Bool = true // Custom API
            let platform: String = "mobile"
        }

    //*************** CATEGORY ****************
        struct Response: Codable {
            var status: Bool = false
            var message: String = ""
            var data: SalonCategoryModel?
        }

        struct SalonCategoryModel: Codable {
            var id: String?
            var name: String?
            var male_img: String?
            var female_img: String?
            var url: String?
            var category_type: String?
            var children: [CategoryModel]?
            var why_enrich: WhyEnrichModel?
            var gender_id: String?
            var is_combo: Bool?
            var is_filter_available: Bool?

        }

        struct CategoryModel: Codable {
            var id: String?
            var name: String?
            var desc: String?
            var male_img: String?
            var female_img: String?
            var url: String?
            var is_combo: Bool?
            var filters: [Filters]?

        }
    struct Filters: Codable {
        let title: String?
        var values: [Values]?
        var isParentSelected: Bool? = false

    }
    struct Values: Codable {
        let attr_code: String?
        let display: String?
        let value: AnyCodable?
        let count: String?
        var isChildSelected: Bool? = false
    }
    struct WhyEnrichModel: Codable {
        var holistic_services: String?
        var certified_professional: String?
        var latest_products: String?

    }

    //*************** TESTIMONIALS ****************
    struct TestimonialRequest: Codable {
        let limit: String
        let is_custom: Bool = true // Custom API
        let platform: String = "mobile"

    }
        struct TestimonialResponse: Codable {
            var status: Bool = false
            var message: String = ""
            var data: TestimonialData?
        }
    struct TestimonialData: Codable {
        var testimonials: [TestimonialModel]?
    }

        struct TestimonialModel: Codable {
            var title: String?
            var desc: String?
            var profile_img: String?
            var name: String?
            var id: String
        }

    }
}
