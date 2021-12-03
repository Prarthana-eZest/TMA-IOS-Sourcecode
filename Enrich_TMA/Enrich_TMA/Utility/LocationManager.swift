//
//  LocationManager.swift
//  GoVida
//
//  Created by Harshal Patil on 26/04/19.
//  Copyright © 2019 e-Zest. All rights reserved.
//

import UIKit
import CoreLocation

@objc
protocol LocationManagerDelegate {

    func locationDidFound(_ latitude: Double, longitude: Double)
    @objc optional func locationServicesEnabled(_ status: Bool)
}

private let SharedInstance = LocationManager()

class LocationManager: NSObject {

    weak var delegate: LocationManagerDelegate?

    class var sharedInstance: LocationManager {
        return SharedInstance
    }

    fileprivate var locationManager: CLLocationManager?

    func location() -> (latitude: Double, longitude: Double) {
        if let locationManager = self.locationManager {

            if let latitude = locationManager.location?.coordinate.latitude, let longitude = locationManager.location?.coordinate.longitude {
                return(latitude, longitude)
            }
        }
        return (0, 0)
    }

    func initialiseLocationManager() {
        if self.locationManager == nil {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager = CLLocationManager()
                self.locationManager?.delegate = self
                self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                //self.locationManager?.requestAlwaysAuthorization()
                self.locationManager?.requestWhenInUseAuthorization()
                self.locationManager?.startUpdatingLocation()
            }
            else {
                self.delegate?.locationServicesEnabled?(false)
            }
        }
    }

    func isLocationServiceIsOn() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined :
                return false
            case .restricted :
                return false
            case .denied:
                print("No access")
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                return true
            }
        }
        else {
            print("Location services are not enabled")
            return false
        }
    }

    func isLocationServiceEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined :
                return false
            case .restricted, .denied, .authorizedAlways, .authorizedWhenInUse :
                return true
            }
        }
        else {
            print("Location services are not enabled")
            return false
        }
    }

    func deinitialiseLocationManager() {
        self.stopUpdatingLocation()
        self.locationManager = nil
    }

    func startUpdatingLocation() {
        locationManager?.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager?.stopUpdatingLocation()
    }

}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        print("didChangeAuthorizationStatus")

        switch status {
        case .notDetermined:
            print(".NotDetermined")

        case .authorizedAlways:
            print(".AuthorizedAlways")
            self.initialiseLocationManager()
            self.startUpdatingLocation()

        case .authorizedWhenInUse:
            print(".AuthorizedWhenInUse")
            self.initialiseLocationManager()
            self.startUpdatingLocation()

        case .restricted:
            print(".Restricted")

        case .denied:
            print(".Denied")
        }

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let latitude = locationManager?.location?.coordinate.latitude, let longitude = locationManager?.location?.coordinate.longitude {
//            let coordinate₀ = CLLocation(latitude: 20.46502444573954, longitude: 74.99002792586407)
//            let coordinate₁ = CLLocation(latitude: latitude, longitude: longitude)
//            let distanceInMeters = coordinate₀.distance(from: coordinate₁)
//            print("Lat:\(latitude) Long:\(longitude) Distance:\(distanceInMeters)")
            print("Lat:\(latitude) Long:\(longitude)")
            delegate?.locationDidFound(latitude, longitude: longitude)
        }
        //self.stopUpdatingLocation()
    }
}
