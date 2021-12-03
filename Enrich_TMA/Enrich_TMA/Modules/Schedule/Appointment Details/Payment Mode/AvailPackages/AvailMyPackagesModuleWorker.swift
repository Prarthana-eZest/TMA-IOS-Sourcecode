//
//  AvailMyPackagesModuleWorker.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class AvailMyPackagesModuleWorker {
    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    // let networkLayer = NetworkLayer() // Uncomment this in case do request using URLsession
    var presenter: AvailMyPackagesModulePresentationLogic?
    func applyValuePackages(request: AvailMyPackagesModule.ApplyPackages.RequestValuePackage) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (AvailMyPackagesModule.ApplyPackages.Response) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }

            self.networkLayer.post(urlString: ConstantAPINames.applyRemovePackages.rawValue,
                                   body: request, headers: ["Authorization": "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"], successHandler: successHandler,
                                   errorHandler: errorHandler, method: .post)

    }
    func applyServicePackages(request: AvailMyPackagesModule.ApplyPackages.RequestServicePackage) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (AvailMyPackagesModule.ApplyPackages.Response) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.applyRemovePackages.rawValue,
                               body: request, headers: ["Authorization": "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"], successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }

    func removeValueOrServicePackage(request: AvailMyPackagesModule.RemovePackages.RequestRemovePackages) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (AvailMyPackagesModule.RemovePackages.Response) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.applyRemovePackages.rawValue,
                               body: request, headers: ["Authorization": "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"], successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }
}
