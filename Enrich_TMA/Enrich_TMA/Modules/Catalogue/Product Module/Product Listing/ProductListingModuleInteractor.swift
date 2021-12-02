//
//  ProductListingModuleInteractor.swift
//  EnrichSalon
//

import UIKit

// MARK: - protocol - ProductListingModuleBusinessLogic
protocol ProductListingModuleBusinessLogic {
    func doGetRequestWithParameter(request: HairTreatmentModule.Something.Request, isBestSeller: Bool)
    func getURLForType(customer_id: Double, arrSubCat_type: [FilterKeys], pageSize: Int, currentPageNo: Int) -> String
     func doPostRequestAddToWishList(request: HairTreatmentModule.Something.AddToWishListRequest, method: HTTPMethod, accessToken: String)
    func doPostRequestRemoveFromWishList(request: HairTreatmentModule.Something.RemoveFromWishListRequest, method: HTTPMethod, accessToken: String)

    func getProductModel(element: HairTreatmentModule.Something.Items, isLogin: Bool) -> ProductModel
    // Cart Manager
    func doPostRequestGetQuoteIdMine(request: ProductDetailsModule.GetQuoteIDMine.Request, accessToken: String)
    func doPostRequestGetQuoteIdGuest(request: ProductDetailsModule.GetQuoteIDGuest.Request, method: HTTPMethod)
    func doGetRequestToGetAllCartItemsCustomer(request: ProductDetailsModule.GetAllCartsItemCustomer.Request, method: HTTPMethod)
    func doGetRequestToGetAllCartItemsGuest(request: ProductDetailsModule.GetAllCartsItemGuest.Request, method: HTTPMethod)
}

// MARK: -
class ProductListingModuleInteractor: ProductListingModuleBusinessLogic {
    var presenter: ProductListingModulePresentationLogic?
    var worker: ProductListingModuleWorker?
    var workerCart: CartManager?

    // MARK: GET, POST
     func doPostRequestAddToWishList(request: HairTreatmentModule.Something.AddToWishListRequest, method: HTTPMethod, accessToken: String) {
        worker = ProductListingModuleWorker()
        worker?.presenter = presenter
        worker?.postRequestAddToWishList(request: request, accessToken: accessToken)
    }

    func doPostRequestRemoveFromWishList(request: HairTreatmentModule.Something.RemoveFromWishListRequest, method: HTTPMethod, accessToken: String) {
        worker = ProductListingModuleWorker()
        worker?.presenter = presenter
        worker?.postRequestRemovefromWishList(request: request, accessToken: accessToken)
    }

