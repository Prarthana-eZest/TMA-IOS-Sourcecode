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
    func presentLoginSuccess<T: Decodable>(response: T)
    func presentLoginError(responseError: String?)
}

class LoginModulePresenter: LoginModulePresentationLogic {
  weak var viewController: LoginModuleDisplayLogic?

  // MARK: Do something

    // MARK: Do something
    func presentLoginSuccess<T: Decodable>(response: T) {
        viewController?.displaySuccess(viewModel: response)
    }
    func presentLoginError(responseError: String? ) {
        viewController?.displayError(errorMessage: responseError)
    }

}
