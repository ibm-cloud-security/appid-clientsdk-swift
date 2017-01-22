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
    
    internal var preferences:AppIDPreferences
    
    internal init(preferences:AppIDPreferences)
    {
        self.preferences = preferences
    }

    
    internal func invokeTokenRequest(_ grantCode:String, callback: BMSCompletionHandler?){
        let options:RequestOptions  = RequestOptions()
        do {
            options.parameters = try createTokenRequestParams(grantCode)
            options.headers =  try createTokenRequestHeaders()
            options.requestMethod = HttpMethod.POST
            let internalCallback:BMSCompletionHandler = {(response: Response?, error: Error?) in
                if error == nil {
                    if let unWrappedResponse = response, unWrappedResponse.isSuccessful {
                        do {
                            try self.saveTokenFromResponse(unWrappedResponse)
                            callback?(response, nil)
                        } catch(let thrownError) {
                            callback?(response, AppIDError.tokenRequestError(msg: thrownError.localizedDescription))
                        }
                    }
                    else {
                        callback?(nil, AppIDError.tokenRequestError(msg: "token request failed"))
                    }
                } else {
                    callback?(response, AppIDError.tokenRequestError(msg: error?.localizedDescription))
                }
            }
            let appIDRequestManager:AppIDRequestManager = AppIDRequestManager(completionHandler: internalCallback)
            try appIDRequestManager.send(getTokenUrl(), options: options )
        } catch (let err){
            callback?(nil, AppIDError.tokenRequestError(msg: err.localizedDescription))
        }
        
    }
    private func createTokenRequestHeaders()  throws -> [String:String] {
        var headers = [String:String]()
        guard let clientId = preferences.clientId.get() else {
            throw AppIDError.tokenRequestError(msg: "Client is not registered")
        }

        let username = clientId
        let signed = try? SecurityUtils.signString(username, keyIds: (AppIDConstants.publicKeyIdentifier, AppIDConstants.privateKeyIdentifier), keySize: 512)
        headers[AppIDConstants.AUTHORIZATION_HEADER] = AppIDConstants.BASIC_AUTHORIZATION_STRING + " " + (username + ":" + signed!).data(using: .utf8)!.base64EncodedString()
        return headers
    }
    
    private func createTokenRequestParams(_ grantCode:String) throws -> [String : String]{
        guard let clientId = preferences.clientId.get() else {
            throw AppIDError.tokenRequestError(msg: "Client is not registered")
        }
        let params : [String : String] = [
            AppIDConstants.JSON_CODE_KEY : grantCode,
            AppIDConstants.client_id_String :  clientId,
            AppIDConstants.JSON_GRANT_TYPE_KEY : AppIDConstants.authorization_code_String,
            AppIDConstants.JSON_REDIRECT_URI_KEY :AppIDConstants.REDIRECT_URI_VALUE
        ]
        return params;
    }
    
    
    private func saveTokenFromResponse(_ response:Response) throws {
        do {
            if let data = response.responseData, let responseJson =  try JSONSerialization.jsonObject(with: data as Data, options: []) as? [String:Any]{
                if let accessTokenFromResponse = responseJson[caseInsensitive : AppIDConstants.JSON_ACCESS_TOKEN_KEY] as? String, let idTokenFromResponse =
                    responseJson[caseInsensitive : AppIDConstants.JSON_ID_TOKEN_KEY] as? String {
                    //save the tokens
                    _ = preferences.idToken.set(idTokenFromResponse)
                    _ = preferences.accessToken.set(accessTokenFromResponse)
                    AppID.logger.debug(message: "token successfully saved")
                    if let userIdentity = getUserIdentityFromToken(idTokenFromResponse)
                    {
                        preferences.userIdentity.set(userIdentity)
                    }
                }
            }
        } catch  {
            throw AppIDError.tokenRequestError(msg: "Could not save token")
        }
    }
    
    
    private func getUserIdentityFromToken(_ idToken:String) -> [String:Any]?
    {
        do {
            if let decodedIdTokenData = Utils.decodeBase64WithString(idToken.components(separatedBy: ".")[1], isSafeUrl: true), let _ = String(data: decodedIdTokenData, encoding: String.Encoding.utf8), let decodedIdTokenString = String(data: decodedIdTokenData, encoding: String.Encoding.utf8), let userIdentity = try Utils.parseJsonStringtoDictionary(decodedIdTokenString)[caseInsensitive : AppIDConstants.JSON_IMF_USER_KEY] as? [String:Any] {
                return userIdentity
            }
        } catch {
            return nil
        }
        return nil
    }
    
    private func getTokenUrl() -> String {
        let tokenUrl = AppID.sharedInstance.serverUrl
            + "/"
            + AppIDConstants.V3_AUTH_PATH
            + AppID.sharedInstance.tenantId!
        return tokenUrl + "/" + AppIDConstants.tokenEndPoint
    }

    
    
    
}
