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
        SecurityUtils.deleteCertificateFromKeyChain(BMSSecurityConstants.certificateIdentifier)
        let options:RequestOptions = RequestOptions()
        options.parameters = try createRegistrationParams()
        options.headers = createRegistrationHeaders()
        options.requestMethod = HttpMethod.POST
        
        let internalCallBack:BMSCompletionHandler = {(response: Response?, error: Error?) in
            if error == nil {
                if let unWrappedResponse = response, unWrappedResponse.isSuccessful {
                    do {
                        try self.saveCertificateFromResponse(response)
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
            var params = [String:String]()
            try SecurityUtils.generateKeyPair(512, publicTag: BMSSecurityConstants.publicKeyIdentifier, privateTag: BMSSecurityConstants.privateKeyIdentifier)
            let csrValue:String = try SecurityUtils.signCsr(BMSSecurityConstants.deviceInfo, keyIds: (BMSSecurityConstants.publicKeyIdentifier, BMSSecurityConstants.privateKeyIdentifier), keySize: 512)
            params[BMSSecurityConstants.JSON_CSR_KEY] = csrValue
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
    
    
    private func saveCertificateFromResponse(_ response:Response?) throws {
        guard let responseBody:String? = response?.responseText, let data = responseBody?.data(using: String.Encoding.utf8) else {
            throw JsonUtilsErrors.jsonIsMalformed
        }
        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any], let certificateString = jsonResponse[caseInsensitive : BMSSecurityConstants.JSON_CERTIFICATE_KEY] as? String {
                //handle certificate
                let certificate =  try SecurityUtils.getCertificateFromString(certificateString)
                try  SecurityUtils.checkCertificatePublicKeyValidity(certificate, publicKeyTag: BMSSecurityConstants.publicKeyIdentifier)
                try SecurityUtils.saveCertificateToKeyChain(certificate, certificateLabel: BMSSecurityConstants.certificateIdentifier)
                
                //save the clientId separately
                if let id = jsonResponse[caseInsensitive : BMSSecurityConstants.JSON_CLIENT_ID_KEY] as? String? {
                    preferences.clientId.set(id)
                } else {
                    throw AuthorizationProcessManagerError.certificateDoesNotIncludeClientId                     }
            }else {
                throw AuthorizationProcessManagerError.responseDoesNotIncludeCertificate
            }
        }
        AppID.logger.debug(message: "certificate successfully saved")
    }
    private func addSessionIdHeader(_ headers:inout [String:String]) {
        headers[BMSSecurityConstants.X_WL_SESSION_HEADER_NAME] =  self.sessionId
    }
    
    
}
