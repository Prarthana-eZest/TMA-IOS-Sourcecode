//
//  BonusPresenter.swift
//  Enrich_TMA
//
//  Created by Harshal on 21/12/21.
//  Copyright (c) 2021 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol BonusPresentationLogic
{
  func presentSomething(response: Bonus.Something.Response)
}

class BonusPresenter: BonusPresentationLogic
{
  weak var viewController: BonusDisplayLogic?
  
  // MARK: Do something
  
  func presentSomething(response: Bonus.Something.Response)
  {
    let viewModel = Bonus.Something.ViewModel()
    viewController?.displaySomething(viewModel: viewModel)
  }
}
