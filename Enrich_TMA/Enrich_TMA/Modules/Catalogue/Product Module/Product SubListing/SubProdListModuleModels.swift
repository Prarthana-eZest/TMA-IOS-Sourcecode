//
//  SubProdListModuleModels.swift
//  EnrichSalon
//

import UIKit

enum SubProdListModule {

    enum Categories {

        struct RequestTypes: Codable {
            let category_type: String?
            let is_custom: Bool = true // Custom API
            let platform: String = "mobile"
        }

        struct ResponseTypes: Codable {
            let status: Bool?
            let message: String?
            let data: SubCategoryType?
        }

        struct SubCategoryType: Codable {
            let category_type: String?
            let category_sub_type: [SubCatTypeModel]?
        }

        struct SubCatTypeModel: Codable {
            let label: String?
            let value: String?
            let swatch_image_url: String?
        }
    }
}
