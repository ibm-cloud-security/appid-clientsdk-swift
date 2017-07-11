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

import XCTest
import BMSCore
@testable import BluemixAppID

public class AuthorizationManagerTests : XCTestCase {

    func testGetAuthorizationUrl() {
        let authManager = BluemixAppID.AuthorizationManager(oAuthManager: OAuthManager(appId: AppID.sharedInstance))
        authManager.registrationManager.preferenceManager.getStringPreference(name: AppIDConstants.client_id_String).clear()
        authManager.registrationManager.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).clear()
        // with idp, no registration data
        XCTAssertEqual(authManager.getAuthorizationUrl(idpName: "someidp", accessToken: nil, responseType:  AppIDConstants.JSON_CODE_KEY), Config.getServerUrl(appId: AppID.sharedInstance) + AppIDConstants.OAUTH_AUTHORIZATION_PATH + "?" + AppIDConstants.JSON_RESPONSE_TYPE_KEY + "=" + AppIDConstants.JSON_CODE_KEY + "&" + AppIDConstants.JSON_SCOPE_KEY + "=" + AppIDConstants.OPEN_ID_VALUE + "&idp=someidp")

        // no idp, no registration data

        XCTAssertEqual(authManager.getAuthorizationUrl(idpName: nil, accessToken: nil, responseType:  AppIDConstants.JSON_CODE_KEY), Config.getServerUrl(appId: AppID.sharedInstance) + AppIDConstants.OAUTH_AUTHORIZATION_PATH + "?" + AppIDConstants.JSON_RESPONSE_TYPE_KEY + "=" + "code" + "&" + AppIDConstants.JSON_SCOPE_KEY + "=" + AppIDConstants.OPEN_ID_VALUE)
        
        XCTAssertEqual(authManager.getAuthorizationUrl(idpName: nil, accessToken: nil, responseType:  AppIDConstants.JSON_SIGN_UP_KEY), Config.getServerUrl(appId: AppID.sharedInstance) + AppIDConstants.OAUTH_AUTHORIZATION_PATH + "?" + AppIDConstants.JSON_RESPONSE_TYPE_KEY + "=" + "sign_up" + "&" + AppIDConstants.JSON_SCOPE_KEY + "=" + AppIDConstants.OPEN_ID_VALUE)
        
        // with idp, with registration data
        
