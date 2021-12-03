//
//  BlogListingModuleViewController.swift
//  EnrichSalon
//

import UIKit
// MARK: - BlogListingModuleDisplayLogic
protocol BlogListingModuleDisplayLogic: class {
    func displaySuccessFeaturedVideos<T: Decodable> (viewModel: T)
    func displaySuccess<T: Decodable> (viewModel: T)
    func displayError(errorMessage: String?)
    func displaySuccess<T: Decodable>(responseSuccess: [T])
}

// MARK: - Class BlogListingModuleViewController
class BlogListingModuleVC: UIViewController {

    let kCollectionHeaderTag = 101
    let kCollectionDataTag = 102

    @IBOutlet weak private var collectionHeaders: UICollectionView!
    @IBOutlet weak private var collectionViewObj: UICollectionView!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var viewFeaturedVideos: UIView!

    var interactor: BlogListingModuleBusinessLogic?

    var sections = [SectionConfiguration]()
    private let dispatchGroup = DispatchGroup()

    var arrCategories: [BlogListingAPICall.categories.CategoriesModel] = []
    var arrBlogs: [BlogListingAPICall.listing.BlogListModel] = []
    var arrCategoriesUI: [SelectedCellModel] = []
    var arrBlogsFeatured: [BlogListingAPICall.listing.BlogListModel] = []

    var totalItemsCount = 0
    var currentPageNumber = 1

    var totalItemsCountFeaturedVideos = 0
    var currentPageFeaturedVideos = 1
    var selectedBlogTitleCell = 0

    // MARK: - Initiate
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: Setup
    private func setup() {
        let viewController = self
        let interactor = BlogListingModuleInteractor()
        let presenter = BlogListingModulePresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setup()
        showNavigationBarRigtButtons()
    }

    func setUpSubViews() {
        self.collectionHeaders.tag = kCollectionHeaderTag
        self.collectionViewObj.tag = kCollectionDataTag

        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.addCustomBackButton(title: "Blog")

        self.viewFeaturedVideos.isHidden = true

        tableView.separatorColor = .clear
        tableView.register(UINib(nibName: CellIdentifier.headerViewWithTitleCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.headerViewWithTitleCell)
        tableView.register(UINib(nibName: CellIdentifier.blogCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.blogCell)

        collectionViewObj.register(UINib(nibName: CellIdentifier.featuredVideosCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.featuredVideosCell)
        collectionHeaders.register(UINib(nibName: CellIdentifier.hairServicesCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.hairServicesCell)

        // API CALL
        callBlogsCategoriesFromServer()
//        callFeaturedVideosFromServer()
        dispatchGroup.notify(queue: .main) {[unowned self] in
            self.updateUIAfterServerData()
            DispatchQueue.main.async {[unowned self] in
                self.updateUIAfterRefresh()
            }
        }
    }

    func updateUIAfterRefresh() {
        self.tableView.reloadData()
        self.viewFeaturedVideos.isHidden = true
        if !self.arrBlogsFeatured.isEmpty {
            self.viewFeaturedVideos.isHidden = false
            self.collectionViewObj.reloadData()
            self.collectionHeaders.reloadData()
        }
    }

    func updateUIAfterServerData() {
        sections.removeAll()
//        sections.append(configureSection(idetifier: .blog_Topics,items: self.arrCategoriesUI.count, data: self.arrCategoriesUI))
        sections.append(configureSection(idetifier: .blog_List, items: self.arrBlogs.count, data: []))
    }

    // MARK: - Top Navigation Bar And  Actions
    func showNavigationBarRigtButtons() {

        guard let sosImg = UIImage(named: "SOS"),
            let searchImg = UIImage(named: "searchImg") else {
            return
        }

        let searchButton = UIBarButtonItem(image: searchImg, style: .plain, target: self, action: #selector(didTapSearchButton))
        searchButton.tintColor = UIColor.black

        let sosButton = UIBarButtonItem(image: sosImg, style: .plain, target: self, action: #selector(didTapSOSButton))
        sosButton.tintColor = UIColor.black
        navigationItem.title = ""
        if showSOS {
            navigationItem.rightBarButtonItems = [sosButton, searchButton]
        }
        else {
            navigationItem.rightBarButtonItems = [searchButton]
        }
    }

    @objc func didTapSOSButton() {
        SOSFactory.shared.raiseSOSRequest()
    }

    @objc func didTapSearchButton() {
        let vc = BlogSearchModuleVC.instantiate(fromAppStoryboard: .Blog)
        self.navigationController?.pushViewController(vc, animated: true)

    }
}

// MARK: - Select item, Wishlist & Checkbox
extension BlogListingModuleVC: ProductSelectionDelegate {

    func moveToCart(indexPath: IndexPath) {
        print("moveToCart \(indexPath)")
    }
    func actionAddOnsBundle(indexPath: IndexPath) {
        print("actionAddOnsBundle \(indexPath)")
    }

    func actionQunatity(quantity: Int, indexPath: IndexPath) {
        print("quntity:\(quantity)")
    }

    func selectedItem(indexpath: IndexPath, identifier: SectionIdentifier) {
        switch identifier {
            case .blog_Topics:
                self.selectedBlogTitleCell = indexpath.row
                clearListingData()

        case .blog_List:
//            let model = self.arrBlogs[indexpath.row]
//            let vc = BlogDetailsModuleVC.instantiate(fromAppStoryboard: .Blog)
//            vc.blog_id = model.post_id ?? ""
//            self.navigationController?.pushViewController(vc, animated: true)
            break

            default: break
        }
    }

    func clearListingData() {
        self.arrBlogs = []
        totalItemsCount = 0
        currentPageNumber = 1
        arrCategoriesUI = []
        arrCategoriesUI = (interactor?.parseBlogCategories(data: self.arrCategories, selectedIndex: self.selectedBlogTitleCell)) ?? []

        callBlogsListing()
    }

    func callBlogsListing() {
        self.callBlogListingDataFromServer()
        dispatchGroup.notify(queue: .main) {[unowned self] in
            self.updateUIAfterServerData()
            DispatchQueue.main.async {[unowned self] in
                self.tableView.reloadData()
                self.collectionHeaders.reloadData()
            }
        }
    }

    func wishlistStatus(status: Bool, indexpath: IndexPath, identifier: SectionIdentifier) {
        print("WishList:\(status) || \(identifier.rawValue) || item :\(indexpath.row)")
    }
}

// MARK: - Action ViewAll
extension BlogListingModuleVC: HeaderDelegate {

    func actionViewAll(identifier: SectionIdentifier) {
        print("ViewAllAction : \(identifier.rawValue)")
    }
}

// MARK: - Response Success Failure
extension BlogListingModuleVC: BlogListingModuleDisplayLogic {
    //

    func displaySuccess<T: Decodable>(viewModel: T) {
        EZLoadingActivity.hide()

        if let obj: BlogListingAPICall.categories.Response = viewModel as? BlogListingAPICall.categories.Response, let arrCat = obj.data {
            self.arrCategories = arrCat.categories ?? []
            self.arrCategoriesUI = (interactor?.parseBlogCategories(data: self.arrCategories, selectedIndex: self.selectedBlogTitleCell)) ?? []
            self.collectionHeaders.reloadData()
            self.callBlogListingDataFromServer()
            dispatchGroup.leave()
        }

        if let obj: BlogListingAPICall.listing.Response = viewModel as? BlogListingAPICall.listing.Response, let arrBlog = obj.data {
            currentPageNumber += 1
            self.arrBlogs.append(contentsOf: (arrBlog.blogs ?? []))
            self.totalItemsCount = arrBlog.total_number ?? 0
            dispatchGroup.leave()
        }
    }

    func displayError(errorMessage: String?) {
        EZLoadingActivity.hide()
        dispatchGroup.leave()
        DispatchQueue.main.async { [unowned self] in
            self.showAlert(alertTitle: alertTitle, alertMessage: errorMessage ?? "")
        }
    }

    func displaySuccess<T: Decodable>(responseSuccess: [T]) {
//        DispatchQueue.main.async {
//            var obj = [BlogDetailAPICall.Detail.Response]()
//            obj = responseSuccess as! [BlogDetailAPICall.Detail.Response]
//            print("Get API Response -- \n \(obj)")
//        }
    }
}

// MARK: - API Call
extension BlogListingModuleVC {

    func callBlogsCategoriesFromServer() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        let request = BlogListingAPICall.categories.Request()
        interactor?.doPostRequest(request: request, method: .post)
    }

    func callBlogListingDataFromServer() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()

        let catId = arrCategories[selectedBlogTitleCell]
        let request = BlogListingAPICall.listing.Request(category_id: catId.id ?? "", term: "", page: currentPageNumber)
        interactor?.doPostRequestBlogListing(request: request, method: .post)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BlogListingModuleVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = sections[section]

        switch data.identifier {
            case .blog_Topics:
                return 1
            default :
                return data.items
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let data = sections[indexPath.section]

        switch data.identifier {

        case .blog_Topics:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.productsCollectionCell, for: indexPath) as? ProductsCollectionCell else {
                return UITableViewCell()
            }
            cell.tableViewIndexPath = indexPath
            cell.selectionDelegate = self
            cell.hideCheckBox = true
            cell.addSectionSpacing = 0
            cell.selectedMenuCell = selectedBlogTitleCell
            cell.configureCollectionView(configuration: data, scrollDirection: .horizontal)
            cell.selectionStyle = .none
            return cell

        case .blog_List:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.blogCell, for: indexPath) as? BlogCell else {
                return UITableViewCell()
            }
            cell.btnReadMore.tag = indexPath.row
            if indexPath.row < self.arrBlogs.count {
            let data = self.arrBlogs[indexPath.row]
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configureCell(model: (interactor?.getBlogCellModel(model: data))!)
            }
            return cell

        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = sections[indexPath.section]
        switch data.identifier {
        case .blog_Topics, .blog_List :
            return data.cellHeight
        default:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let data = sections[section]
        switch data.identifier {
        case .myPreferred_Blog_Topics:
            return data.headerHeight
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let data = sections[section]
        switch data.identifier {
        case .myPreferred_Blog_Topics,
             .featured_Videos:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.headerViewWithTitleCell) as? HeaderViewWithTitleCell else {
                return nil
            }
            cell.titleLabel.text = data.title
            cell.delegate = self
            if data.identifier == .myPreferred_Blog_Topics {
                cell.viewAllButton.isHidden = false
            }
            else {
                cell.viewAllButton.isHidden = true
            }
            return cell
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = sections[indexPath.section]
        if data.identifier == .blog_List {
            let model = self.arrBlogs[indexPath.row]
            let vc = BlogDetailsModuleVC.instantiate(fromAppStoryboard: .Blog)
            vc.blog_id = model.post_id ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let data = sections[indexPath.section]
        if data.identifier == .blog_List {
            if indexPath.row == (arrBlogs.count - 1) && arrBlogs.count < totalItemsCount {
                callBlogsListing()
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BlogListingModuleVC {

    func configureSection(idetifier: SectionIdentifier, items: Int, data: Any) -> SectionConfiguration {

        let headerHeight: CGFloat = is_iPAD ? 90 : 60
        var cellWidth: CGFloat = tableView.frame.size.width
        var cellHeight: CGFloat = is_iPAD ? 70 : 50
        let margin: CGFloat = is_iPAD ? 30 : 20

        switch idetifier {

        case .blog_Topics:

            cellWidth = is_iPAD ? 150 : 100
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: cellHeight, cellWidth: cellWidth, showHeader: true, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: margin, rightMarging: 0, isPagingEnabled: false, textFont: nil, textColor: .black, items: items, identifier: idetifier, data: data)

        case .blog_List:
            cellHeight = is_iPAD ? 250 : 150

            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: cellHeight, cellWidth: cellWidth, showHeader: false, showFooter: false, headerHeight: 0, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: false, textFont: nil, textColor: .black, items: items, identifier: idetifier, data: data)

        default :
            return SectionConfiguration(title: idetifier.rawValue, subTitle: "", cellHeight: 0, cellWidth: cellWidth, showHeader: false, showFooter: false, headerHeight: headerHeight, footerHeight: 0, leftMargin: 0, rightMarging: 0, isPagingEnabled: false, textFont: nil, textColor: .black, items: items, identifier: idetifier, data: data)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension BlogListingModuleVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == kCollectionDataTag {
            return self.arrBlogsFeatured.count
        }
        return self.arrCategoriesUI.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == kCollectionDataTag {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.featuredVideosCell, for: indexPath) as? FeaturedVideosCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(model: interactor!.getBlogCellModelFeatured(model: arrBlogsFeatured[indexPath.row]))
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.hairServicesCell, for: indexPath) as? HairServicesCell else {
                return UICollectionViewCell()
            }
            cell.configueView(model: self.arrCategoriesUI[indexPath.row])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var cellWidth: CGFloat = collectionView.frame.size.width
        let cellHeight: CGFloat = is_iPAD ? 70 : 50

        if collectionView.tag == kCollectionDataTag {
            let width: CGFloat = is_iPAD ? (cellWidth / 3) - 15 : (cellWidth / 2) - 5
            return CGSize(width: width, height: collectionView.frame.size.height - 10)
        }
        cellWidth = is_iPAD ? 150 : 100

        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == kCollectionHeaderTag {
            self.selectedBlogTitleCell = indexPath.row
            clearListingData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.tag == kCollectionDataTag {
            if indexPath.row == (arrBlogsFeatured.count - 1) && arrBlogsFeatured.count < totalItemsCountFeaturedVideos {
                callFeaturedVideosFromServer()
            }
        }
    }
}

// MARK: - Featured Videos
extension BlogListingModuleVC {

    func callFeaturedVideosFromServer() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        let request = BlogListingAPICall.listing.Request(category_id: "2", term: "", page: currentPageFeaturedVideos)
        interactor?.doPostFeaturedVideos(request: request, method: .post)
    }

    func displaySuccessFeaturedVideos<T: Decodable>(viewModel: T) {
        EZLoadingActivity.hide()
        if let obj: BlogListingAPICall.listing.Response = viewModel as? BlogListingAPICall.listing.Response, let arrBlog = obj.data {
            currentPageFeaturedVideos += 1
            self.arrBlogsFeatured.append(contentsOf: (arrBlog.blogs ?? []))
            self.totalItemsCountFeaturedVideos = obj.data?.total_number ?? 0
            dispatchGroup.leave()
            self.collectionViewObj.reloadData()
        }
    }

}
