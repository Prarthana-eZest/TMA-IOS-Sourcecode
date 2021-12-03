//
//  BlogModuleInteractor.swift
//  EnrichSalon
//

import UIKit

protocol BlogListingModuleBusinessLogic {
    func doPostRequest(request: BlogListingAPICall.categories.Request, method: HTTPMethod)
    func doPostRequestBlogListing(request: BlogListingAPICall.listing.Request, method: HTTPMethod)
    func doPostFeaturedVideos(request: BlogListingAPICall.listing.Request, method: HTTPMethod)

    func parseBlogCategories(data: [BlogListingAPICall.categories.CategoriesModel], selectedIndex: Int) -> [SelectedCellModel]
    func getBlogCellModel(model: BlogListingAPICall.listing.BlogListModel) -> BlogCellModel
    func getBlogCellModelFeatured(model: BlogListingAPICall.listing.BlogListModel) -> FeaturedVideosCellModel
}

class BlogListingModuleInteractor: BlogListingModuleBusinessLogic {

    var presenter: BlogListingModulePresentationLogic?
    var worker: BlogListingModuleWorker?

    func doPostRequest(request: BlogListingAPICall.categories.Request, method: HTTPMethod) {
        worker = BlogListingModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequest(request: request)
    }

    func doPostRequestBlogListing(request: BlogListingAPICall.listing.Request, method: HTTPMethod) {
        worker = BlogListingModuleWorker()
        worker?.presenter = self.presenter
        worker?.doPostRequestBlogListing(request: request)
    }

    func doPostFeaturedVideos(request: BlogListingAPICall.listing.Request, method: HTTPMethod) {
        worker = BlogListingModuleWorker()
        worker?.presenter = self.presenter
        worker?.doPostRequestFeaturedVideos(request: request)
    }
}

extension BlogListingModuleInteractor {

    func parseBlogCategories(data: [BlogListingAPICall.categories.CategoriesModel], selectedIndex: Int) -> [SelectedCellModel] {
        var arrData: [SelectedCellModel] = []

        for (index, model) in data.enumerated() {
            let selected = index == selectedIndex ? true : false
            arrData.append(SelectedCellModel(title: model.title!, indexSelected: selected, id: model.id ?? ""))
        }
        return arrData
    }

    func getBlogCellModel(model: BlogListingAPICall.listing.BlogListModel) -> BlogCellModel {
        var fullDate  = ""
        if let publish_time = model.publish_time {
            fullDate = String(format: "%@%@ %@ %@", publish_time.getFormattedDate().dayDateName, publish_time.getFormattedDate().daySuffix(), publish_time.getFormattedDate().monthNameFirstThree, publish_time.getFormattedDate().OnlyYear)
        }
        return  BlogCellModel(imageURl: model.featured_img ?? "", title: model.title ?? "", dateText: fullDate, subTitle: model.short_content ?? "", videoLink: model.video_link ?? "")
    }

    func getBlogCellModelFeatured(model: BlogListingAPICall.listing.BlogListModel) -> FeaturedVideosCellModel {
        var fullDate  = ""
        if let publish_time = model.publish_time {
            fullDate = String(format: "%@%@ %@ %@", publish_time.getFormattedDate().dayDateName, publish_time.getFormattedDate().daySuffix(), publish_time.getFormattedDate().monthNameFirstThree, publish_time.getFormattedDate().OnlyYear)
        }

        return FeaturedVideosCellModel(imageURl: model.featured_img ?? "", title: model.title ?? "", dateText: fullDate, descriptionText: model.short_content ?? "")
    }
}
