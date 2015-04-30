//
//  CommentEditViewController.swift
//  SwitterApp
//
//  Created by Jing on 4/22/15.
//  Copyright (c) 2015 Jing. All rights reserved.
//

import UIKit

class CommentEditViewController: UIViewController,UITextViewDelegate {
    @IBOutlet weak var commentText: UITextView! = UITextView()
    
    var username : NSString?
    var sweetToReply : PFObject?
    var commentToReply : PFObject?
    
    func fetchUsername() {
        if (commentToReply == nil) {
            self.queryEditor(self.sweetToReply!)
        } else {
            self.queryEditor(self.commentToReply!)
        }
    }
    func queryEditor(data: PFObject) {
        var findEditor:PFQuery = PFUser.query()
        if let id = data.objectForKey("editor")?.objectId {
            findEditor.getObjectInBackgroundWithId(id, block: {
                (result :PFObject!,error : NSError!) -> Void in
                if let res = result as? PFUser {
                    self.username = "@\(res.username) \n"
                    
                    //  get comment content
                    if let name = self.username as? String {
                        var mutableStr = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 17.0)!,
                            NSForegroundColorAttributeName:UIColor.blueColor()])
                        self.commentText.attributedText = mutableStr
                    }
                }
            })
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentText.delegate = self
        commentText.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.fetchUsername()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        if((self.presentingViewController) != nil){
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func textViewShouldReturn(textField: UITextField) -> Bool {
        commentText.resignFirstResponder()
        return true
    }

    @IBAction func send(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        saveComment()
    }

    func saveComment() {
        var comment:PFObject = PFObject(className: "Comment")
        comment["content"] = commentText.text
        if let st = sweetToReply {
            comment["sweet"] = st
        }
        if let ct = commentToReply {
            comment["commentReplied"] = ct
        }
        comment["editor"] = PFUser.currentUser()
        self.sweetToReply!.addUniqueObject(comment, forKey: "comments")
        self.sweetToReply?.saveInBackground()
        comment.saveInBackgroundWithTarget(nil, selector: nil)
    }
}
