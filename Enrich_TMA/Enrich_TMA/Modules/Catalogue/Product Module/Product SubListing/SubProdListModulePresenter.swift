//
//  SubProdListModulePresenter.swift
//  EnrichSalon
//

import UIKit

//protocol SubProdListModulePresentationLogic{
//    func presentSomethingSuccess<T:Decodable>(response: T)
//    func presentSomethingError(responseError: String?)
//}
protocol SubProdListModulePresentationLogic: CartManagerPresentationLogic {
}

class SubProdListModulePresenter: SubProdListModulePresentationLogic {

    weak var viewController: SubProdListModuleDisplayLogic?

    func presentSomethingSuccess<T: Decodable>(response: T) {
        viewController?.displaySuccess(viewModel: response)
    }

    func presentSomethingError(responseError: String? ) {
        viewController?.displayError(errorMessage: responseError)
    }
    func presentSomethingSuccessFor<T: Decodable>(response: [T]) {
        viewController?.displaySuccess(responseSuccess: response)
    }
}
