//
//  AutoDiscountListInteractor.swift
//  Enrich_TMA
//
//  Created by Harshal on 31/07/20.
//  Copyright (c) 2020 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol AutoDiscountListBusinessLogic
{
    func doGetDiscountList(quote_id: String)
    func doPostApplyRemoveDiscount(request: AutoDiscountList.ApplyRemoveDiscount.Request)
}

class AutoDiscountListInteractor: AutoDiscountListBusinessLogic
{
    var presenter: AutoDiscountListPresentationLogic?
    var worker: AutoDiscountListWorker?
    //var name: String = ""
    
    // MARK: Do something
    
    func doGetDiscountList(quote_id: String)
    {
        worker = AutoDiscountListWorker()
        worker?.presenter = self.presenter
        worker?.getDiscountList(quote_id: quote_id)
    }
    
    func doPostApplyRemoveDiscount(request: AutoDiscountList.ApplyRemoveDiscount.Request)
    {
        worker = AutoDiscountListWorker()
        worker?.presenter = self.presenter
        worker?.doApplyRemoveDiscount(request: request)
    }

}