//
//  GenericClass.swift
//  EnrichSalon
//
//  Created by Apple on 16/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit

func BG(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .default).async(execute: block)
}

func UI(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
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
            return jsonString!

        } catch {

        }
        return nil
    }
    func convertJSONToData(json: Any) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }

}

extension GenericClass {
    // MARK: - Database Methods For Salon Service Either Home/Salon
    func checkDataInDatabase(data: HairTreatmentModule.Something.Response) -> HairTreatmentModule.Something.Response {

     //   let records = CoreDataStack.sharedInstance.allRecords(SelectedSalonService.self)
        var serverData = data

//        for (_, element1) in (records.enumerated()) {
//            if let index = data.items?.firstIndex(where: { $0.id == element1.selectedItemId}) {
//                let jsonString = element1.selectedItemValue
//                let jsonData = Data(jsonString!.utf8)
//                if let dataObj = jsonData as? Data {
//                    do {
//                        let responseObject = try JSONDecoder().decode(HairTreatmentModule.Something.Items.self, from: dataObj)
//                        serverData.items?[index] = responseObject
//                    } catch {
//                        print("Error")
//                    }
//                }
//            }
//
//        }

        return serverData
    }
//    func getCartSalonHomeServiceValues(lblHour: UILabel, lblService: UILabel) -> (servicesHours: String, serviceCount: Int, serviceTotalPrice: Double) {
//        let records = CoreDataStack.sharedInstance.allRecords(SelectedSalonService.self)
//
//        var servicesCount: Int = 0
//        var services: String = "Services"
//        var servicesHours: String = ""
//        var serviceTime: Double = 0
//        var servicesText: String = ""
//        var serviceTotalPrice: Double = 0
//
//        for (_, element1) in (records.enumerated()) {
//            let jsonString = element1.selectedItemValue
//            let jsonData = Data(jsonString!.utf8)
//            if let dataObj = jsonData as? Data {
//                do {
//                    let responseObject = try JSONDecoder().decode(HairTreatmentModule.Something.Items.self, from: dataObj)
//
//                    if (responseObject.type_id?.equalsIgnoreCase(string: SalonServiceTypes.bundle))! {
//                        if let productOptions = responseObject.extension_attributes?.bundle_product_options {
//                            let productLinks = productOptions.compactMap {
//                                $0.product_links?.filter { $0.isBundleProductOptionsSelected ?? false }
//                            }.flatMap { $0 }
//                            productLinks.forEach {
//                                let doubleVal: Double = ($0.extension_attributes?.service_time?.toDouble() ?? 0 ) * 60
//                                serviceTime = serviceTime + doubleVal
//                            }
//                        }
//                    } else if (responseObject.type_id?.equalsIgnoreCase(string: SalonServiceTypes.configurable))! {
//                        if let productOptions = responseObject.extension_attributes?.configurable_subproduct_options {
//                            let productLinks = productOptions.first(where: { $0.isSubProductConfigurableSelected == true})
//                            let doubleVal: Double = (productLinks?.service_time?.toDouble() ?? 0 ) * 60
//                            serviceTime = serviceTime + doubleVal
//                        }
//                    } else {
//                        if let object = responseObject.custom_attributes?.first(where: { $0.attribute_code == "service_time"}) {
//                            let doubleVal: Double = (object.value.description.toDouble() ?? 0 ) * 60
//                            serviceTime = serviceTime + doubleVal
//                        }
//                    }
//                    serviceTotalPrice = serviceTotalPrice + (responseObject.price ?? 0)
//                    servicesCount = servicesCount + 1
//                } catch {
//                    print("Error")
//                }
//            }
//
//        }
//        services = servicesCount > 1 ? "Services" : "Service"
//
//        servicesHours = String(format: "%@", serviceTime.asString(style: .brief))
//        servicesText = String(format: "%d %@ ₹ %@", servicesCount, services, serviceTotalPrice.cleanForPrice)
//
//        // Default SemiBold
//        setDefault(text: servicesHours, rangeText: servicesHours, fontName: UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 27.0 : 18.0)!, lable: lblHour)
//        setDefault(text: servicesText, rangeText: servicesText, fontName: UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 27.0 : 18.0)!, lable: lblService)
//
//        resetServiceLabels(text: servicesHours, rangeText: "hrs", fontName: UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 21.0 : 14.0)!, lable: lblHour)
//
//        resetServiceLabels(text: servicesText, rangeText: "₹", fontName: UIFont(name: FontName.NotoSansSemiBold.rawValue, size: is_iPAD ? 21.0 : 14.0)!, lable: lblService)
//
//        return(servicesHours, servicesCount, serviceTotalPrice)
//    }
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
    func getSalonId() -> String? {
//        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
//            return userSelectionForService.salon_id
//        }
        return nil
    }

    func getCustomerId() -> (toDouble: Double, toString: String) {

        if let userLoggedIn = UserDefaults.standard.value( OTPVerificationModule.MobileNumberWithOTPVerification.Response.self, forKey: UserDefauiltsKeys.k_Key_LoginUserSignIn) {
            //            if let accessToken = userLoggedIn.data?.access_token,!accessToken.isEmpty{
            return (Double(userLoggedIn.data?.customer_id ?? "")!, (userLoggedIn.data?.customer_id ?? ""))
            //            }
        }
        return (0, "")
    }

    func getGender() -> String? {
        //        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService.rawValue){
        //            return userSelectionForService.gender
        //        }

        return nil
    }
}
