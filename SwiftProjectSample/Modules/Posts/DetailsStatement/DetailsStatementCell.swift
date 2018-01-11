//
//  DetailsStatementCell.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 01.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import KILabel
import SafariServices
import Kingfisher

class DetailsStatementCell: RxTableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var votingView: VotingView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet fileprivate weak var explanationLabel: UILabel!
    @IBOutlet fileprivate weak var sourcesLabel: KILabel!
    @IBOutlet fileprivate weak var sourcesTitleLabel: UILabel!
    
    
    var didTapOnLinkHandler: ( (URL) -> Void )? = nil
    
    var sources: [String] = [] {
        didSet {
            if sources.count > 0 {
                sourcesLabel.isHidden = false
                sourcesTitleLabel.isHidden = false
                sourcesLabel.text = sources.joined(separator: "\n")
                sourcesLabel.urlLinkTapHandler = { label, url, range in
                    if let url = URL(string: url) {
                        self.didTapOnLinkHandler?(url)
                    }
                }
            } else {
                sourcesLabel.isHidden = true
                sourcesTitleLabel.isHidden = true
            }
        }
    }
    
    var explanation: String? {
        didSet {
            if let explanation = explanation {
                explanationLabel.text = explanation
                explanationLabel.isHidden = false
            } else {
                explanationLabel.isHidden = true
            }
        }
    }
}
