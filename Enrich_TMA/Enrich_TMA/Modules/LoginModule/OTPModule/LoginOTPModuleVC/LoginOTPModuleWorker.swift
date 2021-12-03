//
//  LoginOTPModuleWorker.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.

import UIKit

class LoginOTPModuleWorker {

    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    // let networkLayer = NetworkLayer() // Uncomment this in case do request using URLsession
    var presenter: LoginOTPModulePresentationLogic?

    func postRequest(request: LoginOTPModule.OTP.Request) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (LoginOTPModule.OTP.Response) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.sendOTPOnMobile.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

}
