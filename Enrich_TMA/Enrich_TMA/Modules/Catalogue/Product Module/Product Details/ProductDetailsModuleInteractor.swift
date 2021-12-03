//
//  ProductDetailsModuleInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol ProductDetailsModuleBusinessLogic {

    func doPostRequestProductReviews(request: ServiceDetailModule.ServiceDetails.ProductReviewRequest, method: HTTPMethod)
    func doPostRequestFrequentlyAvailedServices(request: ServiceDetailModule.ServiceDetails.FrequentlyAvailedProductRequest, method: HTTPMethod)
//    func doPostRequestRecentlyViewedProducts(request: ProductDetailsModule.RecentlyViewedProducts.Request,method:HTTPMethod)

    func doPostRequestGetQuoteIdMine(request: ProductDetailsModule.GetQuoteIDMine.Request, accessToken: String)
    func doPostRequestGetQuoteIdGuest(request: ProductDetailsModule.GetQuoteIDGuest.Request, method: HTTPMethod)
    func doPostRequestAddBulkProductToCartMine(request: ProductDetailsModule.AddBulkProductMine.Request, method: HTTPMethod, accessToken: String, customer_id: String)
    func doPostRequestAddBulkProductToCartGuest(request: ProductDetailsModule.AddBulkProductGuest.Request, method: HTTPMethod)
    func doGetRequestToGetAllCartItemsGuest(request: ProductDetailsModule.GetAllCartsItemGuest.Request, method: HTTPMethod)
    func doGetRequestToGetAllCartItemsCustomer(request: ProductDetailsModule.GetAllCartsItemCustomer.Request, method: HTTPMethod)

    func doGetRequestWithParameter(request: ServiceDetailModule.ServiceDetails.Request, method: HTTPMethod)

}

protocol ProductDetailsModuleDataStore {
    //var name: String { get set }
}

class ProductDetailsModuleInteractor: ProductDetailsModuleBusinessLogic, ProductDetailsModuleDataStore {
    var presenter: ProductDetailsModulePresentationLogic?
    var worker: ProductDetailsModuleWorker?
    var workerCart: CartAPIManager?

    // MARK: Do something
    func doPostRequestProductReviews(request: ServiceDetailModule.ServiceDetails.ProductReviewRequest, method: HTTPMethod) {
        worker = ProductDetailsModuleWorker()
        worker?.presenter = self.presenter
        worker?.postProductReviewsRequest(request: request)
    }
    func doPostRequestFrequentlyAvailedServices(request: ServiceDetailModule.ServiceDetails.FrequentlyAvailedProductRequest, method: HTTPMethod) {
        worker = ProductDetailsModuleWorker()
        worker?.presenter = self.presenter
        worker?.postFrequentlyAvailedRequest(request: request)
    }
//    func doPostRequestRecentlyViewedProducts(request: ProductDetailsModule.RecentlyViewedProducts.Request,method:HTTPMethod)
//    {
//        worker = ProductDetailsModuleWorker()
//        worker?.presenter = self.presenter
//        worker?.postRecentlyViewedProducts(request: request)
//    }

    func doPostRequestAddBulkProductToCartMine(request: ProductDetailsModule.AddBulkProductMine.Request, method: HTTPMethod, accessToken: String, customer_id: String) {
        workerCart = CartAPIManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.postRequestAddBulkProductToCartMine(request: request, method: method, accessToken: accessToken, customer_id: customer_id )
    }
    func doPostRequestAddBulkProductToCartGuest(request: ProductDetailsModule.AddBulkProductGuest.Request, method: HTTPMethod) {
        workerCart = CartAPIManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.postRequestAddBulkProductToCartGuest(request: request, method: method)
    }

    // Cart Manager Functions
    func doPostRequestGetQuoteIdMine(request: ProductDetailsModule.GetQuoteIDMine.Request, accessToken: String) {
        workerCart = CartAPIManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.postRequestGetQuoteIdMine(request: request, accessToken: accessToken)
    }
    func doPostRequestGetQuoteIdGuest(request: ProductDetailsModule.GetQuoteIDGuest.Request, method: HTTPMethod) {
        workerCart = CartAPIManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.postRequestGetQuoteIdGuest(request: request)
    }

    func doGetRequestToGetAllCartItemsCustomer(request: ProductDetailsModule.GetAllCartsItemCustomer.Request, method: HTTPMethod) {
        workerCart = CartAPIManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.getRequestToGetAllCartItemsCustomer(request: request)
    }

    func doGetRequestToGetAllCartItemsGuest(request: ProductDetailsModule.GetAllCartsItemGuest.Request, method: HTTPMethod) {
        workerCart = CartAPIManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.getRequestToGetAllCartItemsGuest(request: request)
    }

    func doGetRequestWithParameter(request: ServiceDetailModule.ServiceDetails.Request, method: HTTPMethod) {
        worker = ProductDetailsModuleWorker()
        worker?.presenter = self.presenter
        worker?.getRequestWithParameter(request: request)
    }

}
