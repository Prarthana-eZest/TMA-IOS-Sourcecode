//
//  AttendanceDetailsInteractor.swift
//  Enrich_TMA
//
//  Created by Harshal on 24/02/21.
//  Copyright (c) 2021 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol AttendanceDetailsBusinessLogic
{
  func doSomething(request: AttendanceDetails.Something.Request)
}

protocol AttendanceDetailsDataStore
{
  //var name: String { get set }
}

class AttendanceDetailsInteractor: AttendanceDetailsBusinessLogic, AttendanceDetailsDataStore
{
  var presenter: AttendanceDetailsPresentationLogic?
  var worker: AttendanceDetailsWorker?
  //var name: String = ""
  
  // MARK: Do something
  
  func doSomething(request: AttendanceDetails.Something.Request)
  {
    worker = AttendanceDetailsWorker()
    worker?.doSomeWork()
    
    let response = AttendanceDetails.Something.Response()
    presenter?.presentSomething(response: response)
  }
}