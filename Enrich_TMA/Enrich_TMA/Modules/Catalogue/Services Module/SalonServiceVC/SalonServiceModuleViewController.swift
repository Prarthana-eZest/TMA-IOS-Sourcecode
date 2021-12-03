//
//  SalonServiceModuleViewController.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//

import UIKit
enum SalonServicesSections: Int {
    case titleImageSection = 0
    case categorySection
    case infoSection
    case testimonialsSection

    var heightOfCell: CGFloat {
        switch self {
        case .titleImageSection:
            return is_iPAD ? 400 : 250
        case .categorySection:
            return is_iPAD ? 120 : 80
        case .infoSection:
            return is_iPAD ? 500 : 400
        case .testimonialsSection:
            return is_iPAD ? 500 : 400
        }
    }
}

protocol SalonServiceModuleDisplayLogic: class {
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
}

class SalonServiceModuleViewController: UIViewController, SalonServiceModuleDisplayLogic {
    let marginForCategoryCell: CGFloat = is_iPAD ? 22.5 : 15
    let widthForCategoryCell: CGFloat = is_iPAD ? 30 : 20

    @IBOutlet weak private var SaloonServicesVC: UICollectionView!
    @IBOutlet weak private var reviewsCollectionView: UICollectionView!
    @IBOutlet weak private var servicesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var pageControl: UIPageControl!
    var objectWhyEnrich = SalonServiceModule.Something.WhyEnrichModel()
    var objectHeader = SalonServiceModule.Something.SalonCategoryModel()

    @IBOutlet weak private var collectionViewObj: UICollectionView!
    var arrCustomerReviews = [SalonServiceModule.Something.TestimonialModel]()
    var arrCategories  = [SalonServiceModule.Something.CategoryModel]()
    private let dispatchGroup = DispatchGroup()

    private var serverDataForAllCartItemsGuest: [ProductDetailsModule.GetAllCartsItemGuest.Response]?
    private var serverDataForAllCartItemsCustomer: [ProductDetailsModule.GetAllCartsItemCustomer.Response]?

    private var customerView = CustomerReviewView()
    private var whyEnrichView = WhyEnrich()
    private var headerView = HeaderViewCell()

    private var interactor: SalonServiceModuleBusinessLogic?

    var reposStoreSalonService: LocalJSONStore<SalonServiceModule.Something.Response> = LocalJSONStore(storageType: .cache)

    let reposStoreTestimonials: LocalJSONStore<SalonServiceModule.Something.TestimonialResponse> = LocalJSONStore(storageType: .cache, filename: CacheFileNameKeys.k_file_name_testimonials.rawValue, folderName: CacheFolderNameKeys.k_folder_name_Testimonials.rawValue)

    // MARK: - Object lifecycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        let viewController = self
        let interactor = SalonServiceModuleInteractor()
        let presenter = SalonServiceModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = CustomerReviewView(frame: CGRect.zero).loadNib() as? CustomerReviewView {
            customerView = view
        }
        if let view = WhyEnrich(frame: CGRect.zero).loadNib() as? WhyEnrich {
            whyEnrichView = view
        }
        if let view = HeaderViewCell(frame: CGRect.zero).loadNib() as? HeaderViewCell {
            headerView = view
        }

        objectWhyEnrich = SalonServiceModule.Something.WhyEnrichModel(holistic_services: "NA", certified_professional: "NA", latest_products: "NA")

        UISettings()

        categoryApiCall()
        testimonialsApiCall()

        collectionViewObj.dataSource = self
        collectionViewObj.delegate = self

        dispatchGroup.notify(queue: .main) {[unowned self] in
            EZLoadingActivity.hide(true, animated: false)
            self.collectionViewObj.reloadData()
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.setHidesBackButton(false, animated: false)
        self.navigationController?.addCustomBackButton(title: "")
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Clear Cache
        if self.navigationController?.viewControllers.index(of: self) == nil {
            StorageType.cache.clearStorageForSubfolder(subfolder: CacheFolderNameKeys.k_folder_name_SalonHomeServiceSubCategory.rawValue)
            StorageType.cache.clearStorageForSubfolder(subfolder: CacheFolderNameKeys.k_folder_name_SalonHomeServiceSubCategoryList.rawValue)
        }
        super.viewWillDisappear(animated)
    }

    func UISettings() {
        // Do any additional setup after loading the view.
        //HeaderViewCell
        collectionViewObj.register(UINib(nibName: CellIdentifier.horizontalListingCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.horizontalListingCollectionViewCell)
        collectionViewObj.register(UINib(nibName: CellIdentifier.serviceCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.serviceCell)
        collectionViewObj.register(UINib(nibName: CellIdentifier.horizontalListingCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.horizontalListingCollectionViewCell2)
        collectionViewObj.register(UINib(nibName: CellIdentifier.horizontalListingCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.horizontalListingCollectionViewCell1)
        showNavigationBarRigtButtons()
    }
    func setCartItems(serverDataForAllCartItemsGuest: [ProductDetailsModule.GetAllCartsItemGuest.Response], serverDataForAllCartItemsCustomer: [ProductDetailsModule.GetAllCartsItemCustomer.Response]) {
        self.serverDataForAllCartItemsGuest = serverDataForAllCartItemsGuest
        self.serverDataForAllCartItemsCustomer = serverDataForAllCartItemsCustomer

    }

    func showNavigationBarRigtButtons() {
        guard let callPhoneImg = UIImage(named: "callPhoneImg"),
            let filterSelected = UIImage(named: "filterSelected"),
            let searchImg = UIImage(named: "searchImg"),
            let sosImg = UIImage(named: "SOS")  else {
            return
        }

        let callButton = UIBarButtonItem(image: callPhoneImg, style: .plain, target: self, action: #selector(didTapCallButton))
        callButton.tintColor = UIColor.black

        let filterButton = UIBarButtonItem(image: filterSelected, style: .plain, target: self, action: #selector(didTapFilter))
        filterButton.tintColor = UIColor.black

        let searchButton = UIBarButtonItem(image: searchImg, style: .plain, target: self, action: #selector(didTapSearchButton))
        searchButton.tintColor = UIColor.black

        let sosButton = UIBarButtonItem(image: sosImg, style: .plain, target: self, action: #selector(didTapSOSButton))
        sosButton.tintColor = UIColor.black

        if showSOS {
            navigationItem.rightBarButtonItems = [filterButton, searchButton, callButton, sosButton ]
        }
        else {
            navigationItem.rightBarButtonItems = [filterButton, searchButton, callButton ]
        }
    }

    @objc func didTapSOSButton() {
        SOSFactory.shared.raiseSOSRequest()
    }

    @objc func didTapCallButton() {

        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
            if self.isPhone(userSelectionForService.salon_PhoneNumber) {
                userSelectionForService.salon_PhoneNumber.makeACall()
            }
        }
    }
    @objc func didTapFilter() {

        let selectServiceModuleViewController = SelectServiceModuleViewController.instantiate(fromAppStoryboard: .Services)
        selectServiceModuleViewController.controllerToDismiss = self
        self.view.alpha = screenPopUpAlpha
        UIApplication.shared.keyWindow?.rootViewController?.present(selectServiceModuleViewController, animated: true, completion: nil)
        selectServiceModuleViewController.onDoneBlock = { [unowned self] result in
            // Do something
            if result {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[unowned self] in
                    self.refreshView()
                }
            }
            self.view.alpha = 1.0

        }
    }
    @objc func didTapSearchButton() {
        let searchModuleVC = SearchModuleVC.instantiate(fromAppStoryboard: .Services)
        self.navigationController?.pushViewController(searchModuleVC, animated: false)
    }

    func openSubCategoryView(model: SalonServiceModule.Something.CategoryModel) {
        let vc = SubCategoryVC.instantiate(fromAppStoryboard: .Services)
        self.view.alpha = screenPopUpAlpha
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
            let imageURL: String = (userSelectionForService.gender == PersonType.male ? model.male_img : model.female_img) ?? ""
            if !imageURL.isEmpty {
                vc.setConfig(imageURL: imageURL, title: model.name ?? "")
            }
        }
        vc.onDoneBlock = {[unowned self]  result in
            // Do something
            if result {}
else {}
            self.view.alpha = 1.0
        }
    }

    // MARK: - Refresh View
    func refreshView() {
        categoryApiCall()
        testimonialsApiCall()
        dispatchGroup.notify(queue: .main) {[unowned self] in
            self.collectionViewObj.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                EZLoadingActivity.hide()

            }
        }

    }

    // MARK: - Call Webservice

    func categoryApiCall() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        if self.getSalonServiceDataFromCache() == false {

            if let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {

                reposStoreSalonService = LocalJSONStore(storageType: .cache, filename: String(format: "%@_%@", CacheFileNameKeys.k_file_name_salonService.rawValue, userSelectionForService.salon_id), folderName: CacheFolderNameKeys.k_folder_name_SalonService.rawValue)
                var request = SalonServiceModule.Something.Request(category_id: GenericClass.sharedInstance.getSalonServiceStaticId(), salon_id: userSelectionForService.salon_id, gender: userSelectionForService.gender)

                if  let dummy = UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_Key_SelectedLocationFor) {
                    let obj = dummy as? String ?? ""
                    if  obj == SalonServiceAt.home {
                        reposStoreSalonService = LocalJSONStore(storageType: .cache, filename: String(format: "%@_%@", CacheFileNameKeys.k_file_name_homeService.rawValue, userSelectionForService.salon_id), folderName: CacheFolderNameKeys.k_folder_name_HomeService.rawValue)
                        request = SalonServiceModule.Something.Request(category_id: GenericClass.sharedInstance.getHomeServiceStaticId(), salon_id: userSelectionForService.salon_id, gender: userSelectionForService.gender)
                    }

                }
                // let request = SalonServiceModule.Something.Request(salon_id: userSelectionForService.salon_id,gender:userSelectionForService.gender)
                interactor?.doPostRequest(request: request, method: HTTPMethod.post)

            }
        }
    }

    func testimonialsApiCall() {
        dispatchGroup.enter()
        if self.getTestimonialsDataFromCache() == false {
            let request = SalonServiceModule.Something.TestimonialRequest(limit: "\(maxlimitToTestimonials)")
            interactor?.doPostRequestTestimonials(request: request, method: HTTPMethod.post)
        }
    }

    // MARK: - Webservice responses
    func displaySuccess<T: Decodable>(viewModel: T) {
        DispatchQueue.main.async {[unowned self] in
            if T.self == SalonServiceModule.Something.Response.self {
                // CATEGORY
                if let obj = viewModel as? SalonServiceModule.Something.Response {
                self.reposStoreSalonService.save(obj)
                self.arrCategories = obj.data?.children ?? []
                if let model = obj.data?.why_enrich {
                    self.objectWhyEnrich = model
                }
                if let model = obj.data {
                    self.objectHeader = model
                }
            }
                self.dispatchGroup.leave()
            }
            else {
                // TESTIMONIALS
                if let obj = viewModel as? SalonServiceModule.Something.TestimonialResponse {
                self.reposStoreTestimonials.save(obj)

                self.arrCustomerReviews = obj.data?.testimonials ?? []
                }
                self.dispatchGroup.leave()
            }
        }
    }

    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage!)
        self.dispatchGroup.leave()
    }

