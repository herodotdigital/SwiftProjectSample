//
//  Assembly.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 16.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import CocoaLumberjack

private let kDefaultImagePathKey = "image_path"
private let kDefaultImageKey = "image"

struct Assembly {

    fileprivate static var _fileLogger: DDFileLogger?
    static var fileLogger: DDFileLogger {
        let fileLogger: DDFileLogger = _fileLogger ?? DDFileLogger()
        _fileLogger = fileLogger
        return fileLogger
    }

    struct Dependencies {
        static var userRepository: UserPersistenceRepository {
            return SampleUserPersistenceRepository()
            //return NSUserDefaults.standardUserDefaults()
        }

        fileprivate weak static var _geolocationProvider: GeolocationProvider?
        static var geolocationProvider: GeolocationProvider {
            let geolocationProvider = _geolocationProvider ?? GeolocationProvider()
            _geolocationProvider = geolocationProvider
            return geolocationProvider
        }

        static var localPostsProvider: LocalPostsProvider {
            return LocalPostsProvider(withAPIProvider: Assembly.API.provider(), meService: Assembly.Services.meService, postParser: JSONPostParser())
        }

        static var followingPostsProvider: FollowingPostsProvider {
            return FollowingPostsProvider(withAPIProvider: Assembly.API.provider(), userPersistanceReader: userRepository, postParser: JSONPostParser())
        }
        
        static var hotPostsProvider: HotPostsProvider {
            return HotPostsProvider(withAPIProvider: Assembly.API.provider(), userPersistanceReader: userRepository, postParser: JSONPostParser())
        }

        static var statementUploader: StatementUploader {
            return StatementUploader(withAPIProvider:Assembly.API.provider(), meService: Assembly.Services.meService)
        }

        static var pollUploader: PollUploader {
            return PollUploader(withAPIProvider: Assembly.API.provider(), meService: Assembly.Services.meService)
        }

        static var postVoter: PostVoter {
            return PostVoter(withAPIProvider: Assembly.API.provider(), userPersistanceReader: Assembly.Dependencies.userRepository)
        }

        static var commentsProvider: CommentsProvider {
            return CommentsProvider(withApiProvider: Assembly.API.provider())
        }

        static var commentUploader: CommentUploader {
            return CommentUploader(withApiProvider: Assembly.API.provider(), userReader: userRepository)
        }
    }

    struct Services {
        fileprivate weak static var _meServiceWeakSingleton: MeService?
        static var meService: MeService {
            let meService = _meServiceWeakSingleton ?? MeService(withUserPersistanceRepository: Assembly.Dependencies.userRepository, geolocationProvider: Assembly.Dependencies.geolocationProvider)
            _meServiceWeakSingleton = meService
            return meService
        }

        static var commentsService: CommentsService {
            return CommentsService(withCommentsProvider: Assembly.Dependencies.commentsProvider, commentUploader:  Assembly.Dependencies.commentUploader)
        }
    }

    struct Controllers {
        static var localsVC: PostsListVC {
            let viewModel = PostsListViewModel(withPostsProvider: Assembly.Dependencies.localPostsProvider)
            return PostsListVC(withViewModel: viewModel)
        }
        
        static var hotsVC: PostsListVC {
            let viewModel = PostsListViewModel(withPostsProvider: Assembly.Dependencies.hotPostsProvider)
            return PostsListVC(withViewModel: viewModel)
        }

        static var followingPostsVC: PostsListVC {
            let viewModel = PostsListViewModel(withPostsProvider: Assembly.Dependencies.followingPostsProvider)
            return PostsListVC(withViewModel: viewModel)
        }

        static func detailsStatementVC(withViewModel viewModel: StatementViewModel) -> DetailsStatementVC {
            let vc = DetailsStatementVC(viewModel: DetailsStatementViewModel(withStatementViewModel: viewModel, commentsService: Assembly.Services.commentsService, userReader: Assembly.Dependencies.userRepository))
            return vc
        }
        
        static var addStatementVC: AddStatementVC {
            let viewModel = AddStatementViewModel(withPostUploader: Assembly.Dependencies.statementUploader, userPersistenceReader: Assembly.Dependencies.userRepository)
            return AddStatementVC(withViewModel: viewModel)
        }
        
        static var addPollVC: AddPollVC {
            return AddPollVC(withViewModel: AddPollViewModel(withPostUploader: Assembly.Dependencies.pollUploader, userPersistenceReader: Assembly.Dependencies.userRepository))
        }
    }

    struct API {
        static func provider<T: TargetType>() -> RxAPIProvider<T> {
            let lumberjackPrint = { (separator: String, terminator: String, items: Any...) in
                let message: String = items.reduce("") { agregator, item in
                    return agregator + "\(item)" + separator
                }.appending(terminator)

                DDLogInfo(message)
            }

            return RxAPIProvider<T>(endpointClosure: MoyaUtils.endpointClosure(withAuthorizationToken: "<AUTH TOKEN>"),
                                    stubClosure: MoyaProvider.immediatelyStub,
                                    plugins:[NetworkLoggerPlugin(verbose: true, output: lumberjackPrint)])

        }

        static let domain: URL = URL(string: "http://dev.allinmobile.co/swift-project-sample/")!
        static let baseURL: URL = URL(string: "api/", relativeTo: API.domain)!
        static let dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        static var apiVersion: String {
            return "v1"
        }

        static func parseImageURL(from json: JSON, imagePath: String = kDefaultImagePathKey, imageName: String = kDefaultImageKey) -> URL? {
            let imageURL = json[imagePath].string.flatMap { (imagePath: String) -> URL? in
                var imageEndpoint = imagePath
                if !imageEndpoint.hasSuffix("/") {
                    imageEndpoint = imageEndpoint+"/"
                }
                return URL(string: imageEndpoint, relativeTo: Assembly.API.domain)
                }.flatMap { imageDirectoryURl in
                    return  json[imageName].string.flatMap { imageName in
                        return URL(string: imageName, relativeTo: imageDirectoryURl)
                    }
            }

            return imageURL
        }
    }
}
