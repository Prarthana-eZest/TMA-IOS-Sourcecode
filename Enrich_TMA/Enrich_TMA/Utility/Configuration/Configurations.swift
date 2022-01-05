//
//  Configurations.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 01/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

enum SectionIdentifier: String {

    // ParentViewController Of AnyViewController
    case parentVC = "ParentVC"

    // Product Landing Screen
    case advetisement = "Advetisement"
    case category = "Product categories"
    case irresistible = "Our irresistible offers!"
    case trending = "Our trending products"
    case new_arrivals = "New arrivals"
    case popular = "Popular brands"
    case recently_viewed = "Recently viewed products"
    case get_insightful = "Get insightful"
    case shop_by_hairtype = "Shop by hairtype"
    case serviceCell = "ServiceCell"

    // Product Details Screen
    case productDetails = "Product Details"
    case cashbackOffer = "Cashback Offer"
    case quntity = "Quantity"
    case specifications = "Specifications"
    case frequently_bought = "Frequently bought together"
    case cart_calculation = "Cart Calculation"
    case customer_rating_review = "Customers Ratings & Review"
    case feedbackDetails = "Feedback"
    case customers_also_bought = "Customers also bought"

    // Service Details Screen
    case serviceDetails = "Service Details"
    case additionalDetails = "Additional Details"
    case frequently_booked_together = "Frequently booked together"
    case recommended_products = "Recommended products"
    case frequently_availed_services = "Frequently availed services"

    //Booking Details screen
    case bookingSummary = "Booking Summary"
    case bookedServiceDetails = "Booked Service Details"
    case bookedServiceDetailsWithoutStylist = "Booked Service Details Without Stylist"
    case applyGiftCard = "Redeem Gift Card"

    case applied = " Applied"
    case appliedGiftCard = " Gift Card Applied"

    case membershipPlan = "Membership Plan"

    //Order Booking
    case address = "Shipping Address"
    case orderDetailsAddress = "Order Details Address"

    case billing_Info_Checkbox = "Checkobox"
    case cart_Product = "Cart Product"
    case cart_Service = "Cart Service"
    case cart_MemberShip = "Cart Membership"

    case cart_Product_Confirmation = "Cart Product Confirmation"
    case delivery_PinCode = "Delivery"

    case orderCourier = "Courier Details"
    // Home
    case homeHeader = "Home"
    case first_Time_Client = "Offer"
    case our_Products = "Product"
    case our_Services = "Service"
    case our_Packages = "Package"
    case always_At_Your_Service = "Always at your service!"
    case why_Enrich = "Why Enrich"
    case wedding_Season = "Service combo"
    case customer_Feedback = "What our customers say"
    case refer_And_Earn = "Refer And Earn"
    case membership = "Membership Info"
    case valuePackages  = "Packages"

    // Stylist
    case stylistDetails = "Stylist Details"
    case stylist_Not_Available = "Not Available"
    case check_Available_TimeSlot = "Check available time slots"
    case viewAll_TimeSlots = "View All"

    // Blog
    case featured_Videos = "Featured videos"
    case blog_Topics = "Blog Topics"
    case blog_List = "Blog List"
    case myPreferred_Blog_Topics = "MyPreferred Topics"
    case myPreferred_Blog_List = "MyPreferred Blog List"
    case blog_Details = "Blog Details"

    // My Bookings
    case upcoming_Appointment = "Upcoming Appointment"
    case past_Appointment = "Past Appointment"

    // Gift Card
    case giftCard_Topics = "GiftCard Topics"
    case giftCard_List = "GiftCard List"

    // Payment Mode
    case savedCard = "Saved Cards"
    case paymentOptions = "Payment Options"
    case termsAndConditions = "Terms & Conditions"

    // Preferred Stylist
    case myPreferredStylists = "My Preferred Stylists"
    case otherStylists = "Other Stylists"

