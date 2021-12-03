//
//  ProductListingModuleInteractor.swift
//  EnrichSalon
//

import UIKit

// MARK: - protocol - ProductListingModuleBusinessLogic
protocol ProductListingModuleBusinessLogic {
    func doGetRequestWithParameter(request: HairTreatmentModule.Something.Request, isBestSeller: Bool)

    func getURLForType(customer_id: Double, arrSubCat_type: [FilterKeys], pageSize: Int, currentPageNo: Int, is_config_bundle_brief_info_required: Bool?) -> String
    func getURLForType(customer_id: Double, arrSubCat_type: [FilterKeys], pageSize: Int, currentPageNo: Int, isCustomerIdNeed: Bool, is_config_bundle_brief_info_required: Bool?) -> String
    func getURLForType(arrSubCat_type: [FilterKeys], pageSize: Int, currentPageNo: Int, is_config_bundle_brief_info_required: Bool?) -> String

    func getProductModel(element: HairTreatmentModule.Something.Items, isLogin: Bool) -> ProductModel
    // Cart Manager
    func doPostRequestGetQuoteIdMine(request: ProductDetailsModule.GetQuoteIDMine.Request, accessToken: String)
    func doPostRequestGetQuoteIdGuest(request: ProductDetailsModule.GetQuoteIDGuest.Request, method: HTTPMethod)
    func doGetRequestToGetAllCartItemsCustomer(request: ProductDetailsModule.GetAllCartsItemCustomer.Request, method: HTTPMethod)
    func doGetRequestToGetAllCartItemsGuest(request: ProductDetailsModule.GetAllCartsItemGuest.Request, method: HTTPMethod)
    func postToGetMemberShipBenefits(request: ClubMembershipModule.MembershipKnowMore.Request)
    func doGetRequestToMembershipDetails(request: ClubMembershipModule.MembershipDetails.Request, method: HTTPMethod)

    func doPostRequestFilters(request: HairServiceModule.filtersAPI.Request, method: HTTPMethod)

}

// MARK: -
class ProductListingModuleInteractor: ProductListingModuleBusinessLogic {
    var presenter: ProductListingModulePresentationLogic?
    var worker: ProductListingModuleWorker?
    var workerCart: CartAPIManager?

    // MARK: GET, POST

    func doGetRequestWithParameter(request: HairTreatmentModule.Something.Request, isBestSeller: Bool) {
        worker = ProductListingModuleWorker()
        worker?.presenter = presenter
        worker?.getRequestWithParameter(request: request, isBestSeller: isBestSeller)
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
    func postToGetMemberShipBenefits(request: ClubMembershipModule.MembershipKnowMore.Request) {
        worker = ProductListingModuleWorker()
        worker?.presenter = self.presenter
        worker?.postToGetMemberShipBenefits(request: request)
    }
    func doGetRequestToMembershipDetails(request: ClubMembershipModule.MembershipDetails.Request, method: HTTPMethod) {
        worker = ProductListingModuleWorker()
        worker?.presenter = presenter
        worker?.getRequestForMembershipDetails(request: request)
    }

    func doPostRequestFilters(request: HairServiceModule.filtersAPI.Request, method: HTTPMethod) {
        worker = ProductListingModuleWorker()
        worker?.presenter = presenter
        worker?.postToFiltersData(request: request)
    }
}

// MARK: -
extension ProductListingModuleInteractor {

    func getURLForType(customer_id: Double, arrSubCat_type: [FilterKeys], pageSize: Int, currentPageNo: Int, isCustomerIdNeed: Bool, is_config_bundle_brief_info_required: Bool?) -> String {

        var strFinal = ""
        for (index, value) in arrSubCat_type.enumerated() {

            let model = value

            //  ---------- FILTER And Description CONDITIONS -----
           if model.field == "filter" || model.field == "description_own" {
                if let arrFilters = model.value as? [FilterKeys] {
                    for (indexObj, modelObj) in arrFilters.enumerated() {
                        strFinal = strFinal.isEmpty ? (strFinal + "?") : (strFinal + "&")

                        let strFieldKey0 = "\(GenericClass.sharedInstance.getConditionalFieldKey(index: index, indexFilter: indexObj))"
                        let strValueKey0 = "\(GenericClass.sharedInstance.getConditionalValueKey(index: index, indexFilter: indexObj))"
                        let strTypeKey0 = "\(GenericClass.sharedInstance.getConditionalTypeKey(index: index, indexFilter: indexObj))"

                        strFinal += "\(strFieldKey0)=\(modelObj.field ?? "")" + "&\(strValueKey0)=\(modelObj.value ?? "")" + "&\(strTypeKey0)=\(modelObj.type ?? "")"
                    }
                }
                //  ---------- SORT CONDITIONS -----
            }
            else if model.field == "sort" {
                strFinal = strFinal.isEmpty ? (strFinal + "?") : (strFinal + "&")

                strFinal += "\(GenericClass.sharedInstance.getSortingFieldKey())=\(model.type ?? "")" + "&\(GenericClass.sharedInstance.getSortingDirectionKey())=\(model.value ?? "")"
            }
            else {
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
                strFinal += "\(strFieldKey2)" + "\(strValueKey2)" + "\(strTypeKey2)"
            }
        }

        // IF CATEGORYID AVAIALABLE ADD
        if customer_id != 0 && isCustomerIdNeed {
            strFinal += "&" + "customer_id=\(customer_id)"
        }

        //  ---------- PAGINATION -----
        strFinal += "&" + "searchCriteria[pageSize]=\(pageSize)"
        strFinal += "&" + "searchCriteria[currentPage]=\(currentPageNo)"
        if  let userSalonId = GenericClass.sharedInstance.getSalonId(), userSalonId != "0" {
            strFinal += "&" + String(format: "salon_id=%@", userSalonId)
        }
        if is_config_bundle_brief_info_required == true
        {
            strFinal += "&" + "is_config_bundle_brief_info_required=true"
        }
        strFinal += "&" + "is_custom=true"

        print("\(strFinal)")
        return strFinal
    }

