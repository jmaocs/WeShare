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
    
    @IBOutlet weak var usernameLabel: UILabel! = UILabel()
    
    @IBOutlet weak var makeOrReplyComment: UIButton!
    
  
    @IBOutlet weak var commentTextLabel: UILabel! = UILabel()
    
    
    var comment: PFObject? {
        didSet {
            updateUI()
        }
    }
    
    var editor : PFUser?
    
    func fetchEditor() {
        var findEditor:PFQuery = PFUser.query()
        if let id = self.comment!.objectForKey("editor")?.objectId {
            findEditor.getObjectInBackgroundWithId(id, block: {
                (result :PFObject!,error : NSError!) -> Void in
                if let res = result as? PFUser {
                    self.editor = res
                    self.updateUserInfo()
                }
            })
        }
    }
    
    func updateUserInfo() {
        if let res = self.editor {
            self.usernameLabel.text = res.username
            
            // get profile images
            if let profileImage:PFFile = res.objectForKey("profileImage") as? PFFile {
                profileImage.getDataInBackgroundWithBlock {
                    (imageData:NSData!, error:NSError!)->Void in
                    if !(error != nil) {
                        let image:UIImage = UIImage(data: imageData)!
                        self.avatarImg.image = image
                    }
                }
            } else {
                // get profile images
                if let gender = res.objectForKey("gender") as? NSObject {
                    if (gender == true) {
                        self.avatarImg?.image = UIImage(named: "boy.jpg")
                    } else {
                        self.avatarImg?.image = UIImage(named: "girl.png")
                    }
                } else {
                    self.avatarImg?.image = UIImage(named: "anonymous.png")
                }
            }

            
            updateCommentTextLabel(res)
        }
    }
    
    func updateCommentTextLabel(user: PFUser) {
        // get comment content
        if let contentStr = self.comment?.objectForKey("content") as? String {
            var mutableStr = NSMutableAttributedString(string: contentStr)
            if let username = user.username {
                let coloredStr :NSString = username
                mutableStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: NSRange(location: 0, length: coloredStr.length+1))
            }
            self.commentTextLabel.attributedText = mutableStr
        }
    }
    
    func updateUI() {
        if let comment = self.comment {
            
            // fetch the commenter
            self.fetchEditor()

            // get comment time
            let formatter:NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "MM-dd HH:mm"
            
//            let formatter = NSDateFormatter()
//            if NSDate().timeIntervalSinceDate(comment.createdAt) > 24*60*60 {
//                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
//            } else {
//                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
//            }
            self.timestampLabel.text = formatter.stringFromDate(comment.createdAt)
            
            

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
