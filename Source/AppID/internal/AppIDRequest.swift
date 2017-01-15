/*
*     Copyright 2015 IBM Corp.
*     Licensed under the Apache License, Version 2.0 (the "License");
*     you may not use this file except in compliance with the License.
*     You may obtain a copy of the License at
*     http://www.apache.org/licenses/LICENSE-2.0
*     Unless required by applicable law or agreed to in writing, software
*     distributed under the License is distributed on an "AS IS" BASIS,
*     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*     See the License for the specific language governing permissions and
*     limitations under the License.
*/

import Foundation
import BMSCore
//AppID is used internally to send requests to AppID.
internal class AppIDRequest : Request {
    
    internal func send(_ completionHandler: BMSCompletionHandler?) {
        super.send(completionHandler: completionHandler)
    }
    
    //Add new header
    internal func addHeader(_ key:String, val:String) {
        headers[key] = val
    }
    
    //Iterate and add all new headers
    internal func addHeaders(_ newHeaders: [String:String]) {
        for (key,value) in newHeaders {
            addHeader(key, val: value)
        }
    }
    
    internal init(url:String, method:HttpMethod) {
        super.init(url: url, method: method, headers: nil, queryParameters: nil, timeout: 0)
        allowRedirects = false
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        networkSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    
    internal func sendJson( json : [String : Any], callback : BMSCompletionHandler?) {
        headers[Request.contentType] = "application/json"
        let jsonToSend = try? urlEncode(Utils.JSONStringify(json as AnyObject)).data(using: .utf8)
        send(requestBody: jsonToSend != nil ? jsonToSend! : Data(), completionHandler: callback)
    }

    
    /**
     * Send this resource request asynchronously, with the given form parameters as the request body.
     * This method will set the content type header to "application/x-www-form-urlencoded".
     *
     * @param formParameters The parameters to put in the request body
     * @param listener       The listener whose onSuccess or onFailure methods will be called when this request finishes.
     */
    internal func sendWithCompletionHandler(_ formParamaters : [String : String], callback: BMSCompletionHandler?) {
        headers[Request.contentType] = "application/x-www-form-urlencoded"
        var body = ""
        var i = 0
        //creating body params
        for (key, val) in formParamaters {
            body += "\(urlEncode(key))=\(urlEncode(val))"
            if i < formParamaters.count - 1 {
                body += "&"
            }
            i+=1
        }
        send(requestBody: body.data(using: .utf8), completionHandler: callback)
    }
    private func urlEncode(_ str:String) -> String{
        var encodedString = ""
        var unchangedCharacters = ""
        let FORM_ENCODE_SET = " \"':;<=>@[]^`{}|/\\?#&!$(),~%"
        
        for element: Int in 0x20..<0x7f {
            if !FORM_ENCODE_SET.contains(String(describing: UnicodeScalar(element))) {
                unchangedCharacters += String(Character(UnicodeScalar(element)!))
            }
        }
        
        encodedString = str.trimmingCharacters(in: CharacterSet(charactersIn: "\n\r\t"))
        let charactersToRemove = ["\n", "\r", "\t"]
        for char in charactersToRemove {
            encodedString = encodedString.replacingOccurrences(of: char, with: "")
        }
        if let encodedString = encodedString.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: unchangedCharacters)) {
            return encodedString
        }
        else {
            return "nil"
        }
    }
}
