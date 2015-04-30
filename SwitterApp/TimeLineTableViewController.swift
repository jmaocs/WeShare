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

class TimeLineTableViewController: UITableViewController, UINavigationControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UIImagePickerControllerDelegate {

    
    var timelineData = [PFObject]()
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        self.loginSetup()
    }
    
    var logInViewController: PFLogInViewController! = PFLogInViewController()
    var signUpViewController: PFSignUpViewController! = PFSignUpViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Config for signup
        signUpViewController.fields = (PFSignUpFields.UsernameAndPassword
            | PFSignUpFields.SignUpButton
            | PFSignUpFields.DismissButton)
        
//        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
//            tableView.estimatedRowHeight = tableView.rowHeight
//            tableView.rowHeight = UITableViewAutomaticDimension
//        }
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.loginSetup()
        self.refresh()
        self.navigationItem.title = PFUser.currentUser()?.username
    }
    
    
    
    // loading all sweets from database
    func loadData() {
        
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
    }
    
   

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelineData.count
    }

    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell {
        var cell: SweetTableViewCell = tableView!.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath!) as! SweetTableViewCell
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
    // Image picker
//    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
//        let pickedImage:UIImage = info.objectForKey(UIImagePickerControllerOriginalImage) as! UIImage
//        
//        // Scale down image
//        let scaledImage = self.scaleImageWith(pickedImage, newSize: CGSizeMake(100, 100))
//        
//        let imageData = UIImagePNGRepresentation(pickedImage)
//        let imageFile:PFFile = PFFile(data: imageData)
//        
//        PFUser.currentUser().setObject(imageFile, forKey: "profileImage")
//        PFUser.currentUser().saveInBackground()
//        
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func scaleImageWith(image:UIImage, newSize:CGSize)->UIImage {
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
//        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
//        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return newImage
//    }
//    
//    func imageAction() {
//        var imagePicker:UIImagePickerController = UIImagePickerController()
//        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//        imagePicker.delegate = self
//        println("image")
//        self.presentViewController(imagePicker, animated: true, completion: nil)
//    }
    
    
    /********************************************************************************************/
    
    func loginSetup() {
        if (PFUser.currentUser() == nil) {
            self.logInViewController.fields = PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.SignUpButton | PFLogInFields.PasswordForgotten | PFLogInFields.DismissButton
            
            var logInLogoTitle = UILabel()
            logInLogoTitle.text = "WeShare"
            
            self.logInViewController.logInView.logo = logInLogoTitle
            
            self.logInViewController.delegate = self
            
            var SignUpLogoTitle = UILabel()
            SignUpLogoTitle.text = "WeShare"
            
            self.signUpViewController.signUpView.logo = SignUpLogoTitle
            
            self.signUpViewController.delegate = self
            
            self.logInViewController.signUpController = self.signUpViewController
            self.presentViewController(logInViewController, animated: true, completion: nil)
        }
    }
    

    
    // MARK: Parse Login
    
    func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
        if (!username.isEmpty || !password.isEmpty) {
            return true
        }else {
            return false
        }
        
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController!, didFailToLogInWithError error: NSError!) {
        println("Failed to login...")
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController!) {
        
    }
    
    // MARK: Parse Signup
    
    func signUpViewController(signUpController: PFSignUpViewController!, didSignUpUser user: PFUser!) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    func signUpViewController(signUpController: PFSignUpViewController!, didFailToSignUpWithError error: NSError!) {
        
        println("Failed to sign up...")
        
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController!) {
        
        println("User dismissed sign up.")
        
    }

}
