//
//  PaymentModeInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol PaymentModeBusinessLogic {
    func doPostRequestOfflinePayment(accessToken: String, request: PaymentMode.OfflinePayment.Request)
    func doPostSubmitPaymentDetails(accessToken: String, request: PaymentMode.SubmitDetails.Request)
    func doPostUpdateAppointmentStatus(appointmentId: String, request: JobCard.ChangeAppointmentStatus.Request)
    func doPostSelectUnSelectWalletCash(request: PaymentMode.ApplyWalletCashOrNot.Request)
    func getCustomerWalletRewardPointAndPackages(customerId: String, quoteId: String)
    func doPostRequestRedeemPointsOrNot(request: PaymentMode.RedeemPointOrNot.Request)
    func doPostApplyGiftCard(request: PaymentMode.ApplyGiftCard.Request)
    func doPostApplyCoupon(request: PaymentMode.ApplyCoupon.Request)
}

class PaymentModeInteractor: PaymentModeBusinessLogic {

    var presenter: PaymentModePresentationLogic?
    var worker: PaymentModeWorker?

    func doPostRequestOfflinePayment(accessToken: String, request: PaymentMode.OfflinePayment.Request) {
        worker = PaymentModeWorker()
        worker?.presenter = self.presenter
        worker?.postRequestForOfflinePayment(accessToken: accessToken, request: request)
    }

    func doPostSubmitPaymentDetails(accessToken: String, request: PaymentMode.SubmitDetails.Request) {
        worker = PaymentModeWorker()
        worker?.presenter = self.presenter
        worker?.postRequestSubmitPaymentDetails(accessToken: accessToken, request: request)
    }

    func doPostUpdateAppointmentStatus(appointmentId: String, request: JobCard.ChangeAppointmentStatus.Request) {
        worker = PaymentModeWorker()
        worker?.presenter = self.presenter
        worker?.postRequestForChangeAppointmentStatus(appointmentId: appointmentId, request: request)
    }

    func doPostSelectUnSelectWalletCash(request: PaymentMode.ApplyWalletCashOrNot.Request) {
        worker = PaymentModeWorker()
        worker?.presenter = self.presenter
        worker?.postRequestToApplyWalletCashOrNot(request: request)
    }
    func getCustomerWalletRewardPointAndPackages(customerId: String, quoteId: String) {
        worker = PaymentModeWorker()
        worker?.presenter = self.presenter
        worker?.getCustomerWalletRewardPointAndPackages(customerId: customerId, quoteId: quoteId)
    }
    func doPostRequestRedeemPointsOrNot(request: PaymentMode.RedeemPointOrNot.Request) {
        worker = PaymentModeWorker()
        worker?.presenter = self.presenter
        worker?.postRequestRedeemPointsOrNot(request: request)
    }

    func doPostApplyGiftCard(request: PaymentMode.ApplyGiftCard.Request) {
        worker = PaymentModeWorker()
        worker?.presenter = self.presenter
        worker?.doApplyGiftCard(request: request)
    }

    func doPostApplyCoupon(request: PaymentMode.ApplyCoupon.Request) {
        worker = PaymentModeWorker()
        worker?.presenter = self.presenter
        worker?.doApplyCoupon(request: request)
    }
}
