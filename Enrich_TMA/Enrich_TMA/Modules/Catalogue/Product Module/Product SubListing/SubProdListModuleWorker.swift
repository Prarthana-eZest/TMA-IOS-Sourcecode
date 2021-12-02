//
//  SubProdListModuleWorker.swift
//  EnrichSalon
//

import UIKit

class SubProdListModuleWorker {
    let networkLayer = NetworkLayerAlamofire()
    var presenter: SubProdListModulePresentationLogic?

    // MARK: Add to wishlist api call
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
                               body: request, headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler,errorHandler: errorHandler, method: .post)
    }

    // MARK: Remove to wishlist api call
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

    // MARK: Shop by hairtypes api call
    func postRequestTypes(request: SubProdListModule.Categories.RequestTypes) {

        // Error handling redirection
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }

        // Success handling redirection
        let successHandler: (SubProdListModule.Categories.ResponseTypes) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }

        // POST : API call (<baseurl>/products/shop-by)
        self.networkLayer.post(urlString: ConstantAPINames.productsShopby.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    // MARK: Sub-Category api call
    func postRequestProductCategory(request: ProductLandingModule.Something.ProductCategoryRequest) {

        // Error handling redirection
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }

        // Success handling redirection
        let successHandler: (ProductLandingModule.Something.ProductCategoryResponse) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }

        // POST : API call (<baseurl>/categories/children)
        self.networkLayer.post(urlString: ConstantAPINames.salonServiceCategory.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

}
