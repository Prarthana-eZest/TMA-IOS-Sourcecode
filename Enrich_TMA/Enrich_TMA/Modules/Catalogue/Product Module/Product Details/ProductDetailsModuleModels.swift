//
//  ProductDetailsModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

enum ProductDetailsModule {
  // MARK: Use cases

//  enum RecentlyViewedProducts
//  {
//    struct Request:Codable
//    {
//        let customer_id: String
//        let limit: Int64?
//        let is_custom: Bool  = true // Custom API
//        let platform: String = "mobile"
//    }
//    struct Response:Codable
//    {
//        let status: Bool?
//        let message: String?
//        let data:[ProductLandingModule.Something.Product]?
//    }
//  }

    // Use For Logged In Customer
    enum GetQuoteIDMine {
        struct Request: Codable {
            let is_custom: Bool = true // Custom API
            let platform: String = "mobile"

        }
        struct Response: Codable {
            let status: Bool?
            let message: String?
            let data: DataQuote?
        }
        struct DataQuote: Codable {
            let quote_id: Int64
        }

    }

    // Use For Guest User
    enum GetQuoteIDGuest {
        struct Request: Codable {
            let is_custom: Bool = true // Custom API
            let platform: String = "mobile"
        }
        struct Response: Codable {
            let status: Bool?
            let message: String?
            let data: DataQuote?
        }
        struct DataQuote: Codable {
            let quote_id: String
        }
    }
    // Use For Logged In Customer
    enum AddSimpleOrVirtualProductToCartMine {
        struct Request: Codable {
            let cart_item: Cart_item?

        }
        struct Cart_item: Codable {
            let quote_id: Int64
            let sku: String
            let qty: Int
        }

        struct Response: Codable {
            let message: String?
            let item_id: Int64
            let sku: String
            let name, product_type: String?
            let qty: Int?
            let price: Double?
            let quote_id: String
        }
    }

    // Use For Guest User
    enum AddSimpleOrVirtualProductToCartGuest {
        struct Request: Codable {
            let cart_item: Cart_item?
            let salon_id: String?

        }
        struct Cart_item: Codable {
            let quote_id: String
            let sku: String?
            let qty: Int?
        }

        struct Response: Codable {
            let message: String?
            let item_id: Int64
            let sku: String
            let name, product_type: String?
            let qty: Int?
            let price: Double?
            let quote_id: String
        }
    }

    // Use For Logged In Customer/Guest Same RequestModel
    enum AddBundleProductToCartMineGuest {
        struct Request: Codable {
            let cart_item: Cart_item?
        }
        struct Cart_item: Codable {
            let quote_id: Int64
            let sku: String
            let qty: Int64
            let product_option: Product_option?
        }
        struct Product_option: Codable {
            let extension_attributes: Extension_attributes?
        }
        struct Extension_attributes: Codable {
            let bundle_options: [Bundle_options]?
        }
        struct Bundle_options: Codable {
            let option_id: Int64?
            let option_selections: [Int64]?
        }
        struct Response: Codable {
            let message: String?
            let item_id: Int64
            let sku: String
            let name, product_type: String?
            let qty: Int64?
            let price: Double?
            let quote_id: String
        }
    }

    // Use For Logged In Customer/Guest Same RequestModel
    enum AddConfigurableProductToCartMineGuest {
        struct Request: Codable {
            let cart_item: Cart_item?
        }
        struct Cart_item: Codable {
            let quote_id: Int64
            let sku: String
            let qty: Int64
            let product_option: Product_option?
        }
        struct Product_option: Codable {
            let extension_attributes: Extension_attributes?
        }
        struct Extension_attributes: Codable {
            let configurable_item_options: [Configurable_item_options]?
        }
        struct Configurable_item_options: Codable {
            let option_id: Int64?
            let option_value: Int64?
        }
        struct Response: Codable {
            let message: String?
            let item_id: Int64
            let sku: String
            let name, product_type: String?
            let qty: Int64?
            let price: Double?
            let quote_id: String
            let product_option: Product_option?
        }
    }

    // GetAllCartsItemGuest
    enum GetAllCartsItemGuest {
        struct Request: Codable {
            let quote_id: String
        }
        struct Response: Codable {
            let item_id: Int64?
            let sku: String?
            let qty: Int?
            let name: String?
            let price: Double?
            let product_type: String?
            let quote_id: String?
            let extension_attributes: Extension_attributes?
            let message: String?

        }
        struct Extension_attributes: Codable {
            let appointment_options: [Appointment_options]?
            let image_url: String?
            
        }
        struct Appointment_options: Codable {
            let date_time: String?
            let tehnical_id: Int?
            let technicion_name: String?
            let salon_id: Int?
            let estimated_time: String?
        }

    }

    // GetAllCartsItemCustomer
    // Response would be the same what we have in case of Guest
    enum GetAllCartsItemCustomer {
        struct Request: Codable {
            let accessToken: String
        }
        struct Response: Codable {
            let item_id: Int64
            let sku: String
            let qty: Int64?
            let name: String?
            let price: Double?
            let product_type: String?
            let quote_id: String?
            let extension_attributes: Extension_attributes?
            let message: String?

        }
        struct Extension_attributes: Codable {
            let appointment_options: [Appointment_options]?
            let image_url: String?

        }
        struct Appointment_options: Codable {
            let date_time: String?
            let tehnical_id: Int64?
            let technicion_name: String?
            let salon_id: Int64?
            let estimated_time: String?
        }

    }