    // MARK: Global Search query
    func getURLForType(arrSubCat_type: [FilterKeys], pageSize: Int, currentPageNo: Int, is_config_bundle_brief_info_required: Bool?) -> String {
       return self.getURLForType(customer_id: 0, arrSubCat_type: arrSubCat_type, pageSize: pageSize, currentPageNo: currentPageNo, isCustomerIdNeed: false, is_config_bundle_brief_info_required: is_config_bundle_brief_info_required)
    }

    // MARK: Get request query which contains - Login details, store details, filter details , sort details & pagination details
    func getURLForType(customer_id: Double, arrSubCat_type: [FilterKeys], pageSize: Int, currentPageNo: Int, is_config_bundle_brief_info_required: Bool?) -> String {
       return self.getURLForType(customer_id: customer_id, arrSubCat_type: arrSubCat_type, pageSize: pageSize, currentPageNo: currentPageNo, isCustomerIdNeed: true, is_config_bundle_brief_info_required: is_config_bundle_brief_info_required)
    }

    // MARK: Get product model (ProductModel) from response data for showing on ui
    func getProductModel(element: HairTreatmentModule.Something.Items, isLogin: Bool) -> ProductModel {

        var offerPercentage: Double = 0
        var specialPrice = 0.0
        var productImage = ""
        var isFavourite = false
        var ratingPercentage = 0.0
        var totalReviews = 0.0
        var strBaseMediaUrl = ""
        var elementPrice = 0.0

        if let extension_attributes = element.extension_attributes {
            isFavourite = isLogin ? extension_attributes.wishlist_flag ?? false : false
            ratingPercentage = extension_attributes.rating_percentage ?? 0.0
            ratingPercentage = ((ratingPercentage / 100) * 5 )
            totalReviews = extension_attributes.total_reviews ?? 0.0
            strBaseMediaUrl = extension_attributes.media_url ?? ""
        }

        if let imageUrl = element.custom_attributes?.filter({ $0.attribute_code == "image" }), !strBaseMediaUrl.isEmpty {
            productImage = strBaseMediaUrl + (imageUrl.first?.value.description ?? "")
        }

        var configurablePrice = (price : 0.0, splPrice : 0.0)
        if let extension_attributes = element.extension_attributes, let arrObj = extension_attributes.configurable_options_info {
            configurablePrice = GenericClass.sharedInstance.getConfigurableProductsPriceInfo(element: arrObj)
        }
        elementPrice = element.price ?? 0
        specialPrice = element.price ?? 0

        if configurablePrice.price == 0 {
            // ****** Check for special price
            var isSpecialDateInbetweenTo = false

            if let specialFrom = element.custom_attributes?.filter({ $0.attribute_code == "special_from_date" }), let strDateFrom = specialFrom.first?.value.description, !strDateFrom.isEmpty, !strDateFrom.containsIgnoringCase(find: "null") {
                let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
                let fromDateInt: Int = Int(strDateFrom.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

                if currentDateInt >= fromDateInt {
                    isSpecialDateInbetweenTo = true
                    if let specialTo = element.custom_attributes?.filter({ $0.attribute_code == "special_to_date" }), let strDateTo = specialTo.first?.value.description, !strDateTo.isEmpty, !strDateTo.containsIgnoringCase(find: "null") {
                        let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
                        let toDateInt: Int = Int(strDateTo.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

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
                if let specialPriceValue = element.custom_attributes?.first(where: { $0.attribute_code == "special_price"}) {
                    let responseObject = specialPriceValue.value.description
                    specialPrice = responseObject.toDouble() ?? 0.0
                }
            }

            if  specialPrice != 0 {
                offerPercentage = specialPrice.getPercent(price: element.price ?? 0)
            }
            else {
                specialPrice = elementPrice
            }

        }
        else {
            specialPrice = configurablePrice.splPrice
            elementPrice = configurablePrice.price
        }

        let model = ProductModel(productId: element.id ?? 0, productName: element.name ?? "", price: elementPrice, specialPrice: specialPrice, reviewCount: "\(totalReviews.cleanForRating)", ratingPercentage: ratingPercentage, showCheckBox: false, offerPercentage: offerPercentage.cleanForRating, isFavourite: isFavourite, strImage: productImage, sku: (element.sku ?? ""), isProductSelected: false, type_id: element.type_id ?? "", type_of_service: "")

        return model
    }
}
