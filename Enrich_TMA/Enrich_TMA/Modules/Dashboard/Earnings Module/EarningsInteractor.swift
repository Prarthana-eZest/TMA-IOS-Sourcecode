//
//  EarningsInteractor.swift
//  Enrich_TMA
//
//  Created by Harshal on 13/12/21.
//  Copyright (c) 2021 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol EarningsBusinessLogic
{
  func doSomething(request: Earnings.Something.Request)
}

protocol EarningsDataStore
{
  //var name: String { get set }
}

class EarningsInteractor: EarningsBusinessLogic, EarningsDataStore
{
  var presenter: EarningsPresentationLogic?
  var worker: EarningsWorker?
  //var name: String = ""
  
  // MARK: Do something
  
  func doSomething(request: Earnings.Something.Request)
  {
    worker = EarningsWorker()
    worker?.doSomeWork()
    
    let response = Earnings.Something.Response()
    presenter?.presentSomething(response: response)
  }
}
