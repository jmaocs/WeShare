//
//  DetailTableViewController.swift
//  SwitterApp
//
//  Created by Jing on 4/21/15.
//  Copyright (c) 2015 Jing. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    var sweet: PFObject? {
        didSet{
            loadData()
        }
    }
    
    var comments: [PFObject] = []
    var selectedRow: Int?
    
    func loadData() {
        comments.removeAll(keepCapacity: false)
        
        var allComments: [PFObject] = []
        
        var findAllComments: PFQuery = PFQuery(className: "Comment")    // load all comments
        findAllComments.findObjectsInBackgroundWithBlock {
            (objects:[AnyObject]!, error:NSError!) ->Void in
            if error == nil {
                allComments = objects.reverse() as [PFObject]
                for com in allComments {
                    if (com.objectForKey("sweet").objectId == self.sweet!.objectId) {
                        self.comments.append(com)
                    }
                }
                self.tableView.reloadData()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else {
            return self.comments.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let sweetCell = tableView.dequeueReusableCellWithIdentifier("DetailSweetCell", forIndexPath: indexPath) as SweetTableViewCell
            sweetCell.sweet = self.sweet!
            return sweetCell
        } else {
            let commentCell = tableView.dequeueReusableCellWithIdentifier("DetailCommentCell", forIndexPath: indexPath) as DetailCommentTableViewCell
            commentCell.comment = self.comments[indexPath.row]
            commentCell.makeOrReplyComment.addTarget(self, action: "makeOrReplyAction:", forControlEvents: UIControlEvents.TouchUpInside)
            commentCell.makeOrReplyComment.tag = indexPath.row
            return commentCell
        
        }
    }
    
    
    @IBAction func makeOrReplyAction(sender: UIButton) {
        self.performSegueWithIdentifier("Reply Comment", sender: sender)
    }
    
    private struct Storyboard {
        static let ReplyCommentIdentifier = "Reply Comment"
        static let MakeCommentIdentifier = "Make Comment"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.ReplyCommentIdentifier {
            if let cevc = segue.destinationViewController.contentViewController as? CommentEditViewController {
                if let bt = sender as? UIButton {
                    cevc.commentToReply = comments[sender!.tag]
                }
            }
        } else if segue.identifier == Storyboard.MakeCommentIdentifier {
            if let cevc = segue.destinationViewController.contentViewController as? CommentEditViewController {
                if let bt = sender as? UIButton {
                    cevc.sweetToReply = self.sweet!
                }
            }
        }
    }
}


extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController
        } else {
            return self
        }
    }
}
