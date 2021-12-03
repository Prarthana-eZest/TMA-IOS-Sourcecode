//
//  AvailMyPackagesModuleInteractor.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

protocol AvailMyPackagesModuleBusinessLogic {
    func applyValuePackages(request: AvailMyPackagesModule.ApplyPackages.RequestValuePackage)
    func applyServicePackages(request: AvailMyPackagesModule.ApplyPackages.RequestServicePackage)
    func removeValueOrServicePackage(request: AvailMyPackagesModule.RemovePackages.RequestRemovePackages)
}

protocol AvailMyPackagesModuleDataStore {
  //var name: String { get set }
}

class AvailMyPackagesModuleInteractor: AvailMyPackagesModuleBusinessLogic, AvailMyPackagesModuleDataStore {
  var presenter: AvailMyPackagesModulePresentationLogic?
  var worker: AvailMyPackagesModuleWorker?

    func applyValuePackages(request: AvailMyPackagesModule.ApplyPackages.RequestValuePackage) {
        worker = AvailMyPackagesModuleWorker()
        worker?.presenter = self.presenter
        worker?.applyValuePackages(request: request)

    }
    func applyServicePackages(request: AvailMyPackagesModule.ApplyPackages.RequestServicePackage) {
        worker = AvailMyPackagesModuleWorker()
        worker?.presenter = self.presenter
        worker?.applyServicePackages(request: request)
    }
    func removeValueOrServicePackage(request: AvailMyPackagesModule.RemovePackages.RequestRemovePackages) {
        worker = AvailMyPackagesModuleWorker()
        worker?.presenter = self.presenter
        worker?.removeValueOrServicePackage(request: request)

    }

}
