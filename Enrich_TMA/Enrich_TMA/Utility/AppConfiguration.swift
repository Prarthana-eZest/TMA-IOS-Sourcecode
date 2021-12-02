//
//  AppConfiguration.swift
//  EnrichSalon
//
//  Created by Apple on 24/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit
// MARK: Authorization Key Needs To Be check when App Store Release
let AuthorizationKey = "1kl8wr7axmwbgyi0a06vr8rb0qfhs2dj" // Admin Key
let AuthorizationHeaders = ["Authorization": "Bearer \(AuthorizationKey)"] // Admin Key

// MARK: ThirdPartyKeys Needs To Be check when App Store Release // Facebook Key As Well
enum TwitterKeys {
    static let k_TWTRTwitterConsumerkey = "GYvcq8b4hpuZcHiT1gJVbNVLY"
    static let k_TWTRTwitterConsumerSeceretkey = "xXwbsiKExTOTuuJfkP2X3sYWt5GkRK6kn1Ct6x5pbrFGWAu1Ya"
}
enum GoogleKeys {
    static let k_GoogleSignInKey = "923814802497-4nemiu18jlrp4c63hbh9iqf2buhhham5.apps.googleusercontent.com"
    static let k_Key_GooglePlacesKey = "AIzaSyBKShSPAdalMnylgwhe8Fe_WkAAAWcjRzs" //Client Key
}
