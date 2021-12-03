//
//  CacheKeys.swift
//  EnrichSalon
//
//  Created by Apple on 04/05/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation

public enum CacheFolderNameKeys: String {
    case k_folder_name_SalonLocations = "k_folder_name_SalonLocations"
    case k_folder_name_SalonService = "k_folder_name_SalonService"
    case k_folder_name_HomeService = "k_folder_name_HomeService"
    case k_folder_name_SalonHomeServiceSubCategory = "k_folder_name_SalonServiceSubCategory" // Top Menu
    case k_folder_name_ProductLandingData = "k_folder_name_ProductLandingData" // Top Menu
    case k_folder_name_ProductLandingCategories = "k_folder_name_ProductLandingCategories" // Top Menu
    case k_folder_name_SalonHomeServiceSubCategoryList = "k_folder_name_SalonHomeServiceSubCategoryList" // SubCategory List Items
    case k_folder_name_Testimonials = "k_folder_name_Testimonials"
}

public enum CacheFileNameKeys: String {
    case k_file_name_salonlocation = "k_file_name_salonlocation"
    case k_file_name_salonService = "k_file_name_salonService"
    case k_file_name_homeService = "k_file_name_homeService"
    case k_file_name_salonHomeServiceSubCategory = "k_file_name_salonHomeServiceSubCategory" // Top Menu
    case k_file_name_salonHomeServiceSubCategoryList = "k_file_name_salonHomeServiceSubCategoryList" // SubCategory List Items

    case k_file_name_productLandingData = "k_file_name_productLandingData"
    case k_file_name_productLandingCategories = "k_file_name_productLandingCategories"

    case k_file_name_testimonials = "k_file_name_testimonials"

}
