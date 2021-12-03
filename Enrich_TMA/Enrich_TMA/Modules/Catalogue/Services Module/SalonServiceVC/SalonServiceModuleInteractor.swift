//
//  SalonServiceModuleInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol SalonServiceModuleBusinessLogic {
    func doPostRequest(request: SalonServiceModule.Something.Request, method: HTTPMethod)
    func doPostRequestTestimonials(request: SalonServiceModule.Something.TestimonialRequest, method: HTTPMethod)
    func getServiceCategory(request: HairTreatmentModule.Something.Request, method: HTTPMethod)
    func doPostRequestGetQuoteIdMine(request: ProductDetailsModule.GetQuoteIDMine.Request, accessToken: String)
    func doPostRequestGetQuoteIdGuest(request: ProductDetailsModule.GetQuoteIDGuest.Request, method: HTTPMethod)
    func doPostRequestAddBulkProductToCartMine(request: ProductDetailsModule.AddBulkProductMine.Request, method: HTTPMethod, accessToken: String, customer_id: String)
    func doPostRequestAddBulkProductToCartGuest(request: ProductDetailsModule.AddBulkProductGuest.Request, method: HTTPMethod)
    func doGetRequestToGetAllCartItemsGuest(request: ProductDetailsModule.GetAllCartsItemGuest.Request, method: HTTPMethod)
    func doGetRequestToGetAllCartItemsCustomer(request: ProductDetailsModule.GetAllCartsItemCustomer.Request, method: HTTPMethod)
    func postRequestSalonServiceCategory(request: HairServiceModule.Something.Request, method: HTTPMethod)

    func doPostRequestProductReviews(request: ServiceDetailModule.ServiceDetails.ProductReviewRequest, method: HTTPMethod)
    func doPostRequestFrequentlyAvailedServices(request: ServiceDetailModule.ServiceDetails.FrequentlyAvailedProductRequest, method: HTTPMethod)
    func doPostRequestRateAServices(request: ServiceDetailModule.ServiceDetails.RateAServiceRequest, method: HTTPMethod)

    func doPostRequestBlogs(request: ProductLandingModule.Something.Request, method: HTTPMethod)
    func getProductDetails(request: ServiceDetailModule.ServiceDetails.Request, method: HTTPMethod)
    func doGetRequestForFrequentlyAvailedServices(request: HairTreatmentModule.Something.Request, method: HTTPMethod)

    func postRequestNewServiceCategory(request: HairServiceModule.NewServiceCategory.Request, method: HTTPMethod)

}

protocol SalonServiceModuleDataStore {
  //var name: String { get set }
}

class SalonServiceModuleInteractor: SalonServiceModuleBusinessLogic, SalonServiceModuleDataStore {

  var presenter: SalonServiceModulePresentationLogic?
  var worker: SalonServiceModuleWorker?
  var workerCart: CartAPIManager?

    // MARK: Do something
    func doPostRequestProductReviews(request: ServiceDetailModule.ServiceDetails.ProductReviewRequest, method: HTTPMethod) {
        worker = SalonServiceModuleWorker()
        worker?.presenter = self.presenter
        worker?.postProductReviewsRequest(request: request)
    }
    func doPostRequestFrequentlyAvailedServices(request: ServiceDetailModule.ServiceDetails.FrequentlyAvailedProductRequest, method: HTTPMethod) {
        worker = SalonServiceModuleWorker()
        worker?.presenter = self.presenter
        worker?.postFrequentlyAvailedRequest(request: request)
    }
    func doPostRequestRateAServices(request: ServiceDetailModule.ServiceDetails.RateAServiceRequest, method: HTTPMethod) {
        worker = SalonServiceModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRateAServiceRequest(request: request)
    }
    func doPostRequest(request: SalonServiceModule.Something.Request, method: HTTPMethod) {
        worker = SalonServiceModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequest(request: request)
    }

    func doPostRequestTestimonials(request: SalonServiceModule.Something.TestimonialRequest, method: HTTPMethod) {
        worker = SalonServiceModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestTestimonials(request: request)
    }

    func getServiceCategory(request: HairTreatmentModule.Something.Request, method: HTTPMethod) {
        worker = SalonServiceModuleWorker()
        worker?.presenter = self.presenter
        worker?.getServiceCategory(request: request)
    }

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
    func postRequestSalonServiceCategory(request: HairServiceModule.Something.Request, method: HTTPMethod) {
        worker = SalonServiceModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestSalonServiceCategory(request: request)
    }
    func doPostRequestBlogs(request: ProductLandingModule.Something.Request, method: HTTPMethod) {
        worker = SalonServiceModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestBlogs(request: request)
    }
    func getProductDetails(request: ServiceDetailModule.ServiceDetails.Request, method: HTTPMethod) {
        worker = SalonServiceModuleWorker()
        worker?.presenter = self.presenter
        worker?.getProductDetails(request: request)
    }
    func doGetRequestForFrequentlyAvailedServices(request: HairTreatmentModule.Something.Request, method: HTTPMethod) {
        worker = SalonServiceModuleWorker()
        worker?.presenter = self.presenter
        worker?.getRequestForSelectedService(request: request)
    }

    func postRequestNewServiceCategory(request: HairServiceModule.NewServiceCategory.Request, method: HTTPMethod) {
        worker = SalonServiceModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestNewServiceCategory(request: request)

    }

}
