//
//  ProductListingModuleModels.swift
//  EnrichSalon
//

import UIKit

// MARK: - struct - FilterKeys, ListingDataModel

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

enum ClubMembershipModule {
    // MARK: Use cases

    enum MembershipDetails {
        struct Request: Codable {
        }
        struct Response: Codable {
            let message: String?
            let status: Bool?
            let data: MembershipData?
            let previous_membership: String?

        }
        struct MembershipData: Codable {
            let id: String?
            let name: String?
            let start_date: String?
            let end_date: String?
            let no_of_addon: String?
            let description: String?
            let validity_in_days: String?
            let is_renew_period: Bool?
            let no_days_left: Int?
            let no_of_addon_added: Int?
            let offers: [String]? // This is for Frindge Benefits
            let formatted_end_date: String?
            let formatted_start_date: String?
            let is_applied_for_upgrade: Bool?

        }
    }
    enum MembershipKnowMore {
        struct Request: Codable {
            let is_custom: Bool = true
            let platform: String = "mobile"
            let membership_product_sku: String
        }
        struct Response: Codable {
            let message: String?
            let status: Bool?
            let data: MembershipData?
        }
        struct MembershipData: Codable {
            let id: String?
            let name: String?
            let description: String?
            let price: Double?
            let offers: [String]? // This is for Frindge Benefits
        }
    }

}
