//
//  SearchModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

enum SearchModule {
  enum ApiType {

    struct Request: Codable {
        var searchText: String?
    }
    struct GblSearchResponse: Codable {
        let status: Bool?
        let message: String?
        let data: [GblSearchModel]?
    }

//    struct GblSearchFirstModel: Codable {
//        var type: [GblSearchModel]?
//    }

    struct GblSearchModel: Codable {
        var type: String?
        var title: String?
        var image: String?
        var price: String?
        var url: String?
        var id: String?
        var sku: String?
        var type_of_product: String?
    }
  }
}
