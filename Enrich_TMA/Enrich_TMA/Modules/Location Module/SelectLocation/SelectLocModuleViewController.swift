//
//  SelectLocModuleViewController.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright (c) 2019 Aman Gupta. All rights reserved.
//
//
//

import UIKit
import GooglePlaces

class SelectLocModuleViewController: UIViewController {
    @IBOutlet weak private var lblExample: UILabel!
    @IBOutlet weak private var btnUseCurrentLocation: UIButton!
    @IBOutlet weak private var btnClose: UIButton!
    @IBOutlet weak private var searchObj: UISearchBar!

    let googlePlacesViewController = GooglePlacesViewController.instantiate(fromAppStoryboard: .Main)
    let locationManager = CLLocationManager()
    weak var controllerComingFrom: UINavigationController?

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchObj.placeholder = "Search for area, street name…"
        self.btnClose.isHidden = true
        if((self.controllerComingFrom) != nil) {self.btnClose.isHidden = false}
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "Select Location"
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.btnUseCurrentLocation.isUserInteractionEnabled = true
        self.navigationController?.addCustomBackButton(title: "")
    }

    // MARK: - IBActions
    @IBAction func actionClose(_ sender: Any) {

        if((self.controllerComingFrom) != nil) {
            if (self.controllerComingFrom?.parent) != nil {
                self.hideContentController(content: self.controllerComingFrom!)
            } else {
                self.appDelegate.window?.rootViewController!.dismiss(animated: false, completion: nil)
            }
        }

    }

    @IBAction func actionBtnSelecttLoc(_ sender: Any) {

        if !NetworkRechability.isConnectedToNetwork() {
            self.showAlert(alertTitle: alertTitle, alertMessage: APIErrorMessage.internetConnectionError.description)
        } else {
            self.btnUseCurrentLocation.isUserInteractionEnabled = false
            self.getUserCurrentLocation()
        googlePlacesViewController.delegate = self
            googlePlacesViewController.getCurrentPlace()
        }
    }
}

extension SelectLocModuleViewController: UITextFieldDelegate, GooglePlacesViewControllerDelegate {
    func didReceiveData(_ userData: GMSPlace) {
        let googlePlacesViewController = LocationModuleViewController.instantiate(fromAppStoryboard: .Location)
        googlePlacesViewController.controllerComingFrom = self.controllerComingFrom
        googlePlacesViewController.location = CLLocationCoordinate2D(latitude: userData.coordinate.latitude, longitude: userData.coordinate.longitude) // userData.coordinate

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            googlePlacesViewController.locationName = userData.name ?? "No name available"
            googlePlacesViewController.location = userData.coordinate
            self.navigationController?.addCustomBackButton(title: "")
            self.navigationController?.pushViewController(googlePlacesViewController, animated: false)
        }
    }

    func somethingError(responseError: String?) {
        self.showAlert(alertTitle: alertTitle, alertMessage: responseError ?? "")
        self.locationManager.startUpdatingLocation()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
}
extension SelectLocModuleViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)

        switch status {
        case CLAuthorizationStatus.authorizedAlways, CLAuthorizationStatus.authorizedWhenInUse:                        self.actionBtnSelecttLoc([:])
        case CLAuthorizationStatus.denied, CLAuthorizationStatus.notDetermined, CLAuthorizationStatus.restricted:
            break
        default:
            break
        }
    }

    func getUserCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        let alertController = UIAlertController(title: alertTitle, message: "Please go to settings and turn on the permissions.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (_) in }
                )}
            self.btnUseCurrentLocation.isUserInteractionEnabled = true
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) -> Void in
            self.btnUseCurrentLocation.isUserInteractionEnabled = true
        }
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        // check the permission status
        switch(CLLocationManager.authorizationStatus()) {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorize.")
        // get the user location

        case .notDetermined, .restricted, .denied:
            // redirect the users to settings
            locationManager.requestAlwaysAuthorization()
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation

        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        let googlePlacesViewController = LocationModuleViewController.instantiate(fromAppStoryboard: .Location)
        googlePlacesViewController.controllerComingFrom = self.controllerComingFrom
        googlePlacesViewController.location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude) // userData.coordinate
        self.btnUseCurrentLocation.isUserInteractionEnabled = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            googlePlacesViewController.locationName =  "No name available"
            googlePlacesViewController.location = userLocation.coordinate
            self.navigationController?.addCustomBackButton(title: "")
            self.navigationController?.pushViewController(googlePlacesViewController, animated: false)
        }

    }
}

extension SelectLocModuleViewController {
    func hideContentController(content: UINavigationController) {
        content.willMove(toParent: nil)
        content.view.removeFromSuperview()
        content.removeFromParent()
    }
}

extension SelectLocModuleViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if !NetworkRechability.isConnectedToNetwork() {
                self.showAlert(alertTitle: alertTitle, alertMessage: APIErrorMessage.internetConnectionError.description)
            } else {
                self.googlePlacesViewController.delegate = self
                self.navigationController?.addCustomBackButton(title: "")
                self.navigationController?.pushViewController(self.googlePlacesViewController, animated: false)
            }
        }
        return false
    }
}
