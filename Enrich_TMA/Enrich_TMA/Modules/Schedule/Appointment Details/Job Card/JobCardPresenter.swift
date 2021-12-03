//
//  JobCardPresenter.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 11/11/19.
//  Copyright (c) 2019 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol JobCardPresentationLogic {
    func presentGetAppointmentsSuccess<T: Decodable>(response: T)
    func presentGetBOMSuccess<T: Decodable>(response: T)
    func presentStartServiceSuccess<T: Decodable>(response: T)
    func presentUpdateBOMSuccess<T: Decodable>(response: T)
    func presentServiceDescription<T: Decodable>(response: T)
    func presentGetAppointmentStatus<T: Decodable>(response: T)
    func presentError(responseError: String?)
}

class JobCardPresenter: JobCardPresentationLogic {

  weak var viewController: JobCardDisplayLogic?

  // MARK: Do something

    func presentGetAppointmentsSuccess<T>(response: T) where T: Decodable {
        viewController?.displaySuccess(viewModel: response)
    }

    func presentGetBOMSuccess<T>(response: T) where T: Decodable {
        viewController?.displaySuccess(viewModel: response)
    }

    func presentError(responseError: String?) {
        viewController?.displayError(errorMessage: responseError)
    }

    func presentUpdateBOMSuccess<T: Decodable>(response: T) {
        viewController?.displayCompleteServiceSuccess(viewModel: response)
    }

    func presentStartServiceSuccess<T: Decodable>(response: T) {
        viewController?.displayStartServiceSuccess(viewModel: response)
    }

    func presentServiceDescription<T: Decodable>(response: T) {
        viewController?.displayServiceDescriptionSuccess(viewModel: response)
    }

    func presentUpdateAppointmentStatus<T: Decodable>(response: T) {
        viewController?.displaySuccess(viewModel: response)
    }

    func presentGetAppointmentStatus<T>(response: T) where T: Decodable {
        viewController?.displayGetAppointmentStatus(viewModel: response)
    }
}