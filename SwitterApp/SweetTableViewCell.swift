//
//  SweetTableViewCell.swift
//  SwitterApp
//
//  Created by Jing on 1/19/15.
//  Copyright (c) 2015 Jing. All rights reserved.
//

import UIKit


class SweetTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel! = UILabel()
    
    @IBOutlet weak var timestampLabel: UILabel! = UILabel()
    
    @IBOutlet weak var avatarImg: UIImageView! = UIImageView()
    
    @IBOutlet weak var comentCountLabel: UILabel!  = UILabel()

    
    @IBOutlet weak var makeComment: UIButton! = UIButton()
    
    @IBOutlet weak var sweetTextLabel: UILabel! = UILabel()

    
    @IBOutlet weak var likesImg: UIImageView!
    
    @IBOutlet weak var likesCountLable: UILabel!
    
    var like = "like.png"
    var dislike = "dislike.png"
    
    var sweet :PFObject? {
        didSet {
            updateUI()
        }
    }
    
    
    
    var editor : PFUser?
    
    func fetchEditor() {
        var findEditor:PFQuery = PFUser.query()
        if let id = self.sweet!.objectForKey("editor")?.objectId {
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
        if let user = self.editor {
            self.usernameLabel.text = user.username
            UIView.animateWithDuration(1, animations: {
                self.sweetTextLabel.alpha = 1
                self.timestampLabel.alpha = 1
                self.usernameLabel.alpha = 1
            })
            
            
            if let profileImage:PFFile = user.objectForKey("profileImage") as? PFFile {
                profileImage.getDataInBackgroundWithBlock {
                    (imageData:NSData!, error:NSError!)->Void in
                    if !(error != nil) {
                        let image:UIImage = UIImage(data: imageData)!
                        self.avatarImg.image = image
                    }
                }
            } else {
                // get profile images
                if let gender = user.objectForKey("gender") as? NSObject {
                    if (gender == true) {
                        self.avatarImg?.image = UIImage(named: "boy.jpg")
                    } else {
                        self.avatarImg?.image = UIImage(named: "girl.png")
                    }
                } else {
                    self.avatarImg?.image = UIImage(named: "anonymous.png")
                }
            }
            
        }
    }
    
    func loadLikes() {
        // load likes count
        if let likesArr = self.sweet?.objectForKey("likes") as? [PFUser]{
            var count = likesArr.count
            self.likesCountLable.text = String(count)
        } else {
             self.likesCountLable.text = String(0)
        }
        
        // load current user like or not
        if (self.isCurUserLike()) {
            self.likesImg.image = UIImage(named: dislike)
        } else {
            self.likesImg.image = UIImage(named: like)
        }
    }
    
    func updateUI() {
   
        self.sweetTextLabel.numberOfLines = 0
        self.sweetTextLabel.alpha = 0
        self.timestampLabel.alpha = 0
        self.usernameLabel.alpha = 0
        
        self.loadLikes()
        
        self.sweetTextLabel?.text = self.sweet!.objectForKey("content") as? String
        // Configure the cell...
        
        
        self.fetchEditor()
   
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        //
//        
//        let formatter = NSDateFormatter()
//        if NSDate().timeIntervalSinceDate(self.sweet!.createdAt) > 24*60*60 {
//            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
//        } else {
//            formatter.timeStyle = NSDateFormatterStyle.ShortStyle
//        }
        
        
        self.timestampLabel.text = formatter.stringFromDate(self.sweet!.createdAt)
    }
    
    
    func likesAction(gesture: UIGestureRecognizer) {
        if let likesImg = gesture.view  as? UIImageView {
            if (self.isCurUserLike()) {     // already liked
                self.sweet?.removeObject(PFUser.currentUser(), forKey: "likes")
                self.likesImg.image = UIImage(named: like)
            } else {
                self.sweet?.addUniqueObject(PFUser.currentUser(), forKey: "likes")
                self.likesImg.image = UIImage(named: dislike)
            }
            
            self.sweet?.saveInBackground()
            
            if let likesArr = self.sweet?.objectForKey("likes") as? [PFUser]{
                var count = likesArr.count
                self.likesCountLable.text = String(count)
            } else {
                self.likesCountLable.text = String(0)
            }
        }
    }
    
    func isCurUserLike() -> Bool{
        if let lks = self.sweet?.objectForKey("likes") as?  [PFObject] {
            for each in lks {
                if let curUser = PFUser.currentUser() {
                    if each.objectId == curUser.objectId {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: "likesAction:")
        likesImg.addGestureRecognizer(tapGesture)
        likesImg.userInteractionEnabled = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
