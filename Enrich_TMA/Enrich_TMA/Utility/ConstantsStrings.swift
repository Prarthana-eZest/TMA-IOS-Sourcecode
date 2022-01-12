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
let kProductCountPerPageForListing = 50
let searchBarInsideBackgroundColor: UIColor = UIColor(red: 251 / 255, green: 249 / 255, blue: 249 / 255, alpha: 1.0)
let toastMessageDuration: Double = 2.0

let resendOtpDuration = 59

let k_RupeeSymbol = "₹"

let noReviewsMessage = "Be the first one to review"

let navigationBarTitleTrimTo = 30
let GenericError = "Unable to fetch all the information from server. Please try after some time."
let GenericErrorLoginRefreshToken = "Something went wrong. Please do login again."
let inActiveCartQuoteId = "Current customer does not have an active cart."

let sessionExpire = "Your session is expired. Please do re-login again."

let alertTitle = "Alert!"
let alertTitleSuccess = "Success!"
let maxlimitToProductQuantity: Int64 = 5
let maxlimitToReviewProducts: Int64 = 30
let maxlimitToMyProductOrders: Int64 = 50
let maxlimitToNotificatioListItems: Int64 = 30
let maxlimitToHomeLanding: Int64 = 5
let maxlimitToTestimonials: Int64 = 0
let maxlimitToReviewOnServiceDetails: Int64 = 3
let maxlimitToServiceCategoryProducts: Int64 = 15

let forceUpdateNotNowDuration = 15

let country = "IN"

let salonDefaultNumer = "1800 266 5300"
let salonDefaultWhatsAppNumber = "9339777777"
let salonCustomerCareEmail = "customercare@enrichsalon.com"

let hideModifyFlow = false
var showSOS = false

enum ModifyAppointmentCatagories {
    static let changeServiceTimeslot = "change_service_timeslot"
    static let changeAppointmentTimeslot = "change_appointment_timeslot"
    static let replaceService = "replace_service"
    static let addService = "add_service"
}

enum ImageNames: String {
    case enabledRed = "enabledButton.png"
    case disabledGray = "disabledButton.png"
    case enabledLogo = "iconImgOtpSelected"
    case disabledLogo = "iconImgOtpNonSelected"
}

class ConstantsStrings: NSObject {

}

enum TableViewNoData {
    static let tableViewNoDataAvailable = "No data available"
    static let tableViewNoSalonAvailable = "No salons available"
    static let tableViewNoServiceAvailable = "No services available"
    static let tableViewNoAddOnsAvailable = "No add-ons available"
    static let tableViewNoReviewsAvailable = "No reviews available"
    static let tableViewNoAddressAvailable = "No addresses available"
    static let tableViewNoGiftSentAvailable = "No gifts sent data available"
    static let tableViewNoGiftReceivedAvailable = "No gifts received data available"
    static let tableViewNoPastBookingsAvailable = "No bookings available"
    static let tableViewNoValuePackagesAvailable = "No value package data available"
    static let tableViewNoServicePackagesAvailable = "No service package data available"
    static let tableViewNoReferalPointsAvailable = "No referral points available"
    static let tableViewNoOrdersAvailable = "No orders available"
    static let tableViewNoNotificationsAvailable = "No notifications available"
    static let tableViewNoSearchResults = "No search results found."

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

enum ValuePackageTypes {
    static let valuePackage = 1
    static let servicePackage = 2
}

enum SalonServiceTypes {
    static let simple = "simple"
    static let configurable = "configurable"
    static let bundle = "bundle"
    static let virtual = "virtual" // This is when we add/buy Membership in cart
     static let category = "Category"  // Local Set To Distinguish Service Or Category Not Getting From Server
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
enum ProductConfigurableDetailType {
    static let quantity = "container_qty"
    static let color = "color"
}

enum AlertMessagesSuccess {
    static let removedService = "Service Removed Successfully."
    static let userCancelPayTmTransaction = "User cancelled transaction."
    static let orderPlacedSuccessfully = "Order Placed Successfully."
    static let logoutSuccessfully = "Logout successfully."
    static let eventSuccess = "Event added successfully"
    static let offerCodeCopied = "Offer code copied"

