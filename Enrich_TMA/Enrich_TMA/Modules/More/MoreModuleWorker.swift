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

    func postRequest(request: MoreModule.Something.Request) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (MoreModule.Something.Response) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }

        let emp1 = MoreModule.Something.Request(name: request.name, salary: request.salary, age: request.age)
        self.networkLayer.post(urlString: ConstantAPINames.createData.rawValue,
                               body: emp1, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }
    func getRequestWithParameter(request: MoreModule.Something.Request) {

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: ([MoreModule.Something.Response]) -> Void = { (employees) in
            print(employees)
            //self.view?.displayEmployees(employees: employees)
        }
        self.networkLayer.get(urlString: "http://dummy.restapiexample.com/api/v1/employees",
                              successHandler: successHandler,
                              errorHandler: errorHandler)
    }
    func getRequestWithoutParameter() {

        let successHandler: ([MoreModule.Something.Response]) -> Void = { (employees) in
            print(employees)
            self.presenter?.presentSomethingSuccessFor(response: employees)
        }
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }

        self.networkLayer.get(urlString: "http://dummy.restapiexample.com/api/v1/employees",
                              successHandler: successHandler,
                              errorHandler: errorHandler)
    }

}
