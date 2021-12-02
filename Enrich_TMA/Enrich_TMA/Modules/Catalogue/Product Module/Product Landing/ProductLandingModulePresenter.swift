//
//  ProductLandingModulePresenter.swift
//  EnrichSalon
//

import UIKit

protocol ProductLandingModulePresentationLogic: CartManagerPresentationLogic {
}

class ProductLandingModulePresenter: ProductLandingModulePresentationLogic {
    weak var viewController: ProductLandingModuleDisplayLogic?

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
