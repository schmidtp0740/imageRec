//
//  ChatMessege.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/13/16.
//  Copyright © 2016 Oracle. All rights reserved.
//

import UIKit

enum BubbleType: Int{
    case mineBubble = 0
    case opponentBubble = 1
    case systemBubble = 2
}

class ChatMessege: NSObject {
    
        var text: String?
        var image: UIImage?
        var date: Date?
        var type: BubbleType
        
        init(text: String?,image: UIImage?,date: Date? , type:BubbleType = .mineBubble) {
            self.text = text
            self.image = image
            self.date = date
            self.type = type
        }
}

