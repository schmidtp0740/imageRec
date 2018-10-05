//
//  ProductViewController.swift
//  Augmented Reality Retail
//
//  Created by Optech Developer on 12/12/17.
//  Copyright © 2017 AwesomeDev. All rights reserved.
//

import Foundation
import UIKit


class ProductViewController: UIViewController
{
    @IBOutlet var productDescription: UITextView!

    @IBOutlet var productID: UILabel!

    @IBOutlet var productPrice: UILabel!

    @IBOutlet var productImage: UIImageView!


    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.backgroundColor = UIColor.clear
        self.view.insertSubview(blurEffectView, at: 0)
        
        let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
        let image = UIImage(named: "cancel.png")
        cancelButton.setImage(image, for: UIControlState())
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chatbotButton(_ sender: Any) {
        let id = "retailBot123"
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
}
