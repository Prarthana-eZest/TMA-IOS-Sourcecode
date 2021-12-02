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
    case category = "Product Categories"
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
    case applyCoupon = "Apply Coupon"
    case pricingDetails = "Pricing Details"
    case membershipPlan = "Membership Plan"

    //Order Booking
    case address = "Shipping Address"
    case billing_Info_Checkbox = "Checkobox"
    case cart_Product = "Cart Product"
    case cart_Product_Confirmation = "Cart Product Confirmation"
    case delivery_PinCode = "Delivery"

    // Home
    case homeHeader = "Home"
    case first_Time_Client = "Offer"
    case our_Products = "Products"
    case always_At_Your_Service = "Always at your service!"
    case why_Enrich = "Why Enrich"
    case wedding_Season = "Service combo"
    case customer_Feedback = "What our customers say"
    case refer_And_Earn = "Refer And Earn"
    case membership = "Membership"

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

    // Apply Coupon
    case enterCouponCode = "Enter Coupon Code"
    case availableCoupons = "Available Coupons"

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

    let items: Int

    let identifier: SectionIdentifier
    var data: Any

}

class Configurations {

}
