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
            
            func onAuthorizationSuccess(accessToken: AccessToken?,
                                        identityToken: IdentityToken?,
                                        refreshToken: RefreshToken?,
                                        response:Response?) {
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
    
    func testNoId() {
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
            
            func onAuthorizationSuccess(accessToken: AccessToken?,
                                        identityToken: IdentityToken?,
                                        refreshToken: RefreshToken?,
                                        response:Response?) {
                delegate.success += 1
                if res != "success" {
                    XCTFail()
                }
            }
            
        }
        testLaunchChangePasswordAuthorizationUI_NO_IDToken(authManager: authManager, delegate:delegate(res: "failure", expectedErr: "No identity token found."))
        testLaunchChangeDetailsAuthorizationUI_NO_IDToken(authManager: authManager, delegate:delegate(res: "failure", expectedErr: "No identity token found."))
    }
    
    func testLaunchChangePasswordAuthorizationUI_NO_IDToken(authManager: BluemixAppID.AuthorizationManager, delegate: AuthorizationDelegate) {
        authManager.launchChangePasswordUI(authorizationDelegate: delegate)
        
    }
    
    func testLaunchChangeDetailsAuthorizationUI_NO_IDToken(authManager: BluemixAppID.AuthorizationManager, delegate: AuthorizationDelegate) {
        authManager.launchChangeDetailsUI(authorizationDelegate:delegate)
        
    }
    
    
    func test_ID_Token_Not_Of_CD() {
        let oAuthManager = OAuthManager(appId: AppID.sharedInstance)
        let authManager = BluemixAppID.AuthorizationManager(oAuthManager: oAuthManager)
        
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
            
            func onAuthorizationSuccess(accessToken: AccessToken?,
                                        identityToken: IdentityToken?,
                                        refreshToken: RefreshToken?,
                                        response:Response?) {
                delegate.success += 1
                if res != "success" {
                    XCTFail()
                }
            }
            
        }
        //id token not from cloud directory
        let data = "{\"access_token\":\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpPU0UifQ.eyJpc3MiOiJtb2JpbGVjbGllbnRhY2Nlc3Muc3RhZ2UxLm5nLmJsdWVtaXgubmV0IiwiZXhwIjoxNDg3MDY2MzAyLCJhdWQiOiIxN2UxMjg5YjY3YTUzMjAwNDgxN2E1YTBiZDMxMzliOWNhYzg0MTQ4IiwiaWF0IjoxNDg3MDYyNzAyLCJhdXRoX2J5IjoiZmFjZWJvb2siLCJ0ZW5hbnQiOiI0ZGJhOTQzMC01NGU2LTRjZjItYTUxNi02ZjczZmViNzAyYmIiLCJzY29wZSI6ImFwcGlkX2RlZmF1bHQgYXBwaWRfcmVhZHByb2ZpbGUgYXBwaWRfcmVhZHVzZXJhdHRyIGFwcGlkX3dyaXRldXNlcmF0dHIifQ.enUpEwjdXGJYF9VHolYcKpT8yViYBCbcxp7p7e3n2JamUx68EDEwVPX3qQTyFCz4cXhGmhF8d3rsNGNxMuglor_LRhHDIzHtN5CPi0aqCh3QuF1dQrRBbmjOk2zjinP6pp5WaZvpbush8LEVa8CiZ3Cy2l9IHdY5f4ApKuh29oOj860wwrauYovX2M0f7bDLSwgwXTXydb9-ooawQI7NKkZOlVDI_Bxawmh34VLgAwepyqOR_38YEWyJm7mocJEkT4dqKMaGQ5_WW564JHtqy8D9kIsoN6pufIyr427ApsCdcj_KcYdCdZtJAgiP5x9J5aNmKLsyJYNZKtk2HTMmlw\",\"id_token\":\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpPU0UifQ.eyJpc3MiOiJtb2JpbGVjbGllbnRhY2Nlc3Muc3RhZ2UxLm5nLmJsdWVtaXgubmV0IiwiYXVkIjoiMTdlMTI4OWI2N2E1MzIwMDQ4MTdhNWEwYmQzMTM5YjljYWM4NDE0OCIsImV4cCI6MTQ4NzA2NjMwMiwiYXV0aF9ieSI6ImZhY2Vib29rIiwidGVuYW50IjoiNGRiYTk0MzAtNTRlNi00Y2YyLWE1MTYtNmY3M2ZlYjcwMmJiIiwiaWF0IjoxNDg3MDYyNzAyLCJuYW1lIjoiRG9uIExvbiIsImVtYWlsIjoiZG9ubG9ucXdlcnR5QGdtYWlsLmNvbSIsImdlbmRlciI6Im1hbGUiLCJsb2NhbGUiOiJlbl9VUyIsInBpY3R1cmUiOiJodHRwczovL3Njb250ZW50Lnh4LmZiY2RuLm5ldC92L3QxLjAtMS9wNTB4NTAvMTM1MDE1NTFfMjg2NDA3ODM4Mzc4ODkyXzE3ODU3NjYyMTE3NjY3MzA2OTdfbi5qcGc_b2g9MjQyYmMyZmI1MDU2MDliNDQyODc0ZmRlM2U5ODY1YTkmb2U9NTkwN0IxQkMiLCJpZGVudGl0aWVzIjpbeyJwcm92aWRlciI6ImZhY2Vib29rIiwiaWQiOiIzNzc0NDAxNTkyNzU2NTkifV0sIm9hdXRoX2NsaWVudCI6eyJuYW1lIjoiT2RlZEFwcElEYXBwaWQiLCJ0eXBlIjoibW9iaWxlYXBwIiwic29mdHdhcmVfaWQiOiJPZGVkQXBwSURhcHBpZElEIiwic29mdHdhcmVfdmVyc2lvbiI6IjEuMCIsImRldmljZV9pZCI6Ijk5MDI0Njg4LUZGMTktNDg4Qy04RjJELUY3MTY2MDZDQTU5NCIsImRldmljZV9tb2RlbCI6ImlQaG9uZSIsImRldmljZV9vcyI6ImlQaG9uZSBPUyJ9fQ.kFPUtpi9AROmBvQqPa19LgX18aYSSbnjlea4Hg0OA4UUw8XYnuoufBWpmmzDpaqZVnN5LTWg9YK5-wtB5Hi9YwX8bhklkeciHP_1ue-fyNDLN2uCNUvBxh916mgFy8u1gFicBcCzQkVoSDSL4Pcjgo0VoTla8t36wLFRtEKmBQ-p8UOlvjD-dnAoNBDveUsNNyeaLMdVPRRfXi-RYWOH3E9bjvyhHd-Zea2OX3oC1XRpqNgrUBXQblskOi_mEll_iWAUX5oD23tOZB9cb0eph9B6_tDZutgvaY338ZD1W9St6YokIL8IltKbrX3q1_FFJSu9nfNPgILsKIAKqe9fHQ\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenManager:TokenManager = TokenManager(oAuthManager: oAuthManager)
        tokenManager.extractTokens(response: response, tokenResponseDelegate: delegate(res:"success", expectedErr: ""))
        oAuthManager.tokenManager = tokenManager
        
        testLaunchChangePassword_ID_Token_Not_Of_CD(authManager: authManager, delegate:delegate(res: "failure", expectedErr: "The identity token was not retrieved using cloud directory idp."))
        testLaunchChangeDetails_ID_Token_Not_Of_CD(authManager: authManager, delegate:delegate(res: "failure", expectedErr: "The identity token was not retrieved using cloud directory idp."))
        
    }
    
    func testLaunchChangePassword_ID_Token_Not_Of_CD(authManager: BluemixAppID.AuthorizationManager, delegate: AuthorizationDelegate) {
        authManager.launchChangePasswordUI(authorizationDelegate: delegate)
        
    }
    
    func testLaunchChangeDetails_ID_Token_Not_Of_CD(authManager: BluemixAppID.AuthorizationManager, delegate: AuthorizationDelegate) {
        authManager.launchChangeDetailsUI(authorizationDelegate:delegate)
        
    }
    
    func testLaunchChangePassword_success() {
        let oAuthManager = OAuthManager(appId: AppID.sharedInstance)
        AppID.sharedInstance.initialize(tenantId: "tenant1", bluemixRegion: "region2")
        let authManager = BluemixAppID.AuthorizationManager(oAuthManager: oAuthManager)
        
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
            
            func onAuthorizationSuccess(accessToken: AccessToken?,
                                        identityToken: IdentityToken?,
                                        refreshToken: RefreshToken?,
                                        response:Response?) {
                delegate.success += 1
                if res != "success" {
                    XCTFail()
                }
            }
            
        }
        //id token from cloud directory
        let data = "{\"access_token\":\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpPU0UifQ.eyJpc3MiOiJtb2JpbGVjbGllbnRhY2Nlc3Muc3RhZ2UxLm5nLmJsdWVtaXgubmV0IiwiZXhwIjoxNDg3MDY2MzAyLCJhdWQiOiIxN2UxMjg5YjY3YTUzMjAwNDgxN2E1YTBiZDMxMzliOWNhYzg0MTQ4IiwiaWF0IjoxNDg3MDYyNzAyLCJhdXRoX2J5IjoiZmFjZWJvb2siLCJ0ZW5hbnQiOiI0ZGJhOTQzMC01NGU2LTRjZjItYTUxNi02ZjczZmViNzAyYmIiLCJzY29wZSI6ImFwcGlkX2RlZmF1bHQgYXBwaWRfcmVhZHByb2ZpbGUgYXBwaWRfcmVhZHVzZXJhdHRyIGFwcGlkX3dyaXRldXNlcmF0dHIifQ.enUpEwjdXGJYF9VHolYcKpT8yViYBCbcxp7p7e3n2JamUx68EDEwVPX3qQTyFCz4cXhGmhF8d3rsNGNxMuglor_LRhHDIzHtN5CPi0aqCh3QuF1dQrRBbmjOk2zjinP6pp5WaZvpbush8LEVa8CiZ3Cy2l9IHdY5f4ApKuh29oOj860wwrauYovX2M0f7bDLSwgwXTXydb9-ooawQI7NKkZOlVDI_Bxawmh34VLgAwepyqOR_38YEWyJm7mocJEkT4dqKMaGQ5_WW564JHtqy8D9kIsoN6pufIyr427ApsCdcj_KcYdCdZtJAgiP5x9J5aNmKLsyJYNZKtk2HTMmlw\",\"id_token\":\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpPU0UiLCJraWQiOiJvS3dTY21CRFdITjBMVEhnVDRpQjhpMjdZUjNYOF9IRWQ3Smo2RlEtcHhVIn0.eyJpc3MiOiJhcHBpZC1vYXV0aC5zdGFnZTEubXlibHVlbWl4Lm5ldCIsImF1ZCI6IjQxNDIzNzZmYjFiYjU1ZjE4ZjQxNTE0ZmU4NWNlMGQ2MjlmZjk0YmYiLCJleHAiOjE1MDA1NTE4NzUsInRlbmFudCI6IjIyOGUzMGMyLWM3ZWMtNGUwZS04ZWQxLTZhZWMwZTkzZDRlYSIsImlhdCI6MTUwMDU0ODI3NSwiZW1haWwiOiJyb3RlbUBpYm0uY29tIiwibmFtZSI6InJvdGVtQGlibS5jb20iLCJzdWIiOiI1ZWY3NjQ3Mi0xMGM0LTQ4YmItYTRlMS1iOTg1OGFhODdmODgiLCJpZGVudGl0aWVzIjpbeyJwcm92aWRlciI6ImNsb3VkX2RpcmVjdG9yeSIsImlkIjoiYmQ5OGU3YTgtNjAzNS00ZTA3LTlkOTQtMDRjMDRjOWZkN2FiIn1dLCJhbXIiOlsiY2xvdWRfZGlyZWN0b3J5Il0sIm9hdXRoX2NsaWVudCI6eyJuYW1lIjoiYXBwaWQiLCJ0eXBlIjoibW9iaWxlYXBwIiwic29mdHdhcmVfaWQiOiJjb20uaWJtLm1vYmlsZWZpcnN0cGxhdGZvcm0uYXBwaWQiLCJzb2Z0d2FyZV92ZXJzaW9uIjoiMS4wIiwiZGV2aWNlX2lkIjoiZjNhZWQ3ZWEtMGUzNC0zNGM0LWI2NDgtMTJjZTQwYmE5ZWFhIiwiZGV2aWNlX21vZGVsIjoiQW5kcm9pZCBTREsgYnVpbHQgZm9yIHg4Nl82NCIsImRldmljZV9vcyI6ImFuZHJvaWQifX0.A-cHskvxS947usTLm90DtOYh7qyyvZi61D3XUIZ2Kxtw6mJE_ShsTtsR0b1uavYVyZTXUeD6bqKKzEqDD8TDpB7KO8gAePuUdMyMPF-ObVcgF3mzHzusWOHUiVUr0sbtF-i9YbyPwO4r6cs_GhhfeY05e4sDL7Gy9l2ab9IoSOJ-zDGe4_cJjkevbZ6Sl31PcRqz89wip5ixvhhvApkusojKcO-WG-6hDLWKrlf8Iz5AP4YLN5vpB7-9nCS2Z5whRnlr9kVyott8h6AREI_pvcjUUCvA7hrhiVJv38oS6yeTMeWPj4Q5RI9iYdF3rzFVw44ODnIKtXeP9IOzJEvlqA\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenManager:TokenManager = TokenManager(oAuthManager: oAuthManager)
        tokenManager.extractTokens(response: response, tokenResponseDelegate: delegate(res:"success", expectedErr: ""))
        oAuthManager.tokenManager = tokenManager
        authManager.launchChangePasswordUI(authorizationDelegate:delegate(res:"", expectedErr:""))
        XCTAssertEqual(authManager.authorizationUIManager?.redirectUri as String!, "redirect")
        let expectedUrl: String! = "https://appid-oauthregion2/oauth/v3/tenant1/cloud_directory/change_password?user_id=bd98e7a8-6035-4e07-9d94-04c04c9fd7ab&client_id=someclient&redirect_uri=redirect"
        XCTAssertEqual(authManager.authorizationUIManager?.authorizationUrl as String!, expectedUrl)
    }
    
    func tests_launchDetails() {
        let oAuthManager = OAuthManager(appId: AppID.sharedInstance)
        AppID.sharedInstance.initialize(tenantId: "tenant1", bluemixRegion: "region2")
        let authManager = MockAuthorizationManagerWithGoodResponse(oAuthManager: oAuthManager)
        let authManagerNoCode = MockAuthorizationManager(oAuthManager: oAuthManager)
        let authManagerRequestError = MockAuthorizationManagerWithRequestError(oAuthManager: oAuthManager)
        
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
            
            func onAuthorizationSuccess(accessToken: AccessToken?,
                                        identityToken: IdentityToken?,
                                        refreshToken: RefreshToken?,
                                        response:Response?) {
                delegate.success += 1
                if res != "success" {
                    XCTFail()
                }
            }
            
        }
        //id token from cloud directory
        let data = "{\"access_token\":\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpPU0UifQ.eyJpc3MiOiJtb2JpbGVjbGllbnRhY2Nlc3Muc3RhZ2UxLm5nLmJsdWVtaXgubmV0IiwiZXhwIjoxNDg3MDY2MzAyLCJhdWQiOiIxN2UxMjg5YjY3YTUzMjAwNDgxN2E1YTBiZDMxMzliOWNhYzg0MTQ4IiwiaWF0IjoxNDg3MDYyNzAyLCJhdXRoX2J5IjoiZmFjZWJvb2siLCJ0ZW5hbnQiOiI0ZGJhOTQzMC01NGU2LTRjZjItYTUxNi02ZjczZmViNzAyYmIiLCJzY29wZSI6ImFwcGlkX2RlZmF1bHQgYXBwaWRfcmVhZHByb2ZpbGUgYXBwaWRfcmVhZHVzZXJhdHRyIGFwcGlkX3dyaXRldXNlcmF0dHIifQ.enUpEwjdXGJYF9VHolYcKpT8yViYBCbcxp7p7e3n2JamUx68EDEwVPX3qQTyFCz4cXhGmhF8d3rsNGNxMuglor_LRhHDIzHtN5CPi0aqCh3QuF1dQrRBbmjOk2zjinP6pp5WaZvpbush8LEVa8CiZ3Cy2l9IHdY5f4ApKuh29oOj860wwrauYovX2M0f7bDLSwgwXTXydb9-ooawQI7NKkZOlVDI_Bxawmh34VLgAwepyqOR_38YEWyJm7mocJEkT4dqKMaGQ5_WW564JHtqy8D9kIsoN6pufIyr427ApsCdcj_KcYdCdZtJAgiP5x9J5aNmKLsyJYNZKtk2HTMmlw\",\"id_token\":\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpPU0UiLCJraWQiOiJvS3dTY21CRFdITjBMVEhnVDRpQjhpMjdZUjNYOF9IRWQ3Smo2RlEtcHhVIn0.eyJpc3MiOiJhcHBpZC1vYXV0aC5zdGFnZTEubXlibHVlbWl4Lm5ldCIsImF1ZCI6IjQxNDIzNzZmYjFiYjU1ZjE4ZjQxNTE0ZmU4NWNlMGQ2MjlmZjk0YmYiLCJleHAiOjE1MDA1NTE4NzUsInRlbmFudCI6IjIyOGUzMGMyLWM3ZWMtNGUwZS04ZWQxLTZhZWMwZTkzZDRlYSIsImlhdCI6MTUwMDU0ODI3NSwiZW1haWwiOiJyb3RlbUBpYm0uY29tIiwibmFtZSI6InJvdGVtQGlibS5jb20iLCJzdWIiOiI1ZWY3NjQ3Mi0xMGM0LTQ4YmItYTRlMS1iOTg1OGFhODdmODgiLCJpZGVudGl0aWVzIjpbeyJwcm92aWRlciI6ImNsb3VkX2RpcmVjdG9yeSIsImlkIjoiYmQ5OGU3YTgtNjAzNS00ZTA3LTlkOTQtMDRjMDRjOWZkN2FiIn1dLCJhbXIiOlsiY2xvdWRfZGlyZWN0b3J5Il0sIm9hdXRoX2NsaWVudCI6eyJuYW1lIjoiYXBwaWQiLCJ0eXBlIjoibW9iaWxlYXBwIiwic29mdHdhcmVfaWQiOiJjb20uaWJtLm1vYmlsZWZpcnN0cGxhdGZvcm0uYXBwaWQiLCJzb2Z0d2FyZV92ZXJzaW9uIjoiMS4wIiwiZGV2aWNlX2lkIjoiZjNhZWQ3ZWEtMGUzNC0zNGM0LWI2NDgtMTJjZTQwYmE5ZWFhIiwiZGV2aWNlX21vZGVsIjoiQW5kcm9pZCBTREsgYnVpbHQgZm9yIHg4Nl82NCIsImRldmljZV9vcyI6ImFuZHJvaWQifX0.A-cHskvxS947usTLm90DtOYh7qyyvZi61D3XUIZ2Kxtw6mJE_ShsTtsR0b1uavYVyZTXUeD6bqKKzEqDD8TDpB7KO8gAePuUdMyMPF-ObVcgF3mzHzusWOHUiVUr0sbtF-i9YbyPwO4r6cs_GhhfeY05e4sDL7Gy9l2ab9IoSOJ-zDGe4_cJjkevbZ6Sl31PcRqz89wip5ixvhhvApkusojKcO-WG-6hDLWKrlf8Iz5AP4YLN5vpB7-9nCS2Z5whRnlr9kVyott8h6AREI_pvcjUUCvA7hrhiVJv38oS6yeTMeWPj4Q5RI9iYdF3rzFVw44ODnIKtXeP9IOzJEvlqA\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenManager:TokenManager = TokenManager(oAuthManager: oAuthManager)
        tokenManager.extractTokens(response: response, tokenResponseDelegate: delegate(res:"success", expectedErr: ""))
        oAuthManager.tokenManager = tokenManager
        
        testLaunchChangeDetails_success(authManager: authManager, delegate:delegate(res:"", expectedErr:""))
        testLaunchChangeDetails_no_code(authManager: authManagerNoCode, delegate:delegate(res:"failure", expectedErr:"Failed to extract code"))
        testLaunchChangeDetails_request_error(authManager: authManagerRequestError, delegate:delegate(res:"failure", expectedErr:"Unable to get response from server"))
    }
    
    func testLaunchChangeDetails_success(authManager: BluemixAppID.AuthorizationManager, delegate: AuthorizationDelegate) {
        authManager.launchChangeDetailsUI(authorizationDelegate:delegate)
        XCTAssertEqual(authManager.authorizationUIManager?.redirectUri as String!, "redirect")
        let expectedUrl: String! = "https://appid-oauthregion2/oauth/v3/tenant1/cloud_directory/change_details?code=1234&client_id=someclient&redirect_uri=redirect"
        XCTAssertEqual(authManager.authorizationUIManager?.authorizationUrl as String!, expectedUrl)
    }
    
    func testLaunchChangeDetails_no_code(authManager: BluemixAppID.AuthorizationManager, delegate: AuthorizationDelegate) {
        authManager.launchChangeDetailsUI(authorizationDelegate:delegate)
    }
    
    func testLaunchChangeDetails_request_error(authManager: BluemixAppID.AuthorizationManager, delegate: AuthorizationDelegate) {
        authManager.launchChangeDetailsUI(authorizationDelegate:delegate)
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
            
            func onAuthorizationSuccess(accessToken: AccessToken?,
                                        identityToken: IdentityToken?,
                                        refreshToken: RefreshToken?,
                                        response:Response?) {
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
    
    func testLaunchForgotPasswordUI_registration_fails() {
        let authManager = BluemixAppID.AuthorizationManager(oAuthManager: OAuthManager(appId: AppID.sharedInstance))
        
        class delegate: AuthorizationDelegate {
            var res:String
            var expectedError:String
            static var cancel:Int = 0
            static var fails:Int = 0
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
            
            func onAuthorizationSuccess(accessToken: AccessToken?,
                                        identityToken: IdentityToken?,
                                        refreshToken: RefreshToken?,
                                        response:Response?) {
                delegate.success += 1
                if res != "success" {
                    XCTFail()
                }
            }
            
        }
        
        // ensure registerd fails
        MockRegistrationManager.shouldFail = true
        authManager.registrationManager = MockRegistrationManager(oauthManager:OAuthManager(appId:AppID.sharedInstance))
        authManager.launchForgotPasswordUI(authorizationDelegate: delegate(res: "failure", expectedErr: "Failed to register OAuth client"))
        
    }
    
    func testLaunchForgotPasswordUI_registration_success() {
        let authManager = BluemixAppID.AuthorizationManager(oAuthManager: OAuthManager(appId: AppID.sharedInstance))
        
        class delegate: AuthorizationDelegate {
            var res:String
            var expectedError:String
            static var cancel:Int = 0
            static var fails:Int = 0
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
            
            func onAuthorizationSuccess(accessToken: AccessToken?,
                                        identityToken: IdentityToken?,
                                        refreshToken: RefreshToken?,
                                        response:Response?) {
                delegate.success += 1
                if res != "success" {
                    XCTFail()
                }
            }
            
        }
        
        AppID.sharedInstance.initialize(tenantId: "tenant1", bluemixRegion: ".region2")
        MockRegistrationManager.shouldFail = false
        authManager.registrationManager = MockRegistrationManager(oauthManager:OAuthManager(appId:AppID.sharedInstance))
        authManager.launchForgotPasswordUI(authorizationDelegate: delegate(res: "failure", expectedErr: ""))
        
        let expectedUrl: String! = "https://appid-oauth.region2/oauth/v3/tenant1/cloud_directory/forgot_password?client_id=someclient&redirect_uri=redirect"
        XCTAssertEqual(authManager.authorizationUIManager?.authorizationUrl as String!, expectedUrl)
        
    }
    
    
    class MockTokenManager: TokenManager {
        var shouldCallObtain = true
        
        override func obtainTokensAuthCode(code: String, authorizationDelegate: AuthorizationDelegate) {
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
    
    class MockAuthorizationManagerWithGoodResponse: BluemixAppID.AuthorizationManager {
        
        var response : Response? = Response(responseData: "1234".data(using: .utf8), httpResponse: nil, isRedirect: false)
        var error : Error? = nil
        
        override func sendRequest(request: Request, internalCallBack: @escaping BMSCompletionHandler) {
            internalCallBack(response, error)
        }
    }
    
    class MockAuthorizationManagerWithRequestError: BluemixAppID.AuthorizationManager {
        
        var response : Response? = nil
        class SomeError : Error {
            
        }
        var error : Error? = SomeError()
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
            
            func onAuthorizationSuccess(accessToken: AccessToken?,
                                        identityToken: IdentityToken?,
                                        refreshToken: RefreshToken?,
                                        response:Response?) {
               
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
            
            func onAuthorizationSuccess(accessToken: AccessToken?,
                                        identityToken: IdentityToken?,
                                        refreshToken: RefreshToken?,
                                        response:Response?) {
                
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
