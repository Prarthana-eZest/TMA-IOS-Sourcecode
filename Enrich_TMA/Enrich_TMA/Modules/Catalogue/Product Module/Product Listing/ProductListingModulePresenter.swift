//
//  ProductListingModulePresenter.swift
//  EnrichSalon
//

import UIKit

protocol ProductListingModulePresentationLogic: CartManagerPresentationLogic {
}

class ProductListingModulePresenter: ProductListingModulePresentationLogic {
    weak var viewController: ProductListingModuleDisplayLogic?

    func presentSomethingSuccessFor<T: Decodable>(response: [T]) {
        viewController?.displaySuccess(responseSuccess: response)
    }
    func presentSomethingSuccess<T: Decodable>(response: T) {
        viewController?.displaySuccess(viewModel: response)
    }
    func presentSomethingError(responseError: String? ) {
        viewController?.displayError(errorMessage: responseError)
    }
}
