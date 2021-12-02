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

class OTPVerificationModuleWorker
{
    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    // let networkLayer = NetworkLayer() // Uncomment this in case do request using URLsession
    var presenter: OTPVerificationModulePresentationLogic?
    
    func postRequest(request: OTPVerificationModule.MobileNumberWithOTPVerification.Request,endPoint:String)
    {
        // *********** NETWORK CONNECTION
        
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError:error)
        }
        let successHandler: (OTPVerificationModule.MobileNumberWithOTPVerification.Response) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }
        
       
        
        
       // let emp1 = OTPVerificationModule.MobileNumberWithOTPVerification.Request(otp: request.otp, mobile_number: request.mobile_number)
        self.networkLayer.post(urlString: endPoint,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }
    func getRequestWithParameter(request: OTPVerificationModule.MobileNumberWithOTPVerification.Request,endPoint:String) {
        
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError:error)
        }
        let successHandler: ([OTPVerificationModule.MobileNumberWithOTPVerification.Response]) -> Void = { (employees) in
            print(employees)
            //self.view?.displayEmployees(employees: employees)
        }
        self.networkLayer.get(urlString: endPoint,
                              successHandler: successHandler,
                              errorHandler: errorHandler)
    }
    
    // MARK: MergeRequest
    func putRequestForMergeCartItems(request: ProductDetailsModule.MergeGuestCart.Request, accessToken: String) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (ProductDetailsModule.MergeGuestCart.Response) -> Void = { (response) in
            print(response)

            self.presenter?.presentSomethingSuccess(response: response)
        }

        var strEndPoint = ConstantAPINames.addToCartGuest.rawValue
        strEndPoint = String(format: "\(strEndPoint)/%@", request.cartId)

        let mergeRequest = ProductDetailsModule.MergeGuestCart.Request(cartId: request.cartId, customer_id: request.customer_id, storeId: request.storeId)
//        self.networkLayer.put(urlString: strEndPoint,
//                              body: mergeRequest, headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler,
//                              errorHandler: errorHandler)
        self.networkLayer.post(urlString: strEndPoint,
                              body: mergeRequest, headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler,
                              errorHandler: errorHandler, method: .put)

    }
}
