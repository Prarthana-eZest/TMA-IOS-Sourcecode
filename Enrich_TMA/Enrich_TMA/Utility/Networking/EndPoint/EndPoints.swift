//  Created by Aman Gupta on 07/09/2018.
//  Copyright © 2018 Aman Gupta. All rights reserved.

import Foundation

public enum ConstantAPINames: String {

    case getOnBoarding = "rest/V1/banner/onboarding/" // Custom API
    case postListOfSalons = "rest/V1/salonlocator/salon/list" // Custom API
    case createData = "rest/V1/customers"

    case refreshToken =  "rest/V1/auth/token/refresh"

    // Home Landing API
    case home = "rest/V1/home"
    case guestPushNotificationToken = "rest/V1/guest-device-token"

    // Salon service And Details api
    case salonServiceCategory = "rest/V1/categories/children"// Custom API

    // New Service category API
    case newServiceCategoryAPI = "rest/V1/getServicesAndCategory"

    case salonTestimonials = "rest/V1/testimonials/"// Custom API
    case productCategory  = "rest/V1/products/?searchCriteria" //Product Category
    case addWishList = "rest/V1/wishlist/add"
    case removeFromWishList = "rest/V1/wishlist/delete"
    //case productDetails = "rest/V1/products/" /// Service Details
    case bestsellerproducts = "rest/V1/bestsellerproducts/" /// Service Details

    case productReview = "rest/V1/product/reviews" /// Product Review
    case frquentlyAvailedProduct = "rest/V1/customer/frequentlyavailedservices" // Frequently Availed Service
    case rateAService =  "rest/V1/review/save" // Rate a Service

    // Product Module APIS
    case categorydetails = "rest/V1/category/details" // Products Landing Screen
    case blogDetails = "rest/V1/blog/details" // GetInsightfull section
    case productsShopby = "rest/V1/products/shop-by" // GetInsightfull section
    case recentlyviewedproducts = "rest/V1/recentlyviewedproducts"
    case filtersAPI = "rest/V1/categories/filter"

    // Product Cart APIS
    case getQuoteIdMine = "rest/V1/carts/$$$"  // Append Mine // Same for Delete Product from cart
    case addToCartGuest = "rest/V1/guest-carts" // Add To cart For Guest // Same API to Get all Cart Items from cart in case for Guest// DeleteFroCart API also Same
    case getAllCartItemsCustomer = "rest/V1/carts/mine/items"  // Get All Customer Cart Items
    case getCustomerAddressDetails = "rest/V1/customer/details/"//"rest/V1/customers/me"
    case moveToWishListFromCart = "rest/V1/wishlist/move"
    case moveToCartFromWishlist  = "rest/V1/wishlist/move/tocart"
    case addUpdateAddress = "rest/V1/customer/address/"//"rest/V1/customers/mine/address"
    case getStates = "rest/V1/directory/countries"

    // BLOGS
    case blogListingCategories = "blog/categories"
    case blogList = "rest/V1/blog/lists" // GetInsightfull section

    // PayTM Integration
    case checkSumURL = "rest/V1/paytm/getchecksumhash/"
    case paytmpayonline = "rest/V1/paytm/payonline"

    // More Tab
    case wishlist = "rest/V1/wishlist/listing"

    // Coupons spi
  //  case rewardAPI = "rest/V1/rewards/mine/transactions?is_custom=true"
    case customerWalletCashHistory = "rest/V1/wallet-amount?is_custom=true"

    // Coupons spi
    case couponsAPI = "rest/V1/salesRules/coupon-offers"
    case offersValuePackages = "rest/V1/package-list?is_custom=1"
   // case getCouponsAPI = "rest/V1/carts/mine/coupons?is_custom=true"
   // case applyCouponAPI = "rest/V1/carts/mine/coupons/####?is_custom=true"
    // Profile API's
    case attributeMapping = "rest/V1/customerAttributes?is_custom=1"

    // Membership API's
   // case membershipDetails = "mine/membership?is_custom=true"
    case memberShipBenefits = "rest/V1/membership/benefits"
   // case addMemberAddOnAPI = "rest/V1/mine/membership/addon"
 //   case getOrDeleteMemberAddOnAPI = "rest/V1/mine/membership/addon?is_custom=true"
    case getGiftCardHistory = "rest/V1/giftcardDetails?is_custom=true"
    case sendGiftCard  = "rest/V1/addGiftcardProduct?is_custom=true"
    case getGiftCardPriceLimit = "rest/V1/giftcardPriceLimit?is_custom=true"
    case deleteGiftCard = "rest/V1/removeGiftcard?is_custom=true"
    case getGiftCardAppliedAlready = "rest/V1/getGiftcard?is_custom=true"
    //case applyGiftCard = "applyGiftcard?is_custom=true"
   // case myEnrichWallet = "rest/V1/rewards/mine/balance?is_custom=true"
    case addMoneyEnrichCash = "rest/V1/add-wallet-balance?is_custom=true"
    case getEnrichCashLimit = "rest/V1/wallet-limit?is_custom=true"

