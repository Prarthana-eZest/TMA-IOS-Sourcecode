//
//  ProductLandingModuleInteractor.swift
//  EnrichSalon
//

import UIKit

protocol ProductLandingModuleBusinessLogic {
    func doPostRequest(request: ProductLandingModule.Something.Request, method: HTTPMethod)
    func doPostRequestProductCategory(request: ProductLandingModule.Something.ProductCategoryRequest, method: HTTPMethod)
    func doPostRequestBlogs(request: ProductLandingModule.Something.Request, method: HTTPMethod)

    func getBannersOffersTrending_productsNew_products(serverDataObj: ProductLandingModule.Something.Response?, isLogin: Bool) -> ModelForProductDataUI
    func getBlogs(serverDataObj: ProductLandingModule.Something.ResponseBlogs?) -> Any
    // Cart Manager
    func doPostRequestGetQuoteIdMine(request: ProductDetailsModule.GetQuoteIDMine.Request, accessToken: String)
    func doPostRequestGetQuoteIdGuest(request: ProductDetailsModule.GetQuoteIDGuest.Request, method: HTTPMethod)
     func doGetRequestToGetAllCartItemsCustomer(request: ProductDetailsModule.GetAllCartsItemCustomer.Request, method: HTTPMethod)
     func doGetRequestToGetAllCartItemsGuest(request: ProductDetailsModule.GetAllCartsItemGuest.Request, method: HTTPMethod)
    func getRequestForSelectedServiceDetails(request: HairTreatmentModule.Something.Request, method: HTTPMethod)

}

class ProductLandingModuleInteractor: ProductLandingModuleBusinessLogic {

    var presenter: ProductLandingModulePresentationLogic?
    var worker: ProductLandingModuleWorker?
    var workerCart: CartAPIManager?

    func doPostRequest(request: ProductLandingModule.Something.Request, method: HTTPMethod) {
        worker = ProductLandingModuleWorker()
        worker?.presenter = presenter
        worker?.postRequest(request: request)
    }
    func doPostRequestProductCategory(request: ProductLandingModule.Something.ProductCategoryRequest, method: HTTPMethod) {
        worker = ProductLandingModuleWorker()
        worker?.presenter = presenter
        worker?.postRequestProductCategory(request: request)
    }

    func doPostRequestBlogs(request: ProductLandingModule.Something.Request, method: HTTPMethod) {
        worker = ProductLandingModuleWorker()
        worker?.presenter = presenter
        worker?.postRequestBlogs(request: request)
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

    func getRequestForSelectedServiceDetails(request: HairTreatmentModule.Something.Request, method: HTTPMethod) {
        worker = ProductLandingModuleWorker()
        worker?.presenter = self.presenter
        worker?.getRequestForSelectedServiceDetails(request: request)
    }

}

extension ProductLandingModuleInteractor {

