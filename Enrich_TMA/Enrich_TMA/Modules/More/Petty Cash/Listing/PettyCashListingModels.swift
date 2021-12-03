//
//  PettyCashListingModels.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 27/11/19.
//  Copyright (c) 2019 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

enum PettyCashListing {
    // MARK: Use cases

    enum GetHistory {

        struct Request: Codable {
            let salon_id: String
            let technician_id: String
        }

        struct Response: Codable {
            var status: Bool = false
            var message: String = ""
            var data: Data?
        }

        struct Data: Codable {
            var pettycash_history: [HistoryRecord]?
            var total_amount: Double?
            var format_total_amount: String?
        }

        struct HistoryRecord: Codable {
            let id: String?
            let purpose: String?
            let technician_id: String?
            let technician_name: String?
            let created_at: String?
            let action: String?
            let amount: Double?
            let format_amount: String?
            let attachment: String?
            let current_status: String?
        }

    }
}