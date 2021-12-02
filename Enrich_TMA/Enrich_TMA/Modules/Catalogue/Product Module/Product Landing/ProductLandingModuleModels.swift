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
            case recentlyViewedProducts
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

        enum CodingKeys: String, CodingKey {
            case id, name, image, price, sku, special_to_date, special_from_date
            case special_price
            case total_reviews
            case rating_percentage
            case wishlist_flag
            case type_id
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
