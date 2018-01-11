//
//  GeolocationProviderStub.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 09.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
@testable import SwiftProjectSample
import RxSwift
import CoreLocation

class GeolocationProviderStub: GeolocationProvider {
    
    override init() {
         _ = _givenLocationSequence.asObservable()
            .flatMap { locations in
                return Observable<Int>.interval(0.1, scheduler: MainScheduler.instance).take(locations.count)
                    .map { index in
                   return locations[index]
                }
            }.bindTo(locationsSubject)
    }
    
    var givenAuthorizationStatusSubject: CLAuthorizationStatus = .authorizedWhenInUse
    fileprivate var _givenLocationSequence = Variable<[CLLocation]>([])
    var givenLocationSequence: [CLLocation] = [] {
        didSet {
            _givenLocationSequence.value = givenLocationSequence
        }
    }
    
    fileprivate var locationsSubject = PublishSubject<CLLocation>()
    
    override var location: Observable<CLLocation> {
        return locationsSubject.asObservable()
    }
    
    override var authorizationStatus: Observable<CLAuthorizationStatus> {
        return Observable.deferred {
            return Observable.just(self.givenAuthorizationStatusSubject)
        }
    }
    
    var didStartUpdatingLocations = false
    override func startUpdatingLocations() {
        didStartUpdatingLocations = true
    }
    
    var didStopRecevingLocationUpdates = false
    override func stopReceivingLocationsUpdates() {
        didStopRecevingLocationUpdates = true
    }
}