    static let newAppVersion = "New version available. Update now & get new features."
    static let feedbackSuccess = "feedback submitted successfully"
    static let paymentAlreadyCatured = "Payment has been already taken and Invoice is generated"
    static let savedCustomerSignature = "Signature saved successfully"
}
enum AlertMessagesToAsk {

    static let removeService = "Are you sure you want to remove this service?"
    static let askToLogout = "Are you sure you want to logout?"
    static let askToDeleteAddress = "Are you sure you want to delete address?"
    static let defaultAddress = "Dafault address cannot be removed."
    static let askToSelectColor = "Please select color."
    static let askToSelectQuantity = "Please select quantity."
    static let askToSelectColorQuantityBoth = "Please select color and quantity."
    static let outOfStockMessage = "Sorry this product is not available."
    static let enterYourAllergiesType = "Please enter allergies type in view details"
    static let askToDeleteAddOnMember = "Are you sure you want to delete Add-On member?"
    static let CouponAppliedFail = "Error while applying coupon code"
    static let CouponAppliedAsk =  "Do you want to apply code or open detail page?"
    static let giftAmountRange =  "Gift amount should be in range of"
    static let pleaseSelect = "Please select"
    static let askForSalonORHome = "Where do you want to get service?"
    static let enterGiftCardCode = "Please enter giftcard code"
    static let enterValidMobileNumber = "Valid 10 digits contact number is required"
    static let enterValidEmailAddress  = "Please enter valid email address"
    static let allFieldsAreMandatory  = "Please fill all the mandatory fields data."
    static let enterValidPinCode = "Valid 6 digits pincode is required"

    static let genderMaleNotAllowed = "Only female members can able to get home appointments. Do you want to continue with selected salon address?"
    static let askForChangeTechnicians = "If you change the date previous selected data will get change."
    static let askForChangeDataToApply = "Do you want to confirm this changes?"
    static let stopUserToChangeSalonHome = "Cart update is required to change the service type (home/salon). Please remove the existing services from cart to proceed."
    static let stopUserToChangeGender = "Cart update is required to change the gender type. Please remove the existing services from cart to proceed."

    static let stopUserToChangeLocation = "Cart update is required in case of change of salon. Please remove the existing services from cart to proceed."
    static let serviceIsNotAvailableForSelectedSalon = "This service is currently not available at selected salon. Please select different salon to avail the service and check again."
    static let selectBundleAddOns = "Please select required add-on options"
    static let selectSalonBeforeAddingSeviceToCart = "Please select salon before adding any service to cart."

    static let offerApplicable = "This offer is applicable to all salons."
    static let packageApplicableForSelected = "This package is valid at selected stores only."
    static let packageApplicable = "This package is applicable to all salons."
    static let installWhatsApp = "To refer using Whatsapp, Please install Whatsapp."
    static let selectSalonFirst = "Please select salon to get your preferred stylist"
    static let deletePreferredStylist = "Do you want to remove your preferred stylist?"
    static let deleteYourPreferredSalon = "Do you want to remove this preferred salon?"
    static let checkOutYourCart = "Do you want to check your cart?"
    static let orderIdContains = "This order is having"
    static let reorderMembership = "Membership cant be re-order."
    static let reorderGiftCard = "Giftcard cant be re-order."
    static let reorderWallet = "Wallet cant be re-order."
    static let reOrderForRestItems = "Re-order can be possible only for remaining items against this order."

    static let askToPunchIn = "Are you sure you want to punch in?"
    static let askToPunchOut = "Are you sure you want to punch out?"
    static let addNewNote = "Please add note"
    static let termsAdnConditions = "Please accept terms and conditions"
    static let invoiceNotGenerated = "The appointment is still in progress, Invoice generation will take place once all services are completed."
    static let paymentSuccess = "Payment details are saved succesfully"

    static let enterCouponCode = "Please enter coupon code"
    static let enterReedemPoints = "Please enter redeem points in min and maximum range."
    static let enterWalletEnrichCashLimit = "Please enter minimum amount of"
    static let enterCash = "Please enter cash amount"
    static let enterCardDetails = "Please enter amount and transaction details"

