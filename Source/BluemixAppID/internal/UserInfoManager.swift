/* *     Copyright 2016, 2018 IBM Corp.
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

typealias jsonCompletionResponse = (Error?, [String: Any]?) -> Void

internal class UserInfoManager {
    
    static var logger = Logger.logger(name: AppIDConstants.UserManagerLoggerName)

    private var appId: AppID
    
    internal init(appId: AppID) {
        self.appId = appId
    }
    
    ///
    /// Retrieves user info using the latest access and identity tokens
    ///
    /// - Parameter completion {(Error?, [String: Any]?) -> Void}: result handler
    ///
    internal func getUserInfo(completion: @escaping jsonCompletionResponse) {
        
        guard let accessToken = getLatestAccessToken() else {
            return logAndFail(err: .missingAccessToken, completion: completion)
        }
        
        guard let sub = getLatestIdentityTokenSubject() else {
            return logAndFail(err: .missingOrMalformedIdToken, completion: completion)
        }
        
        getUserInfo(accessToken: accessToken, idTokenSub: sub, completion: completion)
    }
    
    ///
    /// Retrives user info using the provided tokens
    ///
    /// - Parameter accessToken {String}: the access token used for authorization
    /// - Parameter idToken {String}: the identity token used for validation
    /// - Parameter completion {(Error?, [String: Any]?) -> Void}: result handler
    ///
    internal func getUserInfo(accessToken: String, idToken: String, completion: @escaping jsonCompletionResponse) {
        
        guard let idToken = IdentityTokenImpl(with: idToken), let sub = idToken.subject else {
            return logAndFail(err: .missingOrMalformedIdToken, completion: completion)
        }
        
        getUserInfo(accessToken: accessToken, idTokenSub: sub, completion: completion)
    }
    
    ///
    /// Retrives user info using the provided access token and
    ///
    /// - Parameter accessToken {String}: the access token used for authorization
    /// - Parameter idTokenSub {String}: the subject field from the identity token used for validation
    /// - Parameter completion {(Error?, [String: Any]?) -> Void}: result handler
    ///
    private func getUserInfo(accessToken: String, idTokenSub: String, completion: @escaping jsonCompletionResponse) {
        
        let url = Config.getServerUrl(appId: appId) + "/" + AppIDConstants.userInfoEndPoint
        
        sendRequest(url: url, method: HttpMethod.GET, accessToken: accessToken) { (error, profile) in
            
            guard error == nil else {
                return completion(error, nil)
            }
            
            guard let profile = profile else {
                return self.logAndFail(err: "Expected to receive a profile", completion: completion)
            }
            
            guard let subject = profile["sub"], let sub = subject as? String, sub == idTokenSub else {
                return self.logAndFail(err: .responseValidationError, completion: completion)
            }
            
            completion(nil, profile)
        }
    }
    
    ///
    /// Constructs a url request
    ///
    /// - Parameter url {String}: the url to make the request to
    /// - Parameter method {HTTPMethod}: the request method
    /// - Parameter accessToken {String}: access token used for authorization
    /// - Parameter completion {(Error?, [String: Any]?) -> Void}: result handler
    ///
    private func sendRequest(url: String, method: HttpMethod, accessToken: String, completion: @escaping jsonCompletionResponse) {
        
        guard let url = URL(string: url) else {
            return self.logAndFail(err: "Failed to parse URL string", completion: completion)
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.timeoutInterval = BMSClient.sharedInstance.requestTimeout
        
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        
        send(request: req) { (data, response, error) in

            guard error == nil else {
                let errString = error?.localizedDescription ?? "Encountered an error"
                return self.logAndFail(level: "error", err: errString, completion: completion)
            }

            guard let resp = response, let response = resp as? HTTPURLResponse else {
                return self.logAndFail(err: "Did not receive a response from the userinfo endpoint", completion: completion)
            }
            
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                if response.statusCode == 401 {
                    UserInfoManager.logger.warn(message: "Ensure user profiles feature is enabled in the App ID dashboard.")
                    return self.logAndFail(err: .unauthorized, completion: completion)
                } else if response.statusCode == 404 {
                    return self.logAndFail(err: .notFound, completion: completion)
                } else {
                    return self.logAndFail(err: "Unexpected response from server. Status Code:" + String(response.statusCode), completion: completion)
                }
            }
            
            guard let responseData = data else {
                return self.logAndFail(err: "Failed to parse server response - no response text", completion: completion)
            }
            
            guard let respString = String(data: responseData, encoding: .utf8),
                  let json = try? Utils.parseJsonStringtoDictionary(respString)else {
                return self.logAndFail(err: "Failed to parse server body", completion: completion)
            }
            
            completion(nil, json)
        }
    }
    
    ///
    /// Error Handler
    ///
    /// - Parameter err {String}: the error message
    /// - Parameter completion {String}: the callback handler
    private func logAndFail(level: String = "debug", err: String, completion: @escaping jsonCompletionResponse) {
        logAndFail(level: level, err: UserInfoManagerError.general(err), completion: completion)
    }
    
    ///
    /// Error Handler
    ///
    /// - Parameter err {UserManagerError}: the error to log
    /// - Parameter completion {String}: the callback handler
    private func logAndFail(level: String = "debug", err: UserInfoManagerError, completion: @escaping jsonCompletionResponse) {
        switch level {
        case "warn" : UserInfoManager.logger.warn(message: err.description)
        case "error" : UserInfoManager.logger.error(message: err.description)
        default: UserInfoManager.logger.debug(message: err.description)
        }
        
        completion(err, nil)
    }
    
    ///
    /// URLSession datatask helper
    ///
    internal func send(request : URLRequest, handler : @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: request, completionHandler: handler).resume()
    }
    
    ///
    /// Retrieves the latest access token
    ///
    /// - Returns: the raw access token
    internal func getLatestAccessToken() -> String? {
        return  appId.oauthManager?.tokenManager?.latestAccessToken?.raw
    }
    
    ///
    /// Retrieves the latest identity token subject field
    ///
    /// - Returns: the subject field from the latest identity token
    internal func getLatestIdentityTokenSubject() -> String? {
        return  appId.oauthManager?.tokenManager?.latestIdentityToken?.subject
    }
}
