//
//  LocationModuleWorker.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class LocationModuleWorker {
    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    // let networkLayer = NetworkLayer() // Uncomment this in case do request using URLsession
    var presenter: LocationModulePresentationLogic?

    func postRequestRemoveSalon(request: MarkMyAddressModule.Something.Request) {
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
        self.networkLayer.post(urlString: ConstantAPINames.removefavouriteSalon.rawValue,
                               body: request, headers: AuthorizationHeaders, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    func postRequest(request: LocationModule.Something.Request) {
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
            EZLoadingActivity.hide(false, animated: false)
        }
        let successHandler: (LocationModule.Something.APIResponse) -> Void = { (employees) in
            print(employees)

            if(employees.status == false) {
                self.presenter?.presentSomethingError(responseError: employees.message)
                EZLoadingActivity.hide(false, animated: false)
                return
            }

            self.getDetailsInModel(response: employees)
        }

        let urlString = ConstantAPINames.postListOfSalons.rawValue

        EZLoadingActivity.show("Loading...", disableUI: true)
        self.networkLayer.post(urlString: urlString,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    func getRequestWithParameter(request: LocationModule.Something.Request) {
    }

    func getRequestWithoutParameter() {
    }

    func getDetailsInModel(response: LocationModule.Something.APIResponse) {
        EZLoadingActivity.hide(true, animated: false)
        self.presenter?.presentSomethingSuccess(response: response)
    }

}
