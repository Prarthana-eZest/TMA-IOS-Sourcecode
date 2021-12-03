//
//  RateTheProductModuleInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol RateTheProductModuleBusinessLogic {
    func doPostRateTheProduct(request: RateTheProductModule.RateTheProduct.Request, accessToken: String)
}

class RateTheProductModuleInteractor: RateTheProductModuleBusinessLogic {
  var presenter: RateTheProductModulePresentationLogic?
  var worker: RateTheProductModuleWorker?

    // MARK: Do something
    func doPostRateTheProduct(request: RateTheProductModule.RateTheProduct.Request, accessToken: String) {
        worker = RateTheProductModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequest(request: request, accessToken: accessToken)
    }

}
