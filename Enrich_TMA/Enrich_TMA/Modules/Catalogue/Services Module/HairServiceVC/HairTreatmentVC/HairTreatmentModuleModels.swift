//
//  HairTreatmentModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit
enum HairTreatmentModule {
  // MARK: Use cases

  enum Something {
    struct Request: Codable {
        let queryString: String
    }
    struct Response: Codable {
        var items: [Items]?
        let search_criteria: Search_criteria?
        var total_count: Int?
    }

    struct Custom_attributes: Codable {
        let attribute_code: String?
        let value: AnyCodable
        }

    struct Extension_attributes: Codable {
        //let website_ids: [Double]?
       // let category_links : [Category_links]?
        let stock_status: Double?
        let total_reviews: Double? = 0.0
        let rating_percentage: Double? = 0.0
        var wishlist_flag: Bool?
        let media_url: String?
        var configurable_subproduct_options: [Configurable_subproduct_options]?
        var bundle_product_options: [Bundle_product_options]?
        var configurable_options_info: [Configurable_Options_Info]?
        var type_of_service: String?
        var service_category_id: Int?
        let gender: [String]?

    }
    
    struct Configurable_Options_Info: Codable {
        let price: Double?
        var special_price: Double?
        let special_from_date: String?
        let special_to_date: String?
        let shades: Int?
                              
    }
    
    struct Filter_groups: Codable {
        let filters: [Filters]?
        }
    struct Filters: Codable {
        let field: String?
        let value: String?
        let condition_type: String?
    }
    struct Items: Codable {
        let id: Int64?
        let sku: String?
        let name: String?
        let link_type: String?
        let attribute_set_id: Double?
        var price: Double?
        var specialPrice: Double?
        var offerPercentage: String?
        let status: Double?
        let visibility: Double?
        let type_id: String?
        let created_at: String?
        let updated_at: String?
        let stock_status: Int64?
        var extension_attributes: Extension_attributes?
        //let product_links : [Product_links]?
        //var options : [Options]?
        let media_gallery_entries: [Media_gallery_entries]?
        //let tier_prices : [String]?
       let custom_attributes: [Custom_attributes]?
        var isItemSelected: Bool? = false
        var isWishSelected: Bool? = false
     }

    struct Media_gallery_entries: Codable {
        let id: Int?
        let media_type: String?
        let label: String?
        let position: Int?
        let disabled: Bool?
        let types: [String]?
        let file: String?
  }
    struct Configurable_subproduct_options: Codable {
        let sku: String?
        let product_id: String?
        let attribute_code: String?
        let value_index: String?
        let super_attribute_label: String?
        let default_title: AnyCodable?
        let option_title: AnyCodable?
        let attribute_id: String?
        let price: Double?
        var special_price: Double?
        let special_from_date: String?
        let special_to_date: String?
        let service_time: String?
        let swatch_option_value: String?
        var isSubProductConfigurableSelected: Bool? = false

    }
    struct Bundle_product_options: Codable {
        let option_id: Int64?
        let title: String?
        let required: Bool?
        let type: String?
        let sku: String?
        var product_links: [Product_links]?

         }
//    struct Options : Codable {
//        let product_sku : String?
//        let option_id : Double?
//        let title : String?
//        let type : String?
//        let sort_order : Double?
//        let is_require : Bool?
//        let sku : String?
//        let max_characters : Double?
//        let image_size_x : Double?
//        let image_size_y : Double?
//        var values : [Values]?
//         }
    struct Product_links: Codable {
        let id: AnyCodable?
        let sku: String?
        let option_id: Int64?
        let qty: AnyCodable?
        let position: AnyCodable?
        let is_default: AnyCodable?
        let price: Double?
        var specialPrice: Double?
        let price_type: AnyCodable?
        let can_change_quantity: AnyCodable?
        let extension_attributes: Extension_attributeProductLink?
        var isBundleProductOptionsSelected: Bool? = false

          }
     struct Extension_attributeProductLink: Codable {
        let service_time: String?
        let product_id: String?
        let type_of_service: String?
        let gender: [String]?

    }

    struct Search_criteria: Codable {
        let filter_groups: [Filter_groups]?
        let page_size: Int64?
        let current_page: Int64?
    }

    //*************** AddToWishList ****************
    struct AddToWishListRequest: Codable {
        let customer_id: String
        let is_custom: Bool = true // Custom API
        let platform: String = "mobile"
        let wishlist_item: [Wishlist_item]?

    }
    struct Wishlist_item: Codable {
        let product: Int64?
        let qty: Double?

    }
    struct AddToWishListResponse: Codable {
        var status: Bool = false
        var message: String = ""
    }

    //*************** RemoveFromWishList ****************
    struct RemoveFromWishListRequest: Codable {
        let customer_id: String
        let is_custom: Bool = true // Custom API
        let platform: String = "mobile"
        let product_id: Int64?

    }

    struct RemoveFromWishListResponse: Codable {
        var status: Bool = false
        var message: String = ""
    }

  }

 }
