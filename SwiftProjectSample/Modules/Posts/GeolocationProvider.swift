//
//  GeolocationPorvider.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 09.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxOptional

struct GPSReturnedEmptyLocations: Error {}

class GeolocationProvider {
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate let locationSubject = PublishSubject<CLLocation>()
    fileprivate let locationManager = CLLocationManager()
    
    var authorizationStatus: Observable<CLAuthorizationStatus> {
        let currentStatus = CLLocationManager.authorizationStatus()
        return locationManager.rx.didChangeAuthorizationStatus
            .startWith(currentStatus)
    }
    
    var location: Observable<CLLocation> {
        return Observable.deferred {
            self.startUpdatingLocations()
            return self.locationManager.rx.didUpdateLocations
                .map { locations in
                    guard let lastLocation = locations.last else { throw GPSReturnedEmptyLocations() }
                    return lastLocation
            }
        }
    }
    
    var desiredAccuracy: CLLocationAccuracy = 1000 {
        didSet {
            locationManager.desiredAccuracy = desiredAccuracy
        }
    }
    
    init() {
        locationManager.desiredAccuracy = desiredAccuracy

    }
    
    func startUpdatingLocations() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopReceivingLocationsUpdates() {
        locationManager.stopUpdatingLocation()
    }
}
