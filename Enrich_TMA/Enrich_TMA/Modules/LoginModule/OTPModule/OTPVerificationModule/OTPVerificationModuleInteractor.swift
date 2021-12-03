//
//  OTPVerificationModuleInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol OTPVerificationModuleBusinessLogic {
    func doPostRequest(request: OTPVerificationModule.ChangePasswordWithOTPVerification.Request, method: HTTPMethod, endPoint: String)
}

protocol OTPVerificationModuleDataStore {
    //var name: String { get set }
}

class OTPVerificationModuleInteractor: OTPVerificationModuleBusinessLogic, OTPVerificationModuleDataStore {
    var presenter: OTPVerificationModulePresentationLogic?
    var worker: OTPVerificationModuleWorker?

    // MARK: Do something
    func doPostRequest(request: OTPVerificationModule.ChangePasswordWithOTPVerification.Request, method: HTTPMethod, endPoint: String) {
        worker = OTPVerificationModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequest(request: request, endPoint: endPoint)
    }
}
