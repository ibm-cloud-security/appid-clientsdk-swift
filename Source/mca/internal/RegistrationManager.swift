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
        options.parameters = try createRegistrationParams()
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
            + BMSSecurityConstants.AUTH_PATH
            + AppID.sharedInstance.tenantId!
            + "/"
        return registrationPath + BMSSecurityConstants.clientsInstanceEndPoint
    }
    
    
    
    private func createRegistrationParams() throws -> [String:String]{
        do {
             try SecurityUtils.generateKeyPair(512, publicTag: BMSSecurityConstants.publicKeyIdentifier, privateTag: BMSSecurityConstants.privateKeyIdentifier)
            let deviceIdentity = MCADeviceIdentity()
            let appIdentity = MCAAppIdentity()
            var params = [String : String]()
            params["redirect_uris"] = try? Utils.JSONStringify(["https://" + appIdentity.ID! + "/mobile/callback"] as AnyObject)
            params["token_endpoint_auth_method"] = "client_secret_basic"
            params["response_types"] =  try? Utils.JSONStringify([BMSSecurityConstants.JSON_CODE_KEY] as AnyObject)
            params["grant_types"] = try? Utils.JSONStringify([BMSSecurityConstants.authorization_code_String, "password"] as AnyObject)
            params["client_name"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            params["software_id"] =  appIdentity.ID
            params["software_version"] =  appIdentity.version
            params["device_id"] = deviceIdentity.ID
            params["device_model"] = deviceIdentity.model
            params["device_os"] = deviceIdentity.OS
            params["client_type"] = "mobileapp"
            let jwks : [[String:Any]] = [try SecurityUtils.getJWKSHeader()]
            let a = [
                "keys" : jwks
            ]

            params["jwks"] =     try? Utils.JSONStringify(a as AnyObject)
            params["software_statement"] = try SecurityUtils.signPayload(params, keyIds: (BMSSecurityConstants.publicKeyIdentifier, BMSSecurityConstants.privateKeyIdentifier), keySize: 512)
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
        if let id = jsonResponse[caseInsensitive : "client_id"] as? String {
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