    // MARK: Add blank appointment
    case getTechnicians = "esa/technician/get-technicians"
    case getServiceListWithTimeslot = "esa/appointments/set-service-times"
    case confirmAppointment = "rest/V1/appointments/change-booking-status/###"
    case addressCheckAppointment = "rest/V1/get-distance"
    case sendAppointmentToMagento = "rest/V1/appointments/soft-booking?is_custom=true"
    case validAppointmentCheck = "rest/V1/appointments/check-valid-appointment/###"
    case getPastBookings = "rest/V1/appointments/past-appointments?is_custom=true"
    case getUpcomingBookings = "rest/V1/appointments/upcoming-appointments?is_custom=true"
    case cancelAppointment = "rest/V1/appointments/cancel-appointment?is_custom=true"
    case customerFeedbackAppointment = "rest/V1/customer/feedbackbyappointmentid"
    case customerAddFeedbackAppointment = "rest/V1/customer/addappointmentfeedback"
    case checkMagentoUser = "rest/V1/customer/create-customer-cma/"

    // Web View Pages Link
    case aboutUs = "rest/V1/about-us"
    case helpCenter = "rest/V1/help"
    case privacyPolicy = "rest/V1/privacy-policy"
    case termsAndConditions = "rest/V1/terms-conditions"
    // FAQ's links for membership
    case faqForClubMembership = "rest/V1/faq-for-club-membership"
    case faqForPremierMembership = "rest/V1/faq-for-premier-membership"
    case faqForEliteMembership = "rest/V1/faq-for-elite-membership"
    case faqForMyEnrichWallet = "rest/V1/faq-for-wallet-rewards"
    case faqForReferAndEarns = "rest/V1/faq-for-refer-and-earns"

    // Terms and Conditions links for membership
    case termsAndConditionsForClubMembership = "rest/V1/terms-conditions-club-membership"
    case termsAndConditionsForPremierMembership = "rest/V1/terms-conditions-premier-membership"
    case termsAndConditionsForEliteMembership = "rest/V1/terms-conditions-elite-membership"
    case termsAndConditionsForReferAndEarns = "rest/V1/terms-conditions-refer-earns"
    case termsAndConditionsForPayments = "rest/V1/payment-terms-and-conditions"

    // Notifications
    case updateNotificationPrefrences = "rest/V1/update-preference?is_custom=true"
    case getNotificationPrefrences = "rest/V1/preference?is_custom=true"

    // My orders
   // case getMyOrders = "rest/V1/customer/mine/ordered-products"

    // Packages
    case getMyPuchasePackages = "rest/V1/package-history?is_custom=true"

    // Payment Modes Screen Apis
    //case applyAndRemoveWallet = "select-wallet?is_custom=true"
    //case applyOrReedemPointsOnPaymentsScreen = "rewards/mine/apply"

    case applyPackages = "rest/V1/apply-package?is_custom=true"
    case removePackages = "rest/V1/remove-package?is_custom=true"

    // Refer And Earns Points Get
    //case getReferalPoints = "rest/V1/rewards/mine/referrals?is_custom=true"

    // Preferred Sylist
    case getPreferredStylist = "rest/V1/customer/preferred-stylist"
    case addPreferredStylist = "rest/V1/customer/add-preferred-stylist"
    case removePreferredStylist = "rest/V1/customer/remove-preferred-stylist"

    // Clear Cart
    case clearGuestCart = "rest/V1/appointments/clearGuestCart/?quote_id="
    //case clearMineCart = "rest/V1/appointments/mine/clearCart"
    case getCityList = "rest/V1/city-list" // Lumen API
    case getSalonOnCitySelect = "rest/V1/salonlocator/salon-search"

    //.............................TMA New API........................................

    // Login Module
    case userLogin = "rest/V1/integration/admin/token"
    case getTermsAndConditions = "rest/V1/cms/block"
    case authenticateDevice = "rest/V1/employee/device/authenticateRequest"

    //case sendOTPOnMobile = "digimiles/sms/sendotp"
    case sendOTPOnMobile = "rest/V1/employee/reset/password/generate/otp"

    case validateOTPOnLogin =  "rest/V1/digimiles/customer/login"

    case forgotPassword = "rest/V1/employee/reset/password"

    // My Profile

    case getUserProfile = "rest/V1/employee/profile?is_custom=true"
   // case getServiceList = "rest/V1/employee/services?is_custom=true"
    case getServiceList = "/rest/V1/employee/all-services"
    case getEmployeeList = "esa/roster" // L

    // Appoitments
    case getAppointments = "rest/V1/appointments/appointment-list?is_custom=true" // L

