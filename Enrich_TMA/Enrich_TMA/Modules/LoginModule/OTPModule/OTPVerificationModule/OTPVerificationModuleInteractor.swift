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

protocol OTPVerificationModuleBusinessLogic
{
    func doPostRequest(request: OTPVerificationModule.MobileNumberWithOTPVerification.Request,method:HTTPMethod,endPoint:String)
    func doGetRequestWithParameter(request: OTPVerificationModule.MobileNumberWithOTPVerification.Request,method:HTTPMethod,endPoint:String)
    func doPutRequestForMergeRequest(request: ProductDetailsModule.MergeGuestCart.Request,method:HTTPMethod,accessToken:String)
}

protocol OTPVerificationModuleDataStore
{
  //var name: String { get set }
}

class OTPVerificationModuleInteractor: OTPVerificationModuleBusinessLogic, OTPVerificationModuleDataStore
{
  var presenter: OTPVerificationModulePresentationLogic?
  var worker: OTPVerificationModuleWorker?
  
    // MARK: Do something
    func doPostRequest(request: OTPVerificationModule.MobileNumberWithOTPVerification.Request,method:HTTPMethod,endPoint:String)
    {
        worker = OTPVerificationModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequest(request: request, endPoint: endPoint)
    }
    
    func doGetRequestWithParameter(request: OTPVerificationModule.MobileNumberWithOTPVerification.Request, method: HTTPMethod,endPoint:String)
    {
        worker = OTPVerificationModuleWorker()
        worker?.presenter = self.presenter
        worker?.getRequestWithParameter(request: request, endPoint: endPoint)
    }
    func doPutRequestForMergeRequest(request: ProductDetailsModule.MergeGuestCart.Request,method:HTTPMethod,accessToken:String)
    {
        worker = OTPVerificationModuleWorker()
        worker?.presenter = self.presenter
        worker?.putRequestForMergeCartItems(request: request,accessToken: accessToken)
    }
}
