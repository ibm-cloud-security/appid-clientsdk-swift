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
    private var appId:AppID
    private var preferenceManager:PreferenceManager
    //TODO : no persistence policy?
    //TODO : should we implement registaraion keyStore?
    //    private var registrationKeyPair:KeyPair
    //    private var registrationKeyStore:RegistrationKeyStore
    
    internal static let logger = Logger.logger(name: AppIDConstants.RegistrationManagerLoggerName)
    
    
    internal init(oauthManager:OAuthManager)
    {
        self.appId = oauthManager.appId
        self.preferenceManager = oauthManager.preferenceManager
    }
    
    
    public func ensureRegistered(registrationDelegate:RegistrationDelegate) {
        let storedClientId:String? = self.getRegistrationDataString(name: "client_id")
        let storedTenantId:String? = self.preferenceManager.getStringPreference(name: "com.ibm.bluemix.appid.swift.tenantid").get();
        if(storedClientId != nil && self.appId.tenantId == storedTenantId) {
            RegistrationManager.logger.debug(message: "OAuth client is already registered.");
            registrationDelegate.onRegistrationSuccess();
        } else {
            RegistrationManager.logger.info(message: "Registering a new OAuth client");
            self.registerOAuthClient(callback: {(response: Response?, error: Error?) in
                //TODO: check I did guards ok
                guard error == nil else {
                    RegistrationManager.logger.error(message: "Failed to register OAuth client");
                    registrationDelegate.onRegistrationFailure(var1: "Failed to register OAuth client")
                    return
                }
                
                RegistrationManager.logger.info(message: "OAuth client successfully registered.");
                registrationDelegate.onRegistrationSuccess();
            });
        }
        
    }

    
    
    internal func registerOAuthClient(callback :@escaping BMSCompletionHandler) {
        let options:RequestOptions = RequestOptions()
        guard let registrationParams = try? createRegistrationParams() else {
            callback(nil, AppIDError.registrationError(msg: "Could not create registration params"))
            return
        }
        options.json = registrationParams
        options.requestMethod = HttpMethod.POST
        
        let internalCallBack:BMSCompletionHandler = {(response: Response?, error: Error?) in
            if error == nil {
                if let unWrappedResponse = response, unWrappedResponse.isSuccessful, let responseText = unWrappedResponse.responseText {
                        self.preferenceManager.getJSONPreference(name: "com.ibm.bluemix.appid.swift.REGISTRATION_DATA").set(try? Utils.parseJsonStringtoDictionary(responseText))
                        self.preferenceManager.getStringPreference(name: "com.ibm.bluemix.appid.swift.tenantid").set(self.appId.tenantId)
                        callback(response, nil);
                } else {
                    callback(response, error);
                }
            } else {
                callback(response, error);
            }
        }
        let appIDRequestManager:AppIDRequestManager = AppIDRequestManager(completionHandler: internalCallBack)
        do {
            try  appIDRequestManager.send(Config.getServerUrl(appId: self.appId) + "/clients", options: options )
        } catch {
            callback(nil, error);
        }
        
    }
    
    /*
     
     */
    private func createRegistrationParams() throws -> [String:Any]{
        do {
            try SecurityUtils.generateKeyPair(512, publicTag: AppIDConstants.publicKeyIdentifier, privateTag: AppIDConstants.privateKeyIdentifier)
            let deviceIdentity = BaseDeviceIdentity()
            let appIdentity = BaseAppIdentity()
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
    
    
    public func getRegistrationData() -> [String:Any]? {
        return self.preferenceManager.getJSONPreference(name: "com.ibm.bluemix.appid.swift.REGISTRATION_DATA").getAsJSON();
    }
    
    public func getRegistrationDataString(name:String) -> String? {
        guard let registrationData = self.getRegistrationData() else {
            return nil
        }
        return registrationData[name] as? String;
    }
    
    public func getRegistrationDataString(arrayName:String, arrayIndex:Int) -> String? {
        guard let registrationData = self.getRegistrationData() else {
            return nil
        }
        return (registrationData[arrayName] as? NSArray)?[arrayIndex] as? String
    }
    
    
    public func getRegistrationDataObject(name:String) -> [String:Any]? {
        guard let registrationData = self.getRegistrationData() else {
            return nil
        }
        return registrationData[name] as? [String:Any]
    }
    public func getRegistrationDataArray(name:String) -> NSArray? {
        guard let registrationData = self.getRegistrationData() else {
            return nil
        }
        return registrationData[name] as? NSArray
    }
    
    
    public func clearRegistrationData() {
        self.preferenceManager.getStringPreference(name: "com.ibm.bluemix.appid.swift.tenantid").clear();
        self.preferenceManager.getJSONPreference(name: "com.ibm.bluemix.appid.swift.REGISTRATION_DATA").clear();

    }
    
    
}
