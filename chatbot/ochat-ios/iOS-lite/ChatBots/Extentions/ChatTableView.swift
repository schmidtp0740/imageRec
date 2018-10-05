//
//  ChatTableView.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/13/16.
//  Copyright © 2016 Oracle. All rights reserved.
//

import UIKit

extension BubbleView : UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if arrChoices == nil {
            return 0;
        }
        
        return (arrChoices?.count)!;
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        return 28
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "chatBotsCell")
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCellStyle.default, reuseIdentifier:"chatBotsCell")
        }
        
        cell!.accessoryType = UITableViewCellAccessoryType.none
        cell?.selectionStyle = UITableViewCellSelectionStyle.blue
        cell?.textLabel?.textColor = #colorLiteral(red: 0, green: 0.5008062124, blue: 1, alpha: 1)
        cell?.textLabel?.textAlignment = NSTextAlignment.center
        cell!.textLabel!.font = UIFont.boldSystemFont(ofSize: 14);
        cell!.textLabel!.text = arrChoices?.object(at: indexPath.row) as? String;
        cell?.textLabel?.numberOfLines = 0
    
        return cell!;
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kchoiceSelectedOrChatEntered), object: arrChoices?.object(at: indexPath.row) as? String )

        tableView.isUserInteractionEnabled = false;
    }
}
