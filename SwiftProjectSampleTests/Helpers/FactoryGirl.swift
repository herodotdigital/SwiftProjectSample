//
//  File.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 03.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import SwiftyJSON
import Rswift
import CoreLocation
import Fakery

@testable import SwiftProjectSample

let fakery = Faker()

func json(fromFileNamed name: String) -> JSON? {
    return FactoryGirl.Bundle.testBundle.path(forResource: name, ofType: "json")
        .flatMap { try? NSData(contentsOfFile: $0) as Data }
        .map { try! SwiftyJSON.JSON(data: $0) }
}

func dateInUTC(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date {
    var components = DateComponents()
    components.year   = year
    components.month  = month
    components.day    = day
    components.hour   = hour
    components.minute = minute
    components.second = second
    var calendar =  Calendar(identifier: Calendar.Identifier.iso8601)
    calendar.timeZone = TimeZone(abbreviation: "UTC")!
    let date = calendar.date(from: components)!
    return date
}

struct FactoryGirl {
    class Bundle {
        static var testBundle: Foundation.Bundle {
            return Foundation.Bundle(for: FactoryGirl.Bundle.self)
        }
    }
    
    struct Me {
        static var JSON: SwiftyJSON.JSON {
            let path = Bundle.testBundle.path(forResource: "POST_user-checks_success", ofType: "json")!
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            let json = try! SwiftyJSON.JSON(data:data)
            return json
        }
           
        static var object: SwiftProjectSample.Me {
            let json = Me.JSON
            let imageURL = URL(string: "uploads/user/pictures/733c4asdfasdfb7f4ecb.jpg", relativeTo: Assembly.API.domain)
            return SwiftProjectSample.Me(id: json["id"].int!, username: json["username"].string!, realname: json["real_name"].string, avatarURL:imageURL)
        }

        static var userNotFoundError: SwiftyJSON.JSON {
            return SwiftyJSON.JSON(dictionaryLiteral: ("code", 400), ("description", "user not found"))
        }
    }

    struct UserSnapshot {
        static var object: SwiftProjectSample.UserSnapshot {
            return SwiftProjectSample.MinimalUser(id: fakery.number.increasingUniqueId(), username: fakery.name.firstName(), realname: fakery.name.name(), avatarURL: URL(string: fakery.internet.image())!)
        }
    }
    
    struct API {
        static var unknownError: SwiftyJSON.JSON {
            return SwiftyJSON.JSON(dictionaryLiteral: ("code", 400), ("description", "unknown"))
        }
    }
    
    struct Post {
        static var statementUserInputs: SwiftProjectSample.PostUserInputs {
            return SwiftProjectSample.PostUserInputs(title: fakery.lorem.sentence(wordsAmount: 4), description:fakery.lorem.paragraph(), sources:[
                "http://allinmobile.co",
                "Forbes no 2/2016"
                ], image:UIImage(contentsOfFile: Bundle.testBundle.path(forResource: "imageToUpload", ofType: "png")!))
        }
        
        static var pollUserInputs: SwiftProjectSample.PostUserInputs {
            return SwiftProjectSample.PostUserInputs(title: fakery.lorem.sentence(wordsAmount: 4), description:fakery.lorem.paragraph(), sources:[
                "http://allinmobile.co",
                "Forbes no 2/2016"
                ], image:UIImage(contentsOfFile: Bundle.testBundle.path(forResource: "imageToUpload", ofType: "png")!), answers:[
                    
                ])
        }
        
        static var statement: SwiftProjectSample.Post {
            return SwiftProjectSample.Post(id:3, title: fakery.lorem.sentence(), description: fakery.lorem.paragraph(sentencesAmount: 4), owner: FactoryGirl.UserSnapshot.object, creationDate:Date(), imageURL: URL(string: fakery.internet.image())!, sources: [fakery.internet.domainName()], answers:[
                Answer(id: 2, textRepresentation: "agree", votesCount: 3),
                Answer(id: 4, textRepresentation: "disagree", votesCount: 4)
                ], state: .unvoted)
        }
        
        static var jsonList: SwiftyJSON.JSON {
            let path = Bundle.testBundle.path(forResource: "GET_post_success", ofType: "json")!
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            let json = try! SwiftyJSON.JSON(data:data)
            return json
        }
        
        static var list: [SwiftProjectSample.Post] {
            return [
                SwiftProjectSample.Post(id:334, title: "Should be parsed", description:"Test", owner: MinimalUser(id: 24, username: "maciej_jasica", avatarURL: URL(string:"http://dev.allinmobile.co/swift-project-sample/uploads/user/pictures/9535b0390e69d3dce633fbfd8f7d9b5d59961fbb.png")!), creationDate:dateInUTC(year: 2016, month: 7, day: 20, hour: 16, minute: 37, second: 42), imageURL: URL(string:"http://dev.allinmobile.co/swift-project-sample/uploads/post/images/4fa7ee655a7d52ff5e94a981851aea75d08cf733.jpg")!, sources:[], answers:[
                    Answer(id:656, textRepresentation:"disagree", votesCount:1),
                    Answer(id:657, textRepresentation:"agree", votesCount:2)
                    ], state: .unvoted),
                SwiftProjectSample.Post(id:334, title: "Should be parsed", description:"Test explanation", owner: MinimalUser(id: 24, username: "maciej_jasica", avatarURL: URL(string:"http://dev.allinmobile.co/swift-project-sample/uploads/user/pictures/9535b0390e69d3dce633fbfd8f7d9b5d59961fbb.png")!), creationDate:dateInUTC(year: 2016, month: 7, day: 20, hour: 16, minute: 37, second: 42), imageURL: URL(string:"http://dev.allinmobile.co/swift-project-sample/uploads/post/images/4fa7ee655a7d52ff5e94a981851aea75d08cf733.jpg")!, sources:[], answers:[
                    Answer(id:656, textRepresentation:"disagree", votesCount:1),
                    Answer(id:657, textRepresentation:"agree", votesCount:2)
                    ], state: .voted(answerAtIndex:1)),
                SwiftProjectSample.Post(id:334, title: "Should be parsed", description:"Test", owner: MinimalUser(id: 24, username: "maciej_jasica", avatarURL: URL(string:"http://dev.allinmobile.co/swift-project-sample/uploads/user/pictures/9535b0390e69d3dce633fbfd8f7d9b5d59961fbb.png")!), creationDate:dateInUTC(year: 2016, month: 7, day: 20, hour: 16, minute: 37, second: 42), imageURL: URL(string:"http://dev.allinmobile.co/swift-project-sample/uploads/post/images/4fa7ee655a7d52ff5e94a981851aea75d08cf733.jpg")!, sources: [
                    "http://allinmobile.co/",
                    "http://allinmobile.co"], answers:[
                        Answer(id:647, textRepresentation:"First", votesCount:0),
                        Answer(id:648, textRepresentation:"Sec", votesCount:0),
                        Answer(id:649, textRepresentation:"Third", votesCount:1),
                    ], state: .voted(answerAtIndex: 2))
            ]
        }
    }
    
    struct Geolocation {
        static var location: CLLocation {
            return CLLocation(coordinate: coordinate, altitude: 100, horizontalAccuracy: 100, verticalAccuracy: 100, course: 0, speed: 10, timestamp: Date())
        }
        static var coordinate: CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: 40, longitude: 50)
        }
        
        static func randomLocation(withAccuracy accuracy: Double = Double(arc4random_uniform(1000))) -> CLLocation {
            let randomFrom = { (range: UInt32) -> Double in
                return Double(arc4random_uniform(range))
            }
            return CLLocation(coordinate: CLLocationCoordinate2D(latitude: randomFrom(1000), longitude: randomFrom(1000)), altitude: randomFrom(100), horizontalAccuracy: accuracy, verticalAccuracy: accuracy, course: randomFrom(359), speed: randomFrom(100), timestamp: Date())
        }
    }
    
    struct Comment {
        static var list: [SwiftProjectSample.Comment] {
            return [
                SwiftProjectSample.Comment(id: 1, value: "New comment posted on Wed, 15 Jun 2016 20:02:49 +0200", createdAt: dateInUTC(year: 2016, month: 6, day: 15, hour: 18, minute: 02, second: 51), author: MinimalUser(id: 8, username: "donald_trump", avatarURL: URL(string: "http://dev.allinmobile.co/swift-project-sample/uploads/user/pictures/863b4dd336f50f2fd891436ef8284099d143501f.jpg"))),
                SwiftProjectSample.Comment(id: 2, value: "New comment posted on Wed, 15 Jun 2016 20:10:43 +0200", createdAt: dateInUTC(year: 2016, month: 6, day: 15, hour: 18, minute: 10, second: 44), author: MinimalUser(id: 8, username: "donald_trump", avatarURL: URL(string: "http://dev.allinmobile.co/swift-project-sample/uploads/user/pictures/863b4dd336f50f2fd891436ef8284099d143501f.jpg"))),
                SwiftProjectSample.Comment(id: 3, value: "New comment posted on Wed, 15 Jun 2016 20:41:32 +0200", createdAt: dateInUTC(year: 2016, month: 6, day: 15, hour: 18, minute: 41, second: 32), author: MinimalUser(id: 8, username: "donald_trump", avatarURL: URL(string: "http://dev.allinmobile.co/swift-project-sample/uploads/user/pictures/863b4dd336f50f2fd891436ef8284099d143501f.jpg")))
            ]
        }
        
        static var jsonList: SwiftyJSON.JSON {
            let path = Bundle.testBundle.path(forResource: "GET_post-comments_success", ofType: "json")!
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            let json = try! SwiftyJSON.JSON(data:data)
            return json
        }
    }
}
