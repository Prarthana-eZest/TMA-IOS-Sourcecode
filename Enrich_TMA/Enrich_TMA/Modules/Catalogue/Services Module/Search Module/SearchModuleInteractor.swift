//
//  SearchModuleInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol SearchModuleBusinessLogic {
//    func doPostRequest(request: SearchModule.Something.Request, method: HTTPMethod)
//    func doGetRequestWithoutParameter(method: HTTPMethod)
    func doGetRequestWithParameter(request: SearchModule.ApiType.Request, method: HTTPMethod)
}

protocol SearchModuleDataStore {
  //var name: String { get set }
}

class SearchModuleInteractor: SearchModuleBusinessLogic, SearchModuleDataStore {
  var presenter: SearchModulePresentationLogic?
  var worker: SearchModuleWorker?
  //var name: String = ""

  // MARK: Do something

    // MARK: Do something
//    func doPostRequest(request: SearchModule.Something.Request, method: HTTPMethod) {
//        worker = SearchModuleWorker()
//        worker?.presenter = self.presenter
//        worker?.postRequest(request: request)
//    }
//    func doGetRequestWithoutParameter(method: HTTPMethod) {
//        worker = SearchModuleWorker()
//        worker?.presenter = self.presenter
//        worker?.getRequestWithoutParameter()
//    }
    func doGetRequestWithParameter(request: SearchModule.ApiType.Request, method: HTTPMethod) {
        worker = SearchModuleWorker()
        worker?.presenter = self.presenter
        worker?.getRequestWithParameter(request: request)
    }

}
