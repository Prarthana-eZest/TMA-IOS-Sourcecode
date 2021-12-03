//
//  LoginOTPModuleInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.

import UIKit

protocol LoginOTPModuleBusinessLogic {
    func doPostRequest(request: LoginOTPModule.OTP.Request, method: HTTPMethod)
}

protocol LoginOTPModuleDataStore {
    //var name: String { get set }
}

class LoginOTPModuleInteractor: LoginOTPModuleBusinessLogic, LoginOTPModuleDataStore {

    var presenter: LoginOTPModulePresentationLogic?
    var worker: LoginOTPModuleWorker?

    // MARK: Do something
    func doPostRequest(request: LoginOTPModule.OTP.Request, method: HTTPMethod) {
        worker = LoginOTPModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequest(request: request)
    }

}
