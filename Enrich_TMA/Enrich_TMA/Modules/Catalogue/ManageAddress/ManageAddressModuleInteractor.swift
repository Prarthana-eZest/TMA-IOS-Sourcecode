//
//  ManageAddressModuleInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol ManageAddressModuleBusinessLogic {
    func doGetRequestToGetInformationOfLoggedInCustomer(request: ManageAddressModule.CustomerInformation.Request, accessToken: String)
    func doDeleteAddress(accessToken: String, addressId: Int64)
    func doPostRequestAddNewAddress(request: AddNewAddressModule.AddAddress.Request, accessToken: String)
    func doPutRequestToUpdateAddress(request: AddNewAddressModule.UpdateAddress.Request, accessToken: String)
    func doGetStatesRequest(region: String)

}

protocol ManageAddressModuleDataStore {
    //var name: String { get set }
}

class ManageAddressModuleInteractor: ManageAddressModuleBusinessLogic, ManageAddressModuleDataStore {
    var presenter: ManageAddressModulePresentationLogic?
    var worker: ManageAddressModuleWorker?

    //var name: String = ""

    func doGetRequestToGetInformationOfLoggedInCustomer(request: ManageAddressModule.CustomerInformation.Request, accessToken: String) {
        worker = ManageAddressModuleWorker()
        worker?.presenter = self.presenter
        worker?.getRequestToGetCustomerInformation(request: request, accessToken: accessToken)
    }
    func doDeleteAddress(accessToken: String, addressId: Int64) {
        worker = ManageAddressModuleWorker()
        worker?.presenter = self.presenter
        worker?.deleteAddress(accessToken:
            accessToken, addressId: addressId)
    }
    func doGetStatesRequest(region: String) {
        worker = ManageAddressModuleWorker()
        worker?.presenter = self.presenter
        worker?.getStatesRequest(region: region)
    }
    func doPostRequestAddNewAddress(request: AddNewAddressModule.AddAddress.Request, accessToken: String) {
        worker = ManageAddressModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestToAddNewAddress(request: request, accessToken: accessToken)
    }
    func doPutRequestToUpdateAddress(request: AddNewAddressModule.UpdateAddress.Request, accessToken: String) {
        worker = ManageAddressModuleWorker()
        worker?.presenter = self.presenter
        worker?.putRequestToUpdateAddress(request: request, accessToken: accessToken)
    }

}
