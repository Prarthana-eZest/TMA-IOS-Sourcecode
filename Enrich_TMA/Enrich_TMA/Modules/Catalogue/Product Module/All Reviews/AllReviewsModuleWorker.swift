//
//  AllReviewsModuleWorker.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class AllReviewsModuleWorker {
    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    // let networkLayer = NetworkLayer() // Uncomment this in case do request using URLsession
    var presenter: AllReviewsModulePresentationLogic?

    func postProductReviewsRequest(request: ServiceDetailModule.ServiceDetails.ProductReviewRequest, method: HTTPMethod) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (ServiceDetailModule.ServiceDetails.ProductReviewResponse) -> Void = { (response) in
            print(response)
            self.presenter?.presentSomethingSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.productReview.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

}
