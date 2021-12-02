//
//  UserDefaultKeys.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/25/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation

enum UserDefauiltsKeys {

    // Login Screen keys
    static let k_Key_LoginUserOTPDetails = "k_Key_LoginUserOTPDetails" // OTP details
    static let k_Key_LoginUser = "k_Key_LoginUser" // Stores Logged In User Details
    static let k_Key_LoginUserSignIn = "k_Key_LoginUserSignIn" // Stores Logged In User AccessToken

    // Service Catalogue Keys
    static let k_Key_SelectedSalon = "k_Key_SelectedSalon" // Selected salon location
    static let k_Key_SelectedSalonAndGenderForService = "k_Key_SelectedSalonAndGenderForService" // Selected salon location And Gender For salon service booking

    static let k_Key_SelectedLocationFor = "k_Key_SelectedLocationFor" // In case value for this Key is "Any"  :-- User is coming From Home Tab for user location Or For Data Filter as per location selected
        //Incase "Salon" -- User is coming for availing any service at user selected salon
        //Incase "Home" -- User is coming for availing any service at user selected salon at Home

    static let k_key_GuestQuoteIdForCart = "k_key_GuestQuoteIdForCart"
    static let k_key_CustomerQuoteIdForCart = "k_key_CustomerQuoteIdForCart"
    
    // Service Type Selection key
    static let k_key_ServiceType = "ServiceType"
    
    // Logout
    static let lastLoginDate = "lastLoginDate" // Last login date


}
