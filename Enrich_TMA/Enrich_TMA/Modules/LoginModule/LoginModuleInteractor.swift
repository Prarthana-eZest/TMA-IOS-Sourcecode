//
//  LoginModuleInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol LoginModuleBusinessLogic {
    func doPostRequest(request: LoginModule.UserLogin.Request, method: HTTPMethod)
    func doPostAuthenticateDeviceRequest(request: LoginModule.AuthenticateDevice.Request)
}

class LoginModuleInteractor: LoginModuleBusinessLogic {
    var presenter: LoginModulePresentationLogic?
    var worker = LoginModuleWorker()
    // MARK: Do something
    func doPostRequest(request: LoginModule.UserLogin.Request, method: HTTPMethod) {
        worker = LoginModuleWorker()
        worker.presenter = self.presenter
        worker.postRequest(request: request)
    }
    func doPostAuthenticateDeviceRequest(request: LoginModule.AuthenticateDevice.Request) {
        worker = LoginModuleWorker()
        worker.presenter = self.presenter
        worker.postRequestAuthenticateDevice(request: request)
    }

}