    // Membership
    case membershipHeader = "Membership Header"
    case fringeBenefits = "Your fringe Benefits"
    case howItWorks = "How it works"
    case beClubMember = "Be A Club Member"
    case frequentlyAskedQuestions = "Frequently asked questions"
    case chatWithUs = "Chat With Us"
    case membershipJourney = "Membership Journey"
    case premierMembership = "premier Membership"

    // Salon Locations
    case popularCities = "Popular cities"
    case otherCities = "Other cities"

    // Past Appointment
    case appointmentDetailsHeader = "Appointment"
    case selectedServices = "Selected Services"
    case selectedServicesCount = "Selected Services Count"
    case additionalOff = "Additional Off"

    //Booking Details screen
    case applyCoupon = "Apply Coupon"

    //Order Booking
    //case address = "Shipping Address"

    // Apply Coupon
    case enterCouponCode = "Enter Coupon Code"
    case availableCoupons = "Available Coupons"

    // Dashboard
    case dashboardProfile = "Dashboard Profile"
    case appointmentHeader = "Appointment Header"
    case appointmentCollection = "Appointment Collection"
    
    // Incentive Dashboard
    case technicianDashboard = "Dashboard"
    case incentiveEarnings = "Earnings"
    case revenueTrend = "Revenue Trend"
    case productivity = "Productivity"
    case customerServed = "Customer Served"
    case myDetails = "My Details"
    case ctcDetails = "CTC Details"
    case attendanceDetails = "Attendance Details"
    case achievement = "Achievement"
    

    // Client Information
    case generalClientInfo = "General"
    case consulationInfo = "Consultation"
    case memebershipInfo = "Membership"
    case historyInfo = "History"

    // Invoice
    case invoiceHeader = "Invoice"
    case serviceInvoice = "Availed Service"
    case productInvoice = "Availed Products"
    //case valuePackages = "Availed Packages"

    // pricingDetails

    case pricingDetails = "Pricing Details"
    case cashPaymentMode = "Cash Payment"
    case cardPaymentMode = "Card Payment"
    case otherPaymentMode = "Other Payment"
    case couponCodeMode = "Coupon Code Mode"
    case giftCardMode = "GiftCard Mode"
    case bestPossibleDiscount = "Best Possible Discount"
    case walletAndRewardMode = "Wallet Reward Mode"

    case fixedPay = "Fixed Pay"
    case totalCTC = "Total CTC"
    case deductions = "Deductions"
    case takeHome = "Take Home"
    case otherBenefits = "Other Benefits"
}

enum CellIdentifier {

    static let productsCollectionCell = "ProductsCollectionCell"

    //Services

    static let homeHeaderCell = "HomeHeaderCell"

    static let getInsightfulCell = "GetInsightfulCell"
    static let irresistibleOffersCell = "IrresistibleOffersCell"
    static let popularBrandsCell = "PopularBrandsCell"
    static let productCell = "ProductCell"
    static let pointsTitleCell = "PointsTitleCell"
    static let trendingServicesCell = "TrendingServicesCell"
    static let hairServicesCell = "HairServicesCell"
    static let serviceCell = "ServiceCell"
    static let hairstylesCollectionViewCell = "HairstylesCollectionViewCell"
    static let serviceDescriptionCell = "ServiceDescriptionCell"
    static let customerRatingAndReviewCell = "CustomerRatingAndReviewCell"
    static let serviceDetailsHairTreatmentCell = "ServiceDetailsHairTreatmentCell"
    static let addServiceInYourCartCell = "AddServiceInYourCartCell"
    static let hairTreatmentCell = "HairTreatmentCell"
    static let combosCell = "CombosCell"
    static let recommendedForCell = "RecommendedForCell"
    static let myEnrichValuePackagesCell = "MyEnrichValuePackagesCell"
    static let myEnrichServicePackagesCell = "MyEnrichServicePackagesCell"
    static let serviceCategoryTableViewCell = "ServiceCategoryTableViewCell"

