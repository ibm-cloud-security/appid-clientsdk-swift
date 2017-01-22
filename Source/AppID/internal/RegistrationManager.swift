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
internal class RegistrationManager {
    
    private var preferences:AppIDPreferences
    internal static let logger = Logger.logger(name: AppIDConstants.RegistrationManagerLoggerName)
    
    
    internal init(preferences:AppIDPreferences)
    {
        self.preferences = preferences
        _ = self.preferences.persistencePolicy.set(PersistencePolicy.never, shouldUpdateTokens: false);
    }
    
    internal func registerDevice(callback :@escaping BMSCompletionHandler) throws {
        preferences.clientId.clear()
        let options:RequestOptions = RequestOptions()
        options.json = try createRegistrationParams()
        options.requestMethod = HttpMethod.POST
        
        let internalCallBack:BMSCompletionHandler = {(response: Response?, error: Error?) in
            if error == nil {
                if let unWrappedResponse = response, unWrappedResponse.isSuccessful {
                    do {
                        try self.saveClientId(response)
                        callback(response, error);
                    } catch(let thrownError) {
                        callback(nil, thrownError)
                    }
                }
                else {
                    callback(response, error);
                }
            } else {
                callback(response, error);
            }
        }
        let appIDRequestManager:AppIDRequestManager = AppIDRequestManager(completionHandler: internalCallBack)
        do {
            try  appIDRequestManager.send(getRegistrationUrl(), options: options )
        } catch {
            callback(nil, error);
        }
        
    }
    private func getRegistrationUrl() -> String {
        return AppID.sharedInstance.serverUrl
            + "/"
            + AppIDConstants.V3_AUTH_PATH
            + AppID.sharedInstance.tenantId!
            + "/"
            + AppIDConstants.clientsEndPoint
    }
    
    
    /*
 

 
 
 
 
 */
    private func createRegistrationParams() throws -> [String:Any]{
        do {
             try SecurityUtils.generateKeyPair(512, publicTag: AppIDConstants.publicKeyIdentifier, privateTag: AppIDConstants.privateKeyIdentifier)
            let deviceIdentity = AppIDDeviceIdentity()
            let appIdentity = AppIDAppIdentity()
            var params = [String : Any]()
            params[AppIDConstants.JSON_REDIRECT_URIS_KEY] = [AppIDConstants.REDIRECT_URI_VALUE]
            params[AppIDConstants.JSON_TOKEN_ENDPOINT_AUTH_METHOD_KEY] = AppIDConstants.CLIENT_SECRET_BASIC
            params[AppIDConstants.JSON_RESPONSE_TYPES_KEY] =  [AppIDConstants.JSON_CODE_KEY]
            params[AppIDConstants.JSON_GRANT_TYPES_KEY] = [AppIDConstants.authorization_code_String, AppIDConstants.PASSWORD_STRING]
            params[AppIDConstants.JSON_CLIENT_NAME_KEY] = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            params[AppIDConstants.JSON_SOFTWARE_ID_KEY] =  appIdentity.ID
            params[AppIDConstants.JSON_SOFTWARE_VERSION_KEY] =  appIdentity.version
            params[AppIDConstants.JSON_DEVICE_ID_KEY] = deviceIdentity.ID
            params[AppIDConstants.JSON_MODEL_KEY] = deviceIdentity.model
            params[AppIDConstants.JSON_OS_KEY] = deviceIdentity.OS
            
            params[AppIDConstants.JSON_CLIENT_TYPE_KEY] = AppIDConstants.MOBILE_APP_TYPE
            
            let jwks : [[String:Any]] = [try SecurityUtils.getJWKSHeader()]
            
            let keys = [
                AppIDConstants.JSON_KEYS_KEY : jwks
            ]
            
            params[AppIDConstants.JSON_JWKS_KEY] =  keys
            return params
        } catch {
            throw AppIDError.registrationError(msg: "Failed to create registration params")
        }
    }
    
    
    
    private func saveClientId(_ response:Response?) throws {
        guard let responseBody = response?.responseText, let data = responseBody.data(using: String.Encoding.utf8), let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
            throw AppIDError.jsonUtilsError(msg: "Json is malformed")
        }
        //save the clientId
        if let id = jsonResponse[caseInsensitive : AppIDConstants.client_id_String] as? String {
            preferences.clientId.set(id)
        } else {
            throw AppIDError.registrationError(msg: "Could not extract client id from response")
        }
        AppID.logger.debug(message: "client id successfully saved")
    }
    
    
}
