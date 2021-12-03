//
//  LoginModulePresenter.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol LoginModulePresentationLogic {
    func presentSuccess<T: Decodable>(response: T)
    func presentError(responseError: String?)
}

class LoginModulePresenter: LoginModulePresentationLogic {
  weak var viewController: LoginModuleDisplayLogic?

  // MARK: Do something

    // MARK: Do something
    func presentSuccess<T: Decodable>(response: T) {
        viewController?.displaySuccess(viewModel: response)
    }
    func presentError(responseError: String? ) {
        viewController?.displayError(errorMessage: responseError)
    }

}
