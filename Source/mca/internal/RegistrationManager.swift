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
    
    internal var sessionId:String = ""
    private var preferences:AuthorizationManagerPreferences
    internal static let logger = Logger.logger(name: BMSSecurityConstants.authorizationProcessManagerLoggerName)
    
    
    internal init(preferences:AuthorizationManagerPreferences)
    {
        self.preferences = preferences
        self.preferences.persistencePolicy.set(PersistencePolicy.never, shouldUpdateTokens: false);
        //generate new random session id
        sessionId = UUID().uuidString
    }
    
    internal func registerDevice(callback :@escaping BMSCompletionHandler) throws {
        preferences.clientId.clear()
        let options:RequestOptions = RequestOptions()
        options.json = try createRegistrationParams()
        options.headers = createRegistrationHeaders()
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
        let authorizationRequestManager:AuthorizationRequestManager = AuthorizationRequestManager(completionHandler: internalCallBack)
        do {
            try  authorizationRequestManager.send(getRegistrationUrl(), options: options )
        } catch {
            callback(nil, error);
        }
        
    }
    private func getRegistrationUrl() -> String {
        let registrationPath = AppID.sharedInstance.serverUrl
            + "/"
            + BMSSecurityConstants.AUTH_SERVER_NAME
            + "/"
            + "authorization/v3/apps/"
            + AppID.sharedInstance.tenantId!
            + "/"
        return registrationPath + BMSSecurityConstants.clientsInstanceEndPoint
    }
    
    
    
    private func createRegistrationParams() throws -> [String:Any]{
        do {
             try SecurityUtils.generateKeyPair(512, publicTag: BMSSecurityConstants.publicKeyIdentifier, privateTag: BMSSecurityConstants.privateKeyIdentifier)
            let deviceIdentity = MCADeviceIdentity()
            let appIdentity = MCAAppIdentity()
            var params = [String : Any]()
            params[BMSSecurityConstants.JSON_REDIRECT_URIS_KEY] = ["https://" + appIdentity.ID! + "/mobile/callback"]
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
            let strPayloadJSON = try Utils.JSONStringify(params as AnyObject)
            let strPayloadJSONBase64 = Utils.base64StringFromData(Data(strPayloadJSON.utf8), isSafeUrl: true)
            let signature = try SecurityUtils.signPayload(params, keyIds: (BMSSecurityConstants.publicKeyIdentifier, BMSSecurityConstants.privateKeyIdentifier), keySize: 512)
            params[BMSSecurityConstants.JSON_SOFTWARE_STATEMENT_KEY] = strPayloadJSONBase64 + "." + signature
            return params
        } catch {
            throw AuthorizationProcessManagerError.failedToCreateRegistrationParams
        }
    }
    
    private func createRegistrationHeaders() -> [String:String]{
        var headers = [String:String]()
        addSessionIdHeader(&headers)
        
        return headers
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
    
    private func addSessionIdHeader(_ headers:inout [String:String]) {
        headers[BMSSecurityConstants.X_WL_SESSION_HEADER_NAME] =  self.sessionId
    }
    
    
}
