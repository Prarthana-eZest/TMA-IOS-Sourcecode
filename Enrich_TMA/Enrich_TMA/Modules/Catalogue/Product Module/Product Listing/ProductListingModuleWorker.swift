//
//  ProductListingModuleWorker.swift
//  EnrichSalon
//

import UIKit

class ProductListingModuleWorker {
    let networkLayer = NetworkLayerAlamofire()
    var presenter: ProductListingModulePresentationLogic?

    // MARK: - Add to wishlist api call
    func postRequestAddToWishList(request: HairTreatmentModule.Something.AddToWishListRequest, accessToken: String) {
        // Error handling redirection
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }

        // Success handling redirection
        let successHandler: (HairTreatmentModule.Something.AddToWishListResponse) -> Void = { (responseModel) in
            print(responseModel)

            if(responseModel.status == false) {
                self.presenter?.presentSomethingError(responseError: responseModel.message)
                EZLoadingActivity.hide(true, animated: false)
                return
            }

            let response = responseModel
            self.presenter?.presentSomethingSuccess(response: response)
        }

        // POST : API call (<baseurl>/wishlist/add)
        self.networkLayer.post(urlString: ConstantAPINames.addWishList.rawValue,
                               body: request, headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }

    func postRequestRemovefromWishList(request: HairTreatmentModule.Something.RemoveFromWishListRequest, accessToken: String) {
        // Error handling redirection
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)

        }

        // Success handling redirection
        let successHandler: (HairTreatmentModule.Something.RemoveFromWishListResponse) -> Void = { (responseModel) in
            print(responseModel)

            if(responseModel.status == false) {
                self.presenter?.presentSomethingError(responseError: responseModel.message)
                EZLoadingActivity.hide(true, animated: false)
                return
            }

            let response = responseModel
            self.presenter?.presentSomethingSuccess(response: response)
        }

        // POST : API call (<baseurl>/wishlist/delete)
        self.networkLayer.post(urlString: ConstantAPINames.removeFromWishList.rawValue,
                               body: request, headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    func getRequestWithParameter(request: HairTreatmentModule.Something.Request, isBestSeller: Bool) {

        // Error handling redirection
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }

        // Success handling redirection
        let successHandler: (HairTreatmentModule.Something.Response) -> Void = { (employees) in
            print(employees)
            //self.view?.displayEmployees(employees: employees)
            self.presenter?.presentSomethingSuccess(response: employees)
        }

        // URL <baseurl>/products/?<appendFilters>
        var strURL: String = ConstantAPINames.productDetails.rawValue
        if isBestSeller {
            strURL = ConstantAPINames.bestsellerproducts.rawValue
        }
        strURL = strURL + request.queryString
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        // GET : API call
        self.networkLayer.get(urlString: strURL, successHandler: successHandler, errorHandler: errorHandler)
    }

}
