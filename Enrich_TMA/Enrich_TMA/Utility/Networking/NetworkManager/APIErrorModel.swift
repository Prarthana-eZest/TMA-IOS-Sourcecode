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
}
