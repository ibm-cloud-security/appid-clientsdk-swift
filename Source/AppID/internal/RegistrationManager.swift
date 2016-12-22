//
//  RegistrationManager.swift
//  Pods
//
//  Created by Oded Betzalel on 11/12/2016.
//
//

import Foundation
import BMSCore
internal class RegistrationManager {
    
    private var preferences:AppIDPreferences
    internal static let logger = Logger.logger(name: BMSSecurityConstants.RegistrationManagerLoggerName)
    
    
    internal init(preferences:AppIDPreferences)
    {
        self.preferences = preferences
        self.preferences.persistencePolicy.set(PersistencePolicy.never, shouldUpdateTokens: false);
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
            + BMSSecurityConstants.V3_AUTH_PATH
            + AppID.sharedInstance.tenantId!
            + "/"
            + BMSSecurityConstants.clientsEndPoint
    }
    
    
    /*
 

 
 
 
 
 */
    private func createRegistrationParams() throws -> [String:Any]{
        do {
             try SecurityUtils.generateKeyPair(512, publicTag: BMSSecurityConstants.publicKeyIdentifier, privateTag: BMSSecurityConstants.privateKeyIdentifier)
            let deviceIdentity = AppIDDeviceIdentity()
            let appIdentity = AppIDAppIdentity()
            var params = [String : Any]()
            params[BMSSecurityConstants.JSON_REDIRECT_URIS_KEY] = [BMSSecurityConstants.REDIRECT_URI_VALUE]
            params[BMSSecurityConstants.JSON_TOKEN_ENDPOINT_AUTH_METHOD_KEY] = BMSSecurityConstants.CLIENT_SECRET_BASIC
            params[BMSSecurityConstants.JSON_RESPONSE_TYPES_KEY] =  [BMSSecurityConstants.JSON_CODE_KEY]
            params[BMSSecurityConstants.JSON_GRANT_TYPES_KEY] = [BMSSecurityConstants.authorization_code_String, BMSSecurityConstants.PASSWORD_STRING]
            params[BMSSecurityConstants.JSON_CLIENT_NAME_KEY] = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            params[BMSSecurityConstants.JSON_SOFTWARE_ID_KEY] =  appIdentity.ID
            params[BMSSecurityConstants.JSON_SOFTWARE_VERSION_KEY] =  appIdentity.version
            params[BMSSecurityConstants.JSON_DEVICE_ID_KEY] = deviceIdentity.ID
            params[BMSSecurityConstants.JSON_MODEL_KEY] = deviceIdentity.model
            params[BMSSecurityConstants.JSON_OS_KEY] = deviceIdentity.OS
            
            params[BMSSecurityConstants.JSON_CLIENT_TYPE_KEY] = BMSSecurityConstants.MOBILE_APP_TYPE
            
            let jwks : [[String:Any]] = [try SecurityUtils.getJWKSHeader()]
            
            let keys = [
                BMSSecurityConstants.JSON_KEYS_KEY : jwks
            ]
            
            params[BMSSecurityConstants.JSON_JWKS_KEY] =  keys
            return params
        } catch {
            throw AuthorizationProcessManagerError.failedToCreateRegistrationParams
        }
    }
    
    
    
    private func saveClientId(_ response:Response?) throws {
        guard let responseBody = response?.responseText, let data = responseBody.data(using: String.Encoding.utf8), let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
            throw JsonUtilsErrors.jsonIsMalformed
        }
        //save the clientId
        if let id = jsonResponse[caseInsensitive : BMSSecurityConstants.client_id_String] as? String {
            preferences.clientId.set(id)
        } else {
            throw AuthorizationProcessManagerError.couldNotExtractClientId
        }
        AppID.logger.debug(message: "client id successfully saved")
    }
    
    
}
