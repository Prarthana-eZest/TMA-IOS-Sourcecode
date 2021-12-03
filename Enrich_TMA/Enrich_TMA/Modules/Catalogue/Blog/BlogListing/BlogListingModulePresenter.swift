//
//  BlogListingModulePresenter.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol BlogListingModulePresentationLogic {
    func presentFeaturedVideos<T: Decodable>(response: T)
    func presentSomethingSuccess<T: Decodable>(response: T)
    func presentSomethingSuccessFor<T: Decodable>(response: [T])
    func presentSomethingError(responseError: String?)
}

class BlogListingModulePresenter: BlogListingModulePresentationLogic {
    weak var viewController: BlogListingModuleDisplayLogic?

    func presentFeaturedVideos<T: Decodable>(response: T) {
        viewController?.displaySuccessFeaturedVideos(viewModel: response)
    }

    func presentSomethingSuccess<T: Decodable>(response: T) {
        viewController?.displaySuccess(viewModel: response)
    }
    func presentSomethingSuccessFor<T: Decodable>(response: [T]) {
        viewController?.displaySuccess(responseSuccess: response)
    }
    func presentSomethingError(responseError: String? ) {
        viewController?.displayError(errorMessage: responseError)
    }
}
