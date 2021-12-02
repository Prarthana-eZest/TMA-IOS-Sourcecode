//
//  ProductListingModuleModels.swift
//  EnrichSalon
//

import UIKit

// MARK: - struct - FilterKeys, ListingDataModel
struct FilterKeys {
    let field: String?
    let value: Any?
    let type: String?
}

struct ChangedFevoProducts {
    let productId: String?
    let changedState: Bool?
}

struct ListingDataModel {
    let category_id: Int64?
    let gender: Int64?
    let salon_id: Int64?
    let brand_unit: Int64?
    let is_trending: Bool?
    let hair_type: Int64?
    let is_newArrival: Bool?
}

enum HairServiceModule {
    // MARK: Use cases
    
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
}


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
            
            //        enum CodingKeys: String, CodingKey {
            //            case attribute_code
            //            case value
            //        }
            
            //        init(from decoder: Decoder) throws {
            //            do {
            //                let container = try decoder.container(keyedBy: CodingKeys.self)
            //                attribute_code = try container.decodeIfPresent(String.self, forKey: .attribute_code)
            //
            //                if let stringProperty = try? container.decode(String.self, forKey: .value) {
            //                    value = AnyCodable(stringProperty)
            //                } else if let intProperty = try? container.decode(Int.self, forKey: .value) {
            //                    value = AnyCodable(intProperty)
            //                }
            //                else if let doubleProperty = try? container.decode(Double.self, forKey: .value) {
            //                    value = AnyCodable(doubleProperty)
            //                }
            //                else if let objectProperty = try? container.decode([String: JSONValue].self, forKey: .value) {
            //                    value = AnyCodable(objectProperty)
            //                }
            //                else if let arrayProperty = try? container.decode([JSONValue].self, forKey: .value) {
            //                    value = AnyCodable(arrayProperty)
            //                }
            //                else {
            //                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a JSON"))
            //                }
            //            }
            //        }
        }
        struct Extension_attributes: Codable {
            let website_ids: [Double]?
            // let category_links : [Category_links]?
            let stock_status: Double?
            let total_reviews: Double?
            let rating_percentage: Double?
            var wishlist_flag: Bool?
            let media_url: String?
            var configurable_subproduct_options: [Configurable_subproduct_options]?
            var bundle_product_options: [Bundle_product_options]?
            
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
            let status: Double?
            let visibility: Double?
            let type_id: String?
            let created_at: String?
            let updated_at: String?
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
            let default_title: String?
            let option_title: String?
            let attribute_id: String?
            let price: Double?
            let special_price: Double?
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
            let price_type: AnyCodable?
            let can_change_quantity: AnyCodable?
            let extension_attributes: Extension_attributeProductLink?
            var isBundleProductOptionsSelected: Bool? = false
            
        }
        struct Extension_attributeProductLink: Codable {
            let service_time: String?
            let product_id: String?
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