    // Products
    static let cartProductCollectionCell = "CartProductCollectionCell"
    static let cartProductConfirmationCollectionCell = "CartProductConfirmationCollectionCell"
    static let addressCollectionCell = "AddressCollectionCell"

    static let firstTimeClientCell = "FirstTimeClientCell"
    static let ourProductsCell = "OurProductsCell"
    static let alwaysAtYourServiceCell = "AlwaysAtYourServiceCell"
    static let horizontalListingCollectionViewCell = "HorizontalListingCollectionViewCell"
    static let customerReviewCell = "CustomerReviewCell"
    static let weddingSeasonCell = "WeddingSeasonCell"
    static let valuePackagesCell = "ValuePackagesCell"
    static let serviceCollectionCell = "ServiceCollectionCell"
    static let selectedServicesCell = "SelectedServicesCell"
    static let personalDetailsFilledCell = "PersonalDetailsFilledCell"
    static let additionalOffCell = "AdditionalOffCell"
    static let reviewThumpsUpDownCell = "ReviewThumpsUpDownCell"
    static let productDetailsCell = "ProductDetailsCell"
    static let cashbackOfferCell = "CashbackOfferCell"
    static let productQuantityCell = "ProductQuantityCell"
    static let productFullCell = "ProductFullCell"
    static let productSpcificationCell = "ProductSpcificationCell"
    static let productCategoryBackImageCell = "ProductCategoryBackImageCell"
    static let productCategoryFrontImageCell = "ProductCategoryFrontImageCell"
    static let imageViewCollectionCell = "ImageViewCollectionCell"
    static let colorCell = "ColorCell" //
    static let styleCell = "StyleCell"
    static let amountCell = "AmountCell"
    static let upcomingBookingCell = "UpcomingBookingCell"
    static let serviceRemindersCell = "ServiceRemindersCell"
    static let confirmedAppointmentCell = "ConfirmedAppointmentCell"
    static let completedAppointmentCell = "CompletedAppointmentCell"
    static let cancelledAppointmentCell = "CancelledAppointmentCell"
    static let productCatalogHeaderCell = "ProductCatalogHeaderCell"
    static let orderStatusCell = "OrderStatusCell"

    // Header Cells
    static let headerViewWithTitleCell = "HeaderViewWithTitleCell"
    static let headerViewWithSubTitleCell = "HeaderViewWithSubTitleCell"
    static let headerViewWithAdCell = "HeaderViewWithAdCell"

    static let appointmentDetailsHeaderCell = "AppointmentDetailsHeaderCell"

    // Appointment Details
    static let personalAddressCell = "PersonalAddressCell"
    static let personalDetailsCell = "PersonalDetailsCell"
    static let addressTypeCell = "AddressTypeCell"
    static let memberAddOnHeaderCell = "MemberAddOnHeaderCell"
    static let addOnMemberCell = "AddOnMemberCell"
    static let addOnButtonCell = "AddOnButtonCell"
    static let addressDetailsCell = "AddressDetailsCell"
    static let billingInfoCheckboxCell = "BillingInfoCheckboxCell"
    static let cartProductConfirmationCell = "CartProductConfirmationCell"
    static let viewAllRecommendedSlotsCell = "ViewAllRecommendedSlotsCell"
    static let bookingDetailSummaryCell = "BookingDetailSummaryCell"
    static let bookingDetailMembershipPlanCell = "BookingDetailMembershipPlanCell"
    static let deliveryPinCodeCell = "DeliveryPinCodeCell"
    static let bookingDetailsAddOnsCell = "BookingDetailsAddOnsCell"
    static let monthCollectionViewCell = "MonthCollectionViewCell"
    static let RecommendedStylistCollectionViewCell = "RecommendedStylistCollectionViewCell"
    static let timeSlotsTableViewCell = "TimeSlotsTableViewCell"
    static let filtersLeftTableViewCell = "FiltersLeftTableViewCell"
    static let filterRightTableViewCell = "FilterRightTableViewCell"
    static let serviceAddOnsMultiSelectionCell = "ServiceAddOnsMultiSelectionCell"
    static let serviceAddOnsRadioSelectionCell = "ServiceAddOnsRadioSelectionCell"
    static let serviceAddOnsMultiSelectionHeaderCell = "ServiceAddOnsMultiSelectionHeaderCell"
    static let recommendedMoriningAfterEvenNightCollectionViewCell = "RecommendedMoriningAfterEvenNightCollectionViewCell"
    static let horizontalListingCollectionViewCell1 = "HorizontalListingCollectionViewCell1"
    static let horizontalListingCollectionViewCell2 = "HorizontalListingCollectionViewCell2"
    static let upcomingBookingsHeader = "UpcomingBookingsHeader"
    static let serviceReminderHeader = "ServiceReminderHeader"
    static let confirmStylistCollectionCell = "ConfirmStylistCollectionCell"
    static let stylistNameCell = "StylistNameCell"

