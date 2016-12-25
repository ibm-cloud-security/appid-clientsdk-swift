//
//  TokenManager.swift
//  Pods
//
//  Created by Oded Betzalel on 11/12/2016.
//
//

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
        let signed = try? SecurityUtils.signString(username, keyIds: (BMSSecurityConstants.publicKeyIdentifier, BMSSecurityConstants.privateKeyIdentifier), keySize: 512)
        headers[BMSSecurityConstants.AUTHORIZATION_HEADER] = BMSSecurityConstants.BASIC_AUTHORIZATION_STRING + " " + (username + ":" + signed!).data(using: .utf8)!.base64EncodedString()
        return headers
    }
    
    private func createTokenRequestParams(_ grantCode:String) throws -> [String : String]{
        guard let clientId = preferences.clientId.get() else {
            throw AppIDError.tokenRequestError(msg: "Client is not registered")
        }
        let params : [String : String] = [
            BMSSecurityConstants.JSON_CODE_KEY : grantCode,
            BMSSecurityConstants.client_id_String :  clientId,
            BMSSecurityConstants.JSON_GRANT_TYPE_KEY : BMSSecurityConstants.authorization_code_String,
            BMSSecurityConstants.JSON_REDIRECT_URI_KEY :BMSSecurityConstants.REDIRECT_URI_VALUE
        ]
        return params;
    }
    
    
    private func saveTokenFromResponse(_ response:Response) throws {
        do {
            if let data = response.responseData, let responseJson =  try JSONSerialization.jsonObject(with: data as Data, options: []) as? [String:Any]{
                if let accessTokenFromResponse = responseJson[caseInsensitive : BMSSecurityConstants.JSON_ACCESS_TOKEN_KEY] as? String, let idTokenFromResponse =
                    responseJson[caseInsensitive : BMSSecurityConstants.JSON_ID_TOKEN_KEY] as? String {
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
            if let decodedIdTokenData = Utils.decodeBase64WithString(idToken.components(separatedBy: ".")[1], isSafeUrl: true), let _ = String(data: decodedIdTokenData, encoding: String.Encoding.utf8), let decodedIdTokenString = String(data: decodedIdTokenData, encoding: String.Encoding.utf8), let userIdentity = try Utils.parseJsonStringtoDictionary(decodedIdTokenString)[caseInsensitive : BMSSecurityConstants.JSON_IMF_USER_KEY] as? [String:Any] {
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
            + BMSSecurityConstants.V3_AUTH_PATH
            + AppID.sharedInstance.tenantId!
        return tokenUrl + "/" + BMSSecurityConstants.tokenEndPoint
    }

    
    
    
}
