//
//  BlogListingModuleWorker.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit

class BlogListingModuleWorker {
    let networkLayer = NetworkLayerAlamofire()
    var presenter: BlogListingModulePresentationLogic?

    func postRequest(request: BlogListingAPICall.categories.Request) {
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (BlogListingAPICall.categories.Response) -> Void = { (response) in
            print(response)
            self.presenter?.presentSomethingSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.blogListingCategories.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    func doPostRequestBlogListing(request: BlogListingAPICall.listing.Request) {
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (BlogListingAPICall.listing.Response) -> Void = { (response) in
            print(response)
            self.presenter?.presentSomethingSuccess(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.blogList.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }

    func doPostRequestFeaturedVideos(request: BlogListingAPICall.listing.Request) {
        let errorHandler: (String) -> Void = { (error) in
            print(error)
            self.presenter?.presentSomethingError(responseError: error)
        }
        let successHandler: (BlogListingAPICall.listing.Response) -> Void = { (response) in
            print(response)
            self.presenter?.presentFeaturedVideos(response: response)
        }

        self.networkLayer.post(urlString: ConstantAPINames.blogList.rawValue,
                               body: request, successHandler: successHandler,
                               errorHandler: errorHandler, method: .post)
    }
}
