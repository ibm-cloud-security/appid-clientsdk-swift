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
    var completion: ((String?, String?) -> Void)!
    
    func setUrl(url: String) {
        self.url = url
    }
    
    func setCompletionHandler(completionHandler : @escaping (String?, String?) -> Void) {
        self.completion = completionHandler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let webView:UIWebView = UIWebView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height))
        self.view.addSubview(webView)
        webView.delegate = self
        let backButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AppIDView.back))
        navigationItem.leftBarButtonItem = backButton
        let reqUrl = URL(string: url)
        var urlReq:URLRequest = URLRequest(url: reqUrl!)
        urlReq.httpMethod = "GET"
        webView.loadRequest(urlReq)
    }
    
    func back(){
        self.dismiss(animated: true, completion: {
            self.completion(nil, "User canceled the operation")
        })
    }
    
    //    func webViewDidFinishLoad(_ webView: UIWebView) {
    //        //checks if body has error, if so dismisses view
    //        guard let json = webView.stringByEvaluatingJavaScript(from: "document.body.innerHTML")?.components(separatedBy: "<")[1].components(separatedBy: ">")[1], let err = try? Utils.parseJsonStringtoDictionary(json)["error"] as? String else {
    //            return
    //        }
    //        self.dismiss(animated: true, completion: {
    //            self.completion(nil, err)
    //        })
    //    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.url?.absoluteString  {
            if url.hasPrefix(BMSSecurityConstants.HTTP_LOCALHOST_CODE) == true {
                //gets the query, then sepertes it to params, then filters the one the is "code" then takes its value
                let code = request.url?.query?.components(separatedBy: "&").filter({(item) in item.hasPrefix("code")}).first?.components(separatedBy: "=")[1]
                self.dismiss(animated: true, completion: {
                    if(code == nil){
                        self.completion(code, "Failed to extract grant code")
                    } else {
                        self.completion(code, nil)
                    }
                    return
                })
                return false
            }
        }
        return true
    }
    
}
