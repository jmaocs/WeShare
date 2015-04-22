//
//  DetailTableViewController.swift
//  SwitterApp
//
//  Created by Jing on 4/21/15.
//  Copyright (c) 2015 Jing. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
    
    var cell: SweetTableViewCell? {
        didSet{
            loadData()
        }
    }
    var comments: [PFObject] = []
    
    func loadData() {
        comments.removeAll(keepCapacity: false)
        
        var allComments: [PFObject] = []
        
        var findAllComments: PFQuery = PFQuery(className: "Comment")    // load all comments
        findAllComments.findObjectsInBackgroundWithBlock {
            (objects:[AnyObject]!, error:NSError!) ->Void in
            if error == nil {
                allComments = objects.reverse() as [PFObject]
                println(allComments)
                for com in allComments {
                    if (com.objectForKey("sweet").objectId == self.cell?.sweet?.objectId) {
                        self.comments.append(com)
                    }
                }
                self.tableView.reloadData()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if (section == 0) {
            return 1
        } else {
            return self.comments.count
        }

    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let sweetCell = tableView.dequeueReusableCellWithIdentifier("DetailSweetCell", forIndexPath: indexPath) as SweetTableViewCell
            sweetCell.sweetTextView!.text = cell!.sweetTextView.text
            sweetCell.avatarImg!.image = cell!.avatarImg.image
            sweetCell.usernameLabel!.text = cell!.usernameLabel.text
            sweetCell.timestampLabel!.text = cell!.timestampLabel.text
            return sweetCell
        } else {
            let commentCell = tableView.dequeueReusableCellWithIdentifier("DetailCommentCell", forIndexPath: indexPath) as DetailCommentTableViewCell
            commentCell.comment = self.comments[indexPath.row]
            return commentCell
        
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
