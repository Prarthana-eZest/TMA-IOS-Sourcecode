//
//  SOSFactory.swift
//  Enrich_TMA
//
//  Created by Harshal on 02/04/20.
//  Copyright © 2020 e-zest. All rights reserved.
//

import UIKit

class SOSFactory {

    static let shared = SOSFactory()

    let networkLayer = NetworkLayerAlamofire()

    func raiseSOSRequest() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        if let userData = UserDefaults.standard.value(MyProfile.GetUserProfile.UserData.self, forKey: UserDefauiltsKeys.k_Key_LoginUser) {

            let lat =  "\(LocationManager.sharedInstance.location().latitude)"
            let long = "\(LocationManager.sharedInstance.location().longitude)"

            let request = MoreModule.RaiseSOS.Request(employee_id: userData.employee_id ?? "", salon_id: userData.salon_id ?? "", lattitude: lat, longitude: long, is_custom: 1)
            postRequestForRaiseSOS(request: request, method: .post)
        }
    }
    func postRequestForRaiseSOS(request: MoreModule.RaiseSOS.Request, method: HTTPMethod) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            EZLoadingActivity.hide()
            UIApplication.shared.keyWindow?.rootViewController?.showToast(alertTitle: alertTitle, message: error, seconds: toastMessageDuration)
        }
        let successHandler: (MoreModule.RaiseSOS.Response) -> Void = { (response) in
            EZLoadingActivity.hide()
            UIApplication.shared.keyWindow?.rootViewController?.showToast(alertTitle: alertTitle, message: response.message, seconds: toastMessageDuration)
        }

        self.networkLayer.post(urlString: ConstantAPINames.raiseSOS.rawValue, body: request,
                               headers: ["Authorization": "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"],
                               successHandler: successHandler, errorHandler: errorHandler, method: method)
    }
}
