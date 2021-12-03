//
//  MoreModuleInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol MoreModuleBusinessLogic {
    func doPostGetStatusRequest(request: MoreModule.GetCheckInStatus.Request, method: HTTPMethod)
    func doPostMarkCheckInOutRequest(request: MoreModule.MarkCheckInOut.Request, method: HTTPMethod)
    func doPostCheckInOutDetailsRequest(request: MoreModule.CheckInOutDetails.Request, method: HTTPMethod)
}

protocol MoreModuleDataStore {
    //var name: String { get set }
}

class MoreModuleInteractor: MoreModuleBusinessLogic, MoreModuleDataStore {
    var presenter: MoreModulePresentationLogic?
    var worker: MoreModuleWorker?
    //var name: String = ""

    // MARK: Do something

    // MARK: Do something
    func doPostGetStatusRequest(request: MoreModule.GetCheckInStatus.Request, method: HTTPMethod) {
        worker = MoreModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestForCheckInStatus(request: request, method: method)
    }

    func doPostMarkCheckInOutRequest(request: MoreModule.MarkCheckInOut.Request, method: HTTPMethod) {
        worker = MoreModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestForMarkCheckInOut(request: request, method: method)
    }

    func doPostCheckInOutDetailsRequest(request: MoreModule.CheckInOutDetails.Request, method: HTTPMethod) {
        worker = MoreModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestForCheckInOutDetails(request: request, method: method)
    }

}
