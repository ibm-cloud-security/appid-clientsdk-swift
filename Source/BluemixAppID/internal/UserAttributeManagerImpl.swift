//
//  UserAttributeManagerImpl.swift
//  OdedAppIDdonotdeleteappid
//
//  Created by Moty Drimer on 21/02/2017.
//  Copyright © 2017 Oded Betzalel. All rights reserved.
//

import Foundation
import BMSCore

public class UserAttributeManagerImpl: UserAttributeManager {
    
    private var userProfileAttributesPath = "attributes"
    private(set) var appId:AppID
    
    init(appId:AppID) {
        self.appId = appId
    }
    
    public func setAttribute(key: String, value: String, delegate: UserAttributeDelegate) {
        sendRequest(method: HttpMethod.PUT, key: key, value: value, accessToken: nil, delegate: delegate);
    }
    public func setAttribute(key: String, value: String, accessToken: AccessToken, delegate: UserAttributeDelegate) {
        sendRequest(method: HttpMethod.PUT, key: key, value: value, accessToken: accessToken, delegate: delegate);
    }
    
    public func getAttribute(key: String, delegate: UserAttributeDelegate) {
        sendRequest(method: HttpMethod.GET, key: key, value: nil, accessToken: nil, delegate: delegate);
    }
    public func getAttribute(key: String, accessToken: AccessToken, delegate: UserAttributeDelegate) {
        sendRequest(method: HttpMethod.GET, key: key, value: nil, accessToken: accessToken, delegate: delegate);
    }
    
    public func deleteAttribute(key: String, delegate: UserAttributeDelegate) {
        sendRequest(method: HttpMethod.DELETE, key: key, value: nil, accessToken: nil, delegate: delegate);
    }
    public func deleteAttribute(key: String, accessToken: AccessToken, delegate: UserAttributeDelegate) {
            sendRequest(method: HttpMethod.DELETE, key: key, value: nil, accessToken: accessToken, delegate: delegate);
    }
    
    public func getAttributes(delegate: UserAttributeDelegate) {
        sendRequest(method: HttpMethod.GET, key: nil, value: nil, accessToken: nil, delegate: delegate);
    }
    public func getAttributes(accessToken: AccessToken, delegate: UserAttributeDelegate) {
        sendRequest(method: HttpMethod.GET, key: nil, value: nil, accessToken: accessToken, delegate: delegate);
    }
    
    
    internal func sendRequest(method: HttpMethod, key: String?, value: String?, accessToken: AccessToken?, delegate: UserAttributeDelegate) {
        
        var headers:[String:String] = [:]
        if (accessToken == nil) {
            headers = [Request.contentType : "application/json"]
        } else {
            let authHeader = "Bearer " + accessToken!.raw;
            headers = [Request.contentType : "application/json", AppIDConstants.AUTHORIZATION_HEADER : authHeader]
        }
        
        
        
        
        let internalCallback:BMSCompletionHandler = {(response: Response?, error: Error?) in
            if response != nil {
                let unWrappedResponse = response!
                if unWrappedResponse.isSuccessful {
                    guard let responseText = unWrappedResponse.responseText else {
                        delegate.onFailure(error: UserAttributeError.userAttributeFailure("Failed to parse server response - no response text"))
                            return
                    }
                    do {
                        if responseText == "" {
                            // in case we perform delete on an atribute, the server does not return a response body,
                            // so to avoid failing in JSON parsing just ignore it and pass in an empty dictionary:
                            delegate.onSuccess(result: [:]);
                        } else {
                            var responseJson =  try Utils.parseJsonStringtoDictionary(responseText)
                            delegate.onSuccess(result: responseJson);
                        }
                    } catch (_) {
                        delegate.onFailure(error: UserAttributeError.userAttributeFailure("Failed to parse server response - failed to parse json"))
                        return
                    }
                }
                else {
                    if unWrappedResponse.statusCode == 401 {
                         delegate.onFailure(error: UserAttributeError.userAttributeFailure("UNATHORIZED"))
                    } else if unWrappedResponse.statusCode == 404 {
                         delegate.onFailure(error: UserAttributeError.userAttributeFailure("NOT FOUND"))
                    }
                
                }
            } else {
                delegate.onFailure(error: UserAttributeError.userAttributeFailure("Failed to get response from server"))
                
            }
        }
        
        var url = Config.getAttributesUrl(appId: appId) + userProfileAttributesPath;
        
        if (key != nil) {
            let unWrappedKey = key!;
            url = url + "/" + unWrappedKey;
        }
        
        let request:Request = Request(url: url,method: method, headers: headers, queryParameters: nil, timeout: 0)
        request.timeout = BMSClient.sharedInstance.requestTimeout
    
        if (value == nil) {
            
            request.send(completionHandler : internalCallback );
        } else {
            let unwrappedValue = value!;
            request.send(requestBody: unwrappedValue.data(using: .utf8), completionHandler: internalCallback)

        }
        
    
    
    }
    
}
