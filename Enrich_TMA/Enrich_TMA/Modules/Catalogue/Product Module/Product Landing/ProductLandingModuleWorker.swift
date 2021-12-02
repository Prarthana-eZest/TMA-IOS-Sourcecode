//
//  ProductLandingModuleWorker.swift
//  EnrichSalon
//

import UIKit

class ProductLandingModuleWorker {
    let networkLayer = NetworkLayerAlamofire() // Uncomment this in case do request using Alamofire for client request
    // let networkLayer = NetworkLayer() // Uncomment this in case do request using URLsession
    var presenter: ProductLandingModulePresentationLogic?

     func postRequestAddToWishList(request: HairTreatmentModule.Something.AddToWishListRequest, accessToken: String) {
        // *********** NETWORK CONNECTION
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (HairTreatmentModule.Something.AddToWishListResponse) -> Void = { (responseModel) in
            print(responseModel)

            if(responseModel.status == false) {
                self.presenter?.presentSomethingError(responseError: responseModel.message)
                EZLoadingActivity.hide(true, animated: false)
                return
            }

            let response = responseModel
            self.presenter?.presentSomethingSuccess(response: response)
        }
        self.networkLayer.post(urlString: ConstantAPINames.addWishList.rawValue,
                               body: request, headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }

    func postRequestRemovefromWishList(request: HairTreatmentModule.Something.RemoveFromWishListRequest, accessToken: String) {
        // *********** NETWORK CONNECTION
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (HairTreatmentModule.Something.RemoveFromWishListResponse) -> Void = { (responseModel) in
            print(responseModel)

            if(responseModel.status == false) {
                self.presenter?.presentSomethingError(responseError: responseModel.message)
                EZLoadingActivity.hide(true, animated: false)
                return
            }

            let response = responseModel
            self.presenter?.presentSomethingSuccess(response: response)
        }
        self.networkLayer.post(urlString: ConstantAPINames.removeFromWishList.rawValue,
                               body: request, headers: ["Authorization": "Bearer \(accessToken)"], successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)

    }

    func postRequest(request: ProductLandingModule.Something.Request) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (ProductLandingModule.Something.Response) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }
        self.networkLayer.post(urlString: ConstantAPINames.categorydetails.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

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

    func postRequestProductCategory(request: ProductLandingModule.Something.ProductCategoryRequest) {
        // *********** NETWORK CONNECTION

        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (ProductLandingModule.Something.ProductCategoryResponse) -> Void = { (employees) in
            print(employees)
            let response = employees
            self.presenter?.presentSomethingSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.salonServiceCategory.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    func parseBlogData(data: ProductLandingModule.Something.ResponseBlogs) {

        var arrBlogsModel: [GetInsightFulDetails] = []

        if let dataObj = data.data, let blogs = dataObj.blogs {
            for model in blogs {
                arrBlogsModel.append(GetInsightFulDetails(titleString: model.title!, date: model.publish_time!, imageURL: model.featured_img!, blogId: model.post_id!))
            }
        }

        let dict: [String: Any] = ["data": data, "showmodel": arrBlogsModel]
        print("dict blogs : \(dict)")
        self.presenter?.presentSomethingSuccess(response: data)
    }

}
