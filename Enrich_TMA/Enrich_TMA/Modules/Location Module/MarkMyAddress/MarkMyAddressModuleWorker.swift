//
//  MarkMyAddressModuleWorker.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class MarkMyAddressModuleWorker {
    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    // let networkLayer = NetworkLayer() // Uncomment this in case do request using URLsession
    var presenter: MarkMyAddressModulePresentationLogic?

    func postRequest(request: MarkMyAddressModule.Something.Request) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            EZLoadingActivity.hide(false, animated: false)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (MarkMyAddressModule.Something.Response) -> Void = { (employees) in
            print(employees)
            let response = employees
            if(employees.status == false) {
                self.presenter?.presentSomethingError(responseError: employees.message)
                EZLoadingActivity.hide(true, animated: false)
                return
            }
            self.presenter?.presentSomethingSuccess(response: response)
        }
        EZLoadingActivity.show("Loading...", disableUI: true)

        self.networkLayer.post(urlString: ConstantAPINames.addfavouriteSalon.rawValue,
                               body: request, headers: AuthorizationHeaders, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    func getRequestWithParameter(request: MarkMyAddressModule.Something.Request) {
    }

    func getRequestWithoutParameter() {
    }

}
