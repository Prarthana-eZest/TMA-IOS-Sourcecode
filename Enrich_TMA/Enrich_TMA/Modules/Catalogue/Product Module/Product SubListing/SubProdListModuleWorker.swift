//
//  SubProdListModuleWorker.swift
//  EnrichSalon
//

import UIKit

class SubProdListModuleWorker {
    let networkLayer = NetworkLayerAlamofire()
    var presenter: SubProdListModulePresentationLogic?

    // MARK: Shop by hairtypes api call
    func postRequestTypes(request: SubProdListModule.Categories.RequestTypes) {

        // Error handling redirection
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }

        // Success handling redirection
        let successHandler: (SubProdListModule.Categories.ResponseTypes) -> Void = { (response) in
            print(response)
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
        let successHandler: (ProductLandingModule.Something.ProductCategoryResponse) -> Void = { (response) in
            print(response)
            self.presenter?.presentSomethingSuccess(response: response)
        }

        // POST : API call (<baseurl>/categories/children)
        self.networkLayer.post(urlString: ConstantAPINames.salonServiceCategory.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

}
