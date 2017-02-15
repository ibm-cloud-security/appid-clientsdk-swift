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

class TokenManagerTests: XCTestCase {
    var tokenManager:TokenManager = TokenManager(oAuthManager: OAuthManager(appId:AppID.sharedInstance))
    override func setUp() {
        super.setUp();
    }
    
    
    func testClearStoredTokens() {
        XCTAssertNil(tokenManager.latestAccessToken)
        XCTAssertNil(tokenManager.latestIdentityToken)
        
        tokenManager.latestAccessToken = AccessTokenImpl(with: AppIDTestConstants.ACCESS_TOKEN)
        tokenManager.latestIdentityToken = IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)
        
        XCTAssertNotNil(tokenManager.latestAccessToken)
        XCTAssertNotNil(tokenManager.latestIdentityToken)
        
        tokenManager.clearStoredToken()
        XCTAssertNil(tokenManager.latestAccessToken)
        XCTAssertNil(tokenManager.latestIdentityToken)
        
    }
    
    static var clientId = "someclient"
    class MockTokenManagerWithSendRequest: TokenManager {
        var err:Error?
        var response:Response?
        var throwExc:Bool
        init(oauthManager:OAuthManager, response:Response?, err:Error?, throwExc:Bool = false) {
            self.err = err
            self.response = response
            self.throwExc = throwExc
            super.init(oAuthManager:oauthManager)
        }
        
        override internal func extractTokens(response: Response, authorizationDelegate: AuthorizationDelegate) {
            XCTAssertEqual(response.responseData, self.response?.responseData)
            authorizationDelegate.onAuthorizationSuccess(accessToken: AccessTokenImpl(with: AppIDTestConstants.ACCESS_TOKEN)!, identityToken: IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)!, response: response)
        }
        
        override internal func createAuthenticationHeader(clientId: String) throws -> String {
            if throwExc {
             throw AppIDError.generalError
            } else {
            XCTAssertEqual(clientId, TokenManagerTests.clientId)
            return "Bearer signature"
            }
        }
        
        override internal func sendRequest(request:Request, body registrationParamsAsData:Data?, internalCallBack: @escaping BMSCompletionHandler) {
            
            XCTAssertEqual(request.resourceUrl, Config.getServerUrl(appId: AppID.sharedInstance) + "/token")
            XCTAssertEqual(request.httpMethod, HttpMethod.POST)
            XCTAssertEqual(request.headers.count, 2)
            XCTAssertEqual(request.headers["Content-Type"], "application/x-www-form-urlencoded")
            XCTAssertEqual(request.headers["Authorization"], "Bearer signature")
            XCTAssertEqual(request.timeout, BMSClient.sharedInstance.requestTimeout)
            XCTAssertEqual(String(data: registrationParamsAsData!, encoding: .utf8), "grant_type=authorization_code&code=thisisgrantcode&client_id=someclient&redirect_uri=redirect")
            
            internalCallBack(response, err)
        }
    }
    
    
    class delegate: AuthorizationDelegate {
        var exp:XCTestExpectation
        var msg:String
        var success:Bool
        public init(exp:XCTestExpectation, msg:String = "", success:Bool = false) {
            self.exp = exp
            self.msg = msg
            self.success = success
        }
        
        func onAuthorizationCanceled() {
            
        }
        func onAuthorizationFailure(error: AuthorizationError) {
            if !success {
                XCTAssertEqual(error.description, msg)
                exp.fulfill()
            }
        }
        func onAuthorizationSuccess(accessToken: AccessToken, identityToken: IdentityToken, response: Response?) {
            if success {
                XCTAssertEqual(accessToken.raw, AccessTokenImpl(with: AppIDTestConstants.ACCESS_TOKEN)!.raw)
                XCTAssertEqual(identityToken.raw, IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)!.raw)
                exp.fulfill()
            }
        }
    }
    
    
    // no registration data
    func testObtainTokens0() {
        
    
        let expectation1 = expectation(description: "got to callback")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).clear()
        let tokenManager =  MockTokenManagerWithSendRequest(oauthManager:oauthmanager, response: nil, err: nil)
        tokenManager.obtainTokens(code: "thisisgrantcode", authorizationDelegate: delegate(exp:expectation1, msg: "Client not registered", success: false))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }

    }
    
    
    // create auth header throws exception
    func testObtainTokens10() {
        
        let expectation1 = expectation(description: "got to callback")
       // let err = AppIDError.registrationError(msg: "Failed to create authentication header")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : TokenManagerTests.clientId, AppIDConstants.JSON_REDIRECT_URIS_KEY : ["redirect"]] as [String:Any])
        
        
        let tokenManager =  MockTokenManagerWithSendRequest(oauthManager:oauthmanager, response: nil, err: nil, throwExc: true)
        tokenManager.obtainTokens(code: "thisisgrantcode", authorizationDelegate: delegate(exp:expectation1, msg: "Failed to create authentication header"))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }

        
    }
    
    
    // with err
    func testObtainTokens() {
        
        let expectation1 = expectation(description: "got to callback")
        let err = AppIDError.registrationError(msg: "Failed to register OAuth client")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : TokenManagerTests.clientId, AppIDConstants.JSON_REDIRECT_URIS_KEY : ["redirect"]] as [String:Any])
        
        
        let tokenManager =  MockTokenManagerWithSendRequest(oauthManager:oauthmanager, response: nil, err: err)
        tokenManager.obtainTokens(code: "thisisgrantcode", authorizationDelegate: delegate(exp:expectation1, msg: "Failed to retrieve tokens"))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
        
    }
    
    // unsuccessful response
    func testObtainTokens2() {
        
        let expectation1 = expectation(description: "got to callback")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "someclient", AppIDConstants.JSON_REDIRECT_URIS_KEY : ["redirect"]] as [String:Any])
        let response:Response = Response(responseData: "some text".data(using: .utf8), httpResponse: HTTPURLResponse(url: URL(string: "ADS")!, statusCode: 401, httpVersion: nil, headerFields: nil), isRedirect: false)
        
        let tokenManager =  MockTokenManagerWithSendRequest(oauthManager:oauthmanager, response: response, err: nil)
        tokenManager.obtainTokens(code: "thisisgrantcode", authorizationDelegate: delegate(exp:expectation1, msg: "Failed to extract tokens"))
        
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
        
    }
    
    
    // no error and no response
    func testObtainTokens3() {
        
        let expectation1 = expectation(description: "got to callback")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "someclient", AppIDConstants.JSON_REDIRECT_URIS_KEY : ["redirect"]] as [String:Any])
        
        let tokenManager =  MockTokenManagerWithSendRequest(oauthManager:oauthmanager, response: nil, err: nil)
        tokenManager.obtainTokens(code: "thisisgrantcode", authorizationDelegate: delegate(exp:expectation1, msg: "Failed to extract tokens"))
        
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
        
    }
    
    
    // happy flow
    func testObtainTokens4() {
        
        let expectation1 = expectation(description: "got to callback")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "someclient", AppIDConstants.JSON_REDIRECT_URIS_KEY : ["redirect"]] as [String:Any])
        
        let response:Response = Response(responseData: "some text".data(using: .utf8), httpResponse: HTTPURLResponse(url: URL(string: "ADS")!, statusCode: 200, httpVersion: nil, headerFields: nil), isRedirect: false)
        let tokenManager =  MockTokenManagerWithSendRequest(oauthManager:oauthmanager, response: response, err: nil)
        tokenManager.obtainTokens(code: "thisisgrantcode", authorizationDelegate: delegate(exp:expectation1, success: true))
        
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
        
    }
    
    
    
    func testExtractTokens(){
        
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
        
        // no response text
        var response = Response(responseData: nil, httpResponse: nil, isRedirect: false)
        tokenManager.extractTokens(response: response, authorizationDelegate: delegate(res:"failure", expectedErr: "Failed to parse server response - no response text"))
        
        // non parsable text
        var data = "nonParsableText".data(using: .utf8)
        response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        tokenManager.extractTokens(response: response, authorizationDelegate: delegate(res:"failure", expectedErr: "Failed to parse server response - failed to parse json"))
        
        
        // no access token
        data = "{\"id_token\":\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpPU0UifQ.eyJpc3MiOiJtb2JpbGVjbGllbnRhY2Nlc3Muc3RhZ2UxLm5nLmJsdWVtaXgubmV0IiwiYXVkIjoiMTdlMTI4OWI2N2E1MzIwMDQ4MTdhNWEwYmQzMTM5YjljYWM4NDE0OCIsImV4cCI6MTQ4NzA2NjMwMiwiYXV0aF9ieSI6ImZhY2Vib29rIiwidGVuYW50IjoiNGRiYTk0MzAtNTRlNi00Y2YyLWE1MTYtNmY3M2ZlYjcwMmJiIiwiaWF0IjoxNDg3MDYyNzAyLCJuYW1lIjoiRG9uIExvbiIsImVtYWlsIjoiZG9ubG9ucXdlcnR5QGdtYWlsLmNvbSIsImdlbmRlciI6Im1hbGUiLCJsb2NhbGUiOiJlbl9VUyIsInBpY3R1cmUiOiJodHRwczovL3Njb250ZW50Lnh4LmZiY2RuLm5ldC92L3QxLjAtMS9wNTB4NTAvMTM1MDE1NTFfMjg2NDA3ODM4Mzc4ODkyXzE3ODU3NjYyMTE3NjY3MzA2OTdfbi5qcGc_b2g9MjQyYmMyZmI1MDU2MDliNDQyODc0ZmRlM2U5ODY1YTkmb2U9NTkwN0IxQkMiLCJpZGVudGl0aWVzIjpbeyJwcm92aWRlciI6ImZhY2Vib29rIiwiaWQiOiIzNzc0NDAxNTkyNzU2NTkifV0sIm9hdXRoX2NsaWVudCI6eyJuYW1lIjoiT2RlZEFwcElEYXBwaWQiLCJ0eXBlIjoibW9iaWxlYXBwIiwic29mdHdhcmVfaWQiOiJPZGVkQXBwSURhcHBpZElEIiwic29mdHdhcmVfdmVyc2lvbiI6IjEuMCIsImRldmljZV9pZCI6Ijk5MDI0Njg4LUZGMTktNDg4Qy04RjJELUY3MTY2MDZDQTU5NCIsImRldmljZV9tb2RlbCI6ImlQaG9uZSIsImRldmljZV9vcyI6ImlQaG9uZSBPUyJ9fQ.kFPUtpi9AROmBvQqPa19LgX18aYSSbnjlea4Hg0OA4UUw8XYnuoufBWpmmzDpaqZVnN5LTWg9YK5-wtB5Hi9YwX8bhklkeciHP_1ue-fyNDLN2uCNUvBxh916mgFy8u1gFicBcCzQkVoSDSL4Pcjgo0VoTla8t36wLFRtEKmBQ-p8UOlvjD-dnAoNBDveUsNNyeaLMdVPRRfXi-RYWOH3E9bjvyhHd-Zea2OX3oC1XRpqNgrUBXQblskOi_mEll_iWAUX5oD23tOZB9cb0eph9B6_tDZutgvaY338ZD1W9St6YokIL8IltKbrX3q1_FFJSu9nfNPgILsKIAKqe9fHQ\",\"expires_in\":3600}".data(using: .utf8)
        response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        tokenManager.extractTokens(response: response, authorizationDelegate: delegate(res:"failure", expectedErr: "Failed to parse server response - no access or identity token"))
        
        
        // no id token
        data = "{\"access_token\":\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpPU0UifQ.eyJpc3MiOiJtb2JpbGVjbGllbnRhY2Nlc3Muc3RhZ2UxLm5nLmJsdWVtaXgubmV0IiwiZXhwIjoxNDg3MDY2MzAyLCJhdWQiOiIxN2UxMjg5YjY3YTUzMjAwNDgxN2E1YTBiZDMxMzliOWNhYzg0MTQ4IiwiaWF0IjoxNDg3MDYyNzAyLCJhdXRoX2J5IjoiZmFjZWJvb2siLCJ0ZW5hbnQiOiI0ZGJhOTQzMC01NGU2LTRjZjItYTUxNi02ZjczZmViNzAyYmIiLCJzY29wZSI6ImFwcGlkX2RlZmF1bHQgYXBwaWRfcmVhZHByb2ZpbGUgYXBwaWRfcmVhZHVzZXJhdHRyIGFwcGlkX3dyaXRldXNlcmF0dHIifQ.enUpEwjdXGJYF9VHolYcKpT8yViYBCbcxp7p7e3n2JamUx68EDEwVPX3qQTyFCz4cXhGmhF8d3rsNGNxMuglor_LRhHDIzHtN5CPi0aqCh3QuF1dQrRBbmjOk2zjinP6pp5WaZvpbush8LEVa8CiZ3Cy2l9IHdY5f4ApKuh29oOj860wwrauYovX2M0f7bDLSwgwXTXydb9-ooawQI7NKkZOlVDI_Bxawmh34VLgAwepyqOR_38YEWyJm7mocJEkT4dqKMaGQ5_WW564JHtqy8D9kIsoN6pufIyr427ApsCdcj_KcYdCdZtJAgiP5x9J5aNmKLsyJYNZKtk2HTMmlw\",\"expires_in\":3600}".data(using: .utf8)
        response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        tokenManager.extractTokens(response: response, authorizationDelegate: delegate(res:"failure", expectedErr: "Failed to parse server response - no access or identity token"))
        
        // non parsable access token
        data = "{\"access_token\":\"nonParsableAccessToken\",\"id_token\":\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpPU0UifQ.eyJpc3MiOiJtb2JpbGVjbGllbnRhY2Nlc3Muc3RhZ2UxLm5nLmJsdWVtaXgubmV0IiwiYXVkIjoiMTdlMTI4OWI2N2E1MzIwMDQ4MTdhNWEwYmQzMTM5YjljYWM4NDE0OCIsImV4cCI6MTQ4NzA2NjMwMiwiYXV0aF9ieSI6ImZhY2Vib29rIiwidGVuYW50IjoiNGRiYTk0MzAtNTRlNi00Y2YyLWE1MTYtNmY3M2ZlYjcwMmJiIiwiaWF0IjoxNDg3MDYyNzAyLCJuYW1lIjoiRG9uIExvbiIsImVtYWlsIjoiZG9ubG9ucXdlcnR5QGdtYWlsLmNvbSIsImdlbmRlciI6Im1hbGUiLCJsb2NhbGUiOiJlbl9VUyIsInBpY3R1cmUiOiJodHRwczovL3Njb250ZW50Lnh4LmZiY2RuLm5ldC92L3QxLjAtMS9wNTB4NTAvMTM1MDE1NTFfMjg2NDA3ODM4Mzc4ODkyXzE3ODU3NjYyMTE3NjY3MzA2OTdfbi5qcGc_b2g9MjQyYmMyZmI1MDU2MDliNDQyODc0ZmRlM2U5ODY1YTkmb2U9NTkwN0IxQkMiLCJpZGVudGl0aWVzIjpbeyJwcm92aWRlciI6ImZhY2Vib29rIiwiaWQiOiIzNzc0NDAxNTkyNzU2NTkifV0sIm9hdXRoX2NsaWVudCI6eyJuYW1lIjoiT2RlZEFwcElEYXBwaWQiLCJ0eXBlIjoibW9iaWxlYXBwIiwic29mdHdhcmVfaWQiOiJPZGVkQXBwSURhcHBpZElEIiwic29mdHdhcmVfdmVyc2lvbiI6IjEuMCIsImRldmljZV9pZCI6Ijk5MDI0Njg4LUZGMTktNDg4Qy04RjJELUY3MTY2MDZDQTU5NCIsImRldmljZV9tb2RlbCI6ImlQaG9uZSIsImRldmljZV9vcyI6ImlQaG9uZSBPUyJ9fQ.kFPUtpi9AROmBvQqPa19LgX18aYSSbnjlea4Hg0OA4UUw8XYnuoufBWpmmzDpaqZVnN5LTWg9YK5-wtB5Hi9YwX8bhklkeciHP_1ue-fyNDLN2uCNUvBxh916mgFy8u1gFicBcCzQkVoSDSL4Pcjgo0VoTla8t36wLFRtEKmBQ-p8UOlvjD-dnAoNBDveUsNNyeaLMdVPRRfXi-RYWOH3E9bjvyhHd-Zea2OX3oC1XRpqNgrUBXQblskOi_mEll_iWAUX5oD23tOZB9cb0eph9B6_tDZutgvaY338ZD1W9St6YokIL8IltKbrX3q1_FFJSu9nfNPgILsKIAKqe9fHQ\",\"expires_in\":3600}".data(using: .utf8)
        response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        tokenManager.extractTokens(response: response, authorizationDelegate: delegate(res:"failure", expectedErr: "Failed to parse tokens"))
        
        // non parsable id token
        data = "{\"access_token\":\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpPU0UifQ.eyJpc3MiOiJtb2JpbGVjbGllbnRhY2Nlc3Muc3RhZ2UxLm5nLmJsdWVtaXgubmV0IiwiZXhwIjoxNDg3MDY2MzAyLCJhdWQiOiIxN2UxMjg5YjY3YTUzMjAwNDgxN2E1YTBiZDMxMzliOWNhYzg0MTQ4IiwiaWF0IjoxNDg3MDYyNzAyLCJhdXRoX2J5IjoiZmFjZWJvb2siLCJ0ZW5hbnQiOiI0ZGJhOTQzMC01NGU2LTRjZjItYTUxNi02ZjczZmViNzAyYmIiLCJzY29wZSI6ImFwcGlkX2RlZmF1bHQgYXBwaWRfcmVhZHByb2ZpbGUgYXBwaWRfcmVhZHVzZXJhdHRyIGFwcGlkX3dyaXRldXNlcmF0dHIifQ.enUpEwjdXGJYF9VHolYcKpT8yViYBCbcxp7p7e3n2JamUx68EDEwVPX3qQTyFCz4cXhGmhF8d3rsNGNxMuglor_LRhHDIzHtN5CPi0aqCh3QuF1dQrRBbmjOk2zjinP6pp5WaZvpbush8LEVa8CiZ3Cy2l9IHdY5f4ApKuh29oOj860wwrauYovX2M0f7bDLSwgwXTXydb9-ooawQI7NKkZOlVDI_Bxawmh34VLgAwepyqOR_38YEWyJm7mocJEkT4dqKMaGQ5_WW564JHtqy8D9kIsoN6pufIyr427ApsCdcj_KcYdCdZtJAgiP5x9J5aNmKLsyJYNZKtk2HTMmlw\",\"id_token\":\"nonParsableIdToken\",\"expires_in\":3600}".data(using: .utf8)
        response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        tokenManager.extractTokens(response: response, authorizationDelegate: delegate(res:"failure", expectedErr: "Failed to parse tokens"))
        
        
        // happy flow
        data = "{\"access_token\":\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpPU0UifQ.eyJpc3MiOiJtb2JpbGVjbGllbnRhY2Nlc3Muc3RhZ2UxLm5nLmJsdWVtaXgubmV0IiwiZXhwIjoxNDg3MDY2MzAyLCJhdWQiOiIxN2UxMjg5YjY3YTUzMjAwNDgxN2E1YTBiZDMxMzliOWNhYzg0MTQ4IiwiaWF0IjoxNDg3MDYyNzAyLCJhdXRoX2J5IjoiZmFjZWJvb2siLCJ0ZW5hbnQiOiI0ZGJhOTQzMC01NGU2LTRjZjItYTUxNi02ZjczZmViNzAyYmIiLCJzY29wZSI6ImFwcGlkX2RlZmF1bHQgYXBwaWRfcmVhZHByb2ZpbGUgYXBwaWRfcmVhZHVzZXJhdHRyIGFwcGlkX3dyaXRldXNlcmF0dHIifQ.enUpEwjdXGJYF9VHolYcKpT8yViYBCbcxp7p7e3n2JamUx68EDEwVPX3qQTyFCz4cXhGmhF8d3rsNGNxMuglor_LRhHDIzHtN5CPi0aqCh3QuF1dQrRBbmjOk2zjinP6pp5WaZvpbush8LEVa8CiZ3Cy2l9IHdY5f4ApKuh29oOj860wwrauYovX2M0f7bDLSwgwXTXydb9-ooawQI7NKkZOlVDI_Bxawmh34VLgAwepyqOR_38YEWyJm7mocJEkT4dqKMaGQ5_WW564JHtqy8D9kIsoN6pufIyr427ApsCdcj_KcYdCdZtJAgiP5x9J5aNmKLsyJYNZKtk2HTMmlw\",\"id_token\":\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpPU0UifQ.eyJpc3MiOiJtb2JpbGVjbGllbnRhY2Nlc3Muc3RhZ2UxLm5nLmJsdWVtaXgubmV0IiwiYXVkIjoiMTdlMTI4OWI2N2E1MzIwMDQ4MTdhNWEwYmQzMTM5YjljYWM4NDE0OCIsImV4cCI6MTQ4NzA2NjMwMiwiYXV0aF9ieSI6ImZhY2Vib29rIiwidGVuYW50IjoiNGRiYTk0MzAtNTRlNi00Y2YyLWE1MTYtNmY3M2ZlYjcwMmJiIiwiaWF0IjoxNDg3MDYyNzAyLCJuYW1lIjoiRG9uIExvbiIsImVtYWlsIjoiZG9ubG9ucXdlcnR5QGdtYWlsLmNvbSIsImdlbmRlciI6Im1hbGUiLCJsb2NhbGUiOiJlbl9VUyIsInBpY3R1cmUiOiJodHRwczovL3Njb250ZW50Lnh4LmZiY2RuLm5ldC92L3QxLjAtMS9wNTB4NTAvMTM1MDE1NTFfMjg2NDA3ODM4Mzc4ODkyXzE3ODU3NjYyMTE3NjY3MzA2OTdfbi5qcGc_b2g9MjQyYmMyZmI1MDU2MDliNDQyODc0ZmRlM2U5ODY1YTkmb2U9NTkwN0IxQkMiLCJpZGVudGl0aWVzIjpbeyJwcm92aWRlciI6ImZhY2Vib29rIiwiaWQiOiIzNzc0NDAxNTkyNzU2NTkifV0sIm9hdXRoX2NsaWVudCI6eyJuYW1lIjoiT2RlZEFwcElEYXBwaWQiLCJ0eXBlIjoibW9iaWxlYXBwIiwic29mdHdhcmVfaWQiOiJPZGVkQXBwSURhcHBpZElEIiwic29mdHdhcmVfdmVyc2lvbiI6IjEuMCIsImRldmljZV9pZCI6Ijk5MDI0Njg4LUZGMTktNDg4Qy04RjJELUY3MTY2MDZDQTU5NCIsImRldmljZV9tb2RlbCI6ImlQaG9uZSIsImRldmljZV9vcyI6ImlQaG9uZSBPUyJ9fQ.kFPUtpi9AROmBvQqPa19LgX18aYSSbnjlea4Hg0OA4UUw8XYnuoufBWpmmzDpaqZVnN5LTWg9YK5-wtB5Hi9YwX8bhklkeciHP_1ue-fyNDLN2uCNUvBxh916mgFy8u1gFicBcCzQkVoSDSL4Pcjgo0VoTla8t36wLFRtEKmBQ-p8UOlvjD-dnAoNBDveUsNNyeaLMdVPRRfXi-RYWOH3E9bjvyhHd-Zea2OX3oC1XRpqNgrUBXQblskOi_mEll_iWAUX5oD23tOZB9cb0eph9B6_tDZutgvaY338ZD1W9St6YokIL8IltKbrX3q1_FFJSu9nfNPgILsKIAKqe9fHQ\",\"expires_in\":3600}".data(using: .utf8)
        response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        tokenManager.extractTokens(response: response, authorizationDelegate: delegate(res:"success", expectedErr: ""))
        
        
        XCTAssertEqual(delegate.success, 1)
        XCTAssertEqual(delegate.fails, 6)
        XCTAssertEqual(delegate.cancel, 0)
    }
    
}
