//
//  SearchModuleWorker.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class SearchModuleWorker {
    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    var presenter: SearchModulePresentationLogic?

    func getRequestWithParameter(request: SearchModule.ApiType.Request) {

        let _: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let _: ([SearchModule.ApiType.GblSearchModel]) -> Void = { (employees) in

            //self.view?.displayEmployees(employees: employees)
        }

//        let strRequestAPI = ConstantAPINames.globalSearchAPI.rawValue + "\(request.searchText ?? "")".replacingOccurrences(of:" ", with: "%20")
//        self.networkLayer.get(urlString: strRequestAPI,
//                              successHandler: successHandler,
//                              errorHandler: errorHandler)
    }

}
