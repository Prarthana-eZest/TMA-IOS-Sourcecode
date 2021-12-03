//
//  PaymentModePresenter.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol PaymentModePresentationLogic {
    func presentOfflinePaymentSuccess<T: Decodable>(response: T)
    func presentUpdateAppointmentStatus<T: Decodable>(response: T)
    func presentSubmitPaymentDetailsSuccess<T: Decodable>(response: T)
    func presentSelectUnSelectWalletCashSuccess<T: Decodable>(response: T)
    func presentGetMyWalletRewardPointAndPackagesSuccess<T: Decodable>(response: T)
    func presentRedeemPointsOrNotSuccess<T: Decodable>(response: T)
    func presentSuccess<T: Decodable>(response: T)
    func presentError(responseError: String?)
}

class PaymentModePresenter: PaymentModePresentationLogic {

    weak var viewController: PaymentModeDisplayLogic?

    // MARK: Do something
    func presentOfflinePaymentSuccess<T: Decodable>(response: T) {
        viewController?.displaySuccess(viewModel: response)
    }

    func presentSubmitPaymentDetailsSuccess<T: Decodable>(response: T) {
        viewController?.displaySuccess(viewModel: response)
    }
    func presentError(responseError: String? ) {
        viewController?.displayError(errorMessage: responseError)
    }

    func presentUpdateAppointmentStatus<T>(response: T) where T: Decodable {
        viewController?.displaySuccess(viewModel: response)
    }

    func presentSelectUnSelectWalletCashSuccess<T>(response: T) where T: Decodable {
        viewController?.displaySuccess(viewModel: response)
    }

    func presentGetMyWalletRewardPointAndPackagesSuccess<T>(response: T) where T: Decodable {
        viewController?.displaySuccess(viewModel: response)
    }

    func presentRedeemPointsOrNotSuccess<T>(response: T) where T: Decodable {
        viewController?.displaySuccess(viewModel: response)
    }

    func presentSuccess<T: Decodable>(response: T) {
        viewController?.displaySuccess(viewModel: response)
    }

}
