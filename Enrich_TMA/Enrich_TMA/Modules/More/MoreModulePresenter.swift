//
//  MoreModulePresenter.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol MoreModulePresentationLogic {
    func presentSuccess<T: Decodable>(response: T)
    func presentSuccessFor<T: Decodable>(response: [T])
    func presentError(responseError: String?)
}

class MoreModulePresenter: MoreModulePresentationLogic {
    weak var viewController: MoreModuleDisplayLogic?

    // MARK: Do something

    func presentSuccess<T: Decodable>(response: T) {
        viewController?.displaySuccess(viewModel: response)
    }
    func presentError(responseError: String? ) {
        viewController?.displayError(errorMessage: responseError)
    }
    func presentSuccessFor<T: Decodable>(response: [T]) {
        viewController?.displaySuccess(responseSuccess: response)
    }
}
