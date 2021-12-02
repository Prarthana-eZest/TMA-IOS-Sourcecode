//
//  LocationModulePresenter.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol LocationModulePresentationLogic {
    func presentSomethingSuccess<T: Decodable>(response: T)
    func presentSomethingSuccessFor<T: Decodable>(response: [T])
    func presentSomethingError(responseError: String?)
}

class LocationModulePresenter: LocationModulePresentationLogic {
  weak var viewController: LocationModuleDisplayLogic?

  // MARK: Do something

    // MARK: Do something
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
