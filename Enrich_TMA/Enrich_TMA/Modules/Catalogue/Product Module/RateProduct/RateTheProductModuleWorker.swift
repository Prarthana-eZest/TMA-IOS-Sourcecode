//
//  RateTheProductModuleWorker.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class RateTheProductModuleWorker {
    let networkLayer = NetworkLayerAlamofire()
    var presenter: RateTheProductModulePresentationLogic?

    func postRequest(request: RateTheProductModule.RateTheProduct.Request, accessToken: String) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (RateTheProductModule.RateTheProduct.Response) -> Void = { (responseServer) in
            self.presenter?.presentSomethingSuccess(response: responseServer)
        }

        self.networkLayer.post(urlString: ConstantAPINames.rateAService.rawValue,
                               body: request, headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

}
