//
//  GooglePlacesViewController.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/14/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit
import GooglePlaces

protocol GooglePlacesViewControllerDelegate: class {
    func didReceiveData(_ userData: GMSPlace)
    func somethingError(responseError: String?)
}

class GooglePlacesViewController: UIViewController {
    var placesClient: GMSPlacesClient!

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    weak var delegate: GooglePlacesViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        placesClient = GMSPlacesClient.shared()
        self.title = "Search Location"

//        self.addToNavbar()
        //self.addToPopover()

        //*** New Code **** *** ***
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.searchBarStyle = .minimal

        if let textField = searchController?.searchBar.value(forKey: "searchField") as? UITextField,
            let iconView = textField.leftView as? UIImageView {
            iconView.image = iconView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            iconView.tintColor = UIColor.red
            textField.placeholder = "Search for area, street name…"
        }

        let subView = UIView(frame: CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.height)! + 35, width: self.view.frame.size.width - 40, height: 45.0))

        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.searchBar.setShowsCancelButton(false, animated: false)

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        //*** *** *** *** *** *** ***
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.addCustomBackButton(title: "")

    }

    func addToNavbar() {

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        searchController?.searchBar.placeholder = "Search Area,Street,City"
        navigationItem.titleView = searchController?.searchBar

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true

        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
    }

    func addToPopover() {

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        // Add the search bar to the right of the nav bar,
        // use a popover to display the results.
        // Set an explicit size as we don't want to use the entire nav bar.
        searchController?.searchBar.frame = (navigationController?.navigationBar.frame)!
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: (searchController?.searchBar)!)

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true

        // Keep the navigation bar visible.
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.modalPresentationStyle = .popover
    }

    // Add a UIButton in Interface Builder, and connect the action to this function.
    func getCurrentPlace() {

        DispatchQueue.main.async {
            EZLoadingActivity.show("Loading...", disableUI: true)

             DispatchQueue.main.async {

            if(self.placesClient == nil) {
                self.placesClient = GMSPlacesClient.shared()
            }
            self.placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
                if let error = error {
                    EZLoadingActivity.hide()
                    self.delegate?.somethingError(responseError: error.localizedDescription)

                    return
                }
                if let placeLikelihoodList = placeLikelihoodList {
                    let place = placeLikelihoodList.likelihoods.first?.place
                    if let place = place {
                        self.delegate?.didReceiveData(place)
                        EZLoadingActivity.hide(true, animated: false)

                  }
                }
            })

             }
        }

        }

}

// Handle the user's selection.
extension GooglePlacesViewController: GMSAutocompleteResultsViewControllerDelegate {

    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        self.forwardData(place: place)
    }

    func forwardData(place: GMSPlace) {
        print("Place address: \(place.coordinate)")
        print("Place name: \(place.name ?? "No name")")
        print("Place address: \(place.formattedAddress ?? "No address")")
        self.delegate?.didReceiveData(place)
        self.navigationController?.popViewController(animated: false)
    }

    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
        self.delegate?.somethingError(responseError: error.localizedDescription)
        self.navigationController?.popViewController(animated: false)
    }

    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
