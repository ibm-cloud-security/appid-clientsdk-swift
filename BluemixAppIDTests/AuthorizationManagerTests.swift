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
        XCTAssertEqual(authManager.getAuthorizationUrl(idpName: "someidp"), Config.getServerUrl(appId: AppID.sharedInstance) + AppIDConstants.OAUTH_AUTHORIZATION_PATH + "?" + AppIDConstants.JSON_RESPONSE_TYPE_KEY + "=" + AppIDConstants.JSON_CODE_KEY + "&" + AppIDConstants.JSON_SCOPE_KEY + "=" + AppIDConstants.OPEN_ID_VALUE + "&idp=someidp")
        
        // no idp, no registration data
        
        XCTAssertEqual(authManager.getAuthorizationUrl(idpName: nil), Config.getServerUrl(appId: AppID.sharedInstance) + AppIDConstants.OAUTH_AUTHORIZATION_PATH + "?" + AppIDConstants.JSON_RESPONSE_TYPE_KEY + "=" + AppIDConstants.JSON_CODE_KEY + "&" + AppIDConstants.JSON_SCOPE_KEY + "=" + AppIDConstants.OPEN_ID_VALUE)
        
        // with idp, with registration data
        
        authManager.registrationManager.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "someclient", AppIDConstants.JSON_REDIRECT_URIS_KEY : ["redirect"]] as [String:Any])
        
        XCTAssertEqual(authManager.getAuthorizationUrl(idpName: "someidp"), Config.getServerUrl(appId: AppID.sharedInstance) + AppIDConstants.OAUTH_AUTHORIZATION_PATH + "?" + AppIDConstants.JSON_RESPONSE_TYPE_KEY + "=" + AppIDConstants.JSON_CODE_KEY + "&" + AppIDConstants.client_id_String + "=someclient" + "&" + AppIDConstants.JSON_REDIRECT_URI_KEY + "=redirect" + "&" + AppIDConstants.JSON_SCOPE_KEY + "=" + AppIDConstants.OPEN_ID_VALUE + "&idp=someidp")
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
       
        // ensure registerd fails
        MockRegistrationManager.shouldFail = true
        authManager.registrationManager = MockRegistrationManager(oauthManager:OAuthManager(appId:AppID.sharedInstance))
        authManager.launchAuthorizationUI(authorizationDelegate:delegate(res: "failure", expectedErr: "Failed to register OAuth client"))
//        //mock with not error
//        authManager.registrationManager.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "someclient", AppIDConstants.JSON_REDIRECT_URIS_KEY : ["redirect"]] as [String:Any])
//        // TODO:  think how to ovveride it?
//        // no redirects
//        authManager.registrationManager.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "someclient", AppIDConstants.JSON_REDIRECT_URIS_KEY : []] as [String:Any])

        
    }

}
