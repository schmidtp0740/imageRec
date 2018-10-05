//
//  Scene.swift
//  Augmented Reality Retail
//
//  Created by Optech Developer on 12/11/17.
//  Copyright © 2017 AwesomeDev. All rights reserved.
//

import SpriteKit
import ARKit
import Alamofire

var currentObject = ""

class Scene: SKScene {
    
    var bb8Info = "BB8 Sphero Droid"
    var bb8Price = "$129.99"
    
    var bb8Description = "The BB-8™ App-Enabled Droid™ by Sphero is the Droid your little Jedi has been looking for, with its adaptive personality that responds to your voice. Connect to a compatible Apple® iOS or Android device to guide BB-8 around your home. "
    
    var headphoneDescription = "Listen to your music, videos and TV shows with crisp, clear audio when you wear these Bose QuietComfort 25 Acoustic Noise Cancelling Wired Headphones. These sleek over-the-ear headphones feature a simple and clean design that delivers big on functionality."
    
    var headphonesInfo = "Headphones"
    var headphonesPrice = "$179.00"

    var ExpoDescription = "A truly beautiful writing instrument, born for collaboration and concept, may require a whiteboard for non-destructive use"
    
    var ExpoInfo = "Expo Marker"
    var ExpoPrice = "$1.00"
    
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0)
        self.view!.drawHierarchy(in: self.view!.bounds, afterScreenUpdates: true)
        var image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        var photo = image //The image is stored in the variable Image
        

        
        let touch = touches.first as UITouch!
        let touchLocation = touch?.location(in: self)
        guard let targetNode = atPoint(touchLocation!) as? SKSpriteNode else {
            print("Scanning Object")
            
            // Break
//            let im = UIImageJPEGRepresentation(photo, 0.2)
//            print(photo.size.width * photo.scale)
//            let image: UIImage = UIImage(data: im!)!
//
//            print(image.size.width * image.scale)
            let parameters = ["image": UIImageJPEGRepresentation(photo, 0.2)!.base64EncodedString()]
            let URL = try! URLRequest(url: "http://129.146.81.61:8080/detect", method: .post, headers: nil)
            
            NetworkManager.sharedInstance.defaultManager.upload(multipartFormData: { (multipartFormData)  in
                
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            }, with: URL, encodingCompletion: { (result) in
                
                switch result {
                case .success(let upload, _, _):
                    
                    upload.responseJSON { response in
                        self.customActivityIndicatory(self.view!, startAnimate: false)
                        print(response.request)  // original URL request
                        print(response.response) // URL response
                        print(response.data)     // server data
                        print(response.result)   // result of response serialization
                        //                        self.showSuccesAlert()
                        if let JSON = response.result.value as? NSDictionary{
                            print("JSON: \(JSON)")
                            if let object:String = JSON["label"] as! String {
                                if (object == "headphones" || object == "bb8" || object == "marker")
                                {
                                    currentObject = object
                                    if let currentFrame = sceneView.session.currentFrame {
                                        
                                        // Create a transform with a translation of 0.2 meters in front of the camera
                                        var translation = matrix_identity_float4x4
                                        translation.columns.3.z = -0.2
                                        let transform = simd_mul(currentFrame.camera.transform, translation)
                                        
                                        // Add a new anchor to the session
                                        let anchor = ARAnchor(transform: transform)
                                        sceneView.session.add(anchor: anchor)
                                    }
                                }
                                
                            }
                        }
                        
                        else
                        {

                                    if let currentFrame = sceneView.session.currentFrame {
                                        
                                        // Create a transform with a translation of 0.2 meters in front of the camera
                                        var translation = matrix_identity_float4x4
                                        translation.columns.3.z = -0.2
                                        let transform = simd_mul(currentFrame.camera.transform, translation)
                                        
                                        // Add a new anchor to the session
                                        let anchor = ARAnchor(transform: transform)
                                        sceneView.session.add(anchor: anchor)
                                    }
                                
                        }
                        
                    }
                    
                case .failure(let encodingError):
                    print(encodingError)
                }
                
            })
            
            // Break
            return
        }
        if(targetNode.name != nil)
        {
            print(targetNode.name!)
            if(targetNode.name?.contains("messenger"))!
            {
                let id = "targetChatbot"
                if let url = URL(string: "fb-messenger://user-thread/\(id)") {
                    
                    // Attempt to open in Messenger App first
                    UIApplication.shared.open(url, options: [:], completionHandler: {
                        (success) in
                        
                        if success == false {
                            // Messenger is not installed. Open in browser instead.
                            let url = URL(string: "https://m.me/\(id)")
                            if UIApplication.shared.canOpenURL(url!) {
                                UIApplication.shared.open(url!)
                            }
                        }
                    })
                }
            }
            
            if(targetNode.name?.contains("info"))! {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                var newVC = storyboard.instantiateViewController(withIdentifier: "productViewController") as! ProductViewController
                newVC.modalPresentationStyle = .overCurrentContext
                self.view?.window?.rootViewController?.present(newVC, animated: true, completion: {
                    if (currentObject == "bb8" || currentObject == "macncheese" ){
                        newVC.productDescription.text = self.bb8Description
                        newVC.productPrice.text = self.bb8Price
                        newVC.productID.text = self.bb8Info
                        newVC.productImage.image = UIImage(named: "bb8ProductImage.png")
                    }
                    else if (currentObject == "headphones"){
                        newVC.productDescription.text = self.headphoneDescription
                        newVC.productPrice.text = self.headphonesPrice
                        newVC.productID.text = self.headphonesInfo
                        newVC.productImage.image = UIImage(named: "bose.jpeg")
                    }
                    
                    else if (currentObject == "marker"){
                        newVC.productDescription.text = self.ExpoDescription
                        newVC.productPrice.text = self.ExpoPrice
                        newVC.productID.text = self.ExpoInfo
                        newVC.productImage.image = UIImage(named: "expo.png")
                    }
                    
                })
            }
        }
        else
        {
                    // Create anchor using the camera's current position
            if let currentFrame = sceneView.session.currentFrame {
                
                // Create a transform with a translation of 0.2 meters in front of the camera
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -0.2
                let transform = simd_mul(currentFrame.camera.transform, translation)
                
                // Add a new anchor to the session
                let anchor = ARAnchor(transform: transform)
                sceneView.session.add(anchor: anchor)
            }
        }
        
    }
    
    func customActivityIndicatory(_ viewContainer: UIView, startAnimate:Bool? = true) -> UIActivityIndicatorView {
        let mainContainer: UIView = UIView(frame: viewContainer.frame)
        mainContainer.center = viewContainer.center
        mainContainer.backgroundColor = UIColor.white
        mainContainer.alpha = 0.5
        mainContainer.tag = 789456123
        mainContainer.isUserInteractionEnabled = false
        
        let viewBackgroundLoading: UIView = UIView(frame: CGRect(x:0,y: 0,width: 80,height: 80))
        viewBackgroundLoading.center = viewContainer.center
        viewBackgroundLoading.backgroundColor = UIColor.black
        viewBackgroundLoading.alpha = 0.5
        viewBackgroundLoading.clipsToBounds = true
        viewBackgroundLoading.layer.cornerRadius = 15
        
        let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x:0.0,y: 0.0,width: 40.0, height: 40.0)
        activityIndicatorView.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        activityIndicatorView.center = CGPoint(x: viewBackgroundLoading.frame.size.width / 2, y: viewBackgroundLoading.frame.size.height / 2)
        if startAnimate!{
            viewBackgroundLoading.addSubview(activityIndicatorView)
            mainContainer.addSubview(viewBackgroundLoading)
            viewContainer.addSubview(mainContainer)
            activityIndicatorView.startAnimating()
        }else{
            for subview in viewContainer.subviews{
                if subview.tag == 789456123{
                    subview.removeFromSuperview()
                }
            }
        }
        return activityIndicatorView
    }
}

class NetworkManager {
    static let sharedInstance = NetworkManager()
    
    let defaultManager: Alamofire.SessionManager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "129.146.81.61": .disableEvaluation
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        return Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
}
