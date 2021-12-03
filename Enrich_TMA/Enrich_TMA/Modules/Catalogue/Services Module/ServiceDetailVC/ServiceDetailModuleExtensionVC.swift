//
//  ServiceDetailModuleExtensionVC.swift
//  EnrichSalon
//
//  Created by Apple on 02/12/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

extension ServiceDetailModuleVC {

        // MARK: addToCartSimpleOrVirtualProductForCustomer
        func addToCartSimpleOrVirtualProductForCustomer(selected: HairTreatmentModule.Something.Items) {
            if let object = UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDMine.Response.self, forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart) {
                var arrayOfItems =  [ProductDetailsModule.AddBulkProductMine.Items]()
                var arrayOfSimpleProduct = [ProductModel]()

                if (selected.type_id == SalonServiceTypes.simple ) || (selected.type_id == SalonServiceTypes.virtual ) {

                    let model = ProductModel(productId: selected.id ?? 0, productName: selected.name ?? "", price: 0.0, specialPrice: 0.0, reviewCount: "0", ratingPercentage: 0.0, showCheckBox: true, offerPercentage: "0", isFavourite: false, strImage: "", sku: (selected.sku ?? ""), isProductSelected: false, type_id: selected.type_id ?? "", type_of_service: selected.extension_attributes?.type_of_service ?? "")
                    arrayOfSimpleProduct.append(model)

                }
                else if selected.type_id == SalonServiceTypes.configurable {

                    var arrOfConfigurable = [ProductDetailsModule.AddBulkProductMine.Configurable_item_options]()
                    if let productOptions = selected.extension_attributes?.configurable_subproduct_options {
                        let productLinks = productOptions.first(where: { $0.isSubProductConfigurableSelected == true})
                        arrOfConfigurable.append(ProductDetailsModule.AddBulkProductMine.Configurable_item_options(option_id: Int64(productLinks?.attribute_id ?? "0"), option_value: Int64(productLinks?.value_index ?? "0")))
                    }

                    let extensionAttribute = ProductDetailsModule.AddBulkProductMine.Extension_attributes(configurable_item_options: arrOfConfigurable, bundle_options: nil)

                    let productOptions = ProductDetailsModule.AddBulkProductMine.Product_option(extension_attributes: extensionAttribute)
                    let object = ProductDetailsModule.AddBulkProductMine.Items(sku: selected.sku ?? "", qty: 1, product_option: productOptions, appointment_type: selected.extension_attributes?.type_of_service ?? "")
                    arrayOfItems.append(object)

                }
                else if selected.type_id == SalonServiceTypes.bundle {

                    var arrOfBundleProduct = [ProductDetailsModule.AddBulkProductMine.Bundle_options]()
                    var arrOfOptionSelected = [Int64]()
                    if let productOptions = selected.extension_attributes?.bundle_product_options {
                        let productLinks = productOptions.compactMap {
                            $0.product_links?.filter { $0.isBundleProductOptionsSelected ?? false }
                        }.flatMap { $0 }
                        productLinks.forEach {
                            arrOfOptionSelected.append(Int64($0.id?.description ?? "0") ?? 0)
                            arrOfBundleProduct.append(ProductDetailsModule.AddBulkProductMine.Bundle_options(option_id: $0.option_id ?? 0, option_selections: arrOfOptionSelected, option_qty: 1 ))
                            arrOfOptionSelected.removeAll()

                        }
                    }

                    let extensionAttribute = ProductDetailsModule.AddBulkProductMine.Extension_attributes(configurable_item_options: nil, bundle_options: arrOfBundleProduct)

                    let productOptions = ProductDetailsModule.AddBulkProductMine.Product_option(extension_attributes: extensionAttribute)
                    let object = ProductDetailsModule.AddBulkProductMine.Items(sku: selected.sku ?? "", qty: 1, product_option: productOptions, appointment_type: selected.extension_attributes?.type_of_service ?? "")
                    arrayOfItems.append(object)

                }

                for (_, element) in arrayOfSimpleProduct.enumerated() {
                    let object = ProductDetailsModule.AddBulkProductMine.Items(sku: element.sku, qty: 1, product_option: nil, appointment_type: element.type_of_service)
                    arrayOfItems.append(object)
                }
                if !arrayOfItems.isEmpty {
                    callAddToCartBulkProductAPIMine(items: arrayOfItems, quote_Id: object.data?.quote_id ?? 0 )
                }

            }
            else {
                callQuoteIdMineAPI()
                if let object = UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDMine.Response.self, forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart) {
                    var arrayOfItems =  [ProductDetailsModule.AddBulkProductMine.Items]()
                    var arrayOfSimpleProduct = [ProductModel]()

                    if (selected.type_id == SalonServiceTypes.simple ) || (selected.type_id == SalonServiceTypes.virtual ) {

                        let model = ProductModel(productId: selected.id ?? 0, productName: selected.name ?? "", price: 0.0, specialPrice: 0.0, reviewCount: "0", ratingPercentage: 0.0, showCheckBox: true, offerPercentage: "0", isFavourite: false, strImage: "", sku: (selected.sku ?? ""), isProductSelected: false, type_id: selected.type_id ?? "", type_of_service: selected.extension_attributes?.type_of_service ?? "")
                        arrayOfSimpleProduct.append(model)
                    }
                    else if selected.type_id == SalonServiceTypes.configurable {

                        var arrOfConfigurable = [ProductDetailsModule.AddBulkProductMine.Configurable_item_options]()
                        if let productOptions = selected.extension_attributes?.configurable_subproduct_options {
                            let productLinks = productOptions.first(where: { $0.isSubProductConfigurableSelected == true})
                            arrOfConfigurable.append(ProductDetailsModule.AddBulkProductMine.Configurable_item_options(option_id: Int64(productLinks?.attribute_id ?? "0"), option_value: Int64(productLinks?.value_index ?? "0")))
                        }

                        let extensionAttribute = ProductDetailsModule.AddBulkProductMine.Extension_attributes(configurable_item_options: arrOfConfigurable, bundle_options: nil)

                        let productOptions = ProductDetailsModule.AddBulkProductMine.Product_option(extension_attributes: extensionAttribute)
                        let object = ProductDetailsModule.AddBulkProductMine.Items(sku: selected.sku ?? "", qty: 1, product_option: productOptions, appointment_type: selected.extension_attributes?.type_of_service ?? "")
                        arrayOfItems.append(object)
                    }
                    else if selected.type_id == SalonServiceTypes.bundle {

                        var arrOfBundleProduct = [ProductDetailsModule.AddBulkProductMine.Bundle_options]()
                        var arrOfOptionSelected = [Int64]()
                        if let productOptions = selected.extension_attributes?.bundle_product_options {
                            let productLinks = productOptions.compactMap {
                                $0.product_links?.filter { $0.isBundleProductOptionsSelected ?? false }
                            }.flatMap { $0 }
                            productLinks.forEach {
                                arrOfOptionSelected.append(Int64($0.id?.description ?? "0") ?? 0)
                                arrOfBundleProduct.append(ProductDetailsModule.AddBulkProductMine.Bundle_options(option_id: $0.option_id ?? 0, option_selections: arrOfOptionSelected, option_qty: 1 ))
                                arrOfOptionSelected.removeAll()

                            }
                        }

                        let extensionAttribute = ProductDetailsModule.AddBulkProductMine.Extension_attributes(configurable_item_options: nil, bundle_options: arrOfBundleProduct)

                        let productOptions = ProductDetailsModule.AddBulkProductMine.Product_option(extension_attributes: extensionAttribute)
                        let object = ProductDetailsModule.AddBulkProductMine.Items(sku: selected.sku ?? "", qty: 1, product_option: productOptions, appointment_type: selected.extension_attributes?.type_of_service ?? "")
                        arrayOfItems.append(object)

                    }

                    for (_, element) in arrayOfSimpleProduct.enumerated() {
                        let object = ProductDetailsModule.AddBulkProductMine.Items(sku: element.sku, qty: 1, product_option: nil, appointment_type: element.type_of_service)
                        arrayOfItems.append(object)
                    }

                    if !arrayOfItems.isEmpty {
                        callAddToCartBulkProductAPIMine(items: arrayOfItems, quote_Id: object.data?.quote_id ?? 0 )
                    }

                }
            }
        }

        // MARK: addToCartSimpleOrVirtualProductForGuest
        func addToCartSimpleOrVirtualProductForGuest(selected: HairTreatmentModule.Something.Items) {
            if let object = UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDGuest.Response.self, forKey: UserDefauiltsKeys.k_key_GuestQuoteIdForCart) {
                var arrayOfItems = [ProductDetailsModule.AddBulkProductGuest.Items]()
                var arrayOfSimpleProduct = [ProductModel]()

                if (selected.type_id == SalonServiceTypes.simple ) || (selected.type_id == SalonServiceTypes.virtual ) {

                    let model = ProductModel(productId: selected.id ?? 0, productName: selected.name ?? "", price: 0.0, specialPrice: 0.0, reviewCount: "0", ratingPercentage: 0.0, showCheckBox: true, offerPercentage: "0", isFavourite: false, strImage: "", sku: (selected.sku ?? ""), isProductSelected: false, type_id: selected.type_id ?? "", type_of_service: selected.extension_attributes?.type_of_service ?? "")
                    arrayOfSimpleProduct.append(model)
                }
                else if selected.type_id == SalonServiceTypes.configurable {

                    var arrOfConfigurable = [ProductDetailsModule.AddBulkProductGuest.Configurable_item_options]()
                    if let productOptions = selected.extension_attributes?.configurable_subproduct_options {
                        let productLinks = productOptions.first(where: { $0.isSubProductConfigurableSelected == true})
                        arrOfConfigurable.append(ProductDetailsModule.AddBulkProductGuest.Configurable_item_options(option_id: Int64(productLinks?.attribute_id ?? "0"), option_value: Int64(productLinks?.value_index ?? "0")))
                    }

                    let extensionAttribute = ProductDetailsModule.AddBulkProductGuest.Extension_attributes(configurable_item_options: arrOfConfigurable, bundle_options: nil)

                    let productOptions = ProductDetailsModule.AddBulkProductGuest.Product_option(extension_attributes: extensionAttribute)
                    let object = ProductDetailsModule.AddBulkProductGuest.Items(sku: selected.sku ?? "", qty: 1, product_option: productOptions, appointment_type: selected.extension_attributes?.type_of_service ?? "")
                    arrayOfItems.append(object)
                }
                else if selected.type_id == SalonServiceTypes.bundle {

                    var arrOfBundleProduct = [ProductDetailsModule.AddBulkProductGuest.Bundle_options]()
                    var arrOfOptionSelected = [Int64]()
                    if let productOptions = selected.extension_attributes?.bundle_product_options {
                        let productLinks = productOptions.compactMap {
                            $0.product_links?.filter { $0.isBundleProductOptionsSelected ?? false }
                        }.flatMap { $0 }
                        productLinks.forEach {
                            arrOfOptionSelected.append(Int64($0.id?.description ?? "0") ?? 0)
                            arrOfBundleProduct.append(ProductDetailsModule.AddBulkProductGuest.Bundle_options(option_id: $0.option_id ?? 0, option_selections: arrOfOptionSelected, option_qty: 1 ))
                            arrOfOptionSelected.removeAll()
                        }

                    }

                    let extensionAttribute = ProductDetailsModule.AddBulkProductGuest.Extension_attributes(configurable_item_options: nil, bundle_options: arrOfBundleProduct)

                    let productOptions = ProductDetailsModule.AddBulkProductGuest.Product_option(extension_attributes: extensionAttribute)
                    let object = ProductDetailsModule.AddBulkProductGuest.Items(sku: selected.sku ?? "", qty: 1, product_option: productOptions, appointment_type: selected.extension_attributes?.type_of_service ?? "")
                    arrayOfItems.append(object)

                }

                for (_, element) in arrayOfSimpleProduct.enumerated() {
                    let object = ProductDetailsModule.AddBulkProductGuest.Items(sku: element.sku, qty: 1, product_option: nil, appointment_type: element.type_of_service)
                    arrayOfItems.append(object)
                }
                if !arrayOfItems.isEmpty {
                    callAddToCartBulkProductAPIGuest(items: arrayOfItems, quote_Id: object.data?.quote_id ?? "" )
                }

            }
            else {
                callToGetQuoteIdGuestAPI()
            }

        }

    // MARK: API callQuoteIdMineAPI
    func callQuoteIdMineAPI() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        notifyUpdate()

        let request = ProductDetailsModule.GetQuoteIDMine.Request()
        interactor?.doPostRequestGetQuoteIdMine(request: request, accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken)
    }
    // MARK: API callToGetQuoteIdGuestAPI
    func callToGetQuoteIdGuestAPI() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        notifyUpdate()

        let request = ProductDetailsModule.GetQuoteIDGuest.Request()
        interactor?.doPostRequestGetQuoteIdGuest(request: request, method: HTTPMethod.post)
    }

    // MARK: API callAddToCartBulkProductAPIMine
    func callAddToCartBulkProductAPIMine(items: [ProductDetailsModule.AddBulkProductMine.Items], quote_Id: Int64) {

        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        notifyUpdate()
        var salonId: String = ""
        if  let userSalonId = GenericClass.sharedInstance.getSalonId(), userSalonId != "0" {
            salonId = userSalonId
        }
//        var serviceAt: String =  ""
//        if  let dummy = UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_Key_SelectedLocationFor) {
//            let obj = dummy as! String
//                serviceAt = obj.lowercased()
//        }
        let request = ProductDetailsModule.AddBulkProductMine.Request(items: items, quote_id: quote_Id, salon_id: Int64(salonId))

        interactor?.doPostRequestAddBulkProductToCartMine(request: request, method: HTTPMethod.post, accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken, customer_id: GenericClass.sharedInstance.getCustomerId().toString)
    }

    // MARK: API callAddToCartBulkProductAPIGuest
    func callAddToCartBulkProductAPIGuest(items: [ProductDetailsModule.AddBulkProductGuest.Items], quote_Id: String) {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        notifyUpdate()
        var salonId: String = ""
        if  let userSalonId = GenericClass.sharedInstance.getSalonId(), userSalonId != "0" {
            salonId = userSalonId
        }
//        var serviceAt: String =  ""
//        if  let dummy = UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_Key_SelectedLocationFor) {
//            let obj = dummy as! String
//            serviceAt = obj.lowercased()
//        }

        let request = ProductDetailsModule.AddBulkProductGuest.Request(items: items, quote_id: quote_Id, salon_id: Int64(salonId))

        interactor?.doPostRequestAddBulkProductToCartGuest(request: request, method: HTTPMethod.post )
    }
    func getAllCartItemsAPIGuest() {

        if let object = UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDGuest.Response.self, forKey: UserDefauiltsKeys.k_key_GuestQuoteIdForCart) {

            EZLoadingActivity.show("Loading...", disableUI: true)
            dispatchGroup.enter()
            notifyUpdate()

            let request = ProductDetailsModule.GetAllCartsItemGuest.Request(quote_id: object.data?.quote_id ?? "")
            interactor?.doGetRequestToGetAllCartItemsGuest(request: request, method: HTTPMethod.get)
        }
        else {
            callToGetQuoteIdGuestAPI()
        }

    }
    func getAllCartItemsAPICustomer() {
        // Success Needs To check Static
        if UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDMine.Response.self, forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart) != nil {
            EZLoadingActivity.show("Loading...", disableUI: true)
            dispatchGroup.enter()
            notifyUpdate()

            //let request = ProductDetailsModule.GetAllCartsItemCustomer.Request(quote_id: object.data?.quote_id ?? 0, accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken )
            let request = ProductDetailsModule.GetAllCartsItemCustomer.Request(accessToken: GenericClass.sharedInstance.isuserLoggedIn().accessToken )
            interactor?.doGetRequestToGetAllCartItemsCustomer(request: request, method: HTTPMethod.get)

        }
        else {
            callQuoteIdMineAPI()
        }
    }
}