    static let subCategoryCell = "SubCategoryCell"

    // Blog
    static let blogCell = "BlogCell"
    static let blogDetailsCell = "BlogDetailsCell"

    // Stylist
    static let serviceWithoutStylistCell = "ServiceWithoutStylistCell"
    static let preferredStylistCollectionCell = "PreferredStylistCollectionCell"
    static let stylistDetailsCell = "StylistDetailsCell"

    // More Tab
    static let timeSlotCell = "TimeSlotCell"
    static let featuredVideosCell = "FeaturedVideosCell"
    static let myPreferredTopicCell = "MyPreferredTopicCell"

    // Gift Card
    static let giftCardCell = "GiftCardCell"
    static let giftCardHeaderCell = "GiftCardHeaderCell"
    static let selectGiftCardStyleCell = "SelectGiftCardStyleCell"
    static let valueCardCell = "ValueCardCell"
    static let personalizedMessageCell = "PersonalizedMessageCell"
    static let giftCardQuoteCell = "GiftCardQuoteCell"
    static let giftCardValidDateCell = "GiftCardValidDateCell"
    static let giftCardRecepientCell = "GiftCardRecepientCell"
    static let giftCardHeaderTitle = "GiftCardHeaderTitle"
    static let enterCouponCodeCell = "EnterCouponCodeCell"
    static let autoApplyDiscountCell = "AutoApplyDiscountCell"

    // Dashboard
    static let incentiveDashboardCell = "IncentiveDashboardCell"
    static let dashboardProfileCell = "DashboardProfileCell"
    static let yourTargetRevenueCell = "YourTargetRevenueCell"
    static let revenueCell = "RevenueCell"
    static let monthCollectionCell = "MonthCollectionCell"

    // Appointment Status
    static let todaysAppointmentHeaderCell = "TodaysAppointmentHeaderCell"
    static let appointmentStatusCell = "AppointmentStatusCell"
    static let checkBoxCell = "CheckBoxCell"
    static let appoinmentCollectionCell = "AppointmentCollectionCell"

    // Appointment Details
    static let appointmentDetailsCell = "AppointmentDetailsCell"
    static let appointmentTimelineCell = "AppointmentTimelineCell"
    static let appointmentTimelineHeader = "AppointmentTimelineHeader"

    // Modify Appointment
    static let modifyAppointmentHeaderCell = "ModifyAppointmentHeaderCell"
    static let modifyServiceCell = "ModifyServiceCell"
    static let serviceRadioSelectionCell = "ServiceRadioSelectionCell"

    // Client Information
    static let topicCell = "TopicCell"
    static let membershipStatusCell = "MembershipStatusCell"
    static let selectGenderCell = "SelectGenderCell"
    static let tagViewCell = "TagViewCell"
    static let serviceHistoryCell = "ServiceHistoryCell"
    static let addNotesCell = "AddNotesCell"
    static let signatureCell = "SignatureCell"
    static let pointsCell = "PointsCell"

