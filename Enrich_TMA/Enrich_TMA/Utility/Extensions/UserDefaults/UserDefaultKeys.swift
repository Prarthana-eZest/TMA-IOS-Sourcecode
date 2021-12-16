//
//  UserDefaultKeys.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/25/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation

enum UserDefauiltsKeys {

    // On Boarding keys
    static let k_Key_OnBoardingDone = "k_Key_OnBoardingDone"

    // Login Screen keys
    static let k_Key_LoginUser = "k_Key_LoginUser" // Stores Logged In User Details
    static let k_Key_LoginUserSignIn = "k_Key_LoginUserSignIn" // Stores Logged In User AccessToken
    static let k_Key_LoginUserOTPDetails = "k_Key_LoginUserOTPDetails" // OTP Store Locally when user logingOrSignUp

    // Service Catalogue Keys
    static let k_Key_SelectedSalon = "k_Key_SelectedSalon" // Selected salon location
    static let k_Key_SelectedSalonAndGenderForService = "k_Key_SelectedSalonAndGenderForService" // Selected salon location And Gender For salon service booking

    static let k_Key_SelectedLocationFor = "k_Key_SelectedLocationFor" // In case value for this Key is "Any"  :-- User is coming From Home Tab for user location Or For Data Filter as per location selected
    //Incase "Salon" -- User is coming for availing any service at user selected salon
    //Incase "Home" -- User is coming for availing any service at user selected salon at Home

    static let k_key_GuestQuoteIdForCart = "k_key_GuestQuoteIdForCart"
    static let k_key_CustomerQuoteIdForCart = "k_key_CustomerQuoteIdForCart"

    static let k_Key_LoginUserMembershipDetails = "k_Key_LoginUserMembershipDetails" // Membership Tab in More tab

    static let k_key_CustomAttributeData = "k_key_CustomAttributeData"
    static let k_key_FCM_PushNotification = "k_key_FCM_PushNotification"
    static let k_key_UniqueDeviceId = "k_key_UniqueDeviceId"

    static let k_key_GuestDeviceToken = "k_key_GuestDeviceToken"
    static let k_key_CartHavingSalonIdIfService = "k_key_CartHavingSalonIdIfService"
    static let k_key_SalonServiceRange = "k_key_SalonServiceRange"

    // Service Type Selection key
    static let k_key_ServiceType = "ServiceType"

    // Logout
    static let lastLoginDate = "lastLoginDate" // Last login date

    static let k_key_ForceUpdateNotNow = "k_key_ForceUpdateNotNow"
    
    //Incentive data : Dashboard
    static let k_key_RevenueDashboard = "k_key_RevenueDashboard"
    static let k_key_RevenueTotal = "k_key_RevenueTotal"
    static let k_key_SalesToatal = "k_key_SalesToatal"
    static let k_key_FreeServicesToatal = "k_key_FreeServicesToatal"
    static let k_key_FootfallToatal = "k_key_FootfallToatal"
    
    //Earnings data : Dashboard
    static let k_key_EarningsDashboard = "k_key_EarningsDashboard"
    
    //key for from and To date for date filter
    static let k_key_FromDate = "k_key_FromDate"
    static let k_key_ToDate = "k_key_ToDate"
    static let k_key_CustomDateRangeSelected = "k_key_CustomDateRangeSelected"
}
