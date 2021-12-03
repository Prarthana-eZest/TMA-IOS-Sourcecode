//
//  AchievementInteractor.swift
//  Enrich_TMA
//
//  Created by Harshal on 19/02/21.
//  Copyright (c) 2021 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol AchievementBusinessLogic
{
  func doSomething(request: Achievement.Something.Request)
}

protocol AchievementDataStore
{
  //var name: String { get set }
}

class AchievementInteractor: AchievementBusinessLogic, AchievementDataStore
{
  var presenter: AchievementPresentationLogic?
  var worker: AchievementWorker?
  //var name: String = ""
  
  // MARK: Do something
  
  func doSomething(request: Achievement.Something.Request)
  {
    worker = AchievementWorker()
    worker?.doSomeWork()
    
    let response = Achievement.Something.Response()
    presenter?.presentSomething(response: response)
  }
}