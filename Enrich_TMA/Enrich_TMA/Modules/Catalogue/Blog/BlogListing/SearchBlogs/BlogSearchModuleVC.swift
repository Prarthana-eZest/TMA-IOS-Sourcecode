//
//  BlogSearchModuleViewController.swift
//  EnrichSalon
//

import UIKit

// MARK: - Class BlogSearchModuleViewController
class BlogSearchModuleVC: UIViewController {

    @IBOutlet weak private var lblNoDataAvail: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    lazy var searchBar: UISearchBar = UISearchBar()

    var interactor: BlogListingModuleBusinessLogic?
    private let dispatchGroup = DispatchGroup()

    var arrBlogs: [BlogListingAPICall.listing.BlogListModel] = []
    var arrCategoriesUI: [SelectedCellModel] = []

    var totalItemsCount = 0
    var currentPageNumber = 1
    var strSearchText = ""

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
        tableView.register(UINib(nibName: CellIdentifier.blogCell, bundle: nil), forCellReuseIdentifier: CellIdentifier.blogCell)
        tableView.separatorColor = .clear

        searchBar.placeholder = "Search"
        searchBar.setShowsCancelButton(false, animated: false)
        for subview in searchBar.subviews {
            for innerSubview in subview.subviews {
                if innerSubview is UITextField {
                    innerSubview.backgroundColor = searchBarInsideBackgroundColor
                }
            }
        }
        searchBar.delegate = self
        showSearchController()
        searchBar.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.addCustomBackButton(title: "")
        title = ""

        refreshUIData()
    }

    func refreshUIData() {

        if arrBlogs.isEmpty {
            lblNoDataAvail.text = strSearchText == "" ? "" : "No blogs available for this search78"
            lblNoDataAvail.isHidden = false
            self.tableView.isHidden = true
            return
        }

        strSearchText = ""
        lblNoDataAvail.isHidden = true
        tableView.isHidden = false
        DispatchQueue.main.async {[unowned self] in
            self.tableView.reloadData()
        }
    }
}

// MARK: - Select item, Wishlist & Checkbox
extension BlogSearchModuleVC: ProductSelectionDelegate {
    func moveToCart(indexPath: IndexPath) {
        print("moveToCart \(indexPath)")
    }
    func actionAddOnsBundle(indexPath: IndexPath) {
        print("actionAddOnsBundle \(indexPath)")
    }

    func selectedItem(indexpath: IndexPath, identifier: SectionIdentifier) {
        let model = self.arrBlogs[indexpath.row]
        let vc = BlogDetailsModuleVC.instantiate(fromAppStoryboard: .Blog)
        vc.blog_id = model.post_id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func deleteAllPreviousData() {
        self.arrBlogs = []
        self.currentPageNumber = 1
        self.totalItemsCount = 0
    }

    func callBlogsListing() {
        self.callBlogListingDataFromServer(text: strSearchText)
        dispatchGroup.notify(queue: .main) {[unowned self] in
            self.refreshUIData()
        }
    }
}

// MARK: - Action ViewAll
extension BlogSearchModuleVC: HeaderDelegate {
    func actionViewAll(identifier: SectionIdentifier) {
        print("ViewAllAction : \(identifier.rawValue)")
    }
}

// MARK: - Response Success Failure
extension BlogSearchModuleVC: BlogListingModuleDisplayLogic {
    func displaySuccessFeaturedVideos<T: Decodable>(viewModel: T) {
    }

    func displaySuccess<T: Decodable>(viewModel: T) {
        EZLoadingActivity.hide()
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

    func displaySuccess<T: Decodable>(responseSuccess: [T]) {}
}

// MARK: - API Call
extension BlogSearchModuleVC {
    func callBlogListingDataFromServer(text: String) {
        EZLoadingActivity.show("Loading...", disableUI: true)
        dispatchGroup.enter()
        let request = BlogListingAPICall.listing.Request(category_id: "", term: text, page: currentPageNumber)
        interactor?.doPostRequestBlogListing(request: request, method: .post)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BlogSearchModuleVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrBlogs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.blogCell, for: indexPath) as? BlogCell else {
            return UITableViewCell()
        }
        let data = self.arrBlogs[indexPath.row]
        cell.selectionStyle = .none
        cell.delegate = self
        cell.btnReadMore.tag = indexPath.row
        cell.configureCell(model: (interactor?.getBlogCellModel(model: data))!)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return is_iPAD ? 285 : 190
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.arrBlogs[indexPath.row]
        let vc = BlogDetailsModuleVC.instantiate(fromAppStoryboard: .Blog)
        vc.blog_id = model.post_id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (arrBlogs.count - 1) && arrBlogs.count < totalItemsCount {
            callBlogsListing()
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Show & handle search bar on navigation
extension BlogSearchModuleVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        searchBar.resignFirstResponder()
        if let text = searchBar.text, !text.isEmpty {
            strSearchText = "\(text)"
            deleteAllPreviousData()
            callBlogsListing()
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
        perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.75)
    }

    @objc func reload(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.trimmingCharacters(in: .whitespaces) != "" else {
            print("nothing to search")
            return
        }
        print(query)
    }

    func hideSearchController() {
        navigationItem.titleView = nil
    }

    func showSearchController() {
        navigationItem.titleView = searchBar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.searchCancel(sender:)))
    }

    @objc func searchCancel(sender: UIButton) {
        self.searchBar.text = ""
        self.navigationController?.popViewController(animated: false)
    }
}
