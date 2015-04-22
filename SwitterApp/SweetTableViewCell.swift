//
//  SweetTableViewCell.swift
//  SwitterApp
//
//  Created by Jing on 1/19/15.
//  Copyright (c) 2015 Jing. All rights reserved.
//

import UIKit
//import ParseUI

class SweetTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel! = UILabel()
    
    @IBOutlet weak var timestampLabel: UILabel! = UILabel()
    
    @IBOutlet weak var sweetTextView: UITextView! = UITextView()
    
    @IBOutlet weak var avatarImg: UIImageView! = UIImageView()
    
    var sweet :PFObject? {
        didSet {
            updateUI()
        }
    }

    func updateUI() {
        self.sweetTextView.alpha = 0
        self.timestampLabel.alpha = 0
        self.usernameLabel.alpha = 0
        
        self.sweetTextView.text = self.sweet!.objectForKey("content") as NSString
        // Configure the cell...
        var findSweeter:PFQuery = PFUser.query()
        
        //        let dateFormatter:NSDateFormatter = NSDateFormatter()
        //        dateFormatter.dateFormat = "yyyy-MM-dd"
        //
        
        let formatter = NSDateFormatter()
        if NSDate().timeIntervalSinceDate(self.sweet!.createdAt) > 24*60*60 {
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        } else {
            formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        }
        
        
        self.timestampLabel.text = formatter.stringFromDate(self.sweet!.createdAt)
        findSweeter.whereKey("objectId", equalTo: self.sweet!.objectForKey("sweeter").objectId)
        findSweeter.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!) ->Void in
            if error == nil {
                var user:PFUser = (objects! as  NSArray).lastObject as PFUser
                if let user = (objects! as  NSArray).lastObject as?  PFUser {
                    self.usernameLabel.text = user.username
                    UIView.animateWithDuration(1, animations: {
                        self.sweetTextView.alpha = 1
                        self.timestampLabel.alpha = 1
                        self.usernameLabel.alpha = 1
                    })
                    
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

    
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
