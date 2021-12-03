//
//  MoreModuleWorker.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class MoreModuleWorker {

    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    // let networkLayer = NetworkLayer() // Uncomment this in case do request using URLsession
    var presenter: MoreModulePresentationLogic?

    func postRequestForCheckInStatus(request: MoreModule.GetCheckInStatus.Request, method: HTTPMethod) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (MoreModule.GetCheckInStatus.Response) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.getCheckInStatus.rawValue, body: request,
                               headers: ["Authorization": "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"],
                               successHandler: successHandler, errorHandler: errorHandler, method: method)
    }

    func postRequestForMarkCheckInOut(request: MoreModule.MarkCheckInOut.Request, method: HTTPMethod) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (MoreModule.MarkCheckInOut.Response) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.markCheckInOut.rawValue, body: request,
                               headers: ["Authorization": "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"],
                               successHandler: successHandler, errorHandler: errorHandler, method: method)
    }

    func postRequestForCheckInOutDetails(request: MoreModule.CheckInOutDetails.Request, method: HTTPMethod) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (MoreModule.CheckInOutDetails.Response) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.getCheckInOutDetails.rawValue, body: request,
                               headers: ["Authorization": "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"],
                               successHandler: successHandler, errorHandler: errorHandler, method: method)
    }

}
