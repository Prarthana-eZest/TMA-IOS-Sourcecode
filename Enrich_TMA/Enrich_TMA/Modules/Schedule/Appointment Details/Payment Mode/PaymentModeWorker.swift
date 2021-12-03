//
//  PaymentModeWorker.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class PaymentModeWorker {

    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    // let networkLayer = NetworkLayer() // Uncomment this in case do request using URLsession
    var presenter: PaymentModePresentationLogic?

    func postRequestForOfflinePayment(accessToken: String, request: PaymentMode.OfflinePayment.Request) {

        let errorHandler: (String) -> Void = { (error) in
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (PaymentMode.OfflinePayment.Response) -> Void = { (response) in
            self.presenter?.presentOfflinePaymentSuccess(response: response)
        }

        let url = ConstantAPINames.offlinePaymnet.rawValue

        self.networkLayer.post(urlString: url, body: request, headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler, errorHandler: errorHandler, method: .post)
    }

    func postRequestSubmitPaymentDetails(accessToken: String, request: PaymentMode.SubmitDetails.Request) {

        let errorHandler: (String) -> Void = { (error) in
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (PaymentMode.SubmitDetails.Response) -> Void = { (response) in
            self.presenter?.presentSubmitPaymentDetailsSuccess(response: response)
        }

        let url = ConstantAPINames.submitPaymentDetails.rawValue

        self.networkLayer.post(urlString: url, body: request, headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler, errorHandler: errorHandler, method: .post)
    }

    func postRequestForChangeAppointmentStatus(appointmentId: String, request: JobCard.ChangeAppointmentStatus.Request) {

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (JobCard.ChangeAppointmentStatus.Response) -> Void = { (response) in
            print(response)
            self.presenter?.presentUpdateAppointmentStatus(response: response)
        }

        let url = ConstantAPINames.changeAppointmentStatus.rawValue + appointmentId

        self.networkLayer.post(urlString: url, body: request,
                               headers: ["X-Request-From": "tma", "Authorization": "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"],
                               successHandler: successHandler, errorHandler: errorHandler, method: .post)

    }

    func postRequestToApplyWalletCashOrNot(request: PaymentMode.ApplyWalletCashOrNot.Request) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (PaymentMode.ApplyWalletCashOrNot.Response) -> Void = { (response) in
            self.presenter?.presentSelectUnSelectWalletCashSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.applyAndRemoveWallet.rawValue,
                               body: request, headers: ["Authorization": "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"], successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    func getCustomerWalletRewardPointAndPackages(customerId: String, quoteId: String) {

        let errorHandler: (String) -> Void = { (error) in
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (PaymentMode.MyWalletRewardPointsPackages.Response) -> Void = { (response) in
            self.presenter?.presentGetMyWalletRewardPointAndPackagesSuccess(response: response)
        }

        var strURL: String = "\(ConstantAPINames.myPaymentScreenPOS.rawValue)&customer_id=\(customerId)&cart_id=\(quoteId)"

        strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""

        self.networkLayer.get(urlString: strURL, headers: ["Authorization": "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"],
                              successHandler: successHandler, errorHandler: errorHandler)

    }

    // MARK: postRequestPayOnline
    func postRequestRedeemPointsOrNot(request: PaymentMode.RedeemPointOrNot.Request) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (PaymentMode.RedeemPointOrNot.Response) -> Void = { (response) in
            self.presenter?.presentRedeemPointsOrNotSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.applyOrReedemPointsOnPaymentsScreen.rawValue,
                               body: request, headers: ["Authorization": "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"], successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    func doApplyGiftCard(request: PaymentMode.ApplyGiftCard.Request) {

        let errorHandler: (String) -> Void = { (error) in
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (PaymentMode.ApplyGiftCard.Response) -> Void = { (response) in
            self.presenter?.presentSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.applyGiftCard.rawValue, body: request,
                               headers: ["Authorization": "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"],
                               successHandler: successHandler, errorHandler: errorHandler, method: .post)
    }

    func doApplyCoupon(request: PaymentMode.ApplyCoupon.Request) {

        let errorHandler: (String) -> Void = { (error) in
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (PaymentMode.ApplyCoupon.Response) -> Void = { (response) in
            self.presenter?.presentSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.applyCoupon.rawValue, body: request,
                               headers: ["Authorization": "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"],
                               successHandler: successHandler, errorHandler: errorHandler, method: .post)
    }

}