    func displaySuccess<T: Decodable>(responseSuccess: [T]) {}
}

extension SalonServiceModuleViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == SalonServicesSections.categorySection.rawValue {
            return arrCategories.count
        }
        else {
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == SalonServicesSections.categorySection.rawValue {
            return cellServiceSection(collectionView, indexPath: indexPath)

        }
        else if indexPath.section == SalonServicesSections.infoSection.rawValue {

            return cellWhyEnrichSection(collectionView, indexPath: indexPath)
        }
        else if indexPath.section == SalonServicesSections.testimonialsSection.rawValue {

            return cellTestimonialsViewSection(collectionView, indexPath: indexPath)
        }
        return cellTitleImageSection(collectionView, indexPath: indexPath)
    }

    func cellTitleImageSection(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.horizontalListingCollectionViewCell, for: indexPath) as? HorizontalListingCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.addSubview(headerView)

        headerView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: SalonServicesSections.titleImageSection.heightOfCell)

        headerView.lblTitle.text = objectHeader.name ?? ""
        headerView.lblTitle.setLineHeight(lineHeight: 0.7)

        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {

            headerView.imgBackground.image = userSelectionForService.serviceType == SalonServiceAt.home ? UIImage(named: "serviceHomeCategoryPlaceholderWoman") : userSelectionForService.gender == PersonType.male ? UIImage(named: "serviceSalonCategoryPlaceholderMen") :UIImage(named: "serviceSalonCategoryPlaceholderWoman")

        }

        /* var imageURL:String = ""
         if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService.rawValue){
         if(userSelectionForService.gender == PersonType.female.rawValue)
         {
         imageURL = self.objectHeader.female_img ?? ""
         }
         else
         {
         imageURL = self.objectHeader.male_img ?? ""
         
         }
         
         }
         let url = URL(string: imageURL)
         headerView.imgBackground.kf.indicatorType = .activity
         
         
         if let imageurl = self.objectHeader.female_img, !imageurl.isEmpty
         {
         headerView.imgBackground.kf.setImage(with: url, placeholder:UIImage(named: "serviceSalonCategoryPlaceholderWoman") , options: nil, progressBlock: nil, completionHandler: nil)
         } else {
         headerView.imgBackground.image = UIImage(named: "serviceSalonCategoryPlaceholderWoman")
         }*/

        return cell
    }

    func cellTestimonialsViewSection(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.horizontalListingCollectionViewCell2, for: indexPath) as? HorizontalListingCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.addSubview(customerView)
        customerView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: SalonServicesSections.testimonialsSection.heightOfCell)
        customerView.setupUIInit(arrReviewsData: arrCustomerReviews, frameObj: cell.frame)
        return cell
    }

    func cellWhyEnrichSection(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.horizontalListingCollectionViewCell1, for: indexPath) as? HorizontalListingCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.addSubview(whyEnrichView)
        whyEnrichView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: SalonServicesSections.infoSection.heightOfCell)

        whyEnrichView.setupUIInit(model: objectWhyEnrich)
        return cell
    }

    func cellServiceSection(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.serviceCell, for: indexPath) as? ServiceCell else {
            return UICollectionViewCell()
        }
        if !arrCategories.isEmpty {
            let model = arrCategories[indexPath.row]
            cell.serviceNameLabel.text = model.name
            if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
                let imageURL: String = (userSelectionForService.gender == PersonType.male ? model.male_img : model.female_img) ?? ""
                if !imageURL.isEmpty {
                    let url = URL(string: imageURL )
                    cell.backgroundImageView.kf.setImage(with: url, placeholder: UIImage(named: "categoryPlaceholderImg"), options: nil, progressBlock: nil, completionHandler: nil)
                }
            }

        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if indexPath.section == SalonServicesSections.categorySection.rawValue {
            if arrCategories.count % 2 != 0 && indexPath.row == (arrCategories.count - 1) {
                return CGSize(width: (collectionView.frame.size.width - widthForCategoryCell * 1.5 ), height: SalonServicesSections.categorySection.heightOfCell)
            }
            return CGSize(width: ((collectionView.frame.size.width / 2) - widthForCategoryCell), height: SalonServicesSections.categorySection.heightOfCell)
        }
        else {
            return CGSize(width: collectionView.frame.size.width, height: SalonServicesSections(rawValue: indexPath.section)?.heightOfCell ?? 0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == SalonServicesSections.categorySection.rawValue || section == SalonServicesSections.titleImageSection.rawValue {
            return UIEdgeInsets(top: 0, left: marginForCategoryCell, bottom: 0, right: marginForCategoryCell)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.section == SalonServicesSections.categorySection.rawValue {
            let model = arrCategories[indexPath.row]
            let hairServiceModuleViewController = HairServiceModuleVC.instantiate(fromAppStoryboard: .Services)
            hairServiceModuleViewController.categoryModel = model
            hairServiceModuleViewController.salonServiceRef = self
            if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {
                hairServiceModuleViewController.gender = userSelectionForService.gender
            }
            self.navigationController?.pushViewController(hairServiceModuleViewController, animated: true)

            //openSubCategoryView(model: model)
        }
    }
}
// MARK: For Cache Fetching
extension SalonServiceModuleViewController {
    func getSalonServiceDataFromCache() -> Bool {

        var havingCachedData: Bool = false

        if  let userSelectionForService = UserDefaults.standard.value( UserSelectedLocation.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalonAndGenderForService) {

            reposStoreSalonService = LocalJSONStore(storageType: .cache, filename: String(format: "%@_%@", CacheFileNameKeys.k_file_name_salonService.rawValue, userSelectionForService.salon_id), folderName: CacheFolderNameKeys.k_folder_name_SalonService.rawValue)

            if  let dummy = UserDefaults.standard.value(forKey: UserDefauiltsKeys.k_Key_SelectedLocationFor) {
                let obj = dummy as? String ?? ""
                if  obj == SalonServiceAt.home {
                    reposStoreSalonService = LocalJSONStore(storageType: .cache, filename: String(format: "%@_%@", CacheFileNameKeys.k_file_name_homeService.rawValue, userSelectionForService.salon_id), folderName: CacheFolderNameKeys.k_folder_name_HomeService.rawValue)
                }

            }
        }

        if let repos = reposStoreSalonService.storedValue {
            havingCachedData = true
            DispatchQueue.main.async {[unowned self] in
                let obj: SalonServiceModule.Something.Response = repos
                self.arrCategories = obj.data?.children ?? []
                if let model = obj.data?.why_enrich {
                    self.objectWhyEnrich = model
                }
                if let model = obj.data {
                    self.objectHeader = model
                }

                self.collectionViewObj.reloadData()

            }
            self.dispatchGroup.leave()
        }

        return havingCachedData
    }

    func getTestimonialsDataFromCache() -> Bool {
        var havingCachedData: Bool = false

        if let repos = reposStoreTestimonials.storedValue {
            havingCachedData = true

            DispatchQueue.main.async {[unowned self] in
                let obj: SalonServiceModule.Something.TestimonialResponse = repos
                self.arrCustomerReviews = obj.data?.testimonials ?? []
                self.collectionViewObj.reloadData()

            }
            self.dispatchGroup.leave()

        }

        return havingCachedData

    }
}
