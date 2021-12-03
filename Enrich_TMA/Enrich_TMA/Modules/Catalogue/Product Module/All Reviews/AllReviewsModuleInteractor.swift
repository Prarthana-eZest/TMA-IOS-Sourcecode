//
//  AllReviewsModuleInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol AllReviewsModuleBusinessLogic {
    func doPostRequestProductReviews(request: ServiceDetailModule.ServiceDetails.ProductReviewRequest, method: HTTPMethod)
}

protocol AllReviewsModuleDataStore {
  //var name: String { get set }
}

class AllReviewsModuleInteractor: AllReviewsModuleBusinessLogic, AllReviewsModuleDataStore {
  var presenter: AllReviewsModulePresentationLogic?
  var worker: AllReviewsModuleWorker?
  //var name: String = ""

  // MARK: Do something

    // MARK: Do something
    func doPostRequestProductReviews(request: ServiceDetailModule.ServiceDetails.ProductReviewRequest, method: HTTPMethod) {
        worker = AllReviewsModuleWorker()
        worker?.presenter = self.presenter
        worker?.postProductReviewsRequest(request: request, method: method)
    }

}
