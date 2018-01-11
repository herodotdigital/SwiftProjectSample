//
//  StatementViewModel
//  SwiftSampleCode
//
//  Created by Adam Borek on 13.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxNimble
import Nimble
import Quick
@testable import SwiftProjectSample

class StatementViewModelSpec: QuickSpec {
    override func spec() {
        describe("StatementViewModel") {
            var sut: StatementViewModel!
            let statement = FactoryGirl.Post.statement
            var postVoter: PostVoterStub!
            
            beforeEach() {
                postVoter = PostVoterStub()
                sut = StatementViewModel(withStatement: statement, postVoter:  postVoter)
            }
            
            it("has ownername") {
                expect(sut.ownername) == statement.owner.username
            }
            
            it("has title") {
                expect(sut.title) == statement.title
            }
            
            it("has imageURL") {
                expect(sut.image) == statement.imageURL
            }
            
            it("has postTime") {
                expect(sut.postTime) == (statement.creationDate as NSDate).timeAgoSinceNow().uppercased()
            }
            
            it("has image") {
                expect(sut.image) == statement.imageURL
            }
            
            it("has explanation") {
                expect(sut.explanation) == statement.description
            }
            
            it("has sources") {
                expect(sut.sources) == statement.sources
            }
            
            it("has state") {
                expect(sut.votingState) == VotingView.State.unvote
            }
            
            describe("voting") {
                pending("on agree") {
                    context("when current state is unvoted") {
                        var unvotedStatement: Post!
                        beforeEach() {
                            unvotedStatement = FactoryGirl.Post.statement
                            unvotedStatement.state = .unvoted
                            sut = StatementViewModel(withStatement: unvotedStatement, postVoter: postVoter)
                            sut.didTapAgree.onNext()
                        }
                        
                        it("changes state to agree") {
                            expect(sut.votingState) == VotingView.State.agree
                        }
                        
                        it("increase agree count by one") {
                            expect(sut.post.answers.last!.votesCount) == unvotedStatement.answers.last!.votesCount + 1
                        }
                        
                    }
                    
                    context("when current state is disagree") {
                        var disagreeStatement: Post!
                        beforeEach() {
                            disagreeStatement = FactoryGirl.Post.statement
                            disagreeStatement.state = .voted(answerAtIndex: 0)
                            sut = StatementViewModel(withStatement: disagreeStatement, postVoter: postVoter)
                            sut.didTapAgree.onNext()
                        }
                        
                        it("changes state to agree") {
                            expect(sut.votingState) == VotingView.State.agree
                        }
                        
                        it("increase agree answer count by one") {
                            expect(sut.post.answers.last!.votesCount) == disagreeStatement.answers.last!.votesCount + 1
                        }
                        
                        it("decrease disagree answer count by one") {
                            expect(sut.post.answers.first!.votesCount) == disagreeStatement.answers.first!.votesCount - 1
                        }
                    }
                }
                
                pending("votes on disagree") {
                    context("when current state is unvoted") {
                        var unvotedStatement: Post!
                        beforeEach() {
                            unvotedStatement = FactoryGirl.Post.statement
                            unvotedStatement.state = .unvoted
                            sut = StatementViewModel(withStatement: unvotedStatement, postVoter: postVoter)
                            sut.didTapDisagree.onNext()
                        }
                        
                        it("changes state to agree") {
                            expect(sut.votingState) == VotingView.State.disagree
                        }
                        
                        it("increase disagree answer count by one") {
                            expect(sut.post.answers.first!.votesCount) == unvotedStatement.answers.first!.votesCount + 1
                        }
                    }
                    
                    context("when current state is agree") {
                        var agreeStatement: Post!
                        beforeEach() {
                            agreeStatement = FactoryGirl.Post.statement
                            agreeStatement.state = .voted(answerAtIndex: 1)
                            sut = StatementViewModel(withStatement: agreeStatement, postVoter: postVoter)
                            sut.didTapDisagree.onNext()
                        }
                        
                        it("changes state to agree") {
                            expect(sut.votingState) == VotingView.State.disagree
                        }
                        
                        it("increase disagree answer count by one") {
                            expect(sut.post.answers.first!.votesCount) == agreeStatement.answers.first!.votesCount + 1
                        }
                        
                        it("decrease agree answer count by one") {
                            expect(sut.post.answers.last!.votesCount) == agreeStatement.answers.last!.votesCount - 1
                        }
                    }
                }
                
                context("when postVoter return an error") {
                    beforeEach() {
                        let statement = FactoryGirl.Post.statement
                        postVoter.shouldFailed = true
                        sut = StatementViewModel(withStatement: statement, postVoter: postVoter)
                        sut.didTapAgree.onNext()
                        sut.didTapDisagree.onNext()
                    }
                    
                    it("should return to unovted state") {
                        var result: VotingView.State!
                        _ = sut.votingState.subscribe(onNext: { state in
                            result = state
                        }, onError: nil, onCompleted: nil, onDisposed: nil)
                
                        expect(result).toEventually(equal(VotingView.State.unvote))
                    }
                }
            }
        }
    }
}
