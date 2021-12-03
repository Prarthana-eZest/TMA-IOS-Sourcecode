//
//  LoginModuleWorker.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class LoginModuleWorker {

    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    // let networkLayer = NetworkLayer() // Uncomment this in case do request using URLsession
    var presenter: LoginModulePresentationLogic?

    func postRequest(request: LoginModule.UserLogin.Request) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (LoginModule.UserLogin.Response) -> Void = { (response) in
            self.presenter?.presentSuccess(response: response)
        }

        //let user = LoginModule.UserLogin.Request(username: "mack", password: "enrich#123", is_custom: true)
        self.networkLayer.post(urlString: ConstantAPINames.userLogin.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    func postRequestAuthenticateDevice(request: LoginModule.AuthenticateDevice.Request) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (LoginModule.AuthenticateDevice.Response) -> Void = { (response) in
            self.presenter?.presentSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.authenticateDevice.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

}