    func getBannersOffersTrending_productsNew_products(serverDataObj: ProductLandingModule.Something.Response?, isLogin: Bool) -> ModelForProductDataUI {

        var arrBanners: [BannerModel] = []
        let arrOffers: [IrresistibleOfferModel] = []
        var arrTrending_products: [ProductModel] = []
        var arrNew_products: [ProductModel] = []
        var arrRecently_viewed: [ProductModel] = []
        var arrBrands: [PopularBranchModel] = []

        var modelFinal: ModelForProductDataUI = ModelForProductDataUI()

        if let serverData = serverDataObj, let child = serverData.data {
            if let arrBnr = child.banners {
                for model in arrBnr {
                    arrBanners.append(BannerModel(title: model.title ?? "", bannerDesciption: model.desc ?? "", imageUrl: model.image_url ?? ""))
                }
            }

            if let arrOfr = child.offers {
                for _ in arrOfr {
                    //                    arrOffers.append(IrresistibleOfferModel.init(title: <#T##String#>, topTitle: <#T##String#>, offerDiscount: <#T##String#>, offerDescription: <#T##String#>, imageUrl: <#T##String#>)))
                }
            }

            if let arrTrdPrd = child.trending_products {
                for model in arrTrdPrd {
                    var specialPrice = model.price ?? 0
                    var elementPrice = model.price ?? 0
                    var isFevo = isLogin ? (model.wishlist_flag ?? false) : false

                    if let modelFevoObj =
                        GenericClass.sharedInstance.getFevoriteProductSet().filter({ ($0.productId ?? "") == model.id}).first {
                        isFevo = modelFevoObj.changedState ?? false
                    }

                    var offerPercentage: Double = 0
                    // ****** Check for special price
                    let configurablePrice = GenericClass.sharedInstance.getConfigurableProductsPrice(element: model.configurable_subproduct_options ?? [])

                    if configurablePrice.price == 0 {
                        var isSpecialDateInbetweenTo = false

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

                    let intId: Int64? = Int64(model.id!)
                    arrTrending_products.append(ProductModel(productId: intId!, productName: model.name ?? "", price: elementPrice, specialPrice: specialPrice, reviewCount: model.total_reviews?.cleanForPrice ?? "0", ratingPercentage: (model.rating_percentage ?? 0).getPercentageInFive(), showCheckBox: false, offerPercentage: offerPercentage.cleanForRating, isFavourite: isFevo, strImage: (model.image ?? ""), sku: model.sku ?? "", isProductSelected: false, type_id: model.type_id ?? "", type_of_service: ""))
                }
            }

            if let arrNewPrd = child.new_products {
                for model in arrNewPrd {
                    var specialPrice = model.price ?? 0
                    var elementPrice = model.price ?? 0
                    var isFevo = isLogin ? (model.wishlist_flag ?? false) : false

                    if let modelFevoObj = GenericClass.sharedInstance.getFevoriteProductSet().filter({$0.productId! == model.id}).first {
                        isFevo = modelFevoObj.changedState!
                    }

                    // ****** Check for special price
                    var isSpecialDateInbetweenTo = false
                    var offerPercentage: Double = 0

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

                    let intId: Int64? = Int64(model.id!)
                    arrNew_products.append(ProductModel(productId: intId!, productName: model.name ?? "", price: elementPrice, specialPrice: specialPrice, reviewCount: model.total_reviews?.cleanForPrice ?? "0", ratingPercentage: (model.rating_percentage ?? 0).getPercentageInFive(), showCheckBox: false, offerPercentage: offerPercentage.cleanForRating, isFavourite: isFevo, strImage: (model.image ?? ""), sku: (model.sku ?? ""), isProductSelected: false, type_id: model.type_id ?? "", type_of_service: ""))
                }
            }

            if let arrRcntViewPrd = child.recentlyViewedProducts {
                for model in arrRcntViewPrd {
                    var specialPrice = model.price ?? 0
                    var elementPrice = model.price ?? 0
                    var isFevo = isLogin ? (model.wishlist_flag ?? false) : false

                    if let modelFevoObj = GenericClass.sharedInstance.getFevoriteProductSet().filter({$0.productId! == model.id}).first {
                        isFevo = modelFevoObj.changedState!
                    }

                    // ****** Check for special price
                    var isSpecialDateInbetweenTo = false
                    var offerPercentage: Double = 0

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

                    let intId: Int64? = Int64(model.id!)
                    arrRecently_viewed.append(ProductModel(productId: intId!, productName: model.name ?? "", price: elementPrice, specialPrice: specialPrice, reviewCount: model.total_reviews?.cleanForPrice ?? "0", ratingPercentage: (model.rating_percentage ?? 0).getPercentageInFive(), showCheckBox: false, offerPercentage: offerPercentage.cleanForRating, isFavourite: isFevo, strImage: (model.image ?? ""), sku: (model.sku ?? ""), isProductSelected: false, type_id: model.type_id ?? "", type_of_service: ""))
                }
            }

            if let arrBrandsObj = child.brands {
                for model in arrBrandsObj {
                    arrBrands.append(PopularBranchModel(value: model.value ?? "", title: model.label ?? "", imageUrl: model.swatch_image_url ?? ""))
                }
            }

            modelFinal.brands = arrBrands
            modelFinal.banners = arrBanners
            modelFinal.offers = arrOffers
            modelFinal.trending_products = arrTrending_products
            modelFinal.new_products = arrNew_products
            modelFinal.recently_viewed = arrRecently_viewed
        }
        return modelFinal
    }

    func getBlogs(serverDataObj: ProductLandingModule.Something.ResponseBlogs?) -> Any {
        var arrBlogsModel: [GetInsightFulDetails] = []
        if let serverData = serverDataObj, let child = serverData.data {
            if let arrBnr = child.blogs {
                for model in arrBnr {
                    arrBlogsModel.append(GetInsightFulDetails(titleString: model.title ?? "", date: model.publish_time ?? "", imageURL: model.featured_img ?? "", blogId: model.post_id! ))
                }
            }
        }

        return arrBlogsModel
    }
}
