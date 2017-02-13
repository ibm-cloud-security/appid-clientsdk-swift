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
public class AuthorizationManager {

    static var logger = Logger.logger(name: AppIDConstants.RegistrationManagerLoggerName)
    var registrationManager:RegistrationManager
    var appid:AppID
    var oAuthManager:OAuthManager
    var authorizationUIManager:AuthorizationUIManager?
    init(oAuthManager:OAuthManager) {
        self.oAuthManager = oAuthManager
        self.appid = oAuthManager.appId
        self.registrationManager = oAuthManager.registrationManager!
    }

    public func getAuthorizationUrl(idpName:String?) -> String {
        var url = Config.getServerUrl(appId: self.appid) + AppIDConstants.OAUTH_AUTHORIZATION_PATH + "?" + AppIDConstants.JSON_RESPONSE_TYPE_KEY + "=" + AppIDConstants.JSON_CODE_KEY
        if let clientId = self.registrationManager.getRegistrationDataString(name: AppIDConstants.client_id_String) {
            url += "&" + AppIDConstants.client_id_String + "=" + clientId
        }
        if let redirectUri = self.registrationManager.getRegistrationDataString(arrayName: AppIDConstants.JSON_REDIRECT_URIS_KEY, arrayIndex: 0) {
            url +=  "&" + AppIDConstants.JSON_REDIRECT_URI_KEY + "=" + redirectUri
        }
        url += "&" + AppIDConstants.JSON_SCOPE_KEY + "=" + AppIDConstants.OPEN_ID_VALUE
        if let unWrappedIdpName = idpName {
            url += "&idp=" + unWrappedIdpName
        }
        return url
    }
    
    public func launchAuthorizationUI(authorizationDelegate:AuthorizationDelegate) {
        
        self.registrationManager.ensureRegistered(callback: {(error:Error?) in
            guard error == nil else {
                AuthorizationManager.logger.error(message: error!.localizedDescription)
                authorizationDelegate.onAuthorizationFailure(error: AuthorizationError.authorizationFailure(error!.localizedDescription))
                return
            }
            let authorizationUrl = self.getAuthorizationUrl(idpName: nil)
            let redirectUri = self.registrationManager.getRegistrationDataString(arrayName: AppIDConstants.JSON_REDIRECT_URIS_KEY, arrayIndex: 0)
            self.authorizationUIManager = AuthorizationUIManager(oAuthManager: self.oAuthManager, authorizationDelegate: authorizationDelegate, authorizationUrl: authorizationUrl, redirectUri: redirectUri!)
            self.authorizationUIManager?.launch()
            
        })
    }
    
    
    public func loginAnonymously(accessTokenString:String?, authorizationDelegate:AuthorizationDelegate) {
        // TODO: not fully implemented yet
        if let unwrappedAccessTokenString = accessTokenString {
            AccessTokenImpl(with: unwrappedAccessTokenString)
        } else {
            let accessToken = self.oAuthManager.tokenManager?.latestAccessToken
        }
        let authorizationUrl = self.getAuthorizationUrl(idpName: "appid_anon")
    }
    
    
    public func application(_ application: UIApplication, open url: URL, options :[UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return (self.authorizationUIManager?.application(application, open: url, options: options))!
    }
    
    
    
    
    
}