    // Job Card
    static let jabCardServiceHeaderCell = "JabCardServiceHeaderCell"
    static let jobCardSectionHeaderCell = "JobCardSectionHeaderCell"
    static let billOfMaterialCell = "BillOfMaterialCell"
    static let recommendationsCell = "RecommendationsCell"
    static let trendingProductsCell = "TrendingProductsCell"
    static let pointsHeaderCell = "PointsHeaderCell"

    // BOM
    static let bomQuantityCell = "BOMQuantityCell"
    static let bomProductCell = "BOMProductCell"

    // Invoice
    static let invoiceHeaderCell = "InvoiceHeaderCell"
    static let invoiceCell = "InvoiceCell"
    static let cartAmountCell = "CartAmountCell"

    // Payment Details
    static let cashPaymentCell = "CashPaymentCell"
    static let onlinePaymentCell = "OnlinePaymentCell"
    static let transactionDetailsCell = "TransactionDetailsCell"
    static let walletAndRewardCell = "WalletAndRewardCell"
    static let applyGiftCardCell = "ApplyGiftCardCell"
    static let applyCouponCell = "ApplyCouponCell"
    static let myAvailableValuePackagesCell = "MyAvailableValuePackagesCell"
    static let myAvailableServicePackagesCell = "MyAvailableServicePackagesCell"
    static let bestPossibleDiscountCell = "BestPossibleDiscountCell"

    // Profile
    static let myProfileHeaderCell = "MyProfileHeaderCell"
    static let myProfileCell = "MyProfileCell"
    static let myProfileMultiOptionCell = "MyProfileMultiOptionCell"
    static let serviceListingCell = "ServiceListingCell"
    static let listingCell = "ListingCell"
    static let calenderEventDetailsCell = "CalenderEventDetailsCell"

    // My Customers
    static let myCustomersHeaderCell = "MyCustomersHeaderCell"
    static let myCustomerCell = "MyCustomerCell"
    static let searchCell = "SearchCell"

    // Petty Cash
    static let pettyCashCell = "PettyCashCell"
    static let pettyCashAttachementCell = "PettyCashAttachementCell"

    // Employees
    static let employeeCell = "EmployeeCell"

    // Notifications
    static let notificationDetailsCell = "NotificationDetailsCell"

    // Tele Marketing
    static let teleMarketingCell = "TeleMarketingCell"
    static let teleMarketingCompletedCell = "TeleMarketingCompletedCell"
    
    // Dependent Flow
    static let selectServiceDependentCell = "SelectServiceDependentCell"
    static let dependentListCell = "DependentListCell"
    
    // Incentive Dashboard
    static let earningHeaderCell = "EarningHeaderCell"
    static let earningGridViewCell = "EarningGridViewCell"
    static let earningListViewCell = "EarningListViewCell"
    static let incentiveCommonHeaderCell = "IncentiveCommonHeaderCell"
    static let revenueTrendListCell = "RevenueTrendListCell"
    static let revenueTrendGridCell = "RevenueTrendGridCell"
    static let productivityHeaderCell = "ProductivityHeaderCell"
    static let productivityListViewCell = "ProductivityListViewCell"
    static let productivityGridViewCell = "ProductivityGridViewCell"
    static let customerServedCell = "CustomerServedCell"
    static let incentiveMyDetailsCell = "IncentiveMyDetailsCell"
    static let achievementCell = "AchievementCell"
    static let ctcDetailsCell = "CTCDetailsCell"
    static let ctcBreakUpCell = "CTCBreakUpCell"
    static let incentiveDetailsHeaderCell = "IncentiveDetailsHeaderCell"
    static let attendanceDetailsCell = "AttendanceDetailsCell"
    
