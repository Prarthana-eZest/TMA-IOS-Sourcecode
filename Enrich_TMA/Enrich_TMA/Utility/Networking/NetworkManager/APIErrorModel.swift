//
//  APIErrorModel.swift
//  EnrichSalon
//
//  Created by Apple on 16/04/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation

struct CustomError: Codable {
    let message: String?
    let status: Bool?
    let parameters: AccessResources?
}

struct AccessResources: Codable {
    let resources: String?
}

struct RefreshRequest: Codable {
    let access_token: String?
    let refresh_token: String?
    let is_custom: Bool = true
    let user_type: Int = 2
}

struct RefreshResponse: Codable {
    let message: String?
    let success: Bool?
    let data: RefreshResponseAT?
}

struct RefreshResponseAT: Codable {
    let access_token: String?
}