        authManager.registrationManager.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "someclient", AppIDConstants.JSON_REDIRECT_URIS_KEY : ["redirect"]] as [String:Any])
        
        XCTAssertEqual(authManager.getAuthorizationUrl(idpName: "someidp", accessToken: nil, responseType:  AppIDConstants.JSON_CODE_KEY), Config.getServerUrl(appId: AppID.sharedInstance) + AppIDConstants.OAUTH_AUTHORIZATION_PATH + "?" + AppIDConstants.JSON_RESPONSE_TYPE_KEY + "=" + AppIDConstants.JSON_CODE_KEY + "&" + AppIDConstants.client_id_String + "=someclient" + "&" + AppIDConstants.JSON_REDIRECT_URI_KEY + "=redirect" + "&" + AppIDConstants.JSON_SCOPE_KEY + "=" + AppIDConstants.OPEN_ID_VALUE + "&idp=someidp")
        
                XCTAssertEqual(authManager.getAuthorizationUrl(idpName: "someidp", accessToken: "token", responseType:  AppIDConstants.JSON_CODE_KEY), Config.getServerUrl(appId: AppID.sharedInstance) + AppIDConstants.OAUTH_AUTHORIZATION_PATH + "?" + AppIDConstants.JSON_RESPONSE_TYPE_KEY + "=" + AppIDConstants.JSON_CODE_KEY + "&" + AppIDConstants.client_id_String + "=someclient" + "&" + AppIDConstants.JSON_REDIRECT_URI_KEY + "=redirect" + "&" + AppIDConstants.JSON_SCOPE_KEY + "=" + AppIDConstants.OPEN_ID_VALUE + "&idp=someidp" + "&appid_access_token=token")
    }
    
    
    class MockRegistrationManager: RegistrationManager {
        static var shouldFail: Bool?
        
        override func ensureRegistered(callback : @escaping (AppIDError?) -> Void) {
            if MockRegistrationManager.shouldFail == true {
                callback(AppIDError.registrationError(msg: "Failed to register OAuth client"))
            } else {
                callback(nil)
            }
        }
        
    }
    
    func testLaunchAuthorizationUI() {
         let authManager = BluemixAppID.AuthorizationManager(oAuthManager: OAuthManager(appId: AppID.sharedInstance))
        
        class delegate: AuthorizationDelegate {
            var res:String
            var expectedError:String
            static var fails:Int = 0
            static var cancel:Int = 0
            static var success:Int = 0
            public init(res:String, expectedErr:String) {
                self.expectedError = expectedErr
                self.res = res
            }
            
            func onAuthorizationFailure(error: AuthorizationError) {
                XCTAssertEqual(error.description, expectedError)
                delegate.fails += 1
                if res != "failure" {
                    XCTFail()
                }
                
            }
            
            func onAuthorizationCanceled() {
                delegate.cancel += 1
                if res != "cancel" {
                    XCTFail()
                }
            }
            
            func onAuthorizationSuccess(accessToken: AccessToken, identityToken: IdentityToken, response:Response?) {
                delegate.success += 1
                if res != "success" {
                    XCTFail()
                }
            }
            
        }

 
       
        // ensure registerd fails
        MockRegistrationManager.shouldFail = true
        authManager.registrationManager = MockRegistrationManager(oauthManager:OAuthManager(appId:AppID.sharedInstance))
        authManager.launchAuthorizationUI(authorizationDelegate:delegate(res: "failure", expectedErr: "Failed to register OAuth client"))
//        //mock with not error
//        authManager.registrationManager.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "someclient", AppIDConstants.JSON_REDIRECT_URIS_KEY : ["redirect"]] as [String:Any])
        // TODO:  think how to ovveride it?
//        // no redirects
//        authManager.registrationManager.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "someclient", AppIDConstants.JSON_REDIRECT_URIS_KEY : []] as [String:Any])

        
    }
    
    
    func testLaunchSignUpAuthorizationUI() {
        let authManager = BluemixAppID.AuthorizationManager(oAuthManager: OAuthManager(appId: AppID.sharedInstance))
        
        class delegate: AuthorizationDelegate {
            var res:String
            var expectedError:String
            static var fails:Int = 0
            static var cancel:Int = 0
            static var success:Int = 0
            public init(res:String, expectedErr:String) {
                self.expectedError = expectedErr
                self.res = res
            }
            
            func onAuthorizationFailure(error: AuthorizationError) {
                XCTAssertEqual(error.description, expectedError)
                delegate.fails += 1
                if res != "failure" {
                    XCTFail()
                }
                
            }
            
            func onAuthorizationCanceled() {
                delegate.cancel += 1
                if res != "cancel" {
                    XCTFail()
                }
            }
            
            func onAuthorizationSuccess(accessToken: AccessToken, identityToken: IdentityToken, response:Response?) {
                delegate.success += 1
                if res != "success" {
                    XCTFail()
                }
            }
            
        }
        
        
        
        // ensure registerd fails
        MockRegistrationManager.shouldFail = true
        authManager.registrationManager = MockRegistrationManager(oauthManager:OAuthManager(appId:AppID.sharedInstance))
        authManager.launchSignUpAuthorizationUI(authorizationDelegate:delegate(res: "failure", expectedErr: "Failed to register OAuth client"))
        //        //mock with not error
        //        authManager.registrationManager.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "someclient", AppIDConstants.JSON_REDIRECT_URIS_KEY : ["redirect"]] as [String:Any])
        // TODO:  think how to ovveride it?
        //        // no redirects
        //        authManager.registrationManager.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "someclient", AppIDConstants.JSON_REDIRECT_URIS_KEY : []] as [String:Any])
        
    }

    
    class MockTokenManager: TokenManager {
        var shouldCallObtain = true
        
        override func obtainTokens(code: String, authorizationDelegate: AuthorizationDelegate) {
            if !shouldCallObtain {
                XCTFail()
            } else {
                
            }
        }
        
    }
    
    class MockAuthorizationManager: BluemixAppID.AuthorizationManager {
         var response : Response? = nil
         var error : Error? = nil
        
        override func sendRequest(request: Request, internalCallBack: @escaping BMSCompletionHandler) {
                internalCallBack(response, error)
        }
        
    }
    
    
    func testLoginAnonymously() {
          let authManager = MockAuthorizationManager(oAuthManager: OAuthManager(appId: AppID.sharedInstance))
        authManager.registrationManager = MockRegistrationManager(oauthManager:OAuthManager(appId:AppID.sharedInstance))
        let originalTokenManager = authManager.appid.oauthManager?.tokenManager
        authManager.appid.oauthManager?.tokenManager = MockTokenManager(oAuthManager: authManager.appid.oauthManager!)
        
        class SomeError : Error {
            
        }
        class delegate: AuthorizationDelegate {
            var failed = false
            
            func onAuthorizationFailure(error: AuthorizationError) {
                failed = true
            }
            
            func onAuthorizationCanceled() {
                
            }
            
            func onAuthorizationSuccess(accessToken: AccessToken, identityToken: IdentityToken, response:Response?) {
               
            }
            
        }
        
        let del = delegate()
        
        // happy flow:
        let redirect = AppIDConstants.REDIRECT_URI_VALUE
                let goodData = "Found. Redirecting to "+redirect+"?code=w7DClMOnf03Dg8OxeyHCrwzChDXCnsOcw4cSw4nDuU_Dqkcmdy1zwoVKw5xEQMO5CsKYVcOiRsKYw4_Ds8OsBAfCpABrw4sAwqnDr37DiMOQwq7CjXMmw4PCt1knw7vCsMOXGHnCvBQ4wq7DjzMrDAJpwoHCmcKxAxbCjcKHSg1dw4vDr8OhHzE9w57CpygtIcOGwrE_wqdjwpw-VSvDg8K-wr7DvjTCoTMhwrV1w5Y6VGNPJG5IWwFFwqzCl8OAw4TDl8OefMOzSE1ofE4OQVTDkMOnPsO5wpTDuGPDigjDjFbDnkvDrVgWw7TClzjCk8O3AsKrRXLDjMKTwrbDv8Kmd0Nlw7rCn0LDgMKRCW_DtcKJOMK4wrjDpEJ-wqs"
let badData = "Found. Redirecting to "+redirect+"?error=ERROR1"
        let response = Response(responseData: goodData.data(using: .utf8), httpResponse: nil, isRedirect: false)
        
        authManager.response = response
        authManager.error = nil
        MockRegistrationManager.shouldFail = false
        authManager.loginAnonymously(accessTokenString: nil,allowCreateNewAnonymousUsers: true, authorizationDelegate: del)
        
        // sad flow 1: registration error
        MockRegistrationManager.shouldFail = true
        authManager.loginAnonymously(accessTokenString: nil,allowCreateNewAnonymousUsers: true, authorizationDelegate: del)
        if !del.failed {
            XCTFail()
        }
        del.failed = false
        MockRegistrationManager.shouldFail = false
        
        // sad flow 2: error instead of response:
        authManager.response = nil
        authManager.error = SomeError()
        authManager.loginAnonymously(accessTokenString: nil,allowCreateNewAnonymousUsers: true, authorizationDelegate: del)
        if !del.failed {
            XCTFail()
        }
        del.failed = false
        
        // sad flow 3: response from auth server is bad:
        authManager.response = Response(responseData: "Obviously this is not a url, the auth server will never return this, but we need to make sure we can handle it anyway".data(using: .utf8), httpResponse: nil, isRedirect: false)
        authManager.error = nil
        authManager.loginAnonymously(accessTokenString: nil, allowCreateNewAnonymousUsers: true, authorizationDelegate: del)
        if !del.failed {
            XCTFail()
        }
        del.failed = false
        
        // sad flow 4: response from auth server is bad:
        
        authManager.response = Response(responseData: badData.data(using: .utf8), httpResponse: nil, isRedirect: false)
        authManager.error = nil
        authManager.loginAnonymously(accessTokenString: nil,allowCreateNewAnonymousUsers: true, authorizationDelegate: del)
        if !del.failed {
            XCTFail()
        }
        del.failed = false
        
        authManager.appid.oauthManager?.tokenManager = originalTokenManager
        
    }
    
    func testObtainTokensWithROP() {
        let authManager = MockAuthorizationManager(oAuthManager: OAuthManager(appId: AppID.sharedInstance))
        authManager.registrationManager = MockRegistrationManager(oauthManager:OAuthManager(appId:AppID.sharedInstance))
        let originalTokenManager = authManager.appid.oauthManager?.tokenManager
        authManager.appid.oauthManager?.tokenManager = MockTokenManager(oAuthManager: authManager.appid.oauthManager!)
        
        class SomeError : Error {
            
        }
        class delegate: TokenResponseDelegate {
            var failed = false
            
            func onAuthorizationFailure(error: AuthorizationError) {
                failed = true
            }
            
            func onAuthorizationSuccess(accessToken: AccessToken, identityToken: IdentityToken, response:Response?) {
                
            }
            
        }
        
        let del = delegate()
        
        // happy flow:
        authManager.error = nil
        MockRegistrationManager.shouldFail = false
        authManager.obtainTokensWithROP(username: "testUsername", password: "testPassword", tokenResponseDelegate: del)
        
        // sad flow 1: registration error
        MockRegistrationManager.shouldFail = true
        authManager.obtainTokensWithROP(username: "testUsername", password: "testPassword", tokenResponseDelegate: del)
        if !del.failed {
            XCTFail()
        }
        del.failed = false
        MockRegistrationManager.shouldFail = false
        
        authManager.appid.oauthManager?.tokenManager = originalTokenManager
    }


}
