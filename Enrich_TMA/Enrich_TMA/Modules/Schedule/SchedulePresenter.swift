//
//  SchedulePresenter.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 07/10/19.
//  Copyright (c) 2019 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SchedulePresentationLogic
{
  func presentSomething(response: Schedule.Something.Response)
}

class SchedulePresenter: SchedulePresentationLogic
{
  weak var viewController: ScheduleDisplayLogic?
  
  // MARK: Do something
  
  func presentSomething(response: Schedule.Something.Response)
  {
    let viewModel = Schedule.Something.ViewModel()
    viewController?.displaySomething(viewModel: viewModel)
  }
}
