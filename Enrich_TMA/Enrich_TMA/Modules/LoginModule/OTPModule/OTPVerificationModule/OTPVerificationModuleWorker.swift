//
//  OTPVerificationModuleWorker.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class OTPVerificationModuleWorker {
    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    // let networkLayer = NetworkLayer() // Uncomment this in case do request using URLsession
    var presenter: OTPVerificationModulePresentationLogic?

    func postRequest(request: OTPVerificationModule.ChangePasswordWithOTPVerification.Request, endPoint: String) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (OTPVerificationModule.ChangePasswordWithOTPVerification.Response) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }

        self.networkLayer.post(urlString: endPoint,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

}
