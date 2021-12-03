//
//  LoginOTPModulePresenter.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.

import UIKit

protocol LoginOTPModulePresentationLogic {
    func presentSomethingSuccess<T: Decodable>(response: T)
    func presentSomethingError(responseError: String?)
}

class LoginOTPModulePresenter: LoginOTPModulePresentationLogic {

    weak var viewController: LoginOTPModuleDisplayLogic?

    // MARK: Do something
    func presentSomethingSuccess<T: Decodable>(response: T) {
        viewController?.displaySuccessLoginOTPModule(viewModel: response)
    }
    func presentSomethingError(responseError: String? ) {
        viewController?.displayErrorLoginOTPModule(errorMessage: responseError)
    }

}
