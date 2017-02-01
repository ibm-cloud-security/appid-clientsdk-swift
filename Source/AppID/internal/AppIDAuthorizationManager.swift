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

internal class AppIDAuthorizationManager : BMSCore.AuthorizationManager {
    
    
    private var oAuthManager:OAuthManager
    private static let logger =  Logger.logger(name: Logger.bmsLoggerPrefix + "AppIDAuthorizationManager")
    
    
    
    init(appid:AppID) {
        //TODO: is this ok?
        self.oAuthManager = appid.oauthManager!
    }
    
    /**
     A response is an OAuth error response only if,
     1. it's status is 401 or 403.
     2. The value of the "WWW-Authenticate" header contains 'Bearer'.
     
     - Parameter httpResponse - Response to check the authorization conditions for.
     
     - returns: True if the response satisfies both conditions
     */
    
    
    internal func isAuthorizationRequired(for httpResponse: Response) -> Bool {
        if let header = httpResponse.headers![caseInsensitive : AppIDConstants.WWW_AUTHENTICATE_HEADER], let authHeader : String = header as? String {
            guard let statusCode = httpResponse.statusCode else {
                return false
            }
            return isAuthorizationRequired(for: statusCode, httpResponseAuthorizationHeader: authHeader)
        }
        
        return false
    }
    
    /**
     Check if the params came from response that requires authorization
     
     - Parameter statusCode - Status code of the response
     - Parameter responseAuthorizationHeader - Response header
     
     - returns: True if status is 401 or 403 and The value of the header contains 'Bearer'
     */
    
    
    internal func isAuthorizationRequired(for statusCode: Int, httpResponseAuthorizationHeader responseAuthorizationHeader: String) -> Bool {
        
        if (statusCode == 401 || statusCode == 403) &&
            responseAuthorizationHeader.lowercased().contains(AppIDConstants.BEARER.lowercased()) &&
            responseAuthorizationHeader.lowercased().contains(AppIDConstants.AUTH_REALM.lowercased()) {
            return true
        }
        
        return false
    }
    
    
    
    
    public func obtainAuthorization(completionHandler callback: BMSCompletionHandler?) {
        
        class innerAuthorizationDelegate: AuthorizationDelegate {
            var callback:BMSCompletionHandler?
            init(callback:BMSCompletionHandler?){
                self.callback = callback
            }
            func onAuthorizationFailure(error err:AuthorizationError) {
                callback?(nil,err)
            }
            func onAuthorizationCanceled () {
                callback?(nil, AuthorizationError.authorizationFailure("Authorization canceled"))
            }
            func onAuthorizationSuccess (accessToken:AccessToken, identityToken:IdentityToken ) {
                //TODO: fix this
                callback?(nil,nil);
            }
        }
        
        oAuthManager.authorizationManager?.launchAuthorizationUI(authorizationDelegate: innerAuthorizationDelegate(callback: callback))
    }
    
    public func clearAuthorizationData() {
        self.oAuthManager.tokenManager?.clearStoredToken()
    }
    
    
    
    
    
    internal  init(oAuthManager:OAuthManager) {
        self.oAuthManager = oAuthManager
    }
    
    /**
     - returns: The locally stored authorization header or nil if the value does not exist.
     */
    internal var cachedAuthorizationHeader:String? {
        get{
            AppIDAuthorizationManager.logger.debug(message: "getCachedAuthorizationHeader")
            guard let accessToken = self.accessToken, let identityToken = self.identityToken else {
                return nil
            }
            return "Bearer " + accessToken.raw + " " + identityToken.raw
        }
    }
    
    
    //TODO: what should identities return
    
    internal var userIdentity:UserIdentity? {
        return nil
    }
    internal var deviceIdentity:DeviceIdentity {
        return BaseDeviceIdentity()
    }
    internal var appIdentity:AppIdentity {
        return BaseAppIdentity()
    }
    public var accessToken:AccessToken? {
        return self.oAuthManager.tokenManager?.latestAccessToken
    }
    
    public var identityToken:IdentityToken? {
        return self.oAuthManager.tokenManager?.latestIdentityToken
    }
    
    /**
     Adds the cached authorization header to the given URL connection object.
     If the cached authorization header is equal to nil then this operation has no effect.
     - Parameter request - The request to add the header to.
     */
    
    internal func addCachedAuthorizationHeader(_ request: NSMutableURLRequest) {
        addAuthorizationHeader(request, header: cachedAuthorizationHeader)
    }
    
    private func addAuthorizationHeader(_ request: NSMutableURLRequest, header:String?) {
        guard let unWrappedHeader = header else {
            return
        }
        request.setValue(unWrappedHeader, forHTTPHeaderField: AppIDConstants.AUTHORIZATION_HEADER)
    }
    
    public func logout() {
        //TODO: this is not really logout
        self.clearAuthorizationData()
    }
    
    
    
    
    
}
