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
    // Cart Manager
    func doPostRequestGetQuoteIdMine(request: ProductDetailsModule.GetQuoteIDMine.Request, accessToken: String)
    func doPostRequestGetQuoteIdGuest(request: ProductDetailsModule.GetQuoteIDGuest.Request, method: HTTPMethod)
    func doGetRequestToGetAllCartItemsCustomer(request: ProductDetailsModule.GetAllCartsItemCustomer.Request, method: HTTPMethod)
    func doGetRequestToGetAllCartItemsGuest(request: ProductDetailsModule.GetAllCartsItemGuest.Request, method: HTTPMethod)
}

class SubProdListModuleInteractor: SubProdListModuleBusinessLogic {
    var presenter: SubProdListModulePresentationLogic?
    var worker: SubProdListModuleWorker?
    var workerCart: CartAPIManager?

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
        workerCart = CartAPIManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.postRequestGetQuoteIdMine(request: request, accessToken: accessToken)
    }
    func doPostRequestGetQuoteIdGuest(request: ProductDetailsModule.GetQuoteIDGuest.Request, method: HTTPMethod) {
        workerCart = CartAPIManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.postRequestGetQuoteIdGuest(request: request)
    }

    func doGetRequestToGetAllCartItemsCustomer(request: ProductDetailsModule.GetAllCartsItemCustomer.Request, method: HTTPMethod) {
        workerCart = CartAPIManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.getRequestToGetAllCartItemsCustomer(request: request)
    }

    func doGetRequestToGetAllCartItemsGuest(request: ProductDetailsModule.GetAllCartsItemGuest.Request, method: HTTPMethod) {
        workerCart = CartAPIManager()
        workerCart?.presenterCartWorker = presenter
        workerCart?.getRequestToGetAllCartItemsGuest(request: request)
    }
}

extension SubProdListModuleInteractor {

    func getServiceModel(data: ProductLandingModule.Something.ProductCategoryResponse) -> [ServiceModel] {
        var arrServices: [ServiceModel] = []
        if let child = data.data, let children = child.children, !children.isEmpty {

            for model in children {
                arrServices.append(ServiceModel(name: model.name ?? "", female_img: model.category_img ?? "", male_img: model.category_img ?? "", id: model.id ?? ""))
            }
        }
        return arrServices
    }

    func getCategoryTypeModel(data: SubProdListModule.Categories.SubCategoryType) -> [HairstylesModel] {
        var arrHairstylesModel: [HairstylesModel] = []
        for model in (data.category_sub_type ?? []) {
            arrHairstylesModel.append(HairstylesModel(strName: model.label ?? "", imgURL: model.swatch_image_url ?? "", value: model.value?.description ?? "", categoryType: data.category_type ?? ""))
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
                var offerPercentage: Double = 0
                var elementPrice = model.price ?? 0

                // ****** Check for special price

                var isSpecialDateInbetweenTo = false

                let configurablePrice = GenericClass.sharedInstance.getConfigurableProductsPrice(element: model.configurable_subproduct_options ?? [])
                if configurablePrice.price == 0 {
                if let specialFrom = model.special_from_date {

                    let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
                    let fromDateInt: Int = Int(specialFrom.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

                    if currentDateInt >= fromDateInt {
                        isSpecialDateInbetweenTo = true
                        if let specialTo = model.special_to_date {
                            let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
                            let toDateInt: Int = Int(specialTo.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

                            if currentDateInt <= toDateInt {
                                isSpecialDateInbetweenTo = true
                            }
                            else {
                                isSpecialDateInbetweenTo = false
                            }
                        }
                    }
                    else {
                        isSpecialDateInbetweenTo = false
                    }
                }

                if isSpecialDateInbetweenTo {
                    if let splPrice = model.special_price, splPrice != 0 {
                        specialPrice = splPrice
                    }
                }
                }
                else {
                    specialPrice = configurablePrice.splPrice
                    elementPrice = configurablePrice.price
                }

                offerPercentage = specialPrice.getPercent(price: elementPrice)
                offerPercentage = offerPercentage.rounded(toPlaces: 1)

                let intId: Int64? = Int64(model.id!)
                arrPopular_viewed.append(ProductModel(productId: intId!, productName: model.name ?? "", price: model.price ?? 0, specialPrice: specialPrice, reviewCount: model.total_reviews?.cleanForPrice ?? "0", ratingPercentage: (model.rating_percentage ?? 0).getPercentageInFive(), showCheckBox: false, offerPercentage: offerPercentage.cleanForRating, isFavourite: isFevo, strImage: (model.image ?? ""), sku: (model.sku ?? ""), isProductSelected: false, type_id: model.type_id ?? "", type_of_service: ""))
            }
        }
        return arrPopular_viewed
    }

}
