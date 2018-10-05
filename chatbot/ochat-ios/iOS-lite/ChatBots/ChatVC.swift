//
//  ChatVC.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/11/16.
//  Copyright © 2016 Oracle. All rights reserved.
//

import UIKit
import Speech

open class ChatVC: UIViewController, UITextFieldDelegate, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var txtChat: UITextView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnVoice: UIButton!
    @IBOutlet weak var chatScrollView: UIScrollView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var floorConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewRecord: UIView!
    @IBOutlet weak var btnRecordHold: UIButton!
    
    var typingImgView:UIImageView?
    
    var selectedImage : UIImage?
    var lastChatBubbleY: CGFloat = 9.9
    var internalPadding: CGFloat = 9.9
    var lastMessageType: BubbleType?
    var sendTapped:Bool = false
    
    var originalSize:CGSize?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    //private var CBManager.sharedInstance.recognitionRequest: SFSpeechAudioBufferCBManager.sharedInstance.recognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = CBManager.sharedInstance.audioEngine;
        
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationItem.title = UserDefaults.standard.object(forKey: kBotName) as? String;

        //   txtChat.delegate = self;
        self.txtChat.layer.borderWidth = 0.9
        self.txtChat.layer.borderColor = UIColor.lightGray.cgColor;
        self.txtChat.layer.cornerRadius = 10.0
        
        originalSize = self.chatScrollView.contentSize

        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.txtChat.becomeFirstResponder();
        self.viewRecord.isHidden = true
        //        self.btnRecordHold.setBackgroundImage(UIImage.init(named: "micEnabled.png") , for: UIControlState.highlighted)
        self.btnRecordHold.setImage(UIImage.init(named: "micEnabled.png") , for: UIControlState.highlighted)
        self.btnRecordHold.setImage(UIImage.init(named: "mic.png") , for: UIControlState.normal)
        self.btnRecordHold.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.handleNewMessege(_:)), name: NSNotification.Name(rawValue: kNewMessegeReceived), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.sendAndAddMyChat(_:)), name: NSNotification.Name(rawValue: kchoiceSelectedOrChatEntered), object: nil)
        
        moveScrollView(constant: 5.0)
    }
    
    func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        lockOrientation(.all)
    }
    
    @IBAction func resetTapped(_ sender: Any) {
   
        CBManager.sharedInstance.synth?.stopSpeaking(at: .immediate);
        CBManager.sharedInstance.synth = nil;

        print("Resetting current chat")
        
        if audioEngine.isRunning {
            audioEngine.stop()
            CBManager.sharedInstance.recognitionRequest?.endAudio()
            btnVoice.isEnabled = true
            btnVoice.setBackgroundImage(UIImage.init(named: "mic.png"), for: UIControlState.normal)
            if( audioEngine.inputNode != nil ){
                audioEngine.inputNode?.removeTap(onBus: 0)
            }
        }
        
        self.txtChat.text = ""
        
        for aView:UIView in self.chatScrollView.subviews {
            aView.removeFromSuperview()
        }
        
        self.chatScrollView.contentSize = originalSize!
        
        moveToLastMessage()
        
        let defaults = UserDefaults.standard
        let rStr = CBManager.sharedInstance.randomString(length: 6);
        defaults.set(rStr, forKey: "username")
        defaults.synchronize()
        
        CBManager.sharedInstance.disconnectWS()
        
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate;
        appDel.establishWSConnection();
        
        txtChat.resignFirstResponder()
    }
   
    func convertStringToDictionary(json: String) -> NSDictionary? {
       
        if let data = json.data(using: String.Encoding.utf8) {

                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments)
                    
                    //Store response in NSDictionary for easy access
                    let dict = parsedData as? NSDictionary
                    
                    return dict;
                    
                }
                    //else throw an error detailing what went wrong
                catch let error as NSError {
                    print("Details of JSON parsing error:\n \(error)")
                }
            }
        
        return nil
    }
    
    func handleNewMessege(_ notification: Notification) {
        
        let chatMessege = notification.object as! NSDictionary
        
        let arrChoices:NSArray?
        
        let map:NSDictionary?
        
        var body:NSDictionary? = chatMessege.object(forKey: "body") as? NSDictionary;
        if( body == nil ){
            
            let err:NSDictionary? = chatMessege.object(forKey: "error") as? NSDictionary;
            if( err != nil ){
                addBotChatBubble(txt: err?.object(forKey: "message") as! String,
                                 choices: nil, map: nil);
                
                return; // EXIT here.
            }
            else{
                
                // OLD ChatServer parser.
                body = chatMessege;
            }
        }
        
        arrChoices = body?.object(forKey: "choices") as! NSArray?;
        
        map = convertStringToDictionary(json: body?.object(forKey: "text") as! String);
        
        if ( arrChoices != nil ) {
            
            if ( map != nil ){
                addBotChatBubble(txt: "",
                                 choices: arrChoices, map: map);
            }
            else{
                
                addBotChatBubble(txt: body?.object(forKey: "text") as! String,
                                 choices: arrChoices, map: map);
            }
        }
        else if( body != nil ){
            
            if ( map != nil ){
                addBotChatBubble(txt: "",
                                 choices: arrChoices, map: map);
            }
            else{
                addBotChatBubble(txt: body?.object(forKey: "text") as! String,
                                 choices: nil, map: nil);
            }
        }
    }
    
    func sendAndAddMyChat(_ notification: Notification) -> Void {
        
        let chat = notification.object as! NSString

        sendChatToBot(channelID: UserDefaults.standard.object(forKey: kWebhookChannelID) as! String, chat: chat as String);
        
        addMineChatBubble(txt: chat as String);
    }
    
    func handleChoiceTap(_ notification: Notification) {
        
        let selectedOption = notification.object as! NSString
        print(selectedOption);
        
        sendAndAddMyChat(notification);
    }

    
    func sendChatToBot( channelID:String, chat:String ) -> Void {
        
        let strChat:String = "{\"to\":{\"type\": \"bot\",\"id\": \"\(channelID)\"}, \"text\":\"\(chat)\"}"
       
        print(strChat)
        
        CBManager.sharedInstance.sendChat(chatMessege: strChat);
    }
    
    func moveScrollView( constant:CGFloat ){
        
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.floorConstraint.constant = constant;
            
        }, completion: { (completed: Bool) -> Void in
            self.moveToLastMessage()
        })
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if( self.viewRecord.isHidden == false ){
            self.viewRecord.isHidden = true
        }

        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        moveScrollView(constant: keyboardFrame.size.height - 44)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        moveScrollView(constant: 5.0)
    }
    
    @IBAction func btnSendClicked(_ sender: AnyObject) {
        
        txtChat.resignFirstResponder()
        
        if( self.viewRecord.isHidden == false ){
            self.viewRecord.isHidden = true
            moveScrollView(constant: 5.0)
        }

        if audioEngine.isRunning {

            sendTapped = true

            audioEngine.stop()
            CBManager.sharedInstance.recognitionRequest?.endAudio()
            btnVoice.isEnabled = true
            btnVoice.setBackgroundImage(UIImage.init(named: "mic.png"), for: UIControlState.normal)
            if( audioEngine.inputNode != nil ){
                audioEngine.inputNode?.removeTap(onBus: 0)
            }
        }

        if ( txtChat.text.characters.count > 0 ){
            let strChat:String = txtChat.text;
            txtChat.text = "";
            sendChatToBot(channelID: UserDefaults.standard.object(forKey: kWebhookChannelID) as! String, chat: strChat);
            self.addMineChatBubble(txt: strChat)
        }
    }
    
    func addTypingIcon() -> Void {
        
        // If already added, remove it first.
        typingImgView?.removeFromSuperview()

        let startY = self.lastChatBubbleY + 10

        var aFrame:CGRect = BubbleView.framePrimary(BubbleType.opponentBubble , startY: startY)
        aFrame.size.height = 40
        aFrame.size.width = 66
        typingImgView = UIImageView.init(frame: aFrame)

        var images: [UIImage] = []
        for i in 1...3 {
            images.append(UIImage(named: "typing_indicators_\(i)")!)
        }
        typingImgView?.animationImages = images
        typingImgView?.animationDuration = 1.0
        typingImgView?.startAnimating()
        self.chatScrollView.addSubview(typingImgView!)
    }
    
    func addMineChatBubble( txt:String ) {
        
        let bubbleData = ChatMessege(text: txt, image: selectedImage, date: Date(), type: BubbleType.mineBubble )
        addChatBubble(bubbleData, choices: nil, map:nil )
    }
    
    func addBotChatBubble( txt:String, choices:NSArray?, map:NSDictionary? ) {
        
        let bubbleData = ChatMessege(text: txt, image: selectedImage, date: Date(), type: BubbleType.opponentBubble )
        
        addChatBubble(bubbleData, choices: choices, map: map)
    }
    
    func addChatBubble(_ data: ChatMessege, choices:NSArray?, map:NSDictionary? ) {
        
        let padding:CGFloat = lastMessageType == data.type ? internalPadding/3.0 :  internalPadding
        
        DispatchQueue.main.async {
            
            let chatBubble = BubbleView(data: data, startY:self.lastChatBubbleY + padding + 1, choices: choices, map: map)
            
            self.chatScrollView.addSubview(chatBubble)
            
            self.lastChatBubbleY = chatBubble.frame.maxY
            
            self.chatScrollView.contentSize = CGSize(width: self.chatScrollView.frame.width, height: self.lastChatBubbleY + self.internalPadding)
            self.moveToLastMessage()
            self.lastMessageType = data.type
            self.txtChat.text = ""
            
            print("bubble added");
            self.btnVoice.isEnabled = true
            
            if( data.type == BubbleType.mineBubble ){
                // Add typing icon
                self.addTypingIcon()
            }
            else{
                // Remove typing icon
                self.typingImgView?.removeFromSuperview()
                self.typingImgView = nil
            }
        }
    }
    
    func moveToLastMessage() {
        
        if chatScrollView.contentSize.height > chatScrollView.frame.height {
            let contentOffSet = CGPoint(x: 0.0, y: chatScrollView.contentSize.height - chatScrollView.frame.height)
            self.chatScrollView.setContentOffset(contentOffSet, animated: true)
        }
    }
    
    // MARK: - delegate methods
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Send button clicked
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK:- Speech
    override open func viewDidAppear(_ animated: Bool) {
        lockOrientation(.portrait)

        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.btnVoice.isEnabled = true
                    
                case .denied:
                    self.btnVoice.isEnabled = false
                   // self.btnVoice.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.btnVoice.isEnabled = false
                   // self.btnVoice.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.btnVoice.isEnabled = false
                   // self.btnVoice.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        CBManager.sharedInstance.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        btnVoice.setBackgroundImage(UIImage.init(named: "micEnabled.png"), for: UIControlState.normal)
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = CBManager.sharedInstance.recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        CBManager.sharedInstance.recognitionRequest?.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            DispatchQueue.main.async {
                
                if let result = result {
                    
                    if ( self.sendTapped == false ){
                        self.txtChat.text = result.transcriptions.first?.formattedString
                    }
                    // self.txtChat.placeholder = "type here.."
                    isFinal = result.isFinal
                    if isFinal == true {
                        self.sendTapped = false;
                    }
                }
                
                if error != nil || isFinal {
                    
                    if self.audioEngine.isRunning {
                        self.audioEngine.stop()
                    }
                    
                    inputNode.removeTap(onBus: 0)
                    
                    CBManager.sharedInstance.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                    self.btnVoice.isEnabled = true
                    self.btnVoice.setBackgroundImage(UIImage.init(named: "mic.png"), for: UIControlState.normal)
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            CBManager.sharedInstance.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        txtChat.text = "";
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            btnVoice.isEnabled = true
           // btnVoice.setTitle("Start Recording", for: [])
        } else {
            btnVoice.isEnabled = false
          // btnVoice.setTitle("Recognition not available", for: .disabled)
        }
    }
    
    
    @IBAction func btnRecordDown(_ sender: Any) {
        
        CBManager.sharedInstance.synth?.stopSpeaking(at: .immediate);
        CBManager.sharedInstance.synth = nil;
        
        try! startRecording()
    }
    
    @IBAction func btnRecordUp(_ sender: Any) {
        
        if audioEngine.isRunning {
            
            self.txtChat.resignFirstResponder()
            
            audioEngine.stop()
            CBManager.sharedInstance.recognitionRequest?.endAudio()
            if( audioEngine.inputNode != nil ){
                audioEngine.inputNode?.removeTap(onBus: 0)
            }
        }
    }
    
    
    @IBAction func recordButtonTapped() {
        
        txtChat.resignFirstResponder()
        
        if( ScreenSize.SCREEN_WIDTH == 320
            ||  ScreenSize.SCREEN_HEIGHT == 320 ) {
            
            print("smaller device");
            if audioEngine.isRunning {
                self.btnVoice.setImage(UIImage.init(named: "mic.png"), for: UIControlState.normal)
                btnRecordUp(btnVoice);

            }
            else{
                
                self.btnVoice.setImage(UIImage.init(named: "micEnabled.png"), for: UIControlState.normal)
                btnRecordDown(btnVoice);
            }
        }
        else{
            
            if( self.viewRecord.isHidden == false ){
                
                self.viewRecord.isHidden = true
                moveScrollView(constant: 5.0)
            }
            else{
                
                self.viewRecord.isHidden = false
                
                moveScrollView(constant: self.viewRecord.frame.height + 5 )
            }
        }
        /*
         if audioEngine.isRunning {
         
            self.txtChat.resignFirstResponder()

            audioEngine.stop()
            CBManager.sharedInstance.recognitionRequest?.endAudio()
            if( audioEngine.inputNode != nil ){
                audioEngine.inputNode?.removeTap(onBus: 0)
            }

        } else {
            try! startRecording()
           // btnVoice.setTitle("Stop recording", for: [])
        }
         */
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
