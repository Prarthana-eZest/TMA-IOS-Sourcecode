//
//  BlogListingModuleModels.swift
//  EnrichSalon
//

import UIKit

enum BlogListingAPICall {

    enum categories {
        struct Request: Codable {
            let is_custom: Bool = true
            let platform: String = "mobile"
        }

        struct Response: Codable {
            let status: Bool?
            let message: String?
            let data: Categories?
        }

        struct Categories: Codable {
            let categories: [CategoriesModel]?
        }

        struct CategoriesModel: Codable {
            let id: String?
            let title: String?
        }
    }

    enum listing {

        struct Request: Codable {
            let is_custom: Bool = true
            let platform: String = "mobile"
            let category_id: String?
            let limit: Int = kProductCountPerPageForListing
            let term: String?
            let page: Int?
        }

        struct Response: Codable {
            let status: Bool?
            let message: String?
            let data: Blogs?
        }

        struct Blogs: Codable {
            let blogs: [BlogListModel]?
            let total_number: Int?
            let current_page: Int?
        }

        struct BlogListModel: Codable {
            let post_id: String?
            let title: String?
            let short_content: String?
            let publish_time: String?
            let featured_img: String?
            let video_link: String?
        }
    }
}
