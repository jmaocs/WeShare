//
//  SweetTableViewCell.swift
//  SwitterApp
//
//  Created by Jing on 1/19/15.
//  Copyright (c) 2015 Jing. All rights reserved.
//

import UIKit
//import ParseUI

class SweetTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel! = UILabel()
    
    @IBOutlet weak var timestampLabel: UILabel! = UILabel()
    
    @IBOutlet weak var sweetTextView: UITextView! = UITextView()
    
    @IBOutlet weak var avatarImg: UIImageView! = UIImageView()
    
    var sweet :PFObject?
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
