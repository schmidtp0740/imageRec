//
//  CBManager.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/16/16.
//  Copyright © 2016 Oracle. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation
import Speech

let kIsBotsSpeakerON  = "isBotsSpeakerON"
let kNewMessegeReceived = "newMessegeReceived"
let kchoiceSelectedOrChatEntered = "choiceSelectedOrChatEntered"
let kBaseURL = "baseURLWSServer" // localhost:8888
let kWebhookChannelID = "WebhookChannelID"
let kBotName = "botName"

class CBManager: NSObject, WebSocketDelegate {
    
    let notifRequestIdentifier = "WSMessegeNotif" // identifier is to cancel the notification request

    static let sharedInstance = CBManager()
    var socket:WebSocket?
    var manualDC:Bool?
    let audioEngine = AVAudioEngine()
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var synth:AVSpeechSynthesizer?;

    func establishConnection( host:String, userName:String ) -> Void {

        if( host.range(of: "://")?.isEmpty == false ){
            let _host:String = host.substring(from: (host.range(of: "://")?.upperBound)!)
            socket = WebSocket(url: URL(string: "ws://\(_host)/chat/ws?user=\(userName)")!, protocols: [])
        }
        else {
            socket = WebSocket(url: URL(string: "ws://\(host)/chat/ws?user=\(userName)")!, protocols: [])
        }

        socket?.delegate = self;
        socket?.connect()
        manualDC = false;
    }
    
    func randomString(length: Int) -> String {

        let letters : NSString = "abcdefghijklmnopqrstuvwxyzJNV123456789"
        var randomString = "ABCDEF"
        let len = UInt32(letters.length)
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func filterWebHookChannels(arrAllChannels:NSArray?) -> NSArray? {
        
        let arrWebHookChannels:NSMutableArray? = NSMutableArray.init(capacity: 1)
        
        for aChannel in arrAllChannels! {
            
            print("aChannel = ", aChannel)
            
            let aChannelDict:NSDictionary = aChannel as! NSDictionary;
            let config:NSDictionary = aChannelDict.object(forKey: "config") as! NSDictionary
            let type:String? = config.object(forKey: "type") as? String;
            if type != nil && type == "webhook" {
                arrWebHookChannels?.add(aChannelDict);
            }
        }
        
        return arrWebHookChannels
    }

    func disconnectWS () -> Void {
        manualDC = true;
        socket?.disconnect()
    }
    
    //MARK:- Send/Recieve Chat
    
    func sendChat( chatMessege:String ) -> Void {
        socket?.write(string: chatMessege);
    }
   
    func playBotsReply (chatMessege: NSDictionary? ) -> Void {
        
        var body:NSDictionary? = chatMessege?.object(forKey: "body") as? NSDictionary;
        
        if( body == nil ){
            let err:NSDictionary? = chatMessege?.object(forKey: "error") as? NSDictionary;
            if( err == nil ){
                // OLD ChatServer parser.
                body = chatMessege;
            }
        }
        
        // Play a messege if avaialble
        if( body != nil ){
            
            let utterance = AVSpeechUtterance(string: body?.object(forKey: "text") as! String)
            synth = AVSpeechSynthesizer()
            synth?.speak(utterance)
            
            if( body?.object(forKey: "choices") != nil ){
                let arrChoices:NSArray = body?.object(forKey: "choices") as! NSArray
                for aWord in arrChoices {
                    let utterance = AVSpeechUtterance(string: aWord as! String)
                    synth?.speak(utterance)
                }
            }
        }
    }
    
    func messegeRecieved ( chatMessege:NSDictionary? ) -> Void {
        
        if chatMessege == nil {
            print("received nil messege");
        }
        else{
            
            if ( UserDefaults.standard.bool(forKey: kIsBotsSpeakerON) == true ) {
                
                if audioEngine.isRunning {
                    audioEngine.stop()
                }
                recognitionRequest?.endAudio()
                if( audioEngine.inputNode != nil ){
                    audioEngine.inputNode?.removeTap(onBus: 0)
                }

                playBotsReply(chatMessege: chatMessege);
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNewMessegeReceived), object: chatMessege as! [String: AnyObject])
        }
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    // MARK: Websocket Delegate Methods
    public func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
    }
    
    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        if manualDC == true {
            print("websocket disconnected mannually")
            return;
        }
        
        if let e = error {
            
            print("websocket is disconnected: \(e.localizedDescription)")
            let strChat:String = "{\"error\":{\"messege\": \"Websocket disconnected from server with Error: \"\(e.localizedDescription)\"}}"
            print(strChat);

        } else {

            print("websocket disconnected")
            let strChat:String = "{\"error\":{\"messege\": \"Websocket disconnected\"}}"
            print(strChat);
            
            // Try to re-establish a connection
            let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate;
            appDel.establishWSConnection();
        }
    }
    
    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("Received text: \(text)")
        messegeRecieved(chatMessege: convertStringToDictionary(text: text) as NSDictionary?);

        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate;
        let tabBar:UITabBarController = appDel.window?.rootViewController as! UITabBarController
        if ( tabBar.selectedIndex != 0
            || appDel.isRunningInBG == true ) {
            showLocalNotification(msg: (convertStringToDictionary(text: text) as NSDictionary?)!);
        }
    }
    
    public func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("Received data: \(data.count)")
    }
    
    //MARK:- Local Notification
    public func showLocalNotification(msg:NSDictionary) {
        
        let content = UNMutableNotificationContent()
        content.title = "New messege!"
        
        var body:NSDictionary? = msg.object(forKey: "body") as? NSDictionary;
        if( body == nil ){
            let err:NSDictionary? = msg.object(forKey: "error") as? NSDictionary;
            if( err == nil ){
                // OLD ChatServer parser.
                body = msg;
            }
        }
        
        // Construct local notification messege for user.
        var strBody:String!
        if( body?.object(forKey: "choices") != nil ){
            strBody = body?.object(forKey: "text") as! String
            strBody.append("\n[ ")
            let arr:NSArray = body?.object(forKey: "choices") as! NSArray!
            var index:Int = 0;
            for option in arr {
                if index != 0 {
                    strBody.append(" | ")
                }
                index+=1;
                strBody.append( option as! String )
            }
            strBody.append(" ]")
            
        }
        else{
            strBody = body?.object(forKey: "text") as! String
        }
        content.body = strBody;
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "InputTxtCategory";
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        
        let request = UNNotificationRequest(identifier: notifRequestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Error requesting local notification: \(error)")
            }
        }
    }
}

extension CBManager:UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
       switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "inputNotif":
            let txt = response.value(forKey: "userText") as! String?
            print(response.value(forKey: "userText") ?? "");
            NotificationCenter.default.post(name: Notification.Name(rawValue: kchoiceSelectedOrChatEntered), object: txt )

        default:
            print("Unknown action")
        }
        completionHandler()
    }
    
    // Callback to present notification, while the app is still in foreground mode.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Standard notification with alert/sound/badge.
        if notification.request.identifier == notifRequestIdentifier{
            completionHandler( [.alert,.sound,.badge])
        }
    }
}

