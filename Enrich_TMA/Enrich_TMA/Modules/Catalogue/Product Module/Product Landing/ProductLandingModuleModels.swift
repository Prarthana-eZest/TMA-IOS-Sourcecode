//
//  ProductLandingModuleModels.swift
//  EnrichSalon
//

import UIKit

struct ModelForProductDataUI: Codable {
    var brands: [PopularBranchModel] = []
    var banners: [BannerModel] = []
    var offers: [IrresistibleOfferModel] = []
    var trending_products: [ProductModel] = []
    var new_products: [ProductModel] = []
    var recently_viewed: [ProductModel] = []
}

enum ProductLandingModule {
  enum Something {
    struct Request: Codable {
        let category_id: String?
        let customer_id: String?
        let limit: Int64?
        var salon_id: Double?
        let is_custom: Bool = true // Custom API
        let platform: String = "mobile"

    }
    struct Response: Codable {
        let status: Bool?
        let message: String?
        let data: ProductData?
    }

    struct ResponseBlogs: Codable {
        let status: Bool?
        let message: String?
        let data: BlogsData?
    }

    struct BlogsData: Codable {
        let blogs: [Blogs]?
    }

    // MARK: - ProductData
    struct ProductData: Codable {
        let offers: [JSONAny]? // This Model Needs to be final
        let banners: [Banner]?
        let trending_products, new_products: [Product]?
        let brands: [Brand]?
        let recentlyViewedProducts: [Product]?
        let filters: [HairServiceModule.Something.Filters]

        enum CodingKeys: String, CodingKey {
            case offers, banners
            case trending_products
            case new_products
            case brands
            case recentlyViewedProducts = "recently_viewed_products"
            case filters
        }
    }

    // MARK: - Banner
    struct Banner: Codable {
        let title, desc: String?
        let image_url: String?

        enum CodingKeys: String, CodingKey {
            case title, desc
            case image_url
        }
    }

    // MARK: - Brand
    struct Brand: Codable {
        let value, label: String?
        let swatch_image_url: String?

        enum CodingKeys: String, CodingKey {
            case value, label
            case swatch_image_url
        }
    }

    // MARK: - Product
    struct Product: Codable {
        let id, name, image, sku, special_from_date, special_to_date: String?
        let price, special_price: Double?
        let total_reviews, rating_percentage: Double?
        let wishlist_flag: Bool?
        let type_id: String?
        let configurable_subproduct_options: [HairTreatmentModule.Something.Configurable_subproduct_options]?

        enum CodingKeys: String, CodingKey {
            case id, name, image, price, sku, special_to_date, special_from_date
            case special_price
            case total_reviews
            case rating_percentage
            case wishlist_flag
            case type_id
            case configurable_subproduct_options
        }
    }

    //*************** PRODUCTCATEGORY ****************
    struct ProductCategoryRequest: Codable {
        let category_id: String
        let is_custom: Bool = true // Custom API
        let platform: String = "mobile"
        let customer_id: String

    }

    struct ProductCategoryResponse: Codable {
        var status: Bool = false
        var message: String = ""
        var data: ProductCategoryModel?
    }

    struct ProductCategoryModel: Codable {
        var id: String?
        var name: String?
        var male_img: String?
        var female_img: String?
        var url: String?
        var children: [CategoryModel]?
        var gender_id: String?
        var is_combo: Bool?
        var category_type: String?
        var is_filter_available: Bool? = false
        var filters: [HairServiceModule.Something.Filters]?
        let brands: [Brand]?
    }

    struct CategoryModel: Codable {
        var id: String?
        var name: String?
        var desc: String?
        var male_img: String?
        var female_img: String?
        var category_img: String?
        var url: String?
        var is_combo: Bool?
        var filters: [HairServiceModule.Something.Filters]?
        var popular_products: [Product]?

    }

    //******************* Get insightful **********
    struct Blogs: Codable {
        let post_id: String?
        let title: String?
        let publish_time: String?
        let featured_img: String?
        let video_link: String?
    }

  }
}
