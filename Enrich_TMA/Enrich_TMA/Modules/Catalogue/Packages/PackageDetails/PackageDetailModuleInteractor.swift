//
//  PackageDetailModuleInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol PackageDetailModuleBusinessLogic {

    func doPostRequestAddBulkProductToCartMine(request: ProductDetailsModule.AddBulkProductMine.Request, method: HTTPMethod, accessToken: String, customer_id: String)
    func doPostRequestAddBulkProductToCartGuest(request: ProductDetailsModule.AddBulkProductGuest.Request, method: HTTPMethod)

    func doPostRequestGetQuoteIdMine(request: ProductDetailsModule.GetQuoteIDMine.Request, accessToken: String)

}

protocol PackageDetailModuleDataStore {
    //var name: String { get set }
}

class PackageDetailModuleInteractor: PackageDetailModuleBusinessLogic, PackageDetailModuleDataStore {
    var presenter: PackageDetailModulePresentationLogic?
    var workerCart: CartAPIManager?

    func doPostRequestAddBulkProductToCartMine(request: ProductDetailsModule.AddBulkProductMine.Request, method: HTTPMethod, accessToken: String, customer_id: String) {
        workerCart = CartAPIManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.postRequestAddBulkProductToCartMine(request: request, method: method, accessToken: accessToken, customer_id: customer_id )
    }

    func doPostRequestGetQuoteIdMine(request: ProductDetailsModule.GetQuoteIDMine.Request, accessToken: String) {
        workerCart = CartAPIManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.postRequestGetQuoteIdMine(request: request, accessToken: accessToken)
    }
    func doPostRequestAddBulkProductToCartGuest(request: ProductDetailsModule.AddBulkProductGuest.Request, method: HTTPMethod) {
        workerCart = CartAPIManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.postRequestAddBulkProductToCartGuest(request: request, method: method)
    }

}
