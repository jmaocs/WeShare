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
//        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
//            tableView.estimatedRowHeight = tableView.rowHeight
//            tableView.rowHeight = UITableViewAutomaticDimension
//        }
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // loading all sweets from database
    @IBAction func loadData() {
        
        timelineData.removeAll(keepCapacity: false)
        
        // find all sweets
        var findTimelineData:PFQuery = PFQuery(className: "Sweets")
        findTimelineData.findObjectsInBackgroundWithBlock {
            (objects:[AnyObject]!, error:NSError!) ->Void in
            if error == nil {
                self.timelineData = objects.reverse() as [PFObject]
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.loadData()
//        PFUser.logOut()
        
        // create an random user
        PFUser.enableAutomaticUser()
        PFUser.currentUser().username = "Jing"
        PFUser.currentUser().saveInBackground()
        
        var login: PFLogInView
        
        if ((PFUser.currentUser()) == nil) {
            var loginAlert:UIAlertController = UIAlertController(title: "Sign Up / Login", message: "Please sign up or login", preferredStyle:UIAlertControllerStyle.Alert)
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
                let usernameTextfield:UITextField = textFields.objectAtIndex(0) as UITextField
                let passwordTextfield:UITextField = textFields.objectAtIndex(1) as UITextField
                
                var sweeter: PFUser = PFUser()
                sweeter.username = usernameTextfield.text
                sweeter.password = passwordTextfield.text
                
                sweeter.signUpInBackgroundWithBlock{
                    (success:Bool!, error:NSError!) -> Void in
                    if !(error != nil) {
                        println("Sign up successfull")
                    } else {
                        let errorString = error.userInfo!["error"] as NSString
                        println(errorString)
                    }
                }
                
            }))
            self.presentViewController(loginAlert, animated: true, completion: nil)
        }
    }
    
    private struct Storyboard {
        static let CellReuseIdentifier = "Tweet"
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
        let cell: SweetTableViewCell = tableView!.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath!) as SweetTableViewCell
        let sweet:PFObject = self.timelineData[indexPath!.row] as PFObject
        
        
        cell.sweetTextView.alpha = 0
        cell.timestampLabel.alpha = 0
        cell.usernameLabel.alpha = 0
        
        cell.sweetTextView.text = sweet.objectForKey("content") as NSString
        // Configure the cell...
        var findSweeter:PFQuery = PFUser.query()
        
//        let dateFormatter:NSDateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        
        
        let formatter = NSDateFormatter()
        if NSDate().timeIntervalSinceDate(sweet.createdAt) > 24*60*60 {
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        } else {
            formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        }

        
        cell.timestampLabel.text = formatter.stringFromDate(sweet.createdAt)
        findSweeter.whereKey("objectId", equalTo: sweet.objectForKey("sweeter").objectId)
        findSweeter.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!) ->Void in
            if error == nil {
                var user:PFUser = (objects! as  NSArray).lastObject as PFUser
                if let user = (objects! as  NSArray).lastObject as?  PFUser {
                    cell.usernameLabel.text = user.username
                    UIView.animateWithDuration(1, animations: {
                        cell.sweetTextView.alpha = 1
                        cell.timestampLabel.alpha = 1
                        cell.usernameLabel.alpha = 1
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
                                    cell.avatarImg?.image = UIImage(data: imageData!)
                                }
                        }
                    }
                }
            }
        }
        cell.sweet = sweet
        return cell
    }

    
    // MARK: - Navitation
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
//        if identifier == Storyboard.MentionsIdentifier {
//            if let tweetCell = sender as? SweetTableViewCell {
//                if tweetCell.tweet!.hashtags.count + tweetCell.tweet!.urls.count + tweetCell.tweet!.userMentions.count + tweetCell.tweet!.media.count == 0 {
//                    return false
//                }
//            }
//        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Storyboard.DetailIdentifier {
                if let dvc = segue.destinationViewController as? DetailTableViewController {
                    if let tweetCell = sender as? SweetTableViewCell {
                        dvc.cell = tweetCell
                        
                    }
                }
            }
        }
    }

}
