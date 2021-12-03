//
//  ManageAddressModuleWorker.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class ManageAddressModuleWorker {
    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    // let networkLayer = NetworkLayer() // Uncomment this in case do request using URLsession
    var presenter: ManageAddressModulePresentationLogic?

    // MARK: deleteAddress
    func deleteAddress(accessToken: String, addressId: Int64) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (ManageAddressModule.DeleteAddress.Response) -> Void = { (response) in
            print(response)
            self.presenter?.presentSuccess(response: response)
        }

        let strEndPoint = String(format: "%@/%d?is_custom=true", ConstantAPINames.addUpdateAddress.rawValue, addressId)
        self.networkLayer.post(urlString: strEndPoint,
                               body: ManageAddressModule.DeleteAddress.Request(), headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler,
                               errorHandler: errorHandler, method: .delete)

    }
    func getStatesRequest(region: String) {

        let successHandler: (AddNewAddressModule.GetStates.Response) -> Void = { (responseServer) in
            if let messageObj = responseServer.message, !messageObj.isEmpty {
                self.presenter?.presentError(responseError: messageObj)
                return
            }
            self.presenter?.presentSuccess(response: responseServer)
        }

        let errorHandler: (String) -> Void = { (error) in
            self.presenter?.presentError(responseError: error)
        }
        let strEndPoint = String(format: "%@/%@", ConstantAPINames.getStates.rawValue, region)
        self.networkLayer.get(urlString: strEndPoint,
                              successHandler: successHandler,
                              errorHandler: errorHandler)
    }
    // MARK: postRequestToAddNewAddress
    func postRequestToAddNewAddress(request: AddNewAddressModule.AddAddress.Request, accessToken: String) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (AddNewAddressModule.AddAddress.Response) -> Void = { (responseServer) in
            self.presenter?.presentSuccess(response: responseServer)
        }
        
        let url = ConstantAPINames.addUpdateAddress.rawValue + (request.address?.customer_id ?? "")

        self.networkLayer.post(urlString: url,
                               body: request,
                               headers: ["Authorization": "Bearer \(accessToken)"],
                               successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    // MARK: putRequestToUpdateAddress
    func putRequestToUpdateAddress(request: AddNewAddressModule.UpdateAddress.Request, accessToken: String) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (AddNewAddressModule.AddAddress.Response) -> Void = { (responseServer) in
            self.presenter?.presentSuccess(response: responseServer)
        }
        
        let url = ConstantAPINames.addUpdateAddress.rawValue + (request.address?.customer_id ?? "")

        self.networkLayer.post(urlString: url,
                               body: request,
                               headers: ["Authorization": "Bearer \(accessToken)"],
                               successHandler: successHandler,
                               errorHandler: errorHandler, method: .put)
    }

    func getRequestToGetCustomerInformation(request: ManageAddressModule.CustomerInformation.Request, accessToken: String) {

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentError(responseError: error)
        }
        let successHandler: (ManageAddressModule.CustomerAddress.Response) -> Void = { (response) in
            print(response)
            if let messageObj = response.message, !messageObj.isEmpty {
                self.presenter?.presentError(responseError: response.message)
                return
            }
            self.presenter?.presentSuccess(response: response)
        }

       // let url = ConstantAPINames.getCustomerAddressDetails.rawValue + "?customer_id=\(request.customer_id)"
        let url = ConstantAPINames.getCustomerAddressDetails.rawValue + request.customer_id

        self.networkLayer.get(urlString: url,
            headers: ["Authorization": "Bearer \(accessToken)"],
            successHandler: successHandler,
            errorHandler: errorHandler)
    }

}
