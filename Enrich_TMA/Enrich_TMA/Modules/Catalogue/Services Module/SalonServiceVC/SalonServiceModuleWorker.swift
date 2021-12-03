//
//  SalonServiceModuleWorker.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class SalonServiceModuleWorker {
    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    // let networkLayer = NetworkLayer() // Uncomment this in case do request using URLsession
    var presenter: SalonServiceModulePresentationLogic?

    func postRequest(request: SalonServiceModule.Something.Request) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (SalonServiceModule.Something.Response) -> Void = { (responseModel) in
            print(responseModel)

            if responseModel.status == false {
                self.presenter?.presentSomethingError(responseError: responseModel.message)
                EZLoadingActivity.hide(true, animated: false)
                return
            }

            let response = responseModel
            self.presenter?.presentSomethingSuccess(response: response)
        }

//        var strURL = ConstantAPINames.salonServiceCategory.rawValue
//
//
//        if  let dummy = UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_Key_SelectedLocationFor.rawValue){
//            let obj = dummy as! String
//            if( obj == SalonServiceAt.home.rawValue)
//            {
//                strURL = strURL.replacingOccurrences(of: "$$$", with: "91")
//
//          }
//            if( obj == SalonServiceAt.Salon.rawValue)
//            {
//                strURL = strURL.replacingOccurrences(of: "$$$", with: "34")
//
//            }
//        }
////        strURL = strURL.replacingOccurrences(of: "$$$", with: request.salon_id)
//        self.networkLayer.post(urlString: strURL,
//                               body: request, successHandler: successHandler,
//                               errorHandler: errorHandler)
        //let emp1 = SalonServiceModule.Something.Request(category_id: request.category_id, salon_id: request.salon_id, gender: request.gender)

        self.networkLayer.post(urlString: ConstantAPINames.salonServiceCategory.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }

    func postRequestTestimonials(request: SalonServiceModule.Something.TestimonialRequest) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (SalonServiceModule.Something.TestimonialResponse) -> Void = { (responseModel) in
            print(responseModel)

            if responseModel.status == false {
                self.presenter?.presentSomethingError(responseError: responseModel.message)
                EZLoadingActivity.hide(true, animated: false)
                return
            }

            let response = responseModel
            self.presenter?.presentSomethingSuccess(response: response)
        }

       // let emp1 = SalonServiceModule.Something.TestimonialRequest.init(limit: request.limit)
        self.networkLayer.post(urlString: ConstantAPINames.salonTestimonials.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }

    func getServiceCategory(request: HairTreatmentModule.Something.Request) {

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (HairTreatmentModule.Something.Response) -> Void = { (employees) in
            print(employees)
            self.presenter?.presentSomethingSuccess(response: employees)
        }

        var strURL: String = ConstantAPINames.productCategory.rawValue
        strURL += request.queryString
        //strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        self.networkLayer.get(urlString: strURL, headers: AuthorizationHeaders, successHandler: successHandler, errorHandler: errorHandler)

    }

    func postRequestSalonServiceCategory(request: HairServiceModule.Something.Request) {

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (HairServiceModule.Something.Response) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }

        // let emp1 = HairServiceModule.Something.Request.init(category_id: request.category_id, salon_id: request.salon_id, gender: request.gender)
        self.networkLayer.post(urlString: ConstantAPINames.salonServiceCategory.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }
    func getProductDetails(request: ServiceDetailModule.ServiceDetails.Request) {

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (ServiceDetailModule.ServiceDetails.Response) -> Void = { (employees) in
            print(employees)
            self.presenter?.presentSomethingSuccess(response: employees)
        }

        var strURL: String = ConstantAPINames.getRelatedBOMProducts.rawValue
        strURL += request.requestedParameters
        strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        self.networkLayer.get(urlString: strURL, successHandler: successHandler, errorHandler: errorHandler)

    }
    // getRequestForSelectedService
    func getRequestForSelectedService(request: HairTreatmentModule.Something.Request) {

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (HairTreatmentModule.Something.Response) -> Void = { (employees) in
            print(employees)
            self.presenter?.presentSomethingSuccess(response: employees)
        }

        var strURL: String = ConstantAPINames.productCategory.rawValue
        strURL += request.queryString
       // strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        self.networkLayer.get(urlString: strURL, headers: AuthorizationHeaders, successHandler: successHandler, errorHandler: errorHandler)

    }
    // MARK: GetInsight Request
    func postRequestBlogs(request: ProductLandingModule.Something.Request) {
        // *********** NETWORK CONNECTION
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (ProductLandingModule.Something.ResponseBlogs) -> Void = { (responseBlogs) in
            print(responseBlogs)
            let response = responseBlogs
            self.parseBlogData(data: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.blogList.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }
    func parseBlogData(data: ProductLandingModule.Something.ResponseBlogs) {

        var arrBlogsModel: [GetInsightFulDetails] = []

        if let dataObj = data.data, let blogs = dataObj.blogs {
            for model in blogs {
                arrBlogsModel.append(GetInsightFulDetails(titleString: model.title!, date: model.publish_time!, imageURL: model.featured_img ?? "", blogId: model.post_id!))
            }
        }

        let dict: [String: Any] = ["data": data, "showmodel": arrBlogsModel]
        print("dict blogs : \(dict)")
        self.presenter?.presentSomethingSuccess(response: data)
    }
    // MARK: Product Review Request
    func postProductReviewsRequest(request: ServiceDetailModule.ServiceDetails.ProductReviewRequest) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (ServiceDetailModule.ServiceDetails.ProductReviewResponse) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.productReview.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    // MARK: Frequently Availed Service Request
    func postFrequentlyAvailedRequest(request: ServiceDetailModule.ServiceDetails.FrequentlyAvailedProductRequest) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (ServiceDetailModule.ServiceDetails.FrequentlyAvailedProductResponse) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }

        let emp1 = ServiceDetailModule.ServiceDetails.FrequentlyAvailedProductRequest()
        self.networkLayer.post(urlString: ConstantAPINames.frquentlyAvailedProduct.rawValue,
                               body: emp1, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    // MARK: RateAService Request
    func postRateAServiceRequest(request: ServiceDetailModule.ServiceDetails.RateAServiceRequest) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (ServiceDetailModule.ServiceDetails.RateAServiceResponse) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }

        //let emp1 = ServiceDetailModule.ServiceDetails.RateAServiceRequest(customer_id: request.customer_id, product_id: request.product_id, rating: request.rating, summary: request.summary, message: request.message)

        self.networkLayer.post(urlString: ConstantAPINames.rateAService.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    func postRequestNewServiceCategory(request: HairServiceModule.NewServiceCategory.Request) {

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (HairServiceModule.NewServiceCategory.Response) -> Void = { (employees) in

            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.newServiceCategoryAPI.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }

}