    static let askToUseEnrichCash = "Do you want to use your Enrich Cash for current purchase?"
    static let askToRemoveEnrichCash = "Do you want to remove your Enrich Cash for current purchase?"
    static let askToRemovePackage = "Do you want to remove your Applied Package for current purchase?"

    static let selectCustomer = "Please select customer"
    static let servicesUnavailable = "Services of current technician are either cancelled or time elapsed"
    static let offerApplicableForSelected = "This offer is valid at selected stores only."
    static let takeCustomerSignature = "Please take customer signature"
    static let saveCustomerSignature = "Please save customer signature"
    static let formValidation = "Please fill all required fields"
    static let submitSpecificConsultationForm = "Please submit service specific consultation form"
    static let submitGenericConsultationForm = "Please submit generic consultation form"

    // Home customer selection validations
    static let maleCustomerSelectionValidation = "You can book an appointment for male customers only"
    static let femaleCustomerSelectionValidation = "You can book an appointment for female customers only"
    static let otherCustomerSelectionValidation = "You can book an appointment for other gender customers only"
    
    static let otherMaleCustomerSelectionValidation = "You can book an appointment for Other inclined towards male customers only"
    static let otherFemaleCustomerSelectionValidation = "You can book an appointment for Other inclined towards female customers only"
    
    static let inclined_gender_missing = "Inclined towards gender of customer is missing"


    // Modify Appointment
    static let cancelAppointment = "Are you sure you want to cancel this appointment?"
    static let deleteService = "Are you sure you want to delete this service?"

    // Device Authentication
    static let deviceAuthentication = "Device is not authorised. Do you want to authenticate this device?"

    // Add new petty cash
    static let selectAction = "Please select action"
    static let enterAmount = "Please enter amount"
    static let enterPurpose = "Please enter purpose"
    static let selectAttachment = "Please select attachment"

    // BOM validation
    static let requiredBOMQuantity = "Please enter quantity for required products"
    static let removeDependant = "Are you sure you want to remove this dependent?"
    
    // Apply change to wallet
    static let applyChangeToWallet = "Do you want to add change to wallet?"
    static let removeChangeToWallet = "Do you want to return balance change in cash?"

}
enum AlertButtonTitle {
    static let yes = "Yes"
    static let no = "No"
    static let ok = "Ok"
    static let home = "Home"
    static let salon = "Salon"
    static let cancel = "Cancel"
    static let gotToCart = "Go To Cart"
    static let proceed = "Proceed"
    static let callUs = "Call"
    static let emailUs = "Email"
    static let alertTitle = "Alert!"
    static let done = "Done"
    static let select = "Select"
    static let addToCart = "ADD TO CART"
    static let needHelp = "Need Help?"
    static let error = "Error"
    static let save = "Save"
    static let continuebtn = "Continue"
    static let apply = "Apply"
    static let update = "Update"
    static let updateNotNow = "Not Now"
}
enum AlertToWarn {
    static let selectedSalonNotInRange = "We are sorry!\nAt the moment our Home Services are not available in your selected location. \n You can try some other location\nor\nAvail our Salon Services."
    static let eventError = "Event not added."
    static let rateTheCustomer = "Please rate the customer"
}

enum GiftCardCategoryId {
    static let dev = "163"
    static let stage = "163"
    static let production = "163"

}
enum ProductCategoryId {
    static let dev = "3"
    static let stage = "3"
    static let production = "3"

}
enum ProductAttributeSetId {
    static let dev = "9"
    static let stage = "9"
    static let production = "9"

}
enum ServiceAttributeSetId {
    static let dev = "4"
    static let stage = "4"
    static let production = "4"

}
enum MembershipAttributeSetId {
    static let dev = "10"
    static let stage = "10"
    static let production = "10"

}

enum ServiceSalonStaticID {
    static let salonIdDev = "165"
    static let salonIdStage = "165"
    static let salonIdProduction = "165"
}
enum ServiceHomeStaticID {
    static let homeIdDev = "166"
    static let homeIdStage = "166"
    static let homeIdProduction = "166"
}

enum OrderStatus {
    static let InProgress = "Processing"
    static let Completed = "Complete"
    static let Cancelled = "Cancelled"
    static let pending_payment = "Pending Payment"
    static let pending = "Pending"

}
enum Order_Item_Status {
    static let ordered = "Ordered"
    static let invoiced = "Invoiced"

}
enum Order_ItemLabels {
    static let membership = "Membership"
    static let wallet = "Wallet"
    static let giftcard = "Giftcard"

}

enum  NotificationModuleListingKeys {
    static let appointment = "appointment"
    static let order = "order"
    static let campaign = "campaign"
    static let membership = "membership"
}
enum  NotificationModuleListingCategoryKeys {
    static let reminder = "reminder"
    static let alert = "alert"
    static let notice = "notice"
    static let information = "information"
}

enum FCMTopicKeys {
    static let employee = "EMPLOYEE_"
    static let employeeAll = "EMPLOYEE"
    static let technician = "TECHNICIAN"
}

enum TotalSegmentsCode {
    static let spendMinPoints = "rewards-spend-min-points"
    static let spendMaxPoints = "rewards-spend-max-points"
    static let youEarnPoints = "rewards-total"
    static let youSpendPoints = "rewards-spend"
    static let rewardsCalculations = "rewards_calculations"
    static let grandtotal = "grand_total"
    static let subtotal = "subtotal"
    static let shipping = "shipping"
    static let discount = "discount"
    static let rewardsSpendAmount = "rewards-spend-amount"
    static let taxNote = "tax-note"
    static let remainingAmount = "Remaining Amount"
    static let rewardsSpend = "rewards-spend"
}
enum CTCDetailsCode{
    static let fixedPay = "Fixed Pay" 
    static let totalCTC = "Total CTC"
    static let deductions = "Deductions"
    static let takeHome = "Take Home"
    static let otherBenefits = "Other Benefits"
    static let total = "Total"
    
