//
//  ComposeViewController.swift
//  SwitterApp
//
//  Created by Jing on 1/19/15.
//  Copyright (c) 2015 Jing. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var sweetTextView: UITextView! = UITextView()
    
    @IBOutlet weak var charRemainingLabel: UILabel! = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        sweetTextView.layer.borderColor = UIColor.blackColor().CGColor
        sweetTextView.layer.borderWidth = 0.5
        sweetTextView.layer.cornerRadius = 5
        
        sweetTextView.delegate = self
        
        sweetTextView.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendSweet(sender: AnyObject) {
        var sweet:PFObject = PFObject(className: "Sweets")
        sweet["content"] = sweetTextView.text
        sweet["editor"] = PFUser.currentUser()
        sweet.saveInBackgroundWithTarget(nil, selector: nil)
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    func textView(textView: UITextView,
        shouldChangeTextInRange range: NSRange,
        replacementText text: String) -> Bool {
            var newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
            var remainingChar:Int = 140 - newLength
            charRemainingLabel.text =   "\(remainingChar)"
            return (newLength > 140) ? false : true
    }


}
