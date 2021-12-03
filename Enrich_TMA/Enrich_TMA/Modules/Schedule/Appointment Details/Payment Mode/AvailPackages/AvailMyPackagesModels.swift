//
//  AvailMyPackagesModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.

import UIKit

enum AvailMyPackagesModule {

    enum ApplyPackages {
        struct RequestValuePackage: Codable {
            let package: ValuePackage?
            let cart_id: String
            let use_package: Int
            let packageId: Int64?
        }

        struct ValuePackage: Codable {
            let packageId: Int64?
            let packageDiscount: Double?
            let packageQty: Int64?
        }

        struct RequestServicePackage: Codable {
            let package: ServicePackage?
            let cart_id: String
            let use_package: Int
            let packageId: Int64?
        }

        struct ServicePackage: Codable {
            let packageId: Int64?
            let packageDiscount: Double?
           // let packageQty: String?
            let packageQty: [PaymentMode.MyWalletRewardPointsPackages.Discount_qty_cma]?
        }

        struct RequestRemovePackages: Codable {
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
            let applicable_packages: PaymentMode.MyWalletRewardPointsPackages.Applicable_packages?
            let is_cart_rule_applied: Bool?
            let grand_total: Double?
            let package_id_applied_to_cart: Int64?
            let multi_package_id_applied_to_cart: [Int64]?
        }
    }
    enum RemovePackages {

        struct RequestRemovePackages: Codable {
            let cart_id: String
            let use_package: Int
            let package_id: Int64?
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
            let applicable_packages: PaymentMode.MyWalletRewardPointsPackages.Applicable_packages?
            let is_cart_rule_applied: Bool?
            let grand_total: Double?
            let package_id_applied_to_cart: Int64?
            let multi_package_id_applied_to_cart: [Int64]?
        }
    }

}
