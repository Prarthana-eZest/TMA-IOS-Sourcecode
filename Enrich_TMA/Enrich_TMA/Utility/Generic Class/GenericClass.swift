//
//  GenericClass.swift
//  EnrichSalon
//
//  Created by Apple on 16/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit

// MARK: - struct - FilterKeys, ListingDataModel

func BG(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .default).async(execute: block)
}

func UI(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}

struct FilterKeys {
    let field: String?
    let value: Any?
    let type: String?
}

class GenericClass: NSObject {

    static let sharedInstance = GenericClass()

    private var setFevoProducts: [ChangedFevoProducts] = []

    // ------------- SEARCH FIELDS  -------------
    let filterGroups = "searchCriteria[filterGroups]"
    let appendField = "[filters][0][field]"
    let appendValue = "[filters][0][value]"
    let appendConditionType = "[filters][0][conditionType]"
    let searchGroupField = "searchCriteria[sortOrders][0][field]"
    let searchGroupDirection = "searchCriteria[sortOrders][0][direction]"
    // -------------  -------------  -------------

    func convertCodableToJSONString<T: Codable>(obj: T) -> String? {

        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(obj)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString ?? ""

        }
        catch {

        }
        return nil
    }
    func convertJSONToData(json: Any) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        }
        catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }

    func getDeviceUUID() -> String {
        let uniqueDeviceId: String? = KeychainWrapper.standard.string(forKey: UserDefauiltsKeys.k_key_UniqueDeviceId)

        guard uniqueDeviceId != nil else {
            let uuid = generateUuid()
            let saveSuccessful: Bool = KeychainWrapper.standard.set(uuid, forKey: UserDefauiltsKeys.k_key_UniqueDeviceId)
            if saveSuccessful {
                return uuid
            }
            else {
                fatalError("Unable to save uuid")
            }

        }
        return uniqueDeviceId!
    }

    private func generateUuid() -> String {

        let uuidRef: CFUUID = CFUUIDCreate(nil)
        let uuidStringRef: CFString = CFUUIDCreateString(nil, uuidRef)
        return uuidStringRef as String
    }
    
    func getDurationTextFromSeconds(minuts: Int) -> String{
        let values = secondsToHoursMinutesSeconds(seconds: minuts * 60)
        var labelText = ""
        if minuts == 0 {
            return "0 min"
        }
        if values.0 > 0{
            labelText.append("\(values.0) hr ")
        }
        if values.1 > 0 {
            labelText.append("\(values.1) min")
        }
        return labelText
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

}

extension GenericClass {
    // MARK: - Database Methods For Salon Service Either Home/Salon

    func resetServiceLabels(text: String, rangeText: String, fontName: UIFont, lable: UILabel) {
        let range = (text as NSString).range(of: rangeText)
        let attribute = NSMutableAttributedString(string: text)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range)
        attribute.addAttribute(NSAttributedString.Key.font, value: fontName, range: range)
        lable.attributedText = attribute

    }

    func setDefault(text: String, rangeText: String, fontName: UIFont, lable: UILabel) {
        let range = (text as NSString).range(of: rangeText)
        let attribute = NSMutableAttributedString(string: text)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range)
        attribute.addAttribute(NSAttributedString.Key.font, value: fontName, range: range)
        lable.attributedText = attribute

    }

    func getUserLoggedInInfoKeyChain() -> LoginModule.UserLogin.UserData? {

        let uniqueUserInfo: Data? = KeychainWrapper.standard.data(forKey: UserDefauiltsKeys.k_Key_LoginUserSignIn)
        guard uniqueUserInfo != nil else {
            return nil
        }
        if let data = uniqueUserInfo,
            let value = try? JSONDecoder().decode(LoginModule.UserLogin.UserData.self, from: data) {
            return value
        }
        return nil
    }

    func setUserLoggedInfoInKeyChain(data: Data) {
        KeychainWrapper.standard.set(data, forKey: UserDefauiltsKeys.k_Key_LoginUserSignIn)
    }

}

extension GenericClass {

    func isuserLoggedIn() ->(status: Bool, accessToken: String, refreshToken: String) {

        var userAccessToken: String = ""
        var userRefreshToken: String = ""
        var userstatus: Bool = false

        if let dummy = getUserLoggedInInfoKeyChain() {
            userstatus = true
            userAccessToken = (dummy.access_token ?? "")
            userRefreshToken = dummy.refresh_token ?? ""
        }

        return(userstatus, userAccessToken, userRefreshToken)
    }

