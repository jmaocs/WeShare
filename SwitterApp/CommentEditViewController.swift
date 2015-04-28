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

    var sweetToReply : PFObject? {
        didSet{
            queryOriginalSweetAuthor(sweetToReply!)
        }
    }
    var commentToReply : PFObject? {
        didSet{
            queryOriginalCommentAuthor(commentToReply!)
        }
    }
    
    func queryOriginalCommentAuthor(comment: PFObject) {
        
        var findCommenter:PFQuery = PFUser.query()
        findCommenter.whereKey("objectId", equalTo: comment.objectForKey("commenter").objectId)
        findCommenter.findObjectsInBackgroundWithBlock {
            (objects:[AnyObject]!, error:NSError!) ->Void in
            if error == nil {
                var user:PFUser = (objects! as  NSArray).lastObject as PFUser
                if let user = (objects! as  NSArray).lastObject as?  PFUser {
                    var tmp = user.username as NSString
                    self.username = "@ \(tmp) "
                }
            }
        }
    }
    
    func queryOriginalSweetAuthor(sweet: PFObject) {
        var findOriginalAuthor:PFQuery = PFUser.query()
        findOriginalAuthor.whereKey("objectId", equalTo: sweet.objectForKey("sweeter").objectId)
        findOriginalAuthor.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!) ->Void in
            if error == nil {
                var user:PFUser = (objects! as  NSArray).lastObject as PFUser
                if let user = (objects! as  NSArray).lastObject as?  PFUser {
                    self.username = "@ \(user.username!) "
                }
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        commentText.delegate = self
        commentText.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.commentText.text = self.username!
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
        comment["commenter"] = PFUser.currentUser()
        if let st = sweetToReply {
            comment["sweet"] = st
        }
        if let ct = commentToReply {
            comment["commentReplied"] = ct
        }
        comment["commenter"] = PFUser.currentUser()
        comment.saveInBackgroundWithTarget(nil, selector: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
