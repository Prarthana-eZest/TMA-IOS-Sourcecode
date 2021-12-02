//
//  CartManager.swift
//  EnrichSalon
//
//  Created by Apple on 09/08/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation

protocol CartManagerPresentationLogic: class {
    func presentSomethingSuccess<T: Decodable>(response: T)
    func presentSomethingError(responseError: String?)
    func presentSomethingSuccessFor<T: Decodable>(response: [T])

}

class CartManager: NSObject {
    static var sharedInstance = CartManager()
    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    weak var presenterCartWorker: CartManagerPresentationLogic?

    // MARK: GetQuoteId Request Mine
    func postRequestGetQuoteIdMine(request: ProductDetailsModule.GetQuoteIDMine.Request, accessToken: String) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
           self.presenterCartWorker?.presentSomethingError(responseError: error)
        }
        let successHandler: (ProductDetailsModule.GetQuoteIDMine.Response) -> Void = { (response) in
            print(response)
            self.presenterCartWorker?.presentSomethingSuccess(response: response)
        }

        let strEndPoint = ConstantAPINames.getQuoteIdMine.rawValue.replacingOccurrences(of: "$$$", with: "mine" )
        self.networkLayer.post(urlString: strEndPoint,
                               body: request.self, headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }

    // MARK: GetQuoteId Request Guest
    func postRequestGetQuoteIdGuest(request: ProductDetailsModule.GetQuoteIDGuest.Request) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenterCartWorker?.presentSomethingError(responseError: error)
        }
        let successHandler: (ProductDetailsModule.GetQuoteIDGuest.Response) -> Void = { (response) in
            print(response)

            self.presenterCartWorker?.presentSomethingSuccess(response: response)
        }

        let emp1 = ProductDetailsModule.GetQuoteIDGuest.Request()
        self.networkLayer.post(urlString: ConstantAPINames.addToCartGuest.rawValue,
                               body: emp1, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    // MARK: getRequestToGetAllCartItemsGuest
    func getRequestToGetAllCartItemsGuest(request: ProductDetailsModule.GetAllCartsItemGuest.Request) {

        let errorHandler: (String) -> Void = { (error) in
            print(error)
           self.presenterCartWorker?.presentSomethingError(responseError: error)
        }
        let successHandler: ([ProductDetailsModule.GetAllCartsItemGuest.Response]) -> Void = { (response) in
            print(response)
            self.presenterCartWorker?.presentSomethingSuccessFor(response: response)
        }

        var strURL: String = ConstantAPINames.addToCartGuest.rawValue
        strURL = String(format: "\(strURL)/%@/items", request.quote_id)
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        self.networkLayer.get(urlString: strURL, successHandler: successHandler, errorHandler: errorHandler)

    }
    // MARK: getRequestToGetAllCartItemsCustomers
    func getRequestToGetAllCartItemsCustomer(request: ProductDetailsModule.GetAllCartsItemCustomer.Request) {

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenterCartWorker?.presentSomethingError(responseError: error)
        }
        let successHandler: ([ProductDetailsModule.GetAllCartsItemCustomer.Response]) -> Void = { (response) in
            print(response)
            self.presenterCartWorker?.presentSomethingSuccessFor(response: response)
        }
        var strURL: String = ConstantAPINames.getAllCartItemsCustomer.rawValue
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        self.networkLayer.get(urlString: strURL, headers: ["Authorization": "Bearer \(request.accessToken)"], successHandler: successHandler, errorHandler: errorHandler)

    }

}