    // New Native Incentive Dashboard
    
    static let earningDetailsHeaderCell = "EarningDetailsHeaderCell"
    static let earningDetailsHeaderFilterCell = "EarningDetailsHeaderFilterCell"
    static let earningDetailsCell = "EarningDetailsCell"
    static let earningDetailsThreeValueCell = "EarningDetailsThreeValueCell"
    static let earningTotalHeaderCell = "EarningTotalHeaderCell"
    static let viewCTCCell = "ViewCTCCell"
    static let earningDetailsCellWithGraphs = "EarningDetailsCellWithGraphs"
    
    // Filter
    static let packageFilterCell = "PackageFilterCell"
    static let selectFilterDateRangeCell = "SelectFilterDateRangeCell"
    static let earningCategoryFilterCell = "EarningCategoryFilterCell"
    //Earnings cell
    static let earningsSelectFilterDateRangeCell = "EarningsSelectFilterDateRangeCell"
    static let earningDetailsTViewTrendHeaderCell = "EarningDetailsTViewTrendHeaderCell"
    static let earningDetailsViewTrendCellTableViewCell = "EarningDetailsViewTrendCellTableViewCell"
    static let ctcBreakUpTableViewCell = "CTCBreakUpTableViewCell"
    static let ctcBreakUpDetailsTableViewCell = "CTCBreakUpDetailsTableViewCell"
    
}

struct SectionConfiguration {

    let title: String
    let subTitle: String

    let cellHeight: CGFloat
    let cellWidth: CGFloat

    let showHeader: Bool
    let showFooter: Bool

    let headerHeight: CGFloat
    let footerHeight: CGFloat

    let leftMargin: CGFloat
    let rightMarging: CGFloat

    let isPagingEnabled: Bool

    let textFont: UIFont?
    let textColor: UIColor

    var items: Int

    let identifier: SectionIdentifier
    var data: Any

    var selectedIndex: Int
    
    init(title: String, subTitle: String, cellHeight: CGFloat, cellWidth: CGFloat, showHeader: Bool, showFooter: Bool, headerHeight: CGFloat, footerHeight: CGFloat, leftMargin: CGFloat, rightMarging: CGFloat, isPagingEnabled: Bool, textFont: UIFont?, textColor: UIColor, items: Int, identifier: SectionIdentifier, data: Any) {
        self.title = title
        self.subTitle = subTitle
        self.cellHeight = cellHeight
        self.cellWidth = cellWidth
        self.showHeader = showHeader
        self.showFooter = showFooter
        self.headerHeight = headerHeight
        self.footerHeight = footerHeight
        self.leftMargin = leftMargin
        self.rightMarging = rightMarging
        self.isPagingEnabled = isPagingEnabled
        self.textFont = textFont
        self.textColor = textColor
        self.items = items
        self.identifier = identifier
        self.data = data
        self.selectedIndex = 0
    }

    init(title: String, subTitle: String, cellHeight: CGFloat, cellWidth: CGFloat, showHeader: Bool, showFooter: Bool, headerHeight: CGFloat, footerHeight: CGFloat, leftMargin: CGFloat, rightMarging: CGFloat, isPagingEnabled: Bool, textFont: UIFont?, textColor: UIColor, items: Int, identifier: SectionIdentifier, data: Any, selectedIndex: Int) {
        self.title = title
        self.subTitle = subTitle
        self.cellHeight = cellHeight
        self.cellWidth = cellWidth
        self.showHeader = showHeader
        self.showFooter = showFooter
        self.headerHeight = headerHeight
        self.footerHeight = footerHeight
        self.leftMargin = leftMargin
        self.rightMarging = rightMarging
        self.isPagingEnabled = isPagingEnabled
        self.textFont = textFont
        self.textColor = textColor
        self.items = items
        self.identifier = identifier
        self.data = data
        self.selectedIndex = selectedIndex
    }
}



class Configurations {

}
