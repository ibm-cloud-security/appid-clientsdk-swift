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
    //TODO: do we need authorization UI manager?
    private static var OAUTH_AUTHORIZATION_PATH = "/authorization";
    static var logger = Logger.logger(name: AppIDConstants.RegistrationManagerLoggerName)
    
    var registrationManager:RegistrationManager
    var appid:AppID
    var oAuthManager:OAuthManager
    var authorizationUIManager:AuthorizationUIManager?
    init(oAuthManager:OAuthManager) {
        self.oAuthManager = oAuthManager;
        self.appid = oAuthManager.appId
        self.registrationManager = oAuthManager.registrationManager!
    }
    
    
    public func getAuthorizationUrl(useLoginWidget:Bool, idpName:String?) -> String {
        var url = Config.getServerUrl(appId: self.appid) + "/authorization?response_type=code"
        if let clientId = self.registrationManager.getRegistrationDataString(name: "client_id") {
            url += "&client_id=" + clientId
        }
        if let redirectUri = self.registrationManager.getRegistrationDataString(arrayName: "redirect_uris", arrayIndex: 0) {
            url += "&redirect_uri=" + redirectUri
        }
        url += "&scope=openid" + "&use_login_widget=" + useLoginWidget.description
        if let unWrappedIdpName = idpName {
            url += "&idp=" + unWrappedIdpName
        }
        return url
    }
    
    public func launchAuthorizationUI(authorizationDelegate:AuthorizationDelegate) {
        class registrationDelegateImpl:RegistrationDelegate {
            var authorizationManager:AuthorizationManager
            var authorizationDelegate:AuthorizationDelegate
            init(authorizationManager:AuthorizationManager, authorizationDelegate:AuthorizationDelegate){
                self.authorizationManager = authorizationManager
                self.authorizationDelegate = authorizationDelegate
            }
            func onRegistrationFailure(var1 message:String) {
                AuthorizationManager.logger.error(message: message);
                authorizationDelegate.onAuthorizationFailure(error: AuthorizationError.authorizationFailure(message))
            }
            func onRegistrationSuccess() {
                let authorizationUrl = authorizationManager.getAuthorizationUrl(useLoginWidget: true, idpName: nil)
                let redirectUri = authorizationManager.registrationManager.getRegistrationDataString(arrayName: "redirect_uris", arrayIndex: 0);
                authorizationManager.authorizationUIManager = AuthorizationUIManager(oAuthManager: authorizationManager.oAuthManager, authorizationDelegate: authorizationDelegate, authorizationUrl: authorizationUrl, redirectUri: redirectUri!);
                authorizationManager.authorizationUIManager?.launch();
            }
        }
        self.registrationManager.ensureRegistered(registrationDelegate: registrationDelegateImpl(authorizationManager: self, authorizationDelegate: authorizationDelegate))
    }
    
    
    public func loginAnonymously(accessTokenString:String?, authorizationDelegate:AuthorizationDelegate) {
        if let unwrappedAccessTokenString = accessTokenString {
            AccessTokenImpl(with: unwrappedAccessTokenString)
        } else {
            let accessToken = self.oAuthManager.tokenManager?.latestAccessToken
        }
        let authorizationUrl = self.getAuthorizationUrl(useLoginWidget: false, idpName: "anon")
    }
    
    
    public func application(_ application: UIApplication, open url: URL, options :[UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return (self.authorizationUIManager?.application(application, open: url, options: options))!
    }

    
        
    
    
}
