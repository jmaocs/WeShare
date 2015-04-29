//
//  TimeLineTableViewController.swift
//  SwitterApp
//
//  Created by Jing on 1/19/15.
//  Copyright (c) 2015 Jing. All rights reserved.
//

import UIKit
import Foundation
import ParseUI

class TimeLineTableViewController: UITableViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    var timelineData = [PFObject]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        PFUser.logOut()
        
//        PFUser.enableAutomaticUser()    // able to create a random user
        if ((PFUser.currentUser()) == nil) {
            self.createAnAnonymousUser()
        }
        self.refresh()
        
//        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
//            tableView.estimatedRowHeight = tableView.rowHeight
//            tableView.rowHeight = UITableViewAutomaticDimension
//        }
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.loadData()
    }
    
    // loading all sweets from database
    @IBAction func loadData() {
        
        timelineData.removeAll(keepCapacity: false)
        
        // find all sweets
        var findTimelineData:PFQuery = PFQuery(className: "Sweets")
        findTimelineData.findObjectsInBackgroundWithBlock {
            (objects:[AnyObject]!, error:NSError!) ->Void in
            if error == nil {
                if let objArr = objects.reverse() as? [PFObject] {
                    self.timelineData = objArr
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func createAnAnonymousUser() {
        // create an anonymous user
        var user = PFUser()
        user.username = "Jing"
        user.password = "12345"
//        user.setValue(true, forKey: "gender")
        
//        user.signUpInBackgroundWithBlock {
//            (succeeded: Bool?, error: NSError?) -> Void in
//            if let error = error {
//                let errorString = error.userInfo?["error"] as? NSString
//            } else {
//                println("user \(user.username) sign up")
//            }
//        }
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

    
    private struct Storyboard {
        static let MakeCommentIdentifier = "Reply Comment"
        static let AddSweetIdentifier = "Add Sweet"
        static let DetailIdentifier = "Show Detail"
    }
        
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return timelineData.count
    }

    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell {
        var cell: SweetTableViewCell = tableView!.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath!) as SweetTableViewCell
        if (self.timelineData.count == 0) {
            return cell
        }
        let sweet = self.timelineData[indexPath!.row]
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.sweet = sweet
        
        if let comments = sweet.objectForKey("comments") as?  NSArray{
            cell.comentCountLabel.text = String(comments.count)
        } else {
            cell.comentCountLabel.text = String(0)
        }
        
        cell.makeComment.tag = indexPath!.row
        cell.makeComment.addTarget(self, action: "makeOrReplyAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
        
    }

    @IBAction func makeOrReplyAction(sender: UIButton) {
        self.performSegueWithIdentifier("Reply Comment", sender: sender)
    }
    
    // MARK: - Navitation
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == Storyboard.DetailIdentifier {
            if let dvc = segue.destinationViewController as? DetailTableViewController {
                if let tweetCell = sender as? SweetTableViewCell {
                    dvc.sweet = tweetCell.sweet!
                }
            }
        } else if (segue.identifier == Storyboard.MakeCommentIdentifier) {
            if segue.identifier == Storyboard.MakeCommentIdentifier {
                if let cevc = segue.destinationViewController.contentViewController as? CommentEditViewController {
                    if let bt = sender as? UIButton {
                        cevc.sweetToReply = timelineData[sender!.tag]
                    }
                }
            }
        }
       
    }
    
    
    /********************************************************************************************/
    // Log In
    func login() {
        var login: PFLogInView
        var loginAlert:UIAlertController = UIAlertController(title: "Sign Up / Login",
            message: "Please sign up or login", preferredStyle:UIAlertControllerStyle.Alert)
        
        loginAlert.addTextFieldWithConfigurationHandler({
            textfield in
            textfield.placeholder = "Your username"
        })
        
        loginAlert.addTextFieldWithConfigurationHandler({
            textfield in
            textfield.placeholder = "Your password"
            textfield.secureTextEntry = true
        })
        
        loginAlert.addAction(UIAlertAction(title: "Sign Up", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            
            let textFields:NSArray = loginAlert.textFields! as NSArray
            if let usernameTextfield:UITextField = textFields.objectAtIndex(0) as? UITextField {
                if let passwordTextfield:UITextField = textFields.objectAtIndex(1) as? UITextField {
                    var sweeter: PFUser = PFUser()
                    sweeter.username = usernameTextfield.text
                    sweeter.password = passwordTextfield.text
                    sweeter.signUpInBackgroundWithBlock
                    {
                        (succeeded:Bool!, error:NSError!) -> Void in
                        if !(error != nil) {
                            println("Sign up successfull")
                        } else {
                            if let errorString = error.userInfo!["error"] as? NSString {
                                println(errorString)
                            }
                        }
                        
                    }
                }
            }
            
         }))
        
        self.presentViewController(loginAlert, animated: true, completion: nil)
    }


}
