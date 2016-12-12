//
//  view.swift
//  BMSSecurity
//
//  Created by Oded Betzalel on 30/11/2016.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit


class AppIDView: UIViewController, UIWebViewDelegate {
    
    var url:String = ""
    var completion: ((String?) -> Void)!
    
    func setUrl(url: String) {
        self.url = url
    }
    
    func setCompletionHandler(completionHandler : @escaping (String?) -> Void) {
        self.completion = completionHandler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let webView:UIWebView = UIWebView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height))
        self.view.addSubview(webView)
        webView.delegate = self
        var b = UIBarButtonItem(
            title: "Continue",
            style: .plain,
            target: self,
            action: #selector(sayHello(sender:))
        )
        
       
        self.navigationItem.rightBarButtonItem = b
        self.view.addSubview(self.navigationController)
        let reqUrl = URL(string: url)
        var urlReq:URLRequest = URLRequest(url: reqUrl!)
        urlReq.httpMethod = "GET"
        webView.loadRequest(urlReq)
    }
    func sayHello(sender: UIBarButtonItem) {
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.url?.absoluteString  {
            if url.hasPrefix(BMSSecurityConstants.HTTP_LOCALHOST_CODE) == true {
                //gets the query, then sepertes it to params, then filters the one the is "code" then takes its value
                let code = request.url?.query?.components(separatedBy: "&").filter({(item) in item.hasPrefix("code")}).first?.components(separatedBy: "=")[1]
                self.dismiss(animated: true, completion: {
                    self.completion(code)
                })
                return false
            }
        }
        return true
    }
    
}
