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

class CartAPIManager: NSObject {
    static var sharedInstance = CartAPIManager()
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
//        strURL = String(format: "\(strURL)?is_custom=true")
//        if let salonId = GenericClass.sharedInstance.getSalonId(), !salonId.isEmpty
//        {
//            strURL = String(format: "\(strURL)?salon_id=%@",salonId)
//
//        }
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
       // strURL = String(format: "\(strURL)?is_custom=true")
//        if let salonId = GenericClass.sharedInstance.getSalonId(), !salonId.isEmpty
//        {
//            strURL = String(format: "\(strURL)?salon_id=%@",salonId)
//
//        }

        strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        self.networkLayer.get(urlString: strURL, headers: ["Authorization": "Bearer \(request.accessToken)"], successHandler: successHandler, errorHandler: errorHandler)

    }

    // MARK: flushAllServicesFromGuestCart
//    func flushAllServicesFromGuestCart(quote_id: String) {
//
//        let errorHandler: (String) -> Void = { (error) in
//            print(error)
//            self.presenterCartWorker?.presentSomethingError(responseError: error)
//        }
//        let successHandler: ([ProductDetailsModule.FlushCart.Response]) -> Void = { (response) in
//            print(response)
//            self.presenterCartWorker?.presentSomethingSuccessFor(response: response)
//        }
//
//        var strURL: String = ConstantAPINames.clearGuestCart.rawValue
//        strURL = String(format: "\(strURL)%@", quote_id)
//        strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
//
//        self.networkLayer.get(urlString: strURL, successHandler: successHandler, errorHandler: errorHandler)
//
//    }
//    // MARK: flushAllServicesFromGuestCart
//    func flushAllServicesFromCartMine(quote_id: Int64) {
//
//        let errorHandler: (String) -> Void = { (error) in
//            print(error)
//            self.presenterCartWorker?.presentSomethingError(responseError: error)
//        }
//        let successHandler: ([ProductDetailsModule.FlushCart.Response]) -> Void = { (response) in
//            print(response)
//            self.presenterCartWorker?.presentSomethingSuccessFor(response: response)
//        }
//
//        self.networkLayer.get(urlString: ConstantAPINames.clearMineCart.rawValue, successHandler: successHandler, errorHandler: errorHandler)
//    }

  /*  // MARK: AddSimpleOrVirtualProductToCartMine
    func postRequestAddSimpleOrVirtualProductToCartMine(request: ProductDetailsModule.AddSimpleOrVirtualProductToCartMine.Request, method: HTTPMethod, accessToken: String, customer_id: String, salon_id: String?) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenterCartWorker?.presentSomethingError(responseError: error)
        }
        let successHandler: (ProductDetailsModule.AddSimpleOrVirtualProductToCartMine.Response) -> Void = { (response) in
            print(response)
            self.presenterCartWorker?.presentSomethingSuccess(response: response)
        }

        var strEndPoint = ConstantAPINames.getQuoteIdMine.rawValue.replacingOccurrences(of: "$$$", with: "mine" )
        strEndPoint = String(format: "\(strEndPoint)/items?customer_id=%@&salon_id=%@", customer_id, salon_id ?? "0")

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
            self.presenterCartWorker?.presentSomethingError(responseError: error)
        }
        let successHandler: (ProductDetailsModule.AddSimpleOrVirtualProductToCartGuest.Response) -> Void = { (response) in
            print(response)

            if let messageObj = response.message, !messageObj.isEmpty {
                self.presenterCartWorker?.presentSomethingError(responseError: response.message)
                return
            }

            self.presenterCartWorker?.presentSomethingSuccess(response: response)
        }

        var strEndPoint = ConstantAPINames.addToCartGuest.rawValue
        strEndPoint = String(format: "\(strEndPoint)/%@/items?salon_id=%@", (request.cart_item?.quote_id)!, request.salon_id ?? "0")

        let emp1 = ProductDetailsModule.AddSimpleOrVirtualProductToCartGuest.Request(cart_item: request.cart_item, salon_id: request.salon_id)
        self.networkLayer.post(urlString: strEndPoint,
                               body: emp1, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }*/

    // MARK: AddConfigurableProductToCartMine
    func postRequestAddBulkProductToCartMine(request: ProductDetailsModule.AddBulkProductMine.Request, method: HTTPMethod, accessToken: String, customer_id: String) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenterCartWorker?.presentSomethingError(responseError: error)
        }
        let successHandler: (ProductDetailsModule.AddBulkProductMine.Response) -> Void = { (response) in
            print(response)
            self.presenterCartWorker?.presentSomethingSuccess(response: response)
        }

        var strEndPoint = ConstantAPINames.getQuoteIdMine.rawValue.replacingOccurrences(of: "$$$", with: "mine" )
//        if let salonID = salon_id, salonID.containsIgnoringCase(find: "0")
//        {
//            strEndPoint = String(format: "\(strEndPoint)/bulk/add")
//        }
//        else
//        {
//            strEndPoint = String(format: "\(strEndPoint)/bulk/add?salon_id=%@",salon_id ?? "0")
//        }
        strEndPoint = String(format: "\(strEndPoint)/bulk/add")

        self.networkLayer.post(urlString: strEndPoint,
                               body: request, headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }

    // MARK: AddConfigurableProductToCartGuest
    func postRequestAddBulkProductToCartGuest(request: ProductDetailsModule.AddBulkProductGuest.Request, method: HTTPMethod ) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenterCartWorker?.presentSomethingError(responseError: error)
        }
        let successHandler: (ProductDetailsModule.AddBulkProductGuest.Response) -> Void = { (response) in
            print(response)
            self.presenterCartWorker?.presentSomethingSuccess(response: response)
        }

        var strEndPoint = ConstantAPINames.addToCartGuest.rawValue

//        if salon_id.containsIgnoringCase(find: "0")
//        {
//            strEndPoint = String(format: "\(strEndPoint)/bulk/add")
//        }
//        else
//        {
//            strEndPoint = String(format: "\(strEndPoint)/bulk/add?salon_id=%@",salon_id)
//        }
        strEndPoint = String(format: "\(strEndPoint)/bulk/add")

        self.networkLayer.post(urlString: strEndPoint,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }

}
