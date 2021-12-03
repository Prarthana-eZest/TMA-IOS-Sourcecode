//
//  ProductListingModuleWorker.swift
//  EnrichSalon
//

import UIKit

class ProductListingModuleWorker {
    let networkLayer = NetworkLayerAlamofire()
    var presenter: ProductListingModulePresentationLogic?

    func getRequestWithParameter(request: HairTreatmentModule.Something.Request, isBestSeller: Bool) {

        // Error handling redirection
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }

        // Success handling redirection
        let successHandler: (HairTreatmentModule.Something.Response) -> Void = { (employees) in
            print(employees)
            //self.view?.displayEmployees(employees: employees)
            self.presenter?.presentSomethingSuccess(response: employees)
        }

        // URL <baseurl>/products/?<appendFilters>
        var strURL: String = ConstantAPINames.getRelatedBOMProducts.rawValue
        if isBestSeller {
            strURL = ConstantAPINames.bestsellerproducts.rawValue
        }
        strURL += request.queryString
      //  strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        // GET : API call
        self.networkLayer.get(urlString: strURL, successHandler: successHandler, errorHandler: errorHandler)
    }
    // MARK: postToGetMemberShipBenefits
    func postToGetMemberShipBenefits(request: ClubMembershipModule.MembershipKnowMore.Request) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (ClubMembershipModule.MembershipKnowMore.Response) -> Void = { (response) in
            print(response)
            self.presenter?.presentSomethingSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.memberShipBenefits.rawValue,
                               body: request.self, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }
    func getRequestForMembershipDetails(request: ClubMembershipModule.MembershipDetails.Request) {

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }

        let successHandler: (ClubMembershipModule.MembershipDetails.Response) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }

        self.networkLayer.get(urlString: ConstantAPINames.membershipDetails.rawValue,
                              headers: ["Authorization": "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"],
                              successHandler: successHandler, errorHandler: errorHandler)
    }

    // MARK: postToFiltersData
    func postToFiltersData(request: HairServiceModule.filtersAPI.Request) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (HairServiceModule.filtersAPI.Response) -> Void = { (response) in
            print(response)
            self.presenter?.presentSomethingSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.filtersAPI.rawValue,
                               body: request.self, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }

}