    func doGetRequestWithParameter(request: HairTreatmentModule.Something.Request, isBestSeller: Bool) {
        worker = ProductListingModuleWorker()
        worker?.presenter = presenter
        worker?.getRequestWithParameter(request: request, isBestSeller: isBestSeller)
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

// MARK: -
extension ProductListingModuleInteractor {

    // MARK: Get request query which contains - Login details, store details, filter details , sort details & pagination details
    func getURLForType(customer_id: Double, arrSubCat_type: [FilterKeys], pageSize: Int, currentPageNo: Int) -> String {

        var strFinal = ""
        for (index, value) in arrSubCat_type.enumerated() {

            let model = value

            //  ---------- FILTER CONDITIONS -----
            if model.field == "filter" {
                if let arrFilters = model.value as? [FilterKeys] {

                    for (indexObj, modelObj) in arrFilters.enumerated() {
                        let strFieldKey0 = "\(GenericClass.sharedInstance.getConditionalFieldKey(index: index, indexFilter: indexObj))"
                        let strValueKey0 = "\(GenericClass.sharedInstance.getConditionalValueKey(index: index, indexFilter: indexObj))"
                        let strTypeKey0 = "\(GenericClass.sharedInstance.getConditionalTypeKey(index: index, indexFilter: indexObj))"

                        strFinal = strFinal + "&\(strFieldKey0)=\(modelObj.field ?? "")" + "&\(strValueKey0)=\(modelObj.value ?? "")" + "&\(strTypeKey0)=\(modelObj.type ?? "")"
                    }
                }
            //  ---------- SORT CONDITIONS -----
            } else if model.field == "sort" {
                strFinal = strFinal.isEmpty ? (strFinal + "?") : (strFinal + "&")

                strFinal = strFinal + "\(GenericClass.sharedInstance.getSortingFieldKey())=\(model.type ?? "")" + "&\(GenericClass.sharedInstance.getSortingDirectionKey())=\(model.value ?? "")"
            } else {
                strFinal = strFinal.isEmpty ? (strFinal + "?") : (strFinal + "&")

                // GET KEYS
                let strFieldKey0 = "\(GenericClass.sharedInstance.getConditionalFieldKey(index: index, indexFilter: 0))"
                let strValueKey0 = "\(GenericClass.sharedInstance.getConditionalValueKey(index: index, indexFilter: 0))"
                let strTypeKey0 = "\(GenericClass.sharedInstance.getConditionalTypeKey(index: index, indexFilter: 0))"

                // CREATE PARAMETERS WITH VALUES
                let strFieldKey2 = "\(strFieldKey0)=\(model.field ?? "")"
                let strValueKey2 = "&\(strValueKey0)=\(model.value ?? 0)"
                let strTypeKey2 = "&\(strTypeKey0)=\(model.type ?? "")"

                //  ---------- PARAMETERS -----
                strFinal = strFinal + "\(strFieldKey2)" + "\(strValueKey2)" + "\(strTypeKey2)"
            }
        }

        // IF CATEGORYID AVAIALABLE ADD
        if(customer_id != 0) {
            strFinal = strFinal + "&" + "customer_id=\(customer_id)"
        }

        //  ---------- PAGINATION -----
        strFinal = strFinal + "&" + "searchCriteria[pageSize]=\(pageSize)"
        strFinal = strFinal + "&" + "searchCriteria[currentPage]=\(currentPageNo)"

        print("\(strFinal)")
        return strFinal
    }

    // MARK: Get product model (ProductModel) from response data for showing on ui
    func getProductModel(element: HairTreatmentModule.Something.Items, isLogin: Bool) -> ProductModel {

        var offerPercentage = 0
        var specialPrice = 0.0
        var productImage = ""
        var isFavourite = false
        var ratingPercentage = 0.0
        var totalReviews = 0.0
        var strBaseMediaUrl = ""

        if let extension_attributes = element.extension_attributes {
            isFavourite = isLogin ? extension_attributes.wishlist_flag ?? false : false
            ratingPercentage = extension_attributes.rating_percentage ?? 0.0
            totalReviews = extension_attributes.total_reviews ?? 0.0
            strBaseMediaUrl = extension_attributes.media_url ?? ""
        }

        if let imageUrl = element.custom_attributes?.filter({ $0.attribute_code == "image" }), !strBaseMediaUrl.isEmpty {
            productImage = strBaseMediaUrl + (imageUrl.first?.value.description ?? "")
        }

        // ****** Check for special price
        var isSpecialDateInbetweenTo = true

        if let specialFrom = element.custom_attributes?.filter({ $0.attribute_code == "special_from_date" }), let strDateFrom = specialFrom.first?.value.description,!strDateFrom.isEmpty,!strDateFrom.containsIgnoringCase(find: "null") {
            if Date().description.getFormattedDate() >= strDateFrom.getFormattedDate() {
                isSpecialDateInbetweenTo = true
            } else {
                isSpecialDateInbetweenTo = false
            }
        }

        if let specialTo = element.custom_attributes?.filter({ $0.attribute_code == "special_to_date" }), let strDateTo = specialTo.first?.value.description,!strDateTo.isEmpty,!strDateTo.containsIgnoringCase(find: "null") {
            if Date().description.getFormattedDate() <= strDateTo.getFormattedDate() {
                isSpecialDateInbetweenTo = true
            } else {
                isSpecialDateInbetweenTo = false
            }
        }

        if isSpecialDateInbetweenTo  {
            if let specialPriceValue = element.custom_attributes?.filter({ $0.attribute_code == "special_price"}) {
                let responseObject = specialPriceValue.first?.value.description
                specialPrice = responseObject?.toDouble() ?? 0.0
            }
        }

        if  specialPrice != 0 {
            offerPercentage = Int(specialPrice.getPercent(price: element.price ?? 0))
        } else {
            specialPrice = element.price ?? 0
        }

        let model = ProductModel(productId: element.id!, productName: element.name ?? "", price: element.price ?? 0, specialPrice: specialPrice, reviewCount: String(format: " \(SalonServiceSpecifierFormat.reviewFormat)", totalReviews), ratingPercentage: ratingPercentage, showCheckBox: false, offerPercentage: String(format: "%d", offerPercentage), isFavourite: isFavourite, strImage: productImage, sku: (element.sku ?? ""), isProductSelected: false, type_id: element.type_id ?? "")

        return model
    }

}
