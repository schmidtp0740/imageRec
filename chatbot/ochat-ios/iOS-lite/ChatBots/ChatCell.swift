//
//  ChatCell.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/11/16.
//  Copyright © 2016 Oracle. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var imgBubble: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
