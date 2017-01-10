//
//  viewDelegate.swift
//  SampleApp
//
//  Created by Oded Betzalel on 25/12/2016.
//  Copyright © 2016 Oded Betzalel. All rights reserved.
//

import Foundation
import SafariServices
import BMSCore

public class safariView : SFSafariViewController, SFSafariViewControllerDelegate{
    
    var callback:BMSCompletionHandler?


    public init(url URL: URL) {
        super.init(url: URL, entersReaderIfAvailable: false)
        self.delegate = self
    }
    
    public func setCallback(callback:BMSCompletionHandler?){
        self.callback = callback
    }
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        callback?(nil, AppIDError.authenticationError(msg: "User canceled the operation"))
    }

}
