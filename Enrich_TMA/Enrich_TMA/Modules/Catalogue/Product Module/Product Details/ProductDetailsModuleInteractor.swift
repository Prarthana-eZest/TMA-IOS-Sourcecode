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

     func doPostRequestAddToWishList(request: HairTreatmentModule.Something.AddToWishListRequest, method: HTTPMethod, accessToken: String)
    func doPostRequestRemoveFromWishList(request: HairTreatmentModule.Something.RemoveFromWishListRequest, method: HTTPMethod, accessToken: String)

    func doPostRequestGetQuoteIdMine(request: ProductDetailsModule.GetQuoteIDMine.Request, accessToken: String)
     func doPostRequestGetQuoteIdGuest(request: ProductDetailsModule.GetQuoteIDGuest.Request, method: HTTPMethod)

    func doPostRequestAddSimpleOrVirtualProductToCartMine(request: ProductDetailsModule.AddSimpleOrVirtualProductToCartMine.Request, method: HTTPMethod, accessToken: String, customer_id: String, salon_id: String)
    func doPostRequestAddSimpleOrVirtualProductToCartGuest(request: ProductDetailsModule.AddSimpleOrVirtualProductToCartGuest.Request, method: HTTPMethod)

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
    var workerCart: CartManager?

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
     func doPostRequestAddToWishList(request: HairTreatmentModule.Something.AddToWishListRequest, method: HTTPMethod, accessToken: String) {
        worker = ProductDetailsModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestAddToWishList(request: request, accessToken: accessToken)
    }
    func doPostRequestRemoveFromWishList(request: HairTreatmentModule.Something.RemoveFromWishListRequest, method: HTTPMethod, accessToken: String) {
        worker = ProductDetailsModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestRemovefromWishList(request: request, accessToken: accessToken)
    }

    func doPostRequestAddSimpleOrVirtualProductToCartMine(request: ProductDetailsModule.AddSimpleOrVirtualProductToCartMine.Request, method: HTTPMethod, accessToken: String, customer_id: String, salon_id: String) {
        worker = ProductDetailsModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestAddSimpleOrVirtualProductToCartMine(request: request, method: method, accessToken: accessToken, customer_id: customer_id, salon_id: salon_id )
    }

    func doPostRequestAddSimpleOrVirtualProductToCartGuest(request: ProductDetailsModule.AddSimpleOrVirtualProductToCartGuest.Request, method: HTTPMethod) {
        worker = ProductDetailsModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestAddSimpleOrVirtualProductToCartGuest(request: request)
    }

    // Cart Manager Functions
    func doPostRequestGetQuoteIdMine(request: ProductDetailsModule.GetQuoteIDMine.Request, accessToken: String) {
        workerCart = CartManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.postRequestGetQuoteIdMine(request: request, accessToken: accessToken)
    }
    func doPostRequestGetQuoteIdGuest(request: ProductDetailsModule.GetQuoteIDGuest.Request, method: HTTPMethod) {
        workerCart = CartManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.postRequestGetQuoteIdGuest(request: request)
    }

    func doGetRequestToGetAllCartItemsCustomer(request: ProductDetailsModule.GetAllCartsItemCustomer.Request, method: HTTPMethod) {
        workerCart = CartManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.getRequestToGetAllCartItemsCustomer(request: request)
    }

    func doGetRequestToGetAllCartItemsGuest(request: ProductDetailsModule.GetAllCartsItemGuest.Request, method: HTTPMethod) {
        workerCart = CartManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.getRequestToGetAllCartItemsGuest(request: request)
    }

    func doGetRequestWithParameter(request: ServiceDetailModule.ServiceDetails.Request, method: HTTPMethod) {
        worker = ProductDetailsModuleWorker()
        worker?.presenter = self.presenter
        worker?.getRequestWithParameter(request: request)
    }
}
