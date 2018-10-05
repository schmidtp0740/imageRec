//
//  ViewController.swift
//  Augmented Reality Retail
//
//  Created by Optech Developer on 12/11/17.
//  Copyright © 2017 AwesomeDev. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

class ViewController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    var name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        
        let viewFromNib: UIView? = Bundle.main.loadNibNamed("ProductView",
                                                            owner: nil,
                                                            options: nil)?.first as! UIView
        let renderer = UIGraphicsImageRenderer(size: (viewFromNib?.bounds.size)!)
        let image = renderer.image { ctx in
            viewFromNib?.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        let Texture = SKTexture(image: image)
        let Sprite = SKSpriteNode(texture:Texture)
        Sprite.name = "ProductView"
        let labelNodeOne = SKLabelNode(text: "")
        if (currentObject == "bb8" || currentObject == "macncheese") {
            name = "BB8 $129.99 \n"
        }
        else if (currentObject == "headphones") {
            name = "Bose $179.99 \n"
        }
        
        else if (currentObject == "marker") {
            name = "Expo Marker $1.00 \n"
        }
        
        else if (currentObject == "") {
            name = "Try Again"
        }
        let labelNode = SKLabelNode(text: name)
        labelNode.fontSize = 30
        labelNodeOne.fontSize = 30
        labelNode.setScale(0.3)
        //labelNode.setScale(0.3)
        let imageM = UIImage(named: ("messenger.png"))
        let imagei = UIImage(named: ("iconi.png"))
        let TextureM = SKTexture(image: imageM!)
        let messengerNode = SKSpriteNode(texture: TextureM)
        
        let TextureI = SKTexture(image: imagei!)
        let iNode = SKSpriteNode(texture: TextureI)
        iNode.name = "info"
        messengerNode.name = "messenger"
        labelNodeOne.addChild(labelNode)
        labelNodeOne.addChild(messengerNode)
        labelNodeOne.addChild(iNode)
        
        iNode.size.height = iNode.size.height/16
        iNode.size.width = iNode.size.width/16
        messengerNode.size.height = messengerNode.size.height/16
        messengerNode.size.width = messengerNode.size.width/16
        
        iNode.position = labelNode.position
        iNode.position.x = iNode.position.x - 30
        messengerNode.position = labelNode.position
        messengerNode.position.x = messengerNode.position.x + 30
        labelNode.position.y =  labelNode.position.y + 30
        
        labelNodeOne.verticalAlignmentMode = .top
        labelNode.verticalAlignmentMode = .top
        
        return labelNodeOne;
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
