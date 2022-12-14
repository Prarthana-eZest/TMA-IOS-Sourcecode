//
//  MyProfilePresenter.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 16/10/19.
//  Copyright (c) 2019 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol MyProfilePresentationLogic
{
  func presentSomething(response: MyProfile.Something.Response)
}

class MyProfilePresenter: MyProfilePresentationLogic
{
  weak var viewController: MyProfileDisplayLogic?
  
  // MARK: Do something
  
  func presentSomething(response: MyProfile.Something.Response)
  {
    let viewModel = MyProfile.Something.ViewModel()
    viewController?.displaySomething(viewModel: viewModel)
  }
}