    func updateCustomerQuoteId(customerQuoteid: Int64) {
        if let object = UserDefaults.standard.value( ProductDetailsModule.GetQuoteIDMine.Response.self, forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart) {
            var newObject = object
            newObject.data?.quote_id = customerQuoteid
            UserDefaults.standard.set(encodable: newObject, forKey: UserDefauiltsKeys.k_key_CustomerQuoteIdForCart)

        }

    }

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

}

extension GenericClass {

    func getFevoriteProductSet() -> [ChangedFevoProducts] {
        return setFevoProducts
    }

    func removeFevoriteProductSet() {
        setFevoProducts = []
    }

    func setFevoriteProductSet(model: ChangedFevoProducts) {
        setFevoProducts.append(model)
        setFevoProducts = setFevoProducts.reversed().unique(map: {$0.productId})
        print("setFevoriteProductSet : \(setFevoProducts)")
    }

    func getConditionalFieldKey(index: Int, indexFilter: Int) -> String {
        let strField = appendField.replacingOccurrences(of: "0", with: "\(indexFilter)")
        return filterGroups + "[\(index)]" + strField
    }

    //searchCriteria[filterGroups] + [1] + [filters][0][value]
    func getConditionalValueKey(index: Int, indexFilter: Int) -> String {
        let strField = appendValue.replacingOccurrences(of: "0", with: "\(indexFilter)")
        return filterGroups + "[\(index)]" + strField
    }

    func getConditionalTypeKey(index: Int, indexFilter: Int) -> String {
        let strField = appendConditionType.replacingOccurrences(of: "0", with: "\(indexFilter)")
        return filterGroups + "[\(index)]" + strField
    }

    func getSortingFieldKey() -> String {
        return searchGroupField
    }

    func getSortingDirectionKey() -> String {
        return searchGroupDirection
    }
}

extension GenericClass {

    //    func getURLForType(arrSubCat_type: [FilterKeys], pageSize: Int, currentPageNo: Int) -> String
    func getURLForType(arrSubCat_type: [FilterKeys]) -> String {

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

        //        // IF CATEGORYID AVAIALABLE ADD
        //        if(customer_id != 0 && isCustomerIdNeed) {
        //            strFinal = strFinal + "&" + "customer_id=\(customer_id)"
        //        }

        //        //  ---------- PAGINATION -----
        //        strFinal = strFinal + "&" + "searchCriteria[pageSize]=\(pageSize)"
        //        strFinal = strFinal + "&" + "searchCriteria[currentPage]=\(currentPageNo)"

        print("\(strFinal)")
        return strFinal
    }
}

extension GenericClass {
    func getSalonId() -> String? {
        if let userData = UserDefaults.standard.value(MyProfile.GetUserProfile.UserData.self, forKey: UserDefauiltsKeys.k_Key_LoginUser) {
            return userData.salon_id
        }
        return nil
    }

    func getCustomerId() -> (toDouble: Double, toString: String) {

        //        if let userLoggedIn = UserDefaults.standard.value( OTPVerificationModule.ChangePasswordWithOTPVerification.Response.self, forKey: UserDefauiltsKeys.k_Key_LoginUserSignIn) {
        //            //            if let accessToken = userLoggedIn.data?.access_token,!accessToken.isEmpty{
        //            return (Double(userLoggedIn.data?.customer_id ?? "")!, (userLoggedIn.data?.customer_id ?? ""))
        //            //            }
        //        }
        return (0, "")
    }

    func getGender() -> String? {
        //        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService.rawValue){
        //            return userSelectionForService.gender
        //        }

        return nil
    }
}

extension GenericClass {

