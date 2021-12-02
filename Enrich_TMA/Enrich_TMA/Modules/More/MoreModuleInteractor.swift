//
//  MoreModuleInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol MoreModuleBusinessLogic {
    func doPostRequest(request: MoreModule.Something.Request, method: HTTPMethod)
    func doGetRequestWithoutParameter(method: HTTPMethod)
    func doGetRequestWithParameter(request: MoreModule.Something.Request, method: HTTPMethod)

}

protocol MoreModuleDataStore {
  //var name: String { get set }
}

class MoreModuleInteractor: MoreModuleBusinessLogic, MoreModuleDataStore {
  var presenter: MoreModulePresentationLogic?
  var worker: MoreModuleWorker?
  //var name: String = ""

  // MARK: Do something

    // MARK: Do something
    func doPostRequest(request: MoreModule.Something.Request, method: HTTPMethod) {
        worker = MoreModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequest(request: request)
    }
    func doGetRequestWithoutParameter(method: HTTPMethod) {
        worker = MoreModuleWorker()
        worker?.presenter = self.presenter
        worker?.getRequestWithoutParameter()
    }
    func doGetRequestWithParameter(request: MoreModule.Something.Request, method: HTTPMethod) {
        worker = MoreModuleWorker()
        worker?.presenter = self.presenter
        worker?.getRequestWithParameter(request: request)
    }
}
