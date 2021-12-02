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

        let emp1 = ServiceDetailModule.ServiceDetails.ProductReviewRequest(product_id: request.product_id, limit: request.limit)

        self.networkLayer.post(urlString: ConstantAPINames.productReview.rawValue,
                               body: emp1, successHandler: successHandler,
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

// MARK: Recently Viewed Products Request
//    func postRecentlyViewedProducts(request: ProductDetailsModule.RecentlyViewedProducts.Request)
//    {
//        // *********** NETWORK CONNECTION
//        
//        let errorHandler: (String) -> Void = { (error) in
//            print(error)
//            self.presenter?.presentSomethingError(responseError:error)
//        }
//        let successHandler: (ProductDetailsModule.RecentlyViewedProducts.Response) -> Void = { (response) in
//            print(response)
//            self.presenter?.presentSomethingSuccess(response: response)
//        }
//        self.networkLayer.post(urlString: ConstantAPINames.recentlyviewedproducts.rawValue,
//                               body: request,headers: AuthorizationHeaders, successHandler: successHandler,
//                               errorHandler: errorHandler)
//    }
//    
    // MARK: AddToWishList Request
    func postRequestAddToWishList(request: HairTreatmentModule.Something.AddToWishListRequest, accessToken: String) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (HairTreatmentModule.Something.AddToWishListResponse) -> Void = { (response) in
            print(response)

            if(response.status == false) {
                self.presenter?.presentSomethingError(responseError: response.message)
                return
            }

            self.presenter?.presentSomethingSuccess(response: response)
        }

        let emp1 = HairTreatmentModule.Something.AddToWishListRequest(customer_id: request.customer_id, wishlist_item: request.wishlist_item)
        self.networkLayer.post(urlString: ConstantAPINames.addWishList.rawValue,
                               body: emp1, headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }

    // MARK: RemoveFromWishList Request
    func postRequestRemovefromWishList(request: HairTreatmentModule.Something.RemoveFromWishListRequest, accessToken: String) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (HairTreatmentModule.Something.RemoveFromWishListResponse) -> Void = { (response) in
            print(response)

            if(response.status == false) {
                self.presenter?.presentSomethingError(responseError: response.message)
                return
            }

            self.presenter?.presentSomethingSuccess(response: response)
        }

        let emp1 = HairTreatmentModule.Something.RemoveFromWishListRequest(customer_id: request.customer_id, product_id: request.product_id)
        self.networkLayer.post(urlString: ConstantAPINames.removeFromWishList.rawValue,
                               body: emp1, headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }

    // MARK: AddSimpleOrVirtualProductToCartMine
    func postRequestAddSimpleOrVirtualProductToCartMine(request: ProductDetailsModule.AddSimpleOrVirtualProductToCartMine.Request, method: HTTPMethod, accessToken: String, customer_id: String, salon_id: String) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (ProductDetailsModule.AddSimpleOrVirtualProductToCartMine.Response) -> Void = { (response) in
            print(response)
            self.presenter?.presentSomethingSuccess(response: response)
        }

        var strEndPoint = ConstantAPINames.getQuoteIdMine.rawValue.replacingOccurrences(of: "$$$", with: "mine" )
        strEndPoint = String(format: "\(strEndPoint)/items?customer_id=%@&salon_id=%@", customer_id, salon_id)

        let emp1 = ProductDetailsModule.AddSimpleOrVirtualProductToCartMine.Request(cart_item: request.cart_item)
        self.networkLayer.post(urlString: strEndPoint,
                               body: emp1, headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }

    // MARK: AddSimpleOrVirtualProductToCartGuest
    func postRequestAddSimpleOrVirtualProductToCartGuest(request: ProductDetailsModule.AddSimpleOrVirtualProductToCartGuest.Request) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (ProductDetailsModule.AddSimpleOrVirtualProductToCartGuest.Response) -> Void = { (response) in
            print(response)

            if let messageObj = response.message, !messageObj.isEmpty {
                self.presenter?.presentSomethingError(responseError: response.message)
                return
            }

            self.presenter?.presentSomethingSuccess(response: response)
        }

        var strEndPoint = ConstantAPINames.addToCartGuest.rawValue
        strEndPoint = String(format: "\(strEndPoint)/%@/items?salon_id=%@", (request.cart_item?.quote_id)!, request.salon_id!)

        let emp1 = ProductDetailsModule.AddSimpleOrVirtualProductToCartGuest.Request(cart_item: request.cart_item, salon_id: request.salon_id)
        self.networkLayer.post(urlString: strEndPoint,
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

        var strURL: String = ConstantAPINames.productDetails.rawValue
        strURL = strURL + request.requestedParameters
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        self.networkLayer.get(urlString: strURL, successHandler: successHandler, errorHandler: errorHandler)

    }

}
