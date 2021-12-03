//
//  PaymentModeModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

enum PaymentMode {

    enum OfflinePayment {

        struct Request: Codable {
            let data: RequestData
        }
        struct RequestData: Codable {
            let cash_payment: String
            let card_payments: [CardPayments]
            let other_payments: [OtherPayments]
            let quote_id: String
            let status_change_cash: Bool
        }
        
        struct CardPayments: Codable {
            let card_payment: String?
            let card_details: String?
            let card_payment_method: String?
        }
        
        struct OtherPayments: Codable {
            let other_payment: String?
            let other_payment_method: String?
            let other_payment_details: String?
        }
      
        struct Response: Codable {
            var status: Bool = false
            var message: String = ""
            let data: ResponseData?
        }

        struct ResponseData: Codable {
            let cash: PaymentDetails?
            let card_payment: [PaymentDetails]?
            let others: [PaymentDetails]?
            let paid_amount: AnyCodable?
            let remaining_amount: AnyCodable?
            let payment_completed: AnyCodable?
            let change_cash: AnyCodable?
        }
        
        struct PaymentDetails: Codable {
            let use: Int?
            let amount: String?
            let method: String?
            let details: String?
        }
    }

    enum SubmitDetails {

        struct Request: Codable {
            let is_custom: String
            let pos_request: String
            let customer_id: String
            let appointment_id: String
            let platform: String
            let salon_id: String
            let quoteId: String
        }

        struct Response: Codable {
            var status: Bool?
            var message: String = ""
            var data: Data?
        }

        struct Data: Codable {
            var order_id: String?
            var order_increment_id: String?
        }

    }

    enum MyWalletRewardPointsPackages {

        struct Response: Codable {
            let status: Bool?
            let message: String?
            let data: MyWalletRewardPointsPackagesData?
        }
        struct MyWalletRewardPointsPackagesData: Codable {
            let magento_totals: [Magento_totals]?
            let paid_amount: AnyCodable?
            let remaining_amount: AnyCodable?
            let payment_completed: AnyCodable?
            let reward_points: Double?
            let wallet_balance: Double?
            let applicable_packages: Applicable_packages?
            let package_id_applied_to_cart: Int64?
            let wallet_balance_applied_to_cart: Double?
            let rewars_points_applied_to_cart: Double?
            let spend_points_formated: String?
            let is_cart_rule_applied: Bool?
            let coupon_code: String?
            let is_giftcard_applied: Bool?
            let gift_card: String?
            let multi_package_id_applied_to_cart: [Int64]?
            let card_payment_methods: [String]?
            let other_payment_methods: [String]?
        }

        struct Applicable_packages: Codable {
            let Value: [Value]?
            let Service: [Service]?
        }
        struct Value: Codable {
            let package_id: Int64?
            let parent_product_id: String?
            let child_product_id: String?
            let product_name: String?
            let discount_qty: String?
            let discount_price: Double?
            let discount_price_to_be_use: Double?
            let package_price: Double?
            let package_type: String?
            let expiry_at: String?
            let package_type_cma: Int?
            var isSelected: Bool? = false
        }
        struct Service: Codable {
            let package_id: Int64?
            let parent_product_id: String?
            let child_product_id: String?
            let product_name: String?
            let child_product_name: String?
            let balanced_qty: AnyCodable?
            let package_type: String?
            let expiry_at: String?
            let discount_price: Double?
            let discount_price_to_be_use: Double?
            let package_price: Double
            let discount_qty: String?
            let remaining_service: AnyCodable?
            let remaining_service_cma: [Remaining_service_cma]?
            let discount_qty_cma: [Discount_qty_cma]?
            var isSelected: Bool? = false

        }
        struct Remaining_service_cma: Codable {
            let qty: Int?
            let name: String?
        }
        
        struct Discount_qty_cma: Codable {
            let qty: Int?
            let product_id: Int64?
            let price: Double?
        }
    }

    enum RedeemPointOrNot {

        struct Request: Codable {
            let points: String
            let pos_request: String
            let is_custom: String
            let quote_id: String
        }

        struct Response: Codable {
            let status: Bool?
            let message: String?
            let data: totalData?
        }

        struct totalData: Codable {
            let totals_html: Totals_html?
            let paid_amount: AnyCodable?
            let remaining_amount: AnyCodable?
            let payment_completed: AnyCodable?
        }

    }

    enum ApplyWalletCashOrNot {

        struct Request: Codable {
            let cart_item: Cart_item?
            let amount: Int?

        }
        struct Cart_item: Codable {
            let quote_id: String?//Int64?
            let wallet_status: Int?
        }

        struct Response: Codable {
            let status: Bool?
            let message: String?
            let data: totalData?
        }

        struct totalData: Codable {
            let totals_html: Totals_html?
            let paid_amount: AnyCodable?
            let remaining_amount: AnyCodable?
            let payment_completed: AnyCodable?
        }
    }

    enum ApplyGiftCard {

        struct Request: Codable {
            let giftcard: String
            let quote_id: String
        }

        struct Response: Codable {
            let status: Bool?
            let message: String?
            let data: totalData?
        }

        struct totalData: Codable {
            let totals_html: Totals_html?
            let paid_amount: AnyCodable?
            let remaining_amount: AnyCodable?
            let payment_completed: AnyCodable?
        }

    }

    enum ApplyCoupon {

        struct Request: Codable {
            let coupon: String
            let is_custom: String
            let pos_request: String
            let quote_id: String
        }

        struct Response: Codable {
            let status: Bool?
            let message: String?
            let data: totalData?
        }

        struct totalData: Codable {
            let totals_html: Totals_html?
            let paid_amount: AnyCodable?
            let remaining_amount: AnyCodable?
            let payment_completed: AnyCodable?
        }
    }

}
