//
//  ProductLandingModuleInteractor.swift
//  EnrichSalon
//

import UIKit

protocol ProductLandingModuleBusinessLogic {
    func doPostRequest(request: ProductLandingModule.Something.Request, method: HTTPMethod)
    func doPostRequestProductCategory(request: ProductLandingModule.Something.ProductCategoryRequest, method: HTTPMethod)
    func doPostRequestBlogs(request: ProductLandingModule.Something.Request, method: HTTPMethod)
     func doPostRequestAddToWishList(request: HairTreatmentModule.Something.AddToWishListRequest, method: HTTPMethod, accessToken: String)
    func doPostRequestRemoveFromWishList(request: HairTreatmentModule.Something.RemoveFromWishListRequest, method: HTTPMethod, accessToken: String)

    func getBannersOffersTrending_productsNew_products(serverDataObj: ProductLandingModule.Something.Response?, isLogin: Bool) -> ModelForProductDataUI
    func getBlogs(serverDataObj: ProductLandingModule.Something.ResponseBlogs?) -> Any
    // Cart Manager
    func doPostRequestGetQuoteIdMine(request: ProductDetailsModule.GetQuoteIDMine.Request, accessToken: String)
    func doPostRequestGetQuoteIdGuest(request: ProductDetailsModule.GetQuoteIDGuest.Request, method: HTTPMethod)
     func doGetRequestToGetAllCartItemsCustomer(request: ProductDetailsModule.GetAllCartsItemCustomer.Request, method: HTTPMethod)
     func doGetRequestToGetAllCartItemsGuest(request: ProductDetailsModule.GetAllCartsItemGuest.Request, method: HTTPMethod)
}

class ProductLandingModuleInteractor: ProductLandingModuleBusinessLogic {
    var presenter: ProductLandingModulePresentationLogic?
    var worker: ProductLandingModuleWorker?
    var workerCart: CartManager?

     func doPostRequestAddToWishList(request: HairTreatmentModule.Something.AddToWishListRequest, method: HTTPMethod, accessToken: String) {
        worker = ProductLandingModuleWorker()
        worker?.presenter = presenter
        worker?.postRequestAddToWishList(request: request, accessToken: accessToken)
    }

    func doPostRequestRemoveFromWishList(request: HairTreatmentModule.Something.RemoveFromWishListRequest, method: HTTPMethod, accessToken: String) {
        worker = ProductLandingModuleWorker()
        worker?.presenter = presenter
        worker?.postRequestRemovefromWishList(request: request, accessToken: accessToken)
    }

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
                for model in arrOfr {
                    //                    arrOffers.append(IrresistibleOfferModel.init(title: <#T##String#>, topTitle: <#T##String#>, offerDiscount: <#T##String#>, offerDescription: <#T##String#>, imageUrl: <#T##String#>)))
                }
            }

            if let arrTrdPrd = child.trending_products {
                for model in arrTrdPrd {
                    var specialPrice = model.price ?? 0
                    var isFevo = isLogin ? (model.wishlist_flag ?? false) : false

                    if let modelFevoObj = GenericClass.sharedInstance.getFevoriteProductSet().filter({$0.productId! == model.id}).first {
                        isFevo = modelFevoObj.changedState!
                    }

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
                    arrTrending_products.append(ProductModel(productId: intId!, productName: model.name ?? "", price: model.price ?? 0, specialPrice: specialPrice, reviewCount: String(format: "\(model.total_reviews ?? 0)"), ratingPercentage: (model.rating_percentage ?? 0).getPercentageInFive(), showCheckBox: false, offerPercentage: String(format: "\(offerPercentage)"), isFavourite: isFevo, strImage: (model.image ?? ""), sku: model.sku ?? "", isProductSelected: false, type_id: model.type_id ?? ""))
                }
            }

            if let arrNewPrd = child.new_products {
                for model in arrNewPrd {
                    var specialPrice = model.price ?? 0
                    var isFevo = isLogin ? (model.wishlist_flag ?? false) : false

                    if let modelFevoObj = GenericClass.sharedInstance.getFevoriteProductSet().filter({$0.productId! == model.id}).first {
                        isFevo = modelFevoObj.changedState!
                    }

                    // ****** Check for special price
                    var isSpecialDateInbetweenTo = true
                    var offerPercentage = 0

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
                    arrNew_products.append(ProductModel(productId: intId!, productName: model.name ?? "", price: model.price ?? 0, specialPrice: specialPrice, reviewCount: String(format: "\(model.total_reviews ?? 0)"), ratingPercentage: (model.rating_percentage ?? 0).getPercentageInFive(), showCheckBox: false, offerPercentage: String(format: "\(offerPercentage)"), isFavourite: isFevo, strImage: (model.image ?? ""), sku: (model.sku ?? ""), isProductSelected: false, type_id: model.type_id ?? ""))
                }
            }

            if let arrRcntViewPrd = child.recentlyViewedProducts {
                for model in arrRcntViewPrd {
                    var specialPrice = model.price ?? 0
                    var isFevo = isLogin ? (model.wishlist_flag ?? false) : false

                    if let modelFevoObj = GenericClass.sharedInstance.getFevoriteProductSet().filter({$0.productId! == model.id}).first {
                        isFevo = modelFevoObj.changedState!
                    }

                    // ****** Check for special price
                    var isSpecialDateInbetweenTo = true
                    var offerPercentage = 0

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
                    arrRecently_viewed.append(ProductModel(productId: intId!, productName: model.name ?? "", price: model.price ?? 0, specialPrice: specialPrice, reviewCount: String(format: "\(model.total_reviews ?? 0)"), ratingPercentage: (model.rating_percentage ?? 0).getPercentageInFive(), showCheckBox: false, offerPercentage: String(format: "\(offerPercentage)"), isFavourite: isFevo, strImage: (model.image ?? ""), sku: (model.sku ?? ""), isProductSelected: false, type_id: model.type_id ?? ""))
                }
            }

            if let arrBrandsObj = child.brands {
                for model in arrBrandsObj {
                    arrBrands.append(PopularBranchModel(value: model.value ?? "", title: model.label ?? "", imageUrl: model.swatch_image_url ?? ""))
                }
            }
        }

        modelFinal.brands = arrBrands
        modelFinal.banners = arrBanners
        modelFinal.offers = arrOffers
        modelFinal.trending_products = arrTrending_products
        modelFinal.new_products = arrNew_products
        modelFinal.recently_viewed = arrRecently_viewed
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
