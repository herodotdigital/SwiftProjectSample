//
//  PostCell.swift
//  SwiftSampleCode
//
//  Created by Ada Chmielewska on 20.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import Kingfisher

class PostCell: RxTableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var ownernameLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    //@IBOutlet weak var voteView: VotingView!
    
    @IBOutlet var postImageAspectConstraint: NSLayoutConstraint!
    
    fileprivate var imageTask: RetrieveImageTask?
}