    // MergeGuestCart:- This is only call when user is logged in
    enum MergeGuestCart {
        struct Request: Codable {
            let cartId: String // Quote_id
            let customer_id: String
            let storeId: Int64
            let is_custom: Bool = true
            let platform: String = "mobile"

        }
        struct Response: Codable {
            let status: Bool?
            let message: String?
            let data: DataResponse?
        }
        struct DataResponse: Codable {
            let result: Bool
        }

    }

}

enum ServiceDetailModule {
    // MARK: Use cases
    enum ServiceDetails {
        //*************** Service/PRODUCT Details ****************
        
        // ProductDetails Response
        struct Request: Codable {
            let requestedParameters: String
        }
        struct Response: Codable {
            let id: Int64?
            let name, type_id, created_at, updated_at: String?
            let sku: String
            let attribute_set_id, status, visibility: Int64?
            let price: Double?
            let extension_attributes: ExtensionAttributes?
            var product_links: [HairTreatmentModule.Something.Items]?
            let media_gallery_entries: [HairTreatmentModule.Something.Media_gallery_entries]?
            let custom_attributes: [HairTreatmentModule.Something.Custom_attributes]?
            
            enum CodingKeys: String, CodingKey {
                case id, sku, name
                case attribute_set_id
                case status, visibility
                case type_id
                case created_at
                case updated_at
                case extension_attributes
                case product_links
                case media_gallery_entries
                case custom_attributes
                case price
                
            }
        }
        
        // MARK: - ExtensionAttributes
        struct ExtensionAttributes: Codable {
            let website_ids: [Double]?
            let recommended_for_info, product_url: String?
            let tips_info: [TipsInfo]?
            let total_reviews, rating_percentage: Double?
            let media_url: String?
            let wishlist_flag: Bool?
            let recently_viewed_products: [ProductLandingModule.Something.Product]?
            let configurable_subproduct_options: [HairTreatmentModule.Something.Configurable_subproduct_options]?
            
            enum CodingKeys: String, CodingKey {
                case website_ids
                case recommended_for_info
                case tips_info
                case product_url
                case total_reviews
                case rating_percentage
                case media_url
                case wishlist_flag
                case recently_viewed_products
                case configurable_subproduct_options
            }
        }
        
        // MARK: - TipsInfo
        struct TipsInfo: Codable {
            let label, value: String?
        }
        
        //*************** PRODUCT REVIEWS ****************
        // MARK: - ProductReviewRequest
        
        struct ProductReviewRequest: Codable {
            let product_id: String
            let is_custom: Bool = true // Custom API
            let platform: String = "mobile"
            let limit: Int64?
            
        }
        // MARK: - ProductReviewResponse
        struct ProductReviewResponse: Codable {
            let status: Bool?
            let message: String?
            let data: DataClass?
            
            enum CodingKeys: String, CodingKey {
                case status, message
                case data
            }
        }
        // MARK: - DataClass
        struct DataClass: Codable {
            let product_review_count, product_rating_count: Int64?
            let product_rating_percentage: Double?
            let review_items: [ReviewItem]?
            let all_star_rating: [String: Int64]?
            
            enum CodingKeys: String, CodingKey {
                case review_items
                case all_star_rating
                case product_review_count
                case product_rating_percentage
                case product_rating_count
            }
        }
        
        // MARK: - ReviewItem
        struct ReviewItem: Codable {
            let review_id, created_at, title, detail, nickname, entity_code: String?
            let rating_votes: [RatingVote]?
            
            enum CodingKeys: String, CodingKey {
                case review_id
                case created_at
                case title, detail, nickname
                case entity_code
                case rating_votes
            }
        }
        // MARK: - RatingVote
        struct RatingVote: Codable {
            let vote_id, option_id, entity_pk_value, rating_id, review_id, value, rating_code, store_id: String?
            let customer_id: AnyCodable?
            let percent: Double
            
            enum CodingKeys: String, CodingKey {
                case vote_id
                case option_id
                case customer_id
                case entity_pk_value
                case rating_id
                case review_id
                case percent, value
                case rating_code
                case store_id
            }
        }
        //*************** FREQUENTLY AVAILED PRODUCTS ****************
        
        // MARK: - FrequentlyAvailedProductRequest
        
        struct FrequentlyAvailedProductRequest: Codable {
            let is_custom: Bool = true // Custom API
            let platform: String = "mobile"
            
        }
        // MARK: - FrequentlyAvailedProductResponse
        struct FrequentlyAvailedProductResponse: Codable {
            let status: Bool?
            let message: String?
            let data: DataFrequentlyClass?
            
        }
        // MARK: - DataClass
        struct DataFrequentlyClass: Codable {
            let frequently_availed: [FrequentlyAvailed]?
            
            enum CodingKeys: String, CodingKey {
                case frequently_availed
            }
        }
        
        // MARK: - FrequentlyAvailed
        struct FrequentlyAvailed: Codable {
            let id, name, sku: String?
            let image: String?
        }
        
        //*************** RATE A  SERVICES ****************
        
        // MARK: - RateAServiceRequest
        struct RateAServiceRequest: Codable {
            let customer_id: Int64
            let is_custom: Bool = true // Custom API
            let platform: String = "mobile"
            let product_id: String
            let rating: Int64
            let summary: String?
            let message: String?
            
        }
        // MARK: - RateAServiceResponse
        struct RateAServiceResponse: Codable {
            let status: Bool?
            let message: String?
            let data: [JSONAny]?
            
        }
        
    }
}

