//
//  StateOfVoting.swift
//  SwiftSampleCode
//
//  Created by Ada Chmielewska on 22.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit

extension VotingView {
    enum State {
        case unvote, disagree, agree
        
        var frame: CGRect {
            switch  self {
            default:
                return CGRect(x: 0, y: 0, width: 279, height: 48)
            }
        }
        
        var agreeIcon: UIImage? {
            switch self {
            case .unvote:
                return R.image.voteAgree01.image
            case .disagree:
                return R.image.voteAgree03.image
            default:
                return R.image.voteAgree02.image
            }
        }
        
        var disagreeIcon: UIImage? {
            switch self {
            case .unvote:
                return R.image.voteDisagree01.image
            case .disagree:
                return R.image.voteDisagree02.image
            default:
                return R.image.voteDisagree03.image
            }
        }
        
        var alignment: String {
            switch self {
            case .disagree:
                return kCAAlignmentLeft
            case .agree:
                return kCAAlignmentRight
            default:
                return kCAAlignmentLeft
            }
        }
        
        var iconSize: CGSize {
            switch self {
            default:
                return CGSize(width: 18, height: 18)
            }
        }
        
        var swipeableColor: CGColor {
            switch self {
            default:
                return UIColor.projectBluishColor().cgColor
            }
        }
        
        var agreeColor: CGColor {
            switch self {
            case .unvote:
                return UIColor.clear.cgColor
            case .disagree:
                return UIColor.clear.cgColor
            case .agree:
                return UIColor.projectBluishColor().cgColor
            }
        }
        
        var disagreeColor: CGColor {
            switch self {
            case .unvote:
                return UIColor.clear.cgColor
            case .disagree:
                return UIColor.projectBluishColor().cgColor
            case .agree:
                return UIColor.clear.cgColor
            }
        }
        
        var procentageLineColor: CGColor {
            switch self {
            case .disagree:
                return UIColor.projectBluishColor().cgColor
            default:
                return UIColor.projectGrayColor().cgColor
                
            }
        }
        
        var voteLineColor: CGColor {
            switch self {
            case .agree:
                return UIColor.projectBluishColor().cgColor
            default:
                return UIColor.projectGrayColor().cgColor
                
            }
        }
        
        var percentageLineWidth: CGFloat {
            switch self {
            case .unvote:
                return 1
            default:
                return 6
            }
        }
        
        var space: CGFloat {
            switch self {
            case .unvote:
                return 0
            default:
                return 8
            }
        }
        
        var spaceUnvote: CGFloat {
            switch self {
            case .unvote:
                return 8
            default:
                return 0
            }
        }
        
        var spaceVoted: CGFloat {
            switch self {
            case .unvote:
                return 0
            default:
                return 8
            }
        }
    }
}

extension VotingView.State: Equatable {
}

func == (lhs: VotingView.State, rhs: VotingView.State) -> Bool {
    switch (lhs, rhs) {
    case (.unvote, .unvote):
        return true
    case (.agree, .agree):
        return true
    case (.disagree, .disagree):
        return true
    default:
        return false
    }
    
    
}
