//
//  SubProdListModuleInteractor.swift
//  EnrichSalon
//

import UIKit

protocol SubProdListModuleBusinessLogic {
    func doPostRequestTypes(request: SubProdListModule.Categories.RequestTypes, method: HTTPMethod)
    func doPostRequestProductCategory(request: ProductLandingModule.Something.ProductCategoryRequest, method: HTTPMethod)
    func getServiceModel(data: ProductLandingModule.Something.ProductCategoryResponse) -> [ServiceModel]
    func getCategoryTypeModel(data: SubProdListModule.Categories.SubCategoryType) -> [HairstylesModel]
    func getPopularProductArray(data: ProductLandingModule.Something.CategoryModel) -> [ProductModel]
     func doPostRequestAddToWishList(request: HairTreatmentModule.Something.AddToWishListRequest, method: HTTPMethod, accessToken: String)
    func doPostRequestRemoveFromWishList(request: HairTreatmentModule.Something.RemoveFromWishListRequest, method: HTTPMethod, accessToken: String)
    // Cart Manager
    func doPostRequestGetQuoteIdMine(request: ProductDetailsModule.GetQuoteIDMine.Request, accessToken: String)
    func doPostRequestGetQuoteIdGuest(request: ProductDetailsModule.GetQuoteIDGuest.Request, method: HTTPMethod)
    func doGetRequestToGetAllCartItemsCustomer(request: ProductDetailsModule.GetAllCartsItemCustomer.Request, method: HTTPMethod)
    func doGetRequestToGetAllCartItemsGuest(request: ProductDetailsModule.GetAllCartsItemGuest.Request, method: HTTPMethod)
}

class SubProdListModuleInteractor: SubProdListModuleBusinessLogic {
    var presenter: SubProdListModulePresentationLogic?
    var worker: SubProdListModuleWorker?
    var workerCart: CartManager?

     func doPostRequestAddToWishList(request: HairTreatmentModule.Something.AddToWishListRequest, method: HTTPMethod, accessToken: String) {
        worker = SubProdListModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestAddToWishList(request: request, accessToken: accessToken)
    }

    func doPostRequestRemoveFromWishList(request: HairTreatmentModule.Something.RemoveFromWishListRequest, method: HTTPMethod, accessToken: String) {
        worker = SubProdListModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestRemovefromWishList(request: request, accessToken: accessToken)
    }

    func doPostRequestTypes(request: SubProdListModule.Categories.RequestTypes, method: HTTPMethod) {
        worker = SubProdListModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestTypes(request: request)
    }

    func doPostRequestProductCategory(request: ProductLandingModule.Something.ProductCategoryRequest, method: HTTPMethod) {
        worker = SubProdListModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestProductCategory(request: request)
    }

    func doPostRequestProductListing(request: ProductLandingModule.Something.ProductCategoryRequest, method: HTTPMethod) {
        worker = SubProdListModuleWorker()
        worker?.presenter = self.presenter
        worker?.postRequestProductCategory(request: request)
    }

    // Cart Manager Functions
    func doPostRequestGetQuoteIdMine(request: ProductDetailsModule.GetQuoteIDMine.Request, accessToken: String) {
        workerCart = CartManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.postRequestGetQuoteIdMine(request: request, accessToken: accessToken)
    }
    func doPostRequestGetQuoteIdGuest(request: ProductDetailsModule.GetQuoteIDGuest.Request, method: HTTPMethod) {
        workerCart = CartManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.postRequestGetQuoteIdGuest(request: request)
    }

    func doGetRequestToGetAllCartItemsCustomer(request: ProductDetailsModule.GetAllCartsItemCustomer.Request, method: HTTPMethod) {
        workerCart = CartManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.getRequestToGetAllCartItemsCustomer(request: request)
    }

    func doGetRequestToGetAllCartItemsGuest(request: ProductDetailsModule.GetAllCartsItemGuest.Request, method: HTTPMethod) {
        workerCart = CartManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.getRequestToGetAllCartItemsGuest(request: request)
    }
}

extension SubProdListModuleInteractor {

    func getServiceModel(data: ProductLandingModule.Something.ProductCategoryResponse) -> [ServiceModel] {
        var arrServices: [ServiceModel] = []
        if let child = data.data, let children = child.children, children.count > 0 {

            for model in children {
                arrServices.append(ServiceModel(name: model.name ?? "", female_img: model.category_img ?? "", male_img: model.category_img ?? "", id: model.id ?? ""))
            }
        }
        return arrServices
    }

    func getCategoryTypeModel(data: SubProdListModule.Categories.SubCategoryType) -> [HairstylesModel] {
        var arrHairstylesModel: [HairstylesModel] = []
        for model in (data.category_sub_type ?? []) {
            arrHairstylesModel.append(HairstylesModel(strName: model.label ?? "", imgURL: model.swatch_image_url ?? "", value: model.value ?? "", categoryType: data.category_type ?? ""))
        }
        return arrHairstylesModel
    }

    func getPopularProductArray(data: ProductLandingModule.Something.CategoryModel) -> [ProductModel] {
        var arrPopular_viewed: [ProductModel] = []
        if let arrPopularPrd = data.popular_products {
            for model in arrPopularPrd {

                var isFevo = model.wishlist_flag ?? false

                if let modelFevo = GenericClass.sharedInstance.getFevoriteProductSet().filter({$0.productId == model.id!}).first {
                    isFevo = modelFevo.changedState!
                }

                var specialPrice = model.price ?? 0
                var offerPercentage = 0

                // ****** Check for special price
                var isSpecialDateInbetweenTo = true

                if let specialFrom = model.special_from_date {
                    if Date().description.getFormattedDate() >= specialFrom.getFormattedDate() {
                        isSpecialDateInbetweenTo = true
                    } else {
                        isSpecialDateInbetweenTo = false
                    }
                }
                if let specialTo = model.special_to_date {
                    if Date().description.getFormattedDate() <= specialTo.getFormattedDate() {
                        isSpecialDateInbetweenTo = true
                    } else {
                        isSpecialDateInbetweenTo = false
                    }
                }

                if isSpecialDateInbetweenTo {
                    if let splPrice = model.special_price, splPrice != 0 {
                        specialPrice = splPrice
                        offerPercentage = Int(specialPrice.getPercent(price: model.price ?? 0))
                    }
                }

                let intId: Int64? = Int64(model.id!)
                arrPopular_viewed.append(ProductModel(productId: intId!, productName: model.name ?? "", price: model.price ?? 0, specialPrice: specialPrice, reviewCount: String(format: "\(model.total_reviews ?? 0)"), ratingPercentage: (model.rating_percentage ?? 0).getPercentageInFive(), showCheckBox: false, offerPercentage: String(format: "\(offerPercentage)"), isFavourite: isFevo, strImage: (model.image ?? ""), sku: (model.sku ?? ""), isProductSelected: false, type_id: model.type_id ?? ""))
            }
        }
        return arrPopular_viewed
    }

}
