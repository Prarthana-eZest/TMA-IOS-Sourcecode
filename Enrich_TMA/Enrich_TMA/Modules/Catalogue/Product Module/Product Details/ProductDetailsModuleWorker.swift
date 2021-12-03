//
//  ProductDetailsModuleWorker.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class ProductDetailsModuleWorker {
    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    // let networkLayer = NetworkLayer() // Uncomment this in case do request using URLsession
    var presenter: ProductDetailsModulePresentationLogic?

    // MARK: Product Review Request
    func postProductReviewsRequest(request: ServiceDetailModule.ServiceDetails.ProductReviewRequest) {
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
    // MARK: Frequently Availed Service Request
    func postFrequentlyAvailedRequest(request: ServiceDetailModule.ServiceDetails.FrequentlyAvailedProductRequest) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (ServiceDetailModule.ServiceDetails.FrequentlyAvailedProductResponse) -> Void = { (response) in
            print(response)
            self.presenter?.presentSomethingSuccess(response: response)
        }

        let emp1 = ServiceDetailModule.ServiceDetails.FrequentlyAvailedProductRequest()
        self.networkLayer.post(urlString: ConstantAPINames.frquentlyAvailedProduct.rawValue,
                               body: emp1, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    func getRequestWithParameter(request: ServiceDetailModule.ServiceDetails.Request) {

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (ServiceDetailModule.ServiceDetails.Response) -> Void = { (response) in
            print(response)
            self.presenter?.presentSomethingSuccess(response: response)
        }

        var strURL: String = ConstantAPINames.getRelatedBOMProducts.rawValue
        strURL += request.requestedParameters
       // strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        self.networkLayer.get(urlString: strURL, successHandler: successHandler, errorHandler: errorHandler)

    }

}
