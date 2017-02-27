/* *     Copyright 2016, 2017 IBM Corp.
 *     Licensed under the Apache License, Version 2.0 (the "License");
 *     you may not use this file except in compliance with the License.
 *     You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 *     Unless required by applicable law or agreed to in writing, software
 *     distributed under the License is distributed on an "AS IS" BASIS,
 *     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *     limitations under the License.
 */

import Foundation
import BMSCore

public class UserAttributeManagerImpl: UserAttributeManager {

    private let userProfileAttributesPath = "attributes"
    private var appId:AppID

    init(appId:AppID) {
        self.appId = appId
    }

    public func setAttribute(key: String, value: String, delegate: UserAttributeDelegate) {
        sendRequest(method: HttpMethod.PUT, key: key, value: value, accessTokenString: getLatestToken(), delegate: delegate)
    }
    
    public func setAttribute(key: String, value: String, accessTokenString: String, delegate: UserAttributeDelegate) {
        sendRequest(method: HttpMethod.PUT, key: key, value: value, accessTokenString: accessTokenString, delegate: delegate)
    }
    
    public func getAttribute(key: String, delegate: UserAttributeDelegate) {
        sendRequest(method: HttpMethod.GET, key: key, value: nil, accessTokenString: getLatestToken(), delegate: delegate)
    }
    
    public func getAttribute(key: String, accessTokenString: String, delegate: UserAttributeDelegate) {
        sendRequest(method: HttpMethod.GET, key: key, value: nil, accessTokenString: accessTokenString, delegate: delegate)
    }
    
    public func deleteAttribute(key: String, delegate: UserAttributeDelegate) {
        sendRequest(method: HttpMethod.DELETE, key: key, value: nil, accessTokenString: getLatestToken(), delegate: delegate)
    }
    
    public func deleteAttribute(key: String, accessTokenString: String, delegate: UserAttributeDelegate) {
        sendRequest(method: HttpMethod.DELETE, key: key, value: nil, accessTokenString: accessTokenString, delegate: delegate)
    }
    
    public func getAttributes(delegate: UserAttributeDelegate) {
        sendRequest(method: HttpMethod.GET, key: nil, value: nil, accessTokenString: getLatestToken(), delegate: delegate)
    }
    
    public func getAttributes(accessTokenString: String, delegate: UserAttributeDelegate) {
        sendRequest(method: HttpMethod.GET, key: nil, value: nil, accessTokenString: accessTokenString, delegate: delegate)
    }
    
    
    internal func sendRequest(method: HttpMethod, key: String?, value: String?, accessTokenString: String?, delegate: UserAttributeDelegate) {
        var urlString = Config.getAttributesUrl(appId: appId) + userProfileAttributesPath
        
        if key != nil {
            let unWrappedKey = key!
            urlString = urlString + "/" + Utils.urlEncode(unWrappedKey)
        }
        
        let url = URL(string: urlString)
        var req = URLRequest(url: url!)
        req.httpMethod = method.rawValue
        req.timeoutInterval = BMSClient.sharedInstance.requestTimeout
        
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if accessTokenString != nil {
            req.setValue("Bearer " + accessTokenString!, forHTTPHeaderField: "Authorization")
        }
        
        if value != nil {
            let unwrappedValue = value!
            req.httpBody=unwrappedValue.data(using: .utf8)
        }
        
        send(request: req, handler:      {(data, response, error) in
            if response != nil {
                let unWrappedResponse = response as? HTTPURLResponse
                if unWrappedResponse != nil {
                    if unWrappedResponse!.statusCode>=200 && unWrappedResponse!.statusCode < 300 {
                        guard let unWrappedData = data else {
                            delegate.onFailure(error: UserAttributeError.userAttributeFailure("Failed to parse server response - no response text"))
                            return
                        }
                        var responseJson : [String:Any] = [:]
                        do {
                            let responseText = String(data: unWrappedData, encoding: .utf8)
                            if let unWrappedText = responseText {
                                if responseText != "" {
                                    responseJson =  try Utils.parseJsonStringtoDictionary(unWrappedText)
                                }
                            }
                            
                        } catch _ {
                            delegate.onFailure(error: UserAttributeError.userAttributeFailure("Failed to parse server response - failed to parse json"))
                            return
                        }
                        delegate.onSuccess(result: responseJson)
                    }
                    else {
                        if unWrappedResponse!.statusCode == 401 {
                            delegate.onFailure(error: UserAttributeError.userAttributeFailure("UNAUTHORIZED"))
                        } else if unWrappedResponse!.statusCode == 404 {
                            delegate.onFailure(error: UserAttributeError.userAttributeFailure("NOT FOUND"))
                        } else {
                            delegate.onFailure(error: UserAttributeError.userAttributeFailure("Failed to get response from server"))
                        }
                        
                    }
                }
            } else {
                delegate.onFailure(error: UserAttributeError.userAttributeFailure("Failed to get response from server"))
                
            }
            
            
            
        })
        
        
        
    }
    
    internal func send(request : URLRequest, handler : @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: request, completionHandler: handler).resume()
    }
    
    internal func getLatestToken() -> String? {
        return  appId.oauthManager?.tokenManager?.latestAccessToken?.raw
    }
    
}