    func calculateSpecialPriceForConfigurable(element: HairTreatmentModule.Something.Configurable_subproduct_options) -> (specialPrice: Double, offerPercentage: Double, isHavingSpecialPrice: Bool ) {

        // ****** Check for special price

        var specialPrice: Double = 0.0
        var offerPercentage: Double = 0
        var isSpecialDateInbetweenTo = false

        if let specialFrom = element.special_from_date {
            let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
            let fromDateInt: Int = Int(specialFrom.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

            if currentDateInt >= fromDateInt {
                isSpecialDateInbetweenTo = true
                if let specialTo = element.special_to_date {
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
            if let splPrice = element.special_price, splPrice != 0 {
                specialPrice = splPrice
                offerPercentage = specialPrice.getPercent(price: element.price ?? 0)
            }
            if specialPrice == element.price {
                isSpecialDateInbetweenTo = false
            }
        }

        return (specialPrice, offerPercentage.rounded(toPlaces: 1), isSpecialDateInbetweenTo)
    }

    func getConfigurableProductsPrice(element: [HairTreatmentModule.Something.Configurable_subproduct_options]) -> (price: Double, splPrice: Double) {

        let amount = element.sorted { (model1, model2) -> Bool in
            guard let price = model1.price, let price2 = model2.price else {
                return false
            }

            if price < price2 {
                return true
            }
            return false
        }

        var specialPrice = 0.0
        var priceObj = 0.0

        if let firstObj = amount.first {

            specialPrice = firstObj.price ?? 0
            priceObj = firstObj.price ?? 0

            var isSpecialDateInbetweenTo = false

            if let strDateFrom = firstObj.special_from_date, !strDateFrom.isEmpty, !strDateFrom.containsIgnoringCase(find: "null") {
                let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
                let fromDateInt: Int = Int(strDateFrom.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

                if currentDateInt >= fromDateInt {
                    isSpecialDateInbetweenTo = true
                    if let strDateTo = firstObj.special_to_date, !strDateTo.isEmpty, !strDateTo.containsIgnoringCase(find: "null") {

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
                specialPrice = firstObj.special_price ?? 0.0
            }
            else {
                specialPrice = firstObj.price ?? 0.0
            }

            return (priceObj, specialPrice)
        }
        return (0.0, 0.0)
    }
    
    func getConfigurableProductsPriceInfo(element: [HairTreatmentModule.Something.Configurable_Options_Info]) -> (price: Double, splPrice: Double) {

           let amount = element.sorted { (model1, model2) -> Bool in
               guard let price = model1.price, let price2 = model2.price else {
                   return false
               }

               if price < price2 {
                   return true
               }
               return false
           }

           var specialPrice = 0.0
           var priceObj = 0.0

           if let firstObj = amount.first {

               specialPrice = firstObj.price ?? 0
               priceObj = firstObj.price ?? 0

               var isSpecialDateInbetweenTo = false

               isSpecialDateInbetweenTo = GenericClass.sharedInstance.isSpecialPriceApplicable(special_from_date: firstObj.special_from_date ?? "", special_to_date: firstObj.special_to_date ?? "")

              

               if isSpecialDateInbetweenTo {
                   specialPrice = firstObj.special_price ?? 0.0
               }
               else {
                   specialPrice = firstObj.price ?? 0.0
               }

               return (priceObj, specialPrice)
           }
           return (0.0, 0.0)
       }
    
    func isSpecialPriceApplicable (special_from_date: String?, special_to_date : String? )-> Bool
    {
        var isSpecialDateInbetweenTo = false

        if let strDateFrom = special_from_date, !strDateFrom.trim().isEmpty {

                               let currentDateInt: Int = Int(Date().dayYearMonthDateHyphen) ?? 0
                               let fromDateInt: Int = Int(strDateFrom.getFormattedDateForSpecialPrice().dayYearMonthDateHyphen) ?? 0

                               if currentDateInt >= fromDateInt {
                                   isSpecialDateInbetweenTo = true
                                if let strDateTo = special_to_date, !strDateTo.trim().isEmpty {
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
        return isSpecialDateInbetweenTo
    }
}

extension GenericClass {

    func shareOnWhatsApp(message: String) {
        let urlWhats = "whatsapp://send?text=\(message)"

        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let whatsappURL = NSURL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                    UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: { (_) in

                    })
                }
                else {
                    // Handle a problem
                }
            }
        }
    }
    func getGiftCardCategoryId() -> String {

        var  categoryId = GiftCardCategoryId.dev
        #if DEBUG
        print("DEBUG")
        categoryId = GiftCardCategoryId.dev
        #elseif STAGE
        print("STAGE")
        categoryId = GiftCardCategoryId.stage
        #elseif RELEASE
        print("RELEASE")
        categoryId = GiftCardCategoryId.production
        #endif

        return categoryId
    }
    func getProductCategoryId() -> String {

        var  categoryId = ProductCategoryId.dev
        #if DEBUG
        print("DEBUG")
        categoryId = ProductCategoryId.dev
        #elseif STAGE
        print("STAGE")
        categoryId = ProductCategoryId.stage
        #elseif RELEASE
        print("RELEASE")
        categoryId = ProductCategoryId.production
        #endif

        return categoryId
    }

    func getProductAttributeId() -> String {

        var  categoryId = ProductAttributeSetId.dev
        #if DEBUG
        print("DEBUG")
        categoryId = ProductAttributeSetId.dev
        #elseif STAGE
        print("STAGE")
        categoryId = ProductAttributeSetId.stage
        #elseif RELEASE
        print("RELEASE")
        categoryId = ProductAttributeSetId.production
        #endif

        return categoryId
    }
    func getServiceAttributeId() -> String {

        var  categoryId = ServiceAttributeSetId.dev
        #if DEBUG
        print("DEBUG")
        categoryId = ServiceAttributeSetId.dev
        #elseif STAGE
        print("STAGE")
        categoryId = ServiceAttributeSetId.stage
        #elseif RELEASE
        print("RELEASE")
        categoryId = ServiceAttributeSetId.production
        #endif

        return categoryId
    }
    func getMembershipAttributeId() -> String {

        var  categoryId = MembershipAttributeSetId.dev
        #if DEBUG
        print("DEBUG")
        categoryId = MembershipAttributeSetId.dev
        #elseif STAGE
        print("STAGE")
        categoryId = MembershipAttributeSetId.stage
        #elseif RELEASE
        print("RELEASE")
        categoryId = MembershipAttributeSetId.production
        #endif

        return categoryId
    }

    func getSalonServiceStaticId() -> String {

        var  categoryId = ServiceSalonStaticID.salonIdDev
        #if DEBUG
        print("DEBUG")
        categoryId = ServiceSalonStaticID.salonIdDev
        #elseif STAGE
        print("STAGE")
        categoryId = ServiceSalonStaticID.salonIdStage
        #elseif RELEASE
        print("RELEASE")
        categoryId = ServiceSalonStaticID.salonIdProduction
        #endif

        return categoryId
    }
    func getHomeServiceStaticId() -> String {

        var  categoryId = ServiceHomeStaticID.homeIdDev
        #if DEBUG
        print("DEBUG")
        categoryId = ServiceHomeStaticID.homeIdDev
        #elseif STAGE
        print("STAGE")
        categoryId = ServiceHomeStaticID.homeIdStage
        #elseif RELEASE
        print("RELEASE")
        categoryId = ServiceHomeStaticID.homeIdProduction
        #endif

        return categoryId
    }

    func createBaseUrlForWebViewLinks(endPoint: String) -> String {

        let  BaseUrl = getBaseUrl()
        let finalEndpoint = String(format: "%@%@", BaseUrl, endPoint)
        print("BaseUrl \(finalEndpoint)")
        return finalEndpoint
    }

    func getBaseUrl() -> String {

        // MAGENTO
        var  BaseUrl = "https://enrichsalon.co.in/" //"https://enrich-magento.e-zest.net/"
        #if DEBUG
        print("DEBUG")
        BaseUrl = "https://enrichsalon.co.in/"
        #elseif STAGE
        print("STAGE")
        BaseUrl = "https://stage.enrichsalon.co.in/"
        #elseif RELEASE
        print("RELEASE")
        BaseUrl = "https://enrichsalon.co.in/" //"https://enrichsalon.co.in/erp/source/live/"
        #endif

        print("BaseUrl \(BaseUrl)")
        return BaseUrl
    }

    func getFCMTopicKeys(keyFor: String) -> String {

        var  fcmTopicKeys = "DEV_"
        #if DEBUG
        print("DEBUG")
        fcmTopicKeys =  "DEV_" + keyFor
        #elseif STAGE
        print("STAGE")
        fcmTopicKeys =  "STG_" + keyFor
        #elseif RELEASE
        print("RELEASE")
        fcmTopicKeys = "PROD_" + keyFor
        #endif

        return fcmTopicKeys
    }

}

extension GenericClass {

    // MARK: Address show
    func showSalonAddressOnScreen() -> String {
        var strAddress = ""
        //        if  let dummy = UserDefaults.standard.value(LocationModule.Something.SalonParamModel.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalon) {
        //            strAddress = self.getSalonFullAddress(model: dummy)
        //        }
        return strAddress
    }

}

extension UITapGestureRecognizer {

    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        //let textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              //(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

        //let locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                        // locationOfTouchInLabel.y - textContainerOffset.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }

}
