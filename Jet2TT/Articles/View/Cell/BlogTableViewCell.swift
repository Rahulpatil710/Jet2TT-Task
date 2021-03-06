//
//  BlogTableViewCell.swift
//  Jet2TT
//
//  Created by Rahul Patil on 11/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import UIKit

class BlogTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = profileImageView.bounds.width/2
            profileImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var profileActivityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var designationLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var mediaActivityIndicator: UIActivityIndicatorView!


    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.autoresizingMask = .flexibleHeight
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(_ blog: BlogItem) {
        nameLabel.text = blog.userName ?? ""
        designationLabel.text = blog.designation ?? ""
        
        timeLabel.text = (blog.time ?? "").getDate()?.timeAgoDisplay() ?? ""
        
        contentLabel.text = blog.content ?? ""
        titleLabel.text = blog.title ?? ""
        urlLabel.text = blog.url ?? ""
        
        likeLabel.text = "\(blog.likes.formatCounts()) Likes"
        commentLabel.text = "\(blog.comments.formatCounts()) Comments"
        
        mediaView.isHidden = !blog.isMediaPresent
        mediaImageView.isHidden = !blog.isMediaPresent
        titleLabel.isHidden = !blog.isMediaPresent
        urlLabel.isHidden = !blog.isMediaPresent
    }
}
