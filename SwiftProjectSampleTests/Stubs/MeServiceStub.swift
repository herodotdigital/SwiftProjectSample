//
//  MeServiceStub.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 23.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
@testable import SwiftProjectSample
import RxSwift
import CoreLocation

class MeServiceStub: MeService {
    init(withUserPersistanceRepositoryStub stub:UserPersistanceRepositoryStub) {
        super.init(withUserPersistanceRepository: stub, geolocationProvider: GeolocationProviderStub())
    }
    
    var givenLocation: CLLocation? = nil
    override var singleMeLocationUpdate: Observable<CLLocation?> {
        return Observable.deferred {
            return Observable.just(self.givenLocation)
        }
     }
}
