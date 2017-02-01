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
internal class TokenManager {
    
    private final var appid:AppID
    private final var registrationManager:RegistrationManager
    private(set) var latestAccessToken:AccessToken?
    private(set) var latestIdentityToken:IdentityToken?
    internal static let logger = Logger.logger(name: AppIDConstants.TokenManagerLoggerName)
    internal init(oAuthManager:OAuthManager)
    {
        self.appid = oAuthManager.appId
        self.registrationManager = oAuthManager.registrationManager!
    }

    
    public func obtainTokens(code:String, authorizationDelegate:AuthorizationDelegate) {
        TokenManager.logger.debug(message: "obtainTokens")
        let options:RequestOptions  = RequestOptions()
        let tokenUrl = Config.getServerUrl(appId: self.appid) + "/token"
        options.requestMethod = HttpMethod.POST
        
        guard let clientId = self.registrationManager.getRegistrationDataString(name: "client_id"), let redirectUri = self.registrationManager.getRegistrationDataString(arrayName: "redirect_uris", arrayIndex: 0) else {
         return
        }
        
        do {
        options.headers = ["Authorization" : try createAuthenticationHeader(clientId: clientId)]
        } catch (let e) {
            TokenManager.logger.error(message: "Failed to create authentication header")
           return
        }
        options.parameters = [
            "code" : code,
            "client_id" : clientId,
            "grant_type" : "authorization_code",
            "redirect_uri" : redirectUri
        ]
        
        let internalCallback:BMSCompletionHandler = {(response: Response?, error: Error?) in
            if error == nil {
                if let unWrappedResponse = response, unWrappedResponse.isSuccessful {
                    self.extractTokens(response: unWrappedResponse, authorizationDelegate: authorizationDelegate)
                }
                else {
                    authorizationDelegate.onAuthorizationFailure(error: AuthorizationError.authorizationFailure("Failed to retrieve tokens"))
                }
            } else {
                authorizationDelegate.onAuthorizationFailure(error: AuthorizationError.authorizationFailure("Failed to retrieve tokens"))
            }
        }
        let appIDRequestManager:AppIDRequestManager = AppIDRequestManager(completionHandler: internalCallback)
        //TODO: handle err
        try! appIDRequestManager.send(tokenUrl, options: options )

        
        
    }
    
    
    public func extractTokens(response:Response, authorizationDelegate:AuthorizationDelegate) {
        TokenManager.logger.debug(message: "Extracting tokens from server response");
        
        guard let responseText = response.responseText else {
            TokenManager.logger.error(message: "Failed to parse server response")
            return
        }
        do {
        var responseJson =  try Utils.parseJsonStringtoDictionary(responseText);
        
            guard let accessTokenString = (responseJson["access_token"] as? String), let idTokenString = (responseJson["id_token"] as? String) else {
                TokenManager.logger.error(message: "Failed to parse server response")
                return
            }
            guard let accessToken = AccessTokenImpl(with: accessTokenString), let identityToken:IdentityTokenImpl = IdentityTokenImpl(with: idTokenString) else {
                TokenManager.logger.error(message: "Failed to parse tokens")
                return
            }
            self.latestAccessToken = accessToken;
            self.latestIdentityToken = identityToken;
            authorizationDelegate.onAuthorizationSuccess(accessToken: accessToken, identityToken: identityToken);
        } catch (_) {
            TokenManager.logger.error(message: "Failed to parse server response")
            return
        }
       
        
    }
    
    public func createAuthenticationHeader(clientId:String) throws -> String {
        let signed = try SecurityUtils.signString(clientId, keyIds: (AppIDConstants.publicKeyIdentifier, AppIDConstants.privateKeyIdentifier), keySize: 512)
        return AppIDConstants.BASIC_AUTHORIZATION_STRING + " " + (clientId + ":" + signed).data(using: .utf8)!.base64EncodedString()
    }
    
    public func clearStoredToken() {
        self.latestAccessToken = nil
        self.latestIdentityToken = nil
    }

    
    
    
}
