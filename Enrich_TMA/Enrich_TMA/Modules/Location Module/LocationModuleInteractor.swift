//
//  LocationModuleInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol LocationModuleBusinessLogic {
    func doPostRequest(request: LocationModule.Something.Request, method: HTTPMethod)
    func doGetRequestWithoutParameter(method: HTTPMethod)
    func doGetRequestWithParameter(request: LocationModule.Something.Request, method: HTTPMethod)

    func doPostRequestRemoveData(request: MarkMyAddressModule.Something.Request, method: HTTPMethod)

}

protocol LocationModuleDataStore {
  //var name: String { get set }
}

class LocationModuleInteractor: LocationModuleBusinessLogic, LocationModuleDataStore {
  var presenter: LocationModulePresentationLogic?
  var worker: LocationModuleWorker?
  //var name: String = ""

  // MARK: Do something

    func doPostRequestRemoveData(request: MarkMyAddressModule.Something.Request, method: HTTPMethod) {
        worker = LocationModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestRemoveSalon(request: request)
    }

    // MARK: Do something
    func doPostRequest(request: LocationModule.Something.Request, method: HTTPMethod) {
        worker = LocationModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequest(request: request)
    }
    func doGetRequestWithoutParameter(method: HTTPMethod) {
        worker = LocationModuleWorker()
        worker?.presenter = self.presenter
        worker?.getRequestWithoutParameter()
    }
    func doGetRequestWithParameter(request: LocationModule.Something.Request, method: HTTPMethod) {
        worker = LocationModuleWorker()
        worker?.presenter = self.presenter
        worker?.getRequestWithParameter(request: request)
    }
}
