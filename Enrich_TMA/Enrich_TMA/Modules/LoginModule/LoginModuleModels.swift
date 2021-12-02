//
//  LoginModuleModels.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

enum LoginModule {
  // MARK: Use cases

  enum UserLogin {
    
    struct Request: Codable {
        let username: String
        let password: String
        let is_custom: Bool
    }
    struct Response: Codable {
        var status: Bool = false
        var message: String = ""
        var data: UserData?
    }
    
    struct UserData: Codable {
        var access_token: String?
        var username: String?
        var admin_id: String?
        var firstname: String?
        var middlename: String?
        var lastname: String?
        var nickname: String?
        var employee_code: String?
        var birthdate: String?
        var designation: String?
        var base_salon_code: String?
        var base_salon_name: String?
    }
  }
}
