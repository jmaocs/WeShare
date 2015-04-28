//
//  DetailCommentTableViewCell.swift
//  SwitterApp
//
//  Created by Jing on 4/21/15.
//  Copyright (c) 2015 Jing. All rights reserved.
//

import UIKit

class DetailCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImg: UIImageView! = UIImageView()

    @IBOutlet weak var timestampLabel: UILabel! = UILabel()

    @IBOutlet weak var commentText: UITextView! = UITextView()
    
    @IBOutlet weak var usernameLabel: UILabel! = UILabel()
    
    @IBOutlet weak var makeOrReplyComment: UIButton!
    
  
    
    
    var comment: PFObject? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        if let comment = self.comment {
            
            // fetch the commenter
            var findCommenter:PFQuery = PFUser.query()
            findCommenter.whereKey("objectId", equalTo: comment.objectForKey("commenter").objectId)
            findCommenter.findObjectsInBackgroundWithBlock{
                (objects:[AnyObject]!, error:NSError!) ->Void in
                if error == nil {
                    var user:PFUser = (objects! as  NSArray).lastObject as PFUser
                    if let user = (objects! as  NSArray).lastObject as?  PFUser {
                        self.usernameLabel.text = user.username
                        
                        // get profile images
                        var profileImageURL: NSURL?
                        if (user.objectForKey("gender") as NSObject == true) {  // male
                            profileImageURL = NSURL(string: "http://images.clipartpanda.com/sad-boy-clipart-little-boy-clip-art-9932.jpg")
                        } else {
                            profileImageURL =  NSURL(string: "http://fc08.deviantart.net/fs70/f/2013/043/6/4/dynasty_warriors_8_wang_yuanji_avatar_icon_by_mayahabee-d5uqwgp.png")
                        }
                        dispatch_async(dispatch_get_global_queue(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 ? Int(QOS_CLASS_USER_INITIATED.value) : DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                            let imageData = NSData(contentsOfURL: profileImageURL!)
                            dispatch_async(dispatch_get_main_queue()) {
                                if imageData != nil {
                                    self.avatarImg?.image = UIImage(data: imageData!)
                                }
                            }
                        }
                    }

                }
            }

            
            
            // get comment time
//            let dateFormatter:NSDateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(comment.createdAt) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            self.timestampLabel.text = formatter.stringFromDate(comment.createdAt)
            
            // get comment content
            self.commentText.text = comment.objectForKey("content") as NSString
            
            
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
