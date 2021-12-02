//
//  ConstantsStrings.swift
//  EnrichSalon
//
//  Created by Mugdha Mundhe on 4/2/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

let is_iPAD = UIDevice.current.model.hasPrefix("iPad")
let screenPopUpAlpha: CGFloat = 0.50
let kProductCountPerPageForListing = 10
let searchBarInsideBackgroundColor: UIColor = UIColor(red: 251 / 255, green: 249 / 255, blue: 249 / 255, alpha: 1.0)
let toastMessageDuration: Double = 2.0
let tableViewNoDataAvailable = "No data available"
let tableViewNoSalonAvailable = "No salons available"
let tableViewNoServiceAvailable = "No services available"
let tableViewNoAddOnsAvailable = "No add-ons available"
let noReviewsMessage = "Be the first one to review"
let tableViewNoAddressAvailable = "No addresses available"

let navigationBarTitleTrimTo = 25
let GenericError = "Something went wrong. Please try again later"
let alertTitle = "Alert!"
let alertTitleSuccess = "Success!"
let maxlimitToProductQuantity: Int64 = 5
let country = "IN"
//let minlimitToProductQuantity = 1

enum ImageNames: String {
    case enabledRed = "enabledButton.png"
    case disabledGray = "disabledButton.png"
    case enabledLogo = "iconImgOtpSelected"
    case disabledLogo = "iconImgOtpNonSelected"
}

class ConstantsStrings: NSObject {
    
}

enum FontName: String {
    case FuturaPTBook = "FuturaPT-Book"
    case FuturaPTDemi = "FuturaPT-Demi"
    case FuturaPTMedium = "FuturaPT-Medium"
    case NotoSansSemiBold = "NotoSans-SemiBold"
    case NotoSansRegular = "NotoSans-Regular"
    
}

enum NavigationBarTitle {
    static let orderConfirmation = "Order Confirmation"
    static let bookingDetails = "Booking Details"
    static let detailedSummary = "Detailed Summary"
    static let addNewAddress = "Add New Address"
    static let editAddress = "Edit Address"
    static let myWishList = "My Wishlist"
    static let myBookings = "My Bookings"
    
}

enum SalonServiceTypes {
    static let simple = "simple"
    static let configurable = "configurable"
    static let bundle = "bundle"
    
}
enum SalonServiceAt {
    static let home = "Home"
    static let Salon = "Salon"
    static let Anny = "Any"
    
}
enum PersonType {
    static let male = "Male"
    static let female = "Female"
}
enum SalonServiceSpecifierFormat {
    static let priceFormat = "%.1f"
    static let reviewFormat = "%.0f"
}

enum ServiceStaticID: String {
    case salonId = "34"
    case homeId = "91"
}
enum ProductConfigurableDetailType  {
    static let quantity = "container_qty"
    static let color = "color"
}


enum AlertMessagesSuccess {
    static let removedService = "Service Removed Successfully."
    static let userCancelPayTmTransaction = "User cancelled transaction."
    static let orderPlacedSuccessfully = "Order Placed Successfully."
    static let logoutSuccessfully = "Logout successfully."
    static let eventSuccess = "Event added successfully"
    
}
enum AlertMessagesToAsk {
    static let removeService = "Are you sure you want to remove this service?"
    static let askToLogout = "Are you sure you want to logout?"
    static let askToDeleteAddress = "Are you sure you want to delete address?"
    static let defaultAddress = "Dafault address cannot be removed."
    
}
enum AlertButtonTitle {
    static let yes = "Yes"
    static let no = "No"
}
enum AlertToWarn {
    static let selectedSalonNotInRange = "We are sorry!\nAt the moment our Home Services are not available in your selected location. \n You can try some other location\nor\nAvail our Salon Services."
    static let eventError = "Event not added."
    
    
}
