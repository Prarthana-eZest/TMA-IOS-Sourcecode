//
//  HairServiceModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

enum HairServiceModule {
  // MARK: Use cases

    enum filtersAPI {
        struct Request: Codable {
            let category_id: Int64?
            let is_custom = true
        }

        struct Response: Codable {
            let status: Bool?
            let message: String?
            let data: ResponseFilters?
        }

        struct ResponseFilters: Codable {
            var filters: [Something.Filters]?
        }
    }

    enum Something {
        struct Request: Codable {
            let customer_id: String = ""
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
            var children: [CategoryModel]?
            var why_enrich: WhyEnrichModel?
            var gender_id: String?

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
            var title: String?
            var values: [Values]?
            var isParentSelected: Bool? = false

        }
        struct Values: Codable {
            var attr_code: String?
            var display: String?
            var value: AnyCodable?
            var count: String?
            var isChildSelected: Bool? = false
        }
        struct WhyEnrichModel: Codable {
            var holistic_services: String?
            var certified_professional: String?
            var latest_products: String?

        }

    }

    enum NewServiceCategory {
        struct Request: Codable {
            let customer_id: String?
            let category_id: String
            let salon_id: String
            let gender: String
            let is_custom: Bool = true // Custom API
            let platform: String = "mobile"
            let limit: Int64?
            let page: Int?
            let search_criteria: Search_criteria?

        }

        //*************** CATEGORY ****************
        struct Response: Codable {
            var status: Bool = false
            var message: String = ""
            var data: ServerData?
        }

        struct ServerData: Codable {
            let services: Services?
            let category: [HairServiceModule.Something.CategoryModel]?
            let filters: [HairServiceModule.Something.Filters]?

      }
        struct Services: Codable {
            let items: [HairTreatmentModule.Something.Items]?
            let total_number: Int?
            let current_page: Int?

        }

        struct Search_criteria: Codable {
               let filter_groups: [Filter_groups]?
           }
        struct Filter_groups: Codable {
               let filters: [Filters]?
               }
           struct Filters: Codable {
               let field: String?
               let value: String?
               let condition_type: String?
           }

    }
}
