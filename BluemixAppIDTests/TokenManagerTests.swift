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
        super.setUp()
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
        
        override internal func extractTokens(response: Response, tokenResponseDelegate:TokenResponseDelegate) {
            XCTAssertEqual(response.responseData, self.response?.responseData)
            tokenResponseDelegate.onAuthorizationSuccess(
                accessToken: AccessTokenImpl(with: AppIDTestConstants.ACCESS_TOKEN)!,
                identityToken: IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)!,
                refreshToken: nil,
                response: response)
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
    
    class MockTokenManagerWithSendRequestRop: TokenManager {
        var err:Error?
        var response:Response?
        var throwExc:Bool
        init(oauthManager:OAuthManager, response:Response?, err:Error?, throwExc:Bool = false) {
            self.err = err
            self.response = response
            self.throwExc = throwExc
            super.init(oAuthManager:oauthManager)
        }
        
        override internal func extractTokens(response: Response, tokenResponseDelegate:TokenResponseDelegate) {
            XCTAssertEqual(response.responseData, self.response?.responseData)
            tokenResponseDelegate.onAuthorizationSuccess(
                accessToken: AccessTokenImpl(with: AppIDTestConstants.ACCESS_TOKEN)!,
                identityToken: IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)!,
                refreshToken: nil,
                response: response)
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
            XCTAssertEqual(String(data: registrationParamsAsData!, encoding: .utf8), "grant_type=password&username=thisisusername&password=thisispassword")
            
            internalCallBack(response, err)
        }
        
    }
    
    class MockTokenManagerWithSendRequestAssertion: TokenManager {
        var err:Error?
        var response:Response?
        var throwExc:Bool
        var requestFormData: String?
        init(oauthManager:OAuthManager, response:Response?, err:Error?, throwExc:Bool = false) {
            self.err = err
            self.response = response
            self.throwExc = throwExc
            super.init(oAuthManager:oauthManager)
        }
        
        override internal func extractTokens(response: Response, tokenResponseDelegate:TokenResponseDelegate) {
            XCTAssertEqual(response.responseData, self.response?.responseData)
            tokenResponseDelegate.onAuthorizationSuccess(
                accessToken: AccessTokenImpl(with: AppIDTestConstants.ACCESS_TOKEN)!,
                identityToken: IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)!,
                refreshToken: nil,
                response: response)
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
            self.requestFormData = String(data: registrationParamsAsData!, encoding: .utf8)
//            XCTAssertEqual(String(data: registrationParamsAsData!, encoding: .utf8), "grant_type=password&appid_access_token=testAccessToken&username=thisisusername&password=thisispassword")
            
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
        
        func onAuthorizationSuccess(accessToken: AccessToken?,
                                    identityToken: IdentityToken?,
                                    refreshToken: RefreshToken?,
                                    response: Response?) {
            if success {
                XCTAssertEqual(accessToken!.raw, AccessTokenImpl(with: AppIDTestConstants.ACCESS_TOKEN)!.raw)
                XCTAssertEqual(identityToken!.raw, IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)!.raw)
                exp.fulfill()
            }
        }
        
    }
    
    
    // no registration data
    func testObtainTokensFailWhenNotRegistered() {
        let expectation1 = expectation(description: "got to callback")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).clear()
        let tokenManager =  MockTokenManagerWithSendRequest(oauthManager:oauthmanager, response: nil, err: nil)
        tokenManager.obtainTokensAuthCode(code: "thisisgrantcode", authorizationDelegate: delegate(exp:expectation1, msg: "Client not registered", success: false))
        
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
        tokenManager.obtainTokensAuthCode(code: "thisisgrantcode", authorizationDelegate: delegate(exp:expectation1, msg: "Failed to create authentication header"))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }

        
    }
    
    
    func testObtainTokensUsingRop_no_response() {
        
        let expectation1 = expectation(description: "got to callback")
        let err = AppIDError.registrationError(msg: "Failed to register OAuth client")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : TokenManagerTests.clientId])
        
        let tokenManager =  MockTokenManagerWithSendRequestRop(oauthManager:oauthmanager, response: nil, err: err)
        tokenManager.obtainTokensRoP(username: "thisisusername", password: "thisispassword",tokenResponseDelegate:  delegate(exp:expectation1, msg: "Failed to retrieve tokens"))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
    }
   
    func testObtainTokensUsingRop_with_access_token() {
        
        let expectation1 = expectation(description: "got to callback")
        let err = AppIDError.registrationError(msg: "Failed to register OAuth client")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : TokenManagerTests.clientId])
        
        let tokenManager =  MockTokenManagerWithSendRequestAssertion(oauthManager:oauthmanager, response: nil, err: err)
        tokenManager.obtainTokensRoP(accessTokenString: "testAccessToken" ,username: "thisisusername", password: "thisispassword",tokenResponseDelegate:  delegate(exp:expectation1, msg: "Failed to retrieve tokens"))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
        XCTAssertEqual(tokenManager.requestFormData,
                   "grant_type=password&appid_access_token=testAccessToken&username=thisisusername&password=thisispassword")
    }
    
    func testObtainTokensUsingRefreshToken() {
        
        let expectation1 = expectation(description: "got to callback")
        let err = AppIDError.registrationError(msg: "Failed to register OAuth client")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : TokenManagerTests.clientId])
        
        let tokenManager =  MockTokenManagerWithSendRequestAssertion(oauthManager:oauthmanager, response: nil, err: err)
        tokenManager.obtainTokensRefreshToken(refreshTokenString: "xxtt", tokenResponseDelegate: delegate(exp:expectation1, msg: "Failed to retrieve tokens"))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
        XCTAssertEqual(tokenManager.requestFormData, "refresh_token=xxtt&grant_type=refresh_token")
    }

    func testObtainTokensUsingRop2_catch() {
        
        let expectation1 = expectation(description: "got to callback")
        let err = AppIDError.registrationError(msg: "Failed to register OAuth client")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : TokenManagerTests.clientId])
        
        let response:Response = Response(responseData: "some text".data(using: .utf8), httpResponse: HTTPURLResponse(url: URL(string: "ADS")!, statusCode: 400, httpVersion: nil, headerFields: nil), isRedirect: false)
        
        let tokenManager =  MockTokenManagerWithSendRequestRop(oauthManager:oauthmanager, response: response, err: err)
        tokenManager.obtainTokensRoP(username: "thisisusername", password: "thisispassword",tokenResponseDelegate:  delegate(exp:expectation1, msg: "Failed to retrieve tokens"))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
    }
    
    // no error and no response
    func testObtainTokensUsingRop_no_err_no_response() {
        
        let expectation1 = expectation(description: "got to callback")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "someclient"])
        
        let tokenManager =  MockTokenManagerWithSendRequestRop(oauthManager:oauthmanager, response: nil, err: nil)
        tokenManager.obtainTokensRoP(username: "thisisusername", password: "thisispassword",tokenResponseDelegate: delegate(exp:expectation1, msg: "Failed to extract tokens"))
        
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
    }
    
    func testObtainTokensUsingRop4_no_error_description() {
        
        let expectation1 = expectation(description: "got to callback")
        let err = AppIDError.registrationError(msg: "Failed to register OAuth client")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : TokenManagerTests.clientId])
        
        let response:Response = Response(responseData: "{{\"error\":\"invalid_grant\"}}".data(using: .utf8), httpResponse: HTTPURLResponse(url: URL(string: "ADS")!, statusCode: 400, httpVersion: nil, headerFields: nil), isRedirect: false)
        
        let tokenManager =  MockTokenManagerWithSendRequestRop(oauthManager:oauthmanager, response: response, err: err)
        tokenManager.obtainTokensRoP(username: "thisisusername", password: "thisispassword",tokenResponseDelegate:  delegate(exp:expectation1, msg: "Failed to retrieve tokens"))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
    }
    
    func testObtainTokensUsingRop4_no_error() {
        
        let expectation1 = expectation(description: "got to callback")
        let err = AppIDError.registrationError(msg: "Failed to register OAuth client")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : TokenManagerTests.clientId])
        
        let response:Response = Response(responseData: "{\"error_description\":\"some error\", \"baderror\":\"invalid_grant\"}".data(using: .utf8), httpResponse: HTTPURLResponse(url: URL(string: "ADS")!, statusCode: 400, httpVersion: nil, headerFields: nil), isRedirect: false)
        
        let tokenManager =  MockTokenManagerWithSendRequestRop(oauthManager:oauthmanager, response: response, err: err)
        tokenManager.obtainTokensRoP(username: "thisisusername", password: "thisispassword",tokenResponseDelegate:  delegate(exp:expectation1, msg: "Failed to retrieve tokens"))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
    }
    
    func testObtainTokensUsingRop4_with_error_description() {
        
        let expectation1 = expectation(description: "got to callback")
        let err = AppIDError.registrationError(msg: "Failed to register OAuth client")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : TokenManagerTests.clientId])
        
        let response:Response = Response(responseData: "{\"error_description\":\"some error\", \"error\":\"invalid_grant\"}".data(using: .utf8), httpResponse: HTTPURLResponse(url: URL(string: "ADS")!, statusCode: 400, httpVersion: nil, headerFields: nil), isRedirect: false)
        
        let tokenManager =  MockTokenManagerWithSendRequestRop(oauthManager:oauthmanager, response: response, err: err)
        tokenManager.obtainTokensRoP(username: "thisisusername", password: "thisispassword",tokenResponseDelegate:  delegate(exp:expectation1, msg: "some error"))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
    }
    
    func testObtainTokensUsingRop4_casting_issue() {
        
        let expectation1 = expectation(description: "got to callback")
        let err = AppIDError.registrationError(msg: "Failed to register OAuth client")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : TokenManagerTests.clientId])
        
        let response:Response = Response(responseData: "{\"error_description\":123, \"error\":123}".data(using: .utf8), httpResponse: HTTPURLResponse(url: URL(string: "ADS")!, statusCode: 400, httpVersion: nil, headerFields: nil), isRedirect: false)
        
        let tokenManager =  MockTokenManagerWithSendRequestRop(oauthManager:oauthmanager, response: response, err: err)
        tokenManager.obtainTokensRoP(username: "thisisusername", password: "thisispassword",tokenResponseDelegate:  delegate(exp:expectation1, msg: "Failed to retrieve tokens"))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
    }
    
    // Pending User Verification
    func testObtainTokensUsingRop_403_response() {
        
        let expectation1 = expectation(description: "got to callback")
        let err = AppIDError.registrationError(msg: "Failed to register OAuth client")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : TokenManagerTests.clientId])
        
        let response:Response = Response(responseData: "{\"error_description\":\"Pending User Verification\", \"error_code\":\"FORBIDDEN\"}".data(using: .utf8), httpResponse: HTTPURLResponse(url: URL(string: "ADS")!, statusCode: 403, httpVersion: nil, headerFields: nil), isRedirect: false)
        
        let tokenManager =  MockTokenManagerWithSendRequestRop(oauthManager:oauthmanager, response: response, err: err)
        tokenManager.obtainTokensRoP(username: "thisisusername", password: "thisispassword",tokenResponseDelegate:  delegate(exp:expectation1, msg: "Pending User Verification"))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
    }
    
    func testObtainTokensUsingRop_no_400() {
        
        let expectation1 = expectation(description: "got to callback")
        let err = AppIDError.registrationError(msg: "Failed to register OAuth client")
        let oauthmanager = OAuthManager(appId: AppID.sharedInstance)
        oauthmanager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : TokenManagerTests.clientId])
        
        let response:Response = Response(responseData: "{\"error_description\":\"some error\", \"error\":\"invalid_grant\"}".data(using: .utf8), httpResponse: HTTPURLResponse(url: URL(string: "ADS")!, statusCode: 500, httpVersion: nil, headerFields: nil), isRedirect: false)
        
        let tokenManager =  MockTokenManagerWithSendRequestRop(oauthManager:oauthmanager, response: response, err: err)
        tokenManager.obtainTokensRoP(username: "thisisusername", password: "thisispassword",tokenResponseDelegate:  delegate(exp:expectation1, msg: "Failed to retrieve tokens"))
        
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
        tokenManager.obtainTokensAuthCode(code: "thisisgrantcode", authorizationDelegate: delegate(exp:expectation1, msg: "Failed to retrieve tokens"))
        
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
        tokenManager.obtainTokensAuthCode(code: "thisisgrantcode", authorizationDelegate: delegate(exp:expectation1, msg: "Failed to extract tokens"))
        
        
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
        tokenManager.obtainTokensAuthCode(code: "thisisgrantcode", authorizationDelegate: delegate(exp:expectation1, msg: "Failed to extract tokens"))
        
        
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
        tokenManager.obtainTokensAuthCode(code: "thisisgrantcode", authorizationDelegate: delegate(exp:expectation1, success: true))
        
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
        
    }
    
    class ExtractTokensDelegate: AuthorizationDelegate {
        var res:String
        var expectedError:String
        var fails:Int = 0
        var cancel:Int = 0
        var success:Int = 0
        
        var accessToken: AccessToken?
        var identityToken: IdentityToken?
        var refreshToken: RefreshToken?
        
        public init(res:String, expectedErr:String) {
            self.expectedError = expectedErr
            self.res = res
        }
        
        func onAuthorizationFailure(error: AuthorizationError) {
            XCTAssertEqual(error.description, expectedError)
            self.fails += 1
            if res != "failure" {
                XCTFail()
            }
        }
        
        func onAuthorizationCanceled() {
            self.cancel += 1
            if res != "cancel" {
                XCTFail()
            }
        }
        
        func onAuthorizationSuccess(accessToken: AccessToken?,
                                    identityToken: IdentityToken?,
                                    refreshToken: RefreshToken?,
                                    response:Response?) {
            self.accessToken = accessToken
            self.identityToken = identityToken
            self.refreshToken = refreshToken
            self.success += 1
            if res != "success" {
                XCTFail()
            }
        }
        
    }
    
    let validIdTokenPayload = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpPU0UifQ.eyJpc3MiOiJtb2JpbGVjbGllbnRhY2Nlc3Muc3RhZ2UxLm5nLmJsdWVtaXgubmV0IiwiYXVkIjoiMTdlMTI4OWI2N2E1MzIwMDQ4MTdhNWEwYmQzMTM5YjljYWM4NDE0OCIsImV4cCI6MTQ4NzA2NjMwMiwiYXV0aF9ieSI6ImZhY2Vib29rIiwidGVuYW50IjoiNGRiYTk0MzAtNTRlNi00Y2YyLWE1MTYtNmY3M2ZlYjcwMmJiIiwiaWF0IjoxNDg3MDYyNzAyLCJuYW1lIjoiRG9uIExvbiIsImVtYWlsIjoiZG9ubG9ucXdlcnR5QGdtYWlsLmNvbSIsImdlbmRlciI6Im1hbGUiLCJsb2NhbGUiOiJlbl9VUyIsInBpY3R1cmUiOiJodHRwczovL3Njb250ZW50Lnh4LmZiY2RuLm5ldC92L3QxLjAtMS9wNTB4NTAvMTM1MDE1NTFfMjg2NDA3ODM4Mzc4ODkyXzE3ODU3NjYyMTE3NjY3MzA2OTdfbi5qcGc_b2g9MjQyYmMyZmI1MDU2MDliNDQyODc0ZmRlM2U5ODY1YTkmb2U9NTkwN0IxQkMiLCJpZGVudGl0aWVzIjpbeyJwcm92aWRlciI6ImZhY2Vib29rIiwiaWQiOiIzNzc0NDAxNTkyNzU2NTkifV0sIm9hdXRoX2NsaWVudCI6eyJuYW1lIjoiT2RlZEFwcElEYXBwaWQiLCJ0eXBlIjoibW9iaWxlYXBwIiwic29mdHdhcmVfaWQiOiJPZGVkQXBwSURhcHBpZElEIiwic29mdHdhcmVfdmVyc2lvbiI6IjEuMCIsImRldmljZV9pZCI6Ijk5MDI0Njg4LUZGMTktNDg4Qy04RjJELUY3MTY2MDZDQTU5NCIsImRldmljZV9tb2RlbCI6ImlQaG9uZSIsImRldmljZV9vcyI6ImlQaG9uZSBPUyJ9fQ.kFPUtpi9AROmBvQqPa19LgX18aYSSbnjlea4Hg0OA4UUw8XYnuoufBWpmmzDpaqZVnN5LTWg9YK5-wtB5Hi9YwX8bhklkeciHP_1ue-fyNDLN2uCNUvBxh916mgFy8u1gFicBcCzQkVoSDSL4Pcjgo0VoTla8t36wLFRtEKmBQ-p8UOlvjD-dnAoNBDveUsNNyeaLMdVPRRfXi-RYWOH3E9bjvyhHd-Zea2OX3oC1XRpqNgrUBXQblskOi_mEll_iWAUX5oD23tOZB9cb0eph9B6_tDZutgvaY338ZD1W9St6YokIL8IltKbrX3q1_FFJSu9nfNPgILsKIAKqe9fHQ"
    
    let validAccessTokenPayload = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpPU0UifQ.eyJpc3MiOiJtb2JpbGVjbGllbnRhY2Nlc3Muc3RhZ2UxLm5nLmJsdWVtaXgubmV0IiwiZXhwIjoxNDg3MDY2MzAyLCJhdWQiOiIxN2UxMjg5YjY3YTUzMjAwNDgxN2E1YTBiZDMxMzliOWNhYzg0MTQ4IiwiaWF0IjoxNDg3MDYyNzAyLCJhdXRoX2J5IjoiZmFjZWJvb2siLCJ0ZW5hbnQiOiI0ZGJhOTQzMC01NGU2LTRjZjItYTUxNi02ZjczZmViNzAyYmIiLCJzY29wZSI6ImFwcGlkX2RlZmF1bHQgYXBwaWRfcmVhZHByb2ZpbGUgYXBwaWRfcmVhZHVzZXJhdHRyIGFwcGlkX3dyaXRldXNlcmF0dHIifQ.enUpEwjdXGJYF9VHolYcKpT8yViYBCbcxp7p7e3n2JamUx68EDEwVPX3qQTyFCz4cXhGmhF8d3rsNGNxMuglor_LRhHDIzHtN5CPi0aqCh3QuF1dQrRBbmjOk2zjinP6pp5WaZvpbush8LEVa8CiZ3Cy2l9IHdY5f4ApKuh29oOj860wwrauYovX2M0f7bDLSwgwXTXydb9-ooawQI7NKkZOlVDI_Bxawmh34VLgAwepyqOR_38YEWyJm7mocJEkT4dqKMaGQ5_WW564JHtqy8D9kIsoN6pufIyr427ApsCdcj_KcYdCdZtJAgiP5x9J5aNmKLsyJYNZKtk2HTMmlw"

    func testExtractTokensFailsWhenNoResponseText() {
        let response = Response(responseData: nil, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Failed to parse server response - no response text")
        tokenManager.extractTokens(response: response, tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }

    func testExtractTokensFailsWhenNoParsableResponseText() {
        let data = "nonParsableText".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Failed to parse server response - failed to parse json")
        tokenManager.extractTokens(response: response, tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }

    func testExtractTokensFailsWhenNoAccessToken() {
        let data = "{\"id_token\":\"\(validIdTokenPayload)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Failed to parse server response - no access or identity token")
        tokenManager.extractTokens(response: response, tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }
    
    func testExtractTokensFailsWhenNoIdToken() {
        let data = "{\"access_token\":\"\(validAccessTokenPayload)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Failed to parse server response - no access or identity token")
        tokenManager.extractTokens(response: response, tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }

    func testExtractTokensFailsWhenNoParsableAccessToken() {
        let data = "{\"access_token\":\"nonparsable\",\"id_token\":\"\(validIdTokenPayload)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Failed to parse tokens")
        tokenManager.extractTokens(response: response, tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }

    func testExtractTokensFailsWhenNoParsableIdToken() {
        let data = "{\"access_token\":\"\(validAccessTokenPayload)\",\"id_token\":\"nonparsable\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Failed to parse tokens")
        tokenManager.extractTokens(response: response, tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }
    
    func testExtractTokensHappyFlow() {
        let data = "{\"access_token\":\"\(validAccessTokenPayload)\",\"id_token\":\"\(validIdTokenPayload)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"success", expectedErr: "")
        tokenManager.extractTokens(response: response, tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 1)
        XCTAssertEqual(tokenRespDelegate.fails, 0)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
        XCTAssertNotNil(tokenRespDelegate.accessToken)
        XCTAssertNotNil(tokenRespDelegate.identityToken)
        XCTAssertNil(tokenRespDelegate.refreshToken)
    }

    func testExtractTokensHappyFlowWithRefreshToken() {
        let refreshTokenPayload = "no-matter-refresh-token-has-no-spec"
        let data = "{\"access_token\":\"\(validAccessTokenPayload)\",\"id_token\":\"\(validIdTokenPayload)\",\"refresh_token\":\"\(refreshTokenPayload)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"success", expectedErr: "")
        tokenManager.extractTokens(response: response,
                                   tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 1)
        XCTAssertEqual(tokenRespDelegate.fails, 0)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
        XCTAssertNotNil(tokenRespDelegate.refreshToken)
        XCTAssertNotNil(tokenRespDelegate.accessToken)
        XCTAssertNotNil(tokenRespDelegate.identityToken)
        XCTAssertEqual(refreshTokenPayload, tokenRespDelegate.refreshToken!.raw!)
    }

}
