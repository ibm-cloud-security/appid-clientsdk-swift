//
//  ViewController.swift
//  FVT_SwiftSDK
//
//  Created by Rotem Brosh on 07/02/2016.
//  Copyright © 2016 Rotem Brosh. All rights reserved.
//

import UIKit

import BMSCore

class ViewController: UIViewController {
    @IBOutlet weak var msg: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    //function for displaying login
    override func viewDidLoad() {
        
        super.viewDidLoad()
        msg.isHidden = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    @IBAction func log_in(_ sender: AnyObject) {
        let callBack = {(response: Response?, error: Error?) in
            if error == nil {
                let userId = AppID.sharedInstance.userIdentity as! AppIDUserIdentity
                DispatchQueue.main.async {
                    self.msg.isHidden = false
                    self.msg.text = "Hello " + (userId.AppIDdisplayName)!
                }
                //                DispatchQueue.main.async {
                //                    let url = URL(string: ((userId as? AppIDUserIdentity)?.picUrl)!)
                //                    let data = try? Data(contentsOf: url!)
                //                    self.imageView.image = UIImage(data: data!)
                //                }
            }
        }
        self.msg.text = ""
        self.imageView.image = nil
        AppID.sharedInstance.login(onTokenCompletion: callBack)
    }
}

