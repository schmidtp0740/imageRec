//
//  SettingsVC.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/11/16.
//  Copyright © 2016 Oracle. All rights reserved.
//

import UIKit

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

class SettingsVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var switchBotSpeaker: UISwitch!
    @IBOutlet weak var txtURL: UITextField!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var txtUsername: UITextField!
    
    @IBOutlet weak var txtBotname: UITextField!
    @IBOutlet weak var txtChannelId: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtURL.delegate = self
        txtChannelId.delegate = self
        txtBotname.delegate = self

        lblVersion.text = "Build: ".appending(Bundle.main.buildVersionNumber!)
    }

    override func viewWillAppear(_ animated: Bool){

        super.viewWillAppear(animated);
        
        txtURL.text = UserDefaults.standard.object(forKey: kBaseURL) as? String
        txtChannelId.text = UserDefaults.standard.object(forKey: kWebhookChannelID) as? String
        txtBotname.text = UserDefaults.standard.object(forKey: kBotName) as? String
        if ( UserDefaults.standard.bool(forKey: kIsBotsSpeakerON) == true ) {
            switchBotSpeaker.isOn = true
        }
        else{
            switchBotSpeaker.isOn = false
        }
    }

    override func viewWillDisappear(_ animated: Bool){

        super.viewWillDisappear(animated);

    }
    @IBAction func switchChange(_ sender: Any) {

        let aSwitch:UISwitch = sender as! UISwitch;

        if( aSwitch.isOn ){
            print("Switching ON speaker for Bot's reply");
            UserDefaults.standard.set(true, forKey: kIsBotsSpeakerON);
        }
        else{
            print("Switching OFF speaker for Bot's reply");
            UserDefaults.standard.set(false, forKey: kIsBotsSpeakerON);
        }
        
        UserDefaults.standard.synchronize()

    }
    
    @IBAction func btnSaveTapped(_ sender: Any) {
        
        txtURL.resignFirstResponder()
        txtChannelId.resignFirstResponder()
        txtBotname.resignFirstResponder()
        
        let alert = UIAlertController(title: "Success!", message: "Please restart the app now.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        saveCredentials()
    }
    
    func saveCredentials() {
        
        let defaults = UserDefaults.standard
        defaults.set(txtURL.text, forKey: kBaseURL)
        defaults.set(txtChannelId.text, forKey: kWebhookChannelID)
        defaults.set(txtBotname.text, forKey: kBotName)
        defaults.synchronize()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
