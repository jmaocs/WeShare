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
    var countsOfComments : Int?
    
    func loadData() {
        comments.removeAll(keepCapacity: false)
        if let cts = self.sweet?.objectForKey("comments") as?  [PFObject] {
            cts.reverse()
            for each in cts {
                var findComment: PFQuery = PFQuery(className: "Comment")    // load all comments
                findComment.getObjectInBackgroundWithId(each.objectId) {
                    (result: PFObject!, error: NSError!) -> Void in
                    if !(error != nil) {
                        if let res = result {
                            self.comments.append(res)
                            self.countsOfComments = self.comments.count
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func refresh() {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl!)
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        self.loadData()
        sender.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.backItem?.title = "Back"
        self.navigationItem.title = PFUser.currentUser()?.username
    }
    override func viewDidAppear(animated: Bool) {
        self.loadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
            let sweetCell = tableView.dequeueReusableCellWithIdentifier("DetailSweetCell", forIndexPath: indexPath) as! SweetTableViewCell
            sweetCell.sweet = self.sweet!
            if let counts = self.countsOfComments {
                sweetCell.comentCountLabel.text = String(counts)
            } else {
                sweetCell.comentCountLabel.text = String(0)
            }
            return sweetCell
        } else {
            let commentCell = tableView.dequeueReusableCellWithIdentifier("DetailCommentCell", forIndexPath: indexPath) as! DetailCommentTableViewCell
            if (self.comments.count == 0) {
                return commentCell
            }
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
                    cevc.sweetToReply = self.sweet!
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
