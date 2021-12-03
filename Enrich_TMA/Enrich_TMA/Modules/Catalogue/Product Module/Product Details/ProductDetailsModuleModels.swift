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

    // Use For Logged In Customer
    enum GetQuoteIDMine {
        struct Request: Codable {
            let is_custom: Bool = true // Custom API
            let platform: String = "mobile"

        }
        struct Response: Codable {
            let status: Bool?
            let message: String?
            var data: DataQuote?
        }
        struct DataQuote: Codable {
            var quote_id: Int64
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

    // Use For Logged In Mine
    enum AddBulkProductMine {
        struct Request: Codable {
            let items: [Items]?
            let quote_id: Int64?
            let is_custom: Bool = true // Custom API
            let platform: String = "mobile"
            let salon_id: Int64?

        }
        struct Items: Codable {
            let sku: String?
            let qty: Int?
            let product_option: Product_option?
            let appointment_type: String?

        }
        struct Product_option: Codable {
            let extension_attributes: Extension_attributes?
        }
        struct Extension_attributes: Codable {
            let configurable_item_options: [Configurable_item_options]?
           let bundle_options: [Bundle_options]?

        }
        struct Bundle_options: Codable {
            let option_id: Int64?
            let option_selections: [Int64]?
            let option_qty: Int64?
        }
        struct Configurable_item_options: Codable {
            let option_id: Int64?
            let option_value: Int64?
        }
        struct Response: Codable {
            let status: Bool?
            let message: String?
            let quote_id: Int64?
        }
    }

    // Use For Logged In Guest
    enum AddBulkProductGuest {
        struct Request: Codable {
            let items: [Items]?
            let quote_id: String?
            let is_custom: Bool = true // Custom API
            let platform: String = "mobile"
            let salon_id: Int64?

        }
        struct Items: Codable {
            let sku: String?
            let qty: Int?
            let product_option: Product_option?
            let appointment_type: String?
        }
        struct Product_option: Codable {
            let extension_attributes: Extension_attributes?
        }
        struct Extension_attributes: Codable {
            let configurable_item_options: [Configurable_item_options]?
           let bundle_options: [Bundle_options]?

        }
        struct Configurable_item_options: Codable {
            let option_id: Int64?
            let option_value: Int64?
        }
        struct Bundle_options: Codable {
            let option_id: Int64?
            let option_selections: [Int64]?
            let option_qty: Int64?
        }

        struct Response: Codable {
            let status: Bool?
            let message: String?
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
            let product_option: Product_option?
            let extension_attributes: Extension_attributes?
            let message: String?

        }
        struct Product_option: Codable {
            let extension_attributes: Extension_attributesConfigurable?
        }
        struct Extension_attributesConfigurable: Codable {
            let configurable_item_options: [Configurable_item_options]?
            let bundle_options: [AddBulkProductMine.Bundle_options]?

        }
        struct Configurable_item_options: Codable {
            let option_id: String?
            let option_value: Int64?
        }
        struct Extension_attributes: Codable {
            let appointment_options: [Appointment_options]?
            let image_url: String?
            let product_attribute_options: [GetAllCartsItemCustomer.ProductAttributeOption]?
            let product_category_type: String?
            let service_time: String?
            let cart_product_id: Int64?
            let salon_data: [LocationModule.Something.SalonParamModel]?
            let gender: [String]?
            let type_of_service: String?

        }
        struct Appointment_options: Codable {
            let date_time: String?
            let tehnical_id: Int64?
            let technicion_name: String?
            let salon_id: Int64?
            let estimated_time: String?
            let appointment_type: String?
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
            let product_option: Product_option?
            let extension_attributes: Extension_attributes?
            let message: String?
        }

        struct Product_option: Codable {
            let extension_attributes: Extension_attributesConfigurable?
        }

        struct Extension_attributesConfigurable: Codable {
            let configurable_item_options: [Configurable_item_options]?
            let bundle_options: [AddBulkProductMine.Bundle_options]?

        }

        struct Configurable_item_options: Codable {
            let option_id: String?
            let option_value: Int64?
        }

        struct Extension_attributes: Codable {
            let appointment_options: [Appointment_options]?
            let image_url: String?
            let product_attribute_options: [ProductAttributeOption]?
            let product_category_type: String?
            let service_time: String?
            let cart_product_id: Int64?
            let salon_data: [LocationModule.Something.SalonParamModel]?
            let gender: [String]?
            let type_of_service: String?
            let service_category_id: Int64?
        }

        struct Appointment_options: Codable {
            let date_time: String?
            let tehnical_id: Int64?
            let technicion_name: String?
            let salon_id: Int64?
            let estimated_time: String?
            let appointment_type: String?
        }

        struct ProductAttributeOption: Codable {
            let id, label, useDefault, position: String?
            let values: [Value]?
            let attributeID, attributeCode, frontendLabel, storeLabel: String?
            let options: [Option]?
            let optionID, parentID, productAttributeOptionRequired, type: String?
            let defaultTitle: AnyCodable?
            let title: String?
            let optionSelections: [OptionSelection]?

            enum CodingKeys: String, CodingKey {
                case id, label
                case useDefault = "use_default"
                case position, values
                case attributeID = "attribute_id"
                case attributeCode = "attribute_code"
                case frontendLabel = "frontend_label"
                case storeLabel = "store_label"
                case options
                case optionID = "option_id"
                case parentID = "parent_id"
                case productAttributeOptionRequired = "required"
                case type
                case defaultTitle = "default_title"
                case title
                case optionSelections = "option_selections"
            }
        }

        struct OptionSelection: Codable {
            let entityID, attributeSetID, typeID, sku: String?
            let hasOptions, requiredOptions, createdAt, updatedAt: String?
            let selectionID, optionID, parentProductID, productID: String?
            let position, isDefault, selectionPriceType, selectionPriceValue: String?
            let selectionQty, selectionCanChangeQty, productName: String?, service_time: String?

            enum CodingKeys: String, CodingKey {
                case entityID = "entity_id"
                case attributeSetID = "attribute_set_id"
                case typeID = "type_id"
                case sku
                case hasOptions = "has_options"
                case requiredOptions = "required_options"
                case createdAt = "created_at"
                case updatedAt = "updated_at"
                case selectionID = "selection_id"
                case optionID = "option_id"
                case parentProductID = "parent_product_id"
                case productID = "product_id"
                case position
                case isDefault = "is_default"
                case selectionPriceType = "selection_price_type"
                case selectionPriceValue = "selection_price_value"
                case selectionQty = "selection_qty"
                case selectionCanChangeQty = "selection_can_change_qty"
                case productName = "product_name"
                case service_time = "service_time"
            }
        }

        // MARK: - Value
        struct Value: Codable {
            let valueIndex, label, productSuperAttributeID, defaultLabel: String?
            let storeLabel: String?
            let useDefaultValue: Bool?

            enum CodingKeys: String, CodingKey {
                case valueIndex = "value_index"
                case label
                case productSuperAttributeID = "product_super_attribute_id"
                case defaultLabel = "default_label"
                case storeLabel = "store_label"
                case useDefaultValue = "use_default_value"
            }
        }

        // MARK: - Option
        struct Option: Codable {
            let value, label: String?
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

    enum FlushCart {
        struct Response: Codable {
            let status: Bool?
            let message: String?
        }
    }

}
