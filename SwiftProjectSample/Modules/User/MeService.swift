//
//  MeService.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 17.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation
import RxOptional
class MeService: UserPersistenceRepository {
    let userPersistanceRepository: UserPersistenceRepository
    let geolocationProvider: GeolocationProvider
    var notificationCenter = NotificationCenter.default
    
    fileprivate let meLocationSubjectForCache = ReplaySubject<CLLocation?>.create(bufferSize: 1)
    fileprivate let disposeBag = DisposeBag()
    
    init(withUserPersistanceRepository userPersistanceRepository: UserPersistenceRepository, geolocationProvider: GeolocationProvider) {
        self.userPersistanceRepository = userPersistanceRepository
        self.geolocationProvider = geolocationProvider
    
        observeLocationUpdates()
        defineWhenAsksForLocationsUpdates()
    }
    
    fileprivate func observeLocationUpdates() {
        let nilLocationIfPermissionIsNotGranted = self.geolocationProvider.authorizationStatus
            .filter { status in
                switch status {
                case .notDetermined, .authorizedAlways, .authorizedWhenInUse:
                    return false
                default:
                    return true
                }
            }.map { _ -> CLLocation? in
                return nil
        }
        
        let locationFromGPS = self.geolocationProvider.location
            .filterNotSufficientAccuracy(2000)
            .do(onNext: { _ in self.geolocationProvider.stopReceivingLocationsUpdates()}, onError: nil, onCompleted: nil, onSubscribe: nil, onSubscribed: nil, onDispose: nil)
        
        Observable.of(nilLocationIfPermissionIsNotGranted, locationFromGPS.map { location in return Optional.some(location)})
            .merge()
            .bind(to: self.meLocationSubjectForCache)
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func defineWhenAsksForLocationsUpdates() {
        let hasLocationPermissionsChanged = self.geolocationProvider.authorizationStatus
            .map { status -> Bool in
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    return true
                default:
                    return false
                }
            }.distinctUntilChanged()
        
        let locationHasBeenGrantedFromSettings = hasLocationPermissionsChanged.filter { isPermissionGranted in
                return isPermissionGranted
            }.mapToVoid()
        
        let applicationDidBecomeActive = notificationCenter.rx.notification(NSNotification.Name.UIApplicationDidBecomeActive)
            .mapToVoid()
        
        Observable.of(applicationDidBecomeActive, locationHasBeenGrantedFromSettings).merge()
            .subscribe(onNext: { [unowned self]_ in
                self.geolocationProvider.startUpdatingLocations()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
    
    var singleMeLocationUpdate: Observable<CLLocation?> {
        return meLocationSubjectForCache.asObservable()
    }
    
    var currentUser: Me? {
        return userPersistanceRepository.currentUser
    }
    
    var rx_currentUser: Observable<Me> {
        return userPersistanceRepository.rx_currentUser
    }
    
    func save(_ user: Me) -> Bool {
        return userPersistanceRepository.save(user)
    }
}

extension ObservableType where E == CLLocation {
    func filterNotSufficientAccuracy(_ sufficientAccuracy: Double) -> Observable<CLLocation> {
        return filter { location in
            let max = Swift.max(location.horizontalAccuracy, location.verticalAccuracy)
            return max >= 0 && max < sufficientAccuracy
        }
    }
}
