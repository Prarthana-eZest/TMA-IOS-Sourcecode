//
//  MarkMyAddressModuleInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol MarkMyAddressModuleBusinessLogic {
    func doPostRequest(request: MarkMyAddressModule.Something.Request, method: HTTPMethod)
    func doGetRequestWithoutParameter(method: HTTPMethod)
    func doGetRequestWithParameter(request: MarkMyAddressModule.Something.Request, method: HTTPMethod)

}

protocol MarkMyAddressModuleDataStore {
  //var name: String { get set }
}

class MarkMyAddressModuleInteractor: MarkMyAddressModuleBusinessLogic, MarkMyAddressModuleDataStore {
  var presenter: MarkMyAddressModulePresentationLogic?
  var worker: MarkMyAddressModuleWorker?
  //var name: String = ""

  // MARK: Do something

    // MARK: Do something
    func doPostRequest(request: MarkMyAddressModule.Something.Request, method: HTTPMethod) {
        worker = MarkMyAddressModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequest(request: request)
    }
    func doGetRequestWithoutParameter(method: HTTPMethod) {
//        worker = MarkMyAddressModuleWorker()
//        worker?.presenter = self.presenter
//        worker?.getRequestWithoutParameter()
    }
    func doGetRequestWithParameter(request: MarkMyAddressModule.Something.Request, method: HTTPMethod) {
//        worker = MarkMyAddressModuleWorker()
//        worker?.presenter = self.presenter
//        worker?.getRequestWithParameter(request: request)
    }
}
