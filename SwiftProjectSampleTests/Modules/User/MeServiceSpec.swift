//
//  MeServiceSpec.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 23.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxNimble
import Nimble
import Quick
import CoreLocation
@testable import SwiftProjectSample

class MeServiceSpec: QuickSpec {
    override func spec() {
        describe("MeService") {
            var sut: MeService!
            var userRepo: UserPersistanceRepositoryStub!
            var geolocationProvider: GeolocationProviderStub!
            let notificationCenter = NotificationCenter.default
            
            beforeEach() {
                userRepo = UserPersistanceRepositoryStub()
                geolocationProvider = GeolocationProviderStub()
                sut = MeService(withUserPersistanceRepository: userRepo, geolocationProvider: geolocationProvider)
                sut.notificationCenter = notificationCenter
            }
            
            describe("singleMeLocationUpdate") {
                var result: CLLocation? = nil
                let givenLocations: [CLLocation] = [FactoryGirl.Geolocation.randomLocation(withAccuracy: 2500), FactoryGirl.Geolocation.randomLocation(withAccuracy: 1500), FactoryGirl.Geolocation.randomLocation(withAccuracy: 1200)]
                beforeEach() {
                    _ = sut.singleMeLocationUpdate.subscribe(onNext: { location in
                        result = location
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    geolocationProvider.givenLocationSequence = givenLocations
                }
                
                it("recevies the location") {
                    expect(result).toEventuallyNot(beNil())
                }
                
                it("takes first location with accuracy belowe 2000m") {
                    expect(result).toEventually(equal(givenLocations[1]))
                }
                
                it("after receving a location should stop next location updates") {
                    expect(geolocationProvider.didStopRecevingLocationUpdates).toEventually(beTrue())
                }
                
                context("when location is cached") {
                    beforeEach() {
                        _ = sut.singleMeLocationUpdate.subscribe(onNext: { _ in }, onError: nil, onCompleted: nil, onDisposed: nil)
                        geolocationProvider.givenLocationSequence = givenLocations
                    }
                
                    it("returns cached location for 2nd observer") {
                        sleep(1)
                        let resultFor2ndObserver = try! sut.singleMeLocationUpdate.toBlocking().first()!
                        expect(resultFor2ndObserver) == givenLocations[1]
                    }
                }
                
                context("when user grand permission for GPS") {
                    beforeEach() {
                        geolocationProvider.givenAuthorizationStatusSubject = .denied
                        geolocationProvider.givenAuthorizationStatusSubject = .authorizedWhenInUse
                    }
                    
                    it("tells geolocation provider to start updating locations") {
                        expect(geolocationProvider.didStartUpdatingLocations) == true
                    }
                }
                
                context("when user come back to the app") {
                    beforeEach() {
                        notificationCenter.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
                    }
                    
                    it("tells geolocation provider to start updating locations") {
                        expect(geolocationProvider.didStartUpdatingLocations) == true
                    }
                }
            }
        }
    }
}