// MARK: Call Webservice
extension ServiceDetailModuleVC {
    // MARK: callProductDetailsAPI
    func callProductDetailsAPI() {

        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        var queryString = ""
        if let categorySKU = self.serverData[subCategoryDataObjSelectedIndex].sku, !categorySKU.isEmpty {
            queryString += String(format: "%@?", categorySKU)
        }

        if  let userSalonId = GenericClass.sharedInstance.getSalonId(), userSalonId != "0" {
            queryString += String(format: "salon_id=%@", userSalonId)
        }

        if  let userLoggedIn = UserDefaults.standard.value( OTPVerificationModule.MobileNumberWithOTPVerification.Response.self, forKey: UserDefauiltsKeys.k_Key_LoginUserSignIn) {
            if let accessToken = userLoggedIn.data?.access_token, !accessToken.isEmpty {
                queryString += String(format: "&customer_id=%@", userLoggedIn.data?.customer_id ?? "0")
            }
        }
        queryString += String(format: "&is_custom=true")

        let request = ServiceDetailModule.ServiceDetails.Request(requestedParameters: queryString)
        interactor?.getProductDetails(request: request, method: HTTPMethod.get)
    }

    // MARK: callProductReviewsAPI
    func callProductReviewsAPI() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()

        let request = ServiceDetailModule.ServiceDetails.ProductReviewRequest(product_id: "\(self.serverData[subCategoryDataObjSelectedIndex].id!)", limit: maxlimitToReviewOnServiceDetails, page: 1)
        interactor?.doPostRequestProductReviews(request: request, method: HTTPMethod.post)
    }
    // MARK: callFrequentlyAvailedAPI
    func callFrequentlyAvailedAPI() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        let request = ServiceDetailModule.ServiceDetails.FrequentlyAvailedProductRequest()
        interactor?.doPostRequestFrequentlyAvailedServices(request: request, method: HTTPMethod.post)
    }

    // MARK: callInsightAPI
    func callInsightAPI() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        let request = ProductLandingModule.Something.Request(category_id: "", customer_id: "", limit: maxlimitToProductQuantity)
        interactor?.doPostRequestBlogs(request: request, method: HTTPMethod.post)
    }

    // MARK: getDataForSelectedService
    func getDataForSelectedService(subCategoryId: String, genderId: String = "") {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        notifyUpdate()
        var queryString = "[filterGroups][0][filters][0][field]=entity_id&searchCriteria[filterGroups][0][filters][0][value]=\(subCategoryId)&searchCriteria[filterGroups][0][filters][0][conditionType]=eq"

        if !genderId.isEmpty {
            queryString += String(format: "&searchCriteria[filterGroups][1][filters][0][field]=gender&searchCriteria[filterGroups][1][filters][0][value]=\(genderId)&searchCriteria[filterGroups][1][filters][0][conditionType]=finset")

        }
        if  let userSalonId = GenericClass.sharedInstance.getSalonId(), userSalonId != "0" {
            queryString += String(format: "&searchCriteria[filterGroups][2][filters][0][field]=salon_id&searchCriteria[filterGroups][2][filters][0][value]=%@&searchCriteria[filterGroups][2][filters][0][conditionType]=finset", userSalonId)
        }

        queryString += String(format: "&searchCriteria[filterGroups][3][filters][0][field]=visibility&searchCriteria[filterGroups][3][filters][0][value]=4&searchCriteria[filterGroups][3][filters][0][conditionType]=eq")

        if  GenericClass.sharedInstance.isuserLoggedIn().status {
            queryString += String(format: "&customer_id=%@", GenericClass.sharedInstance.getCustomerId().toString)
        }
        queryString += String(format: "&is_custom=true")

        let request = HairTreatmentModule.Something.Request(queryString: queryString)
        interactor?.doGetRequestForFrequentlyAvailedServices(request: request, method: HTTPMethod.get)

    }

    func displaySuccess<T: Decodable>(viewModel: T) {

        DispatchQueue.main.async {[unowned self] in

            if T.self == ServiceDetailModule.ServiceDetails.Response.self {
                // Product Details
                self.parseProductDetails(viewModel: viewModel)

            }
            else  if T.self == ServiceDetailModule.ServiceDetails.FrequentlyAvailedProductResponse.self {
                // Frequently Availed Products
                self.parseFrequentlyAvailedProducts(viewModel: viewModel)

            }
            else if T.self == ServiceDetailModule.ServiceDetails.ProductReviewResponse.self {
                // Products Reviews
                self.parseProductReviews(viewModel: viewModel)
            }
            else if T.self == ServiceDetailModule.ServiceDetails.RateAServiceResponse.self {
                // Rate a Sevice
                self.parseRateAService(viewModel: viewModel)
            }
            else if T.self == HairTreatmentModule.Something.AddToWishListResponse.self {
                // Add To WishList
                self.parseAddToWishList(viewModel: viewModel)
            }
            else if T.self == HairTreatmentModule.Something.RemoveFromWishListResponse.self {
                // Remove From WishList
                self.parseRemoveFromWishList(viewModel: viewModel)

            }
            else if T.self == ProductLandingModule.Something.ResponseBlogs.self {
                // GetInsight
                self.parseGetInsight(viewModel: viewModel)
            }
            else if T.self == ProductDetailsModule.GetQuoteIDMine.Response.self {
                // GetQuoteIdMine
                self.parseDataGetQuoteIDMine(viewModel: viewModel)
            }
            else if T.self == ProductDetailsModule.GetQuoteIDGuest.Response.self {
                // GetQuoteIdGuest
                self.parseDataGetQuoteIDGuest(viewModel: viewModel)
            }
            else if T.self == ProductDetailsModule.AddBulkProductGuest.Response.self {
                // AddBulkProductGuest
                self.parseDataBulkProductGuest(viewModel: viewModel)
            }
            else if T.self == ProductDetailsModule.AddBulkProductMine.Response.self {
                // AddBulkProductMine
                self.parseDataBulkProductMine(viewModel: viewModel)
            }

            if T.self == HairTreatmentModule.Something.Response.self {
                // Add For Frequently Availed Services
                self.parseAddFrequentlyAvailedServices(viewModel: viewModel)
            }

        }

    }

    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        dispatchGroup.leave()
        self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage!)

    }
    func displaySuccess<T: Decodable>(responseSuccess: [T]) {
        DispatchQueue.main.async {[unowned self] in
            if  [T].self == [ProductDetailsModule.GetAllCartsItemCustomer.Response].self {
                // GetAllCartItemsForCustomer
                self.parseGetAllCartsItemCustomer(responseSuccess: responseSuccess)
            }
            else if [T].self == [ProductDetailsModule.GetAllCartsItemGuest.Response].self {
                // GetAllCartItemsForGuest
                self.parseGetAllCartsItemGuest(responseSuccess: responseSuccess)
            }
        }
    }

}