    static let basic = "Basic Allowance"
    static let SpecialAllowance = "Special Allowance"
    static let HRA = "Home Rent Allowance"
    static let StatutoryBonus = "Statutory Bonus Adv."
    static let DearnessAllowance = "Dearness Allowance"
    static let WashingAllowance = "Washing Allowance"
    static let FoodAllowance = "Food Allowance"
    static let ConveyanceAllowance = "Conveyance Allowance"
    static let EducationAllowance = "Education Allowance"
    static let MedicalAllowance = "Medical Allowance"
    static let OtherAllowance = "Other Allowance"
    static let AdditionalSpecialAllowance = "Additional Special Allowance"
    static let AdditionalPayOut = "Additional Payout"
    static let AssuredPayout = "Assured Payout"
    static let BooksPeriodicals = "Books and Periodiscs Allowance"
    static let CarMaintenance = "Car Maintenance"
    static let DriverSalary = "Driver Salary"
    static let DriverAllowance = "Driver Allowance"
    static let ExGratia = "Ex Gratia"
    static let SkillBonus = "Skill Bonus"
    static let TeaAllowance = "Tea Allowance"
    static let TravelAllowance = "Travel Allowance"
    static let TrainingAllowance = "Training Allowance"
    static let CommunicationAllowance = "Communication Allowance"
    static let FUELALLOWANCECARABOVE1600CC = "Fuel Allowance (Care above 1600CC)"
    static let FUELALLOWANCECARBELOW1600CC = "Fuel Allowance (Care below 1600CC)"
    static let FUELALLOWANCETWOWHEELER = "Fuel Allowance (Two Wheeler)"
    static let UHSAllow = "UHS Allowance"
    
    static let CompContPF = "Company Contribution - PF"
    static let ADPF = "Admin Charges - PF"
    static let CompanyContributiontoESIC = "Company Contribution - ESIC"
    static let EmployerContribution = "Employer's Contribution"
    
    static let EmployeeContribution = "Employee's Contribution"
    static let PF_ded = "Employee PF"
    static let ESIC_ded = "Employee ESIC"
    static let PT_ded = "Professional Tax"
    static let MEDICLAIM_DEDUCTION = "Mediclaim"
    
    
    static let TelephoneAllowance = "Telephone Allowance"
    
    static let GroomingPoints = "Grooming Points"
    static let MediclaimCoverage = "Mediclaim Coverage"
    static let LifeInsuranceCoverage = "Life Insurance Coverage"
}