    // Client Information
    case membershipDetails = "rest/V1/membership?is_custom=true"
    case clientPreferences = "rest/V1/customer-preferences?is_custom=true"
    case clientNotes = "rest/V1/customer/ratingandnotes"
    case addClientNote = "rest/V1/customer/addnotes"

    // Job Card
    case getBOM = "rest/V1/service/bom"
    case updateBOM = "rest/V1/appointments/service-change-status"//"esa/services/service-bom-multiple"
    case changeServiceStatus = "rest/V1/appointments/appointments-service-change-status/"
    case changeAppointmentStatus = "rest/V1/appointments/change-status/"
    case getRelatedBOMProducts = "rest/V1/products/"
    case checkAppointmentStatus = "esa/appointments/check-appointment-status/"
    case getInvoiceDetails = "rest/V1/pos/new"
    case sendCustomerOTP = "rest/V1/appointments/resendBelitaOtp"
    case confirmCustomerOTP = "rest/V1/appointments/verifyBelitaOtp"

    // Payment Modes Screen API's
    case offlinePaymnet = "rest/V1/pos/capture-payment?is_custom=1&pos_request=1"
    case submitPaymentDetails = "rest/V1/pos/close?pos_request=1"
    case myPaymentScreenPOS = "rest/V1/pos/get-customer-balance-admin?is_custom=1&pos_request=1"
    case applyAndRemoveWallet = "rest/V1/pos/apply-wallet?is_custom=1&pos_request=1"
    case applyOrReedemPointsOnPaymentsScreen = "rest/V1/pos/apply-reward-points"

    case applyGiftCard = "rest/V1/pos/apply-giftcard?is_custom=1&pos_request=1"
    case applyCoupon = "rest/V1/pos/apply-coupon"

    case applyRemovePackages = "rest/V1/pos/apply-package?is_custom=1&pos_request=1"
    
    // Auto Apply Discount
    case getAutoApplyDiscountList = "rest/V1/pos/applied-cartrules?is_custom=true&pos_request=1"
    case applyRemoveDiscount = "rest/V1/pos/change-cartrules?is_custom=true&pos_request=1"


    // Notifications
    case getNotificationList = "rest/V1/notifications/get?is_custom=true"

    // Check In
    case getCheckInStatus = "rest/V1/biometric/employeeCheckinoutDetails"
    case markCheckInOut = "rest/V1/biometric/checkinoutMobile"
    case getCheckInOutDetails = "rest/V1/biometric/employeeCheckinoutDetailsMobile"

    // Petty Cash
    case getPettyCashHistory = "rest/V1/pettycash-history?is_custom=true"
    case addNewPettyCash = "rest/V1/pettycash-request"

    // My Customer
    case getMyCustomers = "rest/V1/customer/get-list?is_custom=true"

    // SOS
    case raiseSOS = "rest/V1/notifications/triggersos"

    // Dashboard
    case getDashboardData = "rest/V1/gettechniciandashboard"
    case getOneClickRevenueData = "rest/V1/gettmaoneclick"
    case getIncentiveDashboard = "rest/V1/get-incentive-dashboard?is_custom=1"
    case getRevenueDashboard = "rest/V1/get-revenue-dashboard?is_custom=1"
    case getEarningsDashboard = "rest/V1/get-earning-dashboard?is_custom=1"
    case getCTCDetails = "rest/V1/get-salary-details?is_custom=1"

    // Consultaion Form
    case getConsulationForm = "rest/V1/getform"
    case setConsulationForm = "rest/V1/setform"

    // Modify Flow
    case changeTimeslot = "rest/V1/appointments/changeTimeslot"
    case replaceService = "rest/V1/appointments/addApprovalRequest"
    case addSingleService = "rest/V1/appointments/addService"
    case deleteService = "rest/V1/appointments/deleteService/"
    case deleteAppointment = "rest/V1/appointments/"

    // Add New Appointment
    case checkValidAddress = "esa/get-distance"
    case addBlankAppointment = "rest/V1/appointments/addAppointment"
    case addMultipleServices = "rest/V1/appointments/addMultipleService"

    // Tele Marketing
    case telemarketingPending = "/rest/V1/telemarketing/pending"
    case telemarketingCompleted = "rest/V1/telemarketing/completed"
    case submitTeleFeedback = "rest/V1/telemarketing/feedback"
    case getTeleStatusList = "/rest/V1/telemarketing/status-list?is_custom=true"
    case outbondCalling = "/rest/V1/telemarketing/outboundcalling"

    // Upload Selfie
    case uploadSelfie = "esa/appointments/upload-selfie"

    case getForceUpdateInfo = "rest/V1/force-update-info?is_custom=true"

    case sendPaymentLink = "rest/V1/payment/sendLink"
    
    // dependant Flow
    
    case getDependantList = "rest/V1/customer-dependant/get"
    case addDependant = "rest/V1/customer-dependant/add"
    case deleteDependant = "rest/V1/customer-dependant/delete"
    
    case getReportDetails = "rest/V1/getembededurl?is_custom=true"

}
