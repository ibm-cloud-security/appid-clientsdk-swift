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
import JOSESwift
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
        let data = "{\"id_token\":\"\(AppIDTestConstants.ID_TOKEN)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Failed to parse server response - no access or identity token")
        tokenManager.extractTokens(response: response, tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }
    
    func testExtractTokensFailsWhenNoIdToken() {
        let data = "{\"access_token\":\"\(AppIDTestConstants.APP_ANON_ACCESS_TOKEN)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Failed to parse server response - no access or identity token")
        tokenManager.extractTokens(response: response, tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }

    func testExtractTokensFailsWhenNoParsableAccessToken() {
        let data = "{\"access_token\":\"nonparsable\",\"id_token\":\"\(AppIDTestConstants.ID_TOKEN)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Failed to parse server response - corrupt access or identity token")
        tokenManager.extractTokens(response: response, tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }

    func testExtractTokensFailsWhenNoParsableIdToken() {
        let data = "{\"access_token\":\"\(AppIDTestConstants.APP_ANON_ACCESS_TOKEN)\",\"id_token\":\"nonparsable\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Failed to parse server response - corrupt access or identity token")
        tokenManager.extractTokens(response: response, tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }
    
    func testExtractTokensFailsMissingKid() {
        let data = "{\"access_token\":\"\(AppIDTestConstants.ACCESS_TOKEN)\",\"id_token\":\"\(AppIDTestConstants.ID_TOKEN)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Invalid token : Missing kid")
        tokenManager.extractTokens(response: response, tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }
    
    func testExtractTokensFailsInvalidAlg() {
        let data = "{\"access_token\":\"\(AppIDTestConstants.malformedAccessTokenInvalidAlg)\",\"id_token\":\"\(AppIDTestConstants.ID_TOKEN)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Invalid token : Invalid alg")
        tokenManager.extractTokens(response: response, tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }
    
    
    func testValidateTokenFails() {
        let respData = "{\"access_token\":\"\(AppIDTestConstants.APP_ANON_ACCESS_TOKEN)\",\"id_token\":\"\(AppIDTestConstants.ID_TOKEN)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: respData, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Token verification failed")
        let publicKeys = getPublicKeys()
        guard let key = publicKeys[AppIDTestConstants.kid] else {
            tokenRespDelegate.onAuthorizationFailure(error: .authorizationFailure("Failed to get public key"))
            return
        }
        guard let expToken = AccessTokenImpl(with: AppIDTestConstants.expAcessToken) else {
            tokenRespDelegate.onAuthorizationFailure(error: .authorizationFailure("Error in token creation"))
            return
        }
        
        tokenManager.validateToken(token: expToken, key: key, tokenResponseDelegate: tokenRespDelegate) {tokenRespDelegate.onAuthorizationSuccess(accessToken: expToken,identityToken: nil,refreshToken: nil,response:response)}
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }

    func testValidateTokenFailsInvalidIssuer() {
        let respData = "{\"access_token\":\"\(AppIDTestConstants.APP_ANON_ACCESS_TOKEN)\",\"id_token\":\"\(AppIDTestConstants.ID_TOKEN)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: respData, httpResponse: nil, isRedirect: false)
        let tokenRespDelegatIssuer = ExtractTokensDelegate(res:"failure", expectedErr: "Token verification failed : invalid issuer")
        let publicKeys = getPublicKeys()
        guard let key = publicKeys[AppIDTestConstants.kid] else {
            tokenRespDelegatIssuer.onAuthorizationFailure(error: .authorizationFailure("Failed to get public key"))
            return
        }
        
        guard let validToken = AccessTokenImpl(with: AppIDTestConstants.APP_ANON_ACCESS_TOKEN) else {
            tokenRespDelegatIssuer.onAuthorizationFailure(error: .authorizationFailure("Error in token creation"))
            return
        }
        let mockAppId = MockAppId.sharedInstance
        mockAppId.initialize(tenantId: "4dba9430-54e6-4cf2-a516", bluemixRegion: ".ng.bluemix.net")
        let oauthManager = OAuthManager(appId: mockAppId)
        oauthManager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : AppIDTestConstants.clientId])
        
        let manager:TokenManager = TokenManager(oAuthManager: OAuthManager(appId: mockAppId))
        MockAppId.overrideServerHost = "https://app-oauth.ng.bluemix.net/oauth/v3/"
        
        manager.validateToken(token: validToken, key: key, tokenResponseDelegate: tokenRespDelegatIssuer) {tokenRespDelegatIssuer.onAuthorizationSuccess(accessToken: validToken,identityToken: nil,refreshToken: nil,response:response)}
        XCTAssertEqual(tokenRespDelegatIssuer.success, 0)
        XCTAssertEqual(tokenRespDelegatIssuer.fails, 1)
        XCTAssertEqual(tokenRespDelegatIssuer.cancel, 0)
    }
    
    func testValidateTokenFailsInvalidAud() {
        let respData = "{\"access_token\":\"\(AppIDTestConstants.APP_ANON_ACCESS_TOKEN)\",\"id_token\":\"\(AppIDTestConstants.ID_TOKEN)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: respData, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Token verification failed : invalid audience")
        let publicKeys = getPublicKeys()
        guard let key = publicKeys[AppIDTestConstants.kid] else {
            tokenRespDelegate.onAuthorizationFailure(error: .authorizationFailure("Failed to get public key"))
            return
        }
        
        guard let validToken = AccessTokenImpl(with: AppIDTestConstants.APP_ANON_ACCESS_TOKEN) else {
            tokenRespDelegate.onAuthorizationFailure(error: .authorizationFailure("Error in token creation"))
            return
        }
        
        let mockAppId = MockAppId.sharedInstance
        mockAppId.initialize(tenantId: "4dba9430-54e6-4cf2-a516", bluemixRegion: ".ng.bluemix.net")
        let oauthManager = OAuthManager(appId: mockAppId)
        oauthManager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "clientId"])
        let manager:TokenManager =  TokenManager(oAuthManager: oauthManager)
        MockAppId.overrideServerHost = "https://appid-oauth.ng.bluemix.net/oauth/v3/"
        
        manager.validateToken(token: validToken, key: key, tokenResponseDelegate: tokenRespDelegate) {tokenRespDelegate.onAuthorizationSuccess(accessToken: validToken,identityToken: nil,refreshToken: nil,response:response)}
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }
    
    
    
    func testValidateTokenFailsInvalidTenant() {
        let respData = "{\"access_token\":\"\(AppIDTestConstants.APP_ANON_ACCESS_TOKEN)\",\"id_token\":\"\(AppIDTestConstants.ID_TOKEN)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: respData, httpResponse: nil, isRedirect: false)
        let tokenRespDelegateTenant = ExtractTokensDelegate(res:"failure", expectedErr: "Token verification failed : invalid tenant")
        let publicKeys = getPublicKeys()
        guard let key = publicKeys[AppIDTestConstants.kid] else {
            tokenRespDelegateTenant.onAuthorizationFailure(error: .authorizationFailure("Failed to get public key"))
            return
        }
        
        guard let validToken = AccessTokenImpl(with: AppIDTestConstants.APP_ANON_ACCESS_TOKEN) else {
            tokenRespDelegateTenant.onAuthorizationFailure(error: .authorizationFailure("Error in token creation"))
            return
        }
        
        let mockAppId = MockAppId.sharedInstance
        mockAppId.initialize(tenantId: "4dba9430-54e6-4cf2-a516", bluemixRegion: ".ng.bluemix.net")
        let oauthManager = OAuthManager(appId: mockAppId)
        oauthManager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : AppIDTestConstants.clientId])
        let manager:TokenManager = TokenManager(oAuthManager: OAuthManager(appId: mockAppId))
        MockAppId.overrideServerHost = "https://appid-oauth.ng.bluemix.net/oauth/v3/"
        
        manager.validateToken(token: validToken, key: key, tokenResponseDelegate: tokenRespDelegateTenant) {tokenRespDelegateTenant.onAuthorizationSuccess(accessToken: validToken,identityToken: nil,refreshToken: nil,response:response)}
        XCTAssertEqual(tokenRespDelegateTenant.success, 0)
        XCTAssertEqual(tokenRespDelegateTenant.fails, 1)
        XCTAssertEqual(tokenRespDelegateTenant.cancel, 0)
    }
    
    func testExtractTokensHappyFlow() {
         let data = "{\"access_token\":\"\(AppIDTestConstants.APP_ANON_ACCESS_TOKEN)\",\"id_token\":\"\(AppIDTestConstants.ID_TOKEN)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"success", expectedErr: "")
        let manager:TokenManager = MockTokenManagerWithValidateAToken(oAuthManager: OAuthManager(appId: AppID.sharedInstance))
        manager.extractTokens(response: response,
                              tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 1)
        XCTAssertEqual(tokenRespDelegate.fails, 0)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
        XCTAssertNotNil(tokenRespDelegate.accessToken)
        XCTAssertNotNil(tokenRespDelegate.identityToken)
        XCTAssertNil(tokenRespDelegate.refreshToken)
    }
    
    func testExtractTokensHappyFlowWithRefreshToken() {
        let refreshTokenPayload = "no-matter-refresh-token-has-no-spec"
        let data = "{\"access_token\":\"\(AppIDTestConstants.APP_ANON_ACCESS_TOKEN)\",\"id_token\":\"\(AppIDTestConstants.ID_TOKEN)\",\"refresh_token\":\"\(refreshTokenPayload)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"success", expectedErr: "")
        let manager:TokenManager = MockTokenManagerWithValidateAToken(oAuthManager: OAuthManager(appId: AppID.sharedInstance))
        manager.extractTokens(response: response,
                                   tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 1)
        XCTAssertEqual(tokenRespDelegate.fails, 0)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
        XCTAssertNotNil(tokenRespDelegate.refreshToken)
        XCTAssertNotNil(tokenRespDelegate.accessToken)
        XCTAssertNotNil(tokenRespDelegate.identityToken)
        XCTAssertEqual(refreshTokenPayload, tokenRespDelegate.refreshToken!.raw!)
    }
    
    func testExtractTokenPublicKeyFails() {
        let respData = "{\"access_token\":\"\(AppIDTestConstants.APP_ANON_ACCESS_TOKEN)\",\"id_token\":\"\(AppIDTestConstants.ID_TOKEN)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: respData, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Could not find public key for kid")
        let manager:TokenManager = MockTokenManagerWithValidateATokenJWT(oAuthManager: OAuthManager(appId: AppID.sharedInstance))
        manager.extractTokens(response: response,
                              tokenResponseDelegate: tokenRespDelegate)
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }
    
    func testRetrievePublicKeysFailsNilResponse() {
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Failed to get public key from server")
        let manager:TokenManager = MockTokenManagerWithRetrievePublicKeysFails(oAuthManager: OAuthManager(appId: AppID.sharedInstance))
        manager.retrievePublicKeys(tokenResponseDelegate: tokenRespDelegate, callback: {})
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }
    
    func testRetrievePublicKeysFailsInvalidJson() {
        let tokenRespDelegate = ExtractTokensDelegate(res:"failure", expectedErr: "Failed to parse public key response from server")
        let manager:TokenManager = MockTokenManagerWithRetrievePublicKeysFailsInvalidJson(oAuthManager: OAuthManager(appId: AppID.sharedInstance))
        manager.retrievePublicKeys(tokenResponseDelegate: tokenRespDelegate, callback: {})
        XCTAssertEqual(tokenRespDelegate.success, 0)
        XCTAssertEqual(tokenRespDelegate.fails, 1)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }
    
    func testRetrievePublicKeys() {
        let respData = "{\"access_token\":\"\(AppIDTestConstants.APP_ANON_ACCESS_TOKEN)\",\"id_token\":\"\(AppIDTestConstants.ID_TOKEN)\",\"expires_in\":3600}".data(using: .utf8)
        let response = Response(responseData: respData, httpResponse: nil, isRedirect: false)
        let tokenRespDelegate = ExtractTokensDelegate(res:"success", expectedErr: "")
        let manager:TokenManager = MockTokenManagerWithRetrievePublicKeys(oAuthManager: OAuthManager(appId: AppID.sharedInstance))
        guard let accessToken = AccessTokenImpl(with: AppIDTestConstants.APP_ANON_ACCESS_TOKEN) else {
            tokenRespDelegate.onAuthorizationFailure(error: .authorizationFailure("Error in token creation"))
            return
        }
        guard let idToken = IdentityTokenImpl(with: AppIDTestConstants.APP_ANON_ACCESS_TOKEN) else {
            tokenRespDelegate.onAuthorizationFailure(error: .authorizationFailure("Error in token creation"))
            return
        }
        var refreshToken: RefreshTokenImpl?
        manager.retrievePublicKeys(tokenResponseDelegate: tokenRespDelegate){
            tokenRespDelegate.onAuthorizationSuccess(accessToken: accessToken , identityToken: idToken, refreshToken: refreshToken, response: response)
            return
        }
        XCTAssertEqual(tokenRespDelegate.success, 1)
        XCTAssertEqual(tokenRespDelegate.fails, 0)
        XCTAssertEqual(tokenRespDelegate.cancel, 0)
    }
    
    class MockTokenManagerWithValidateAToken: TokenManager {

        override internal func validateToken(token: Token, tokenResponseDelegate: TokenResponseDelegate, callback: @escaping () -> Void) {
            callback()
        }
        
    }
    
    class MockTokenManagerWithValidateATokenJWT: TokenManager {
    
        override internal func validateToken(token: Token, key: SecKey, tokenResponseDelegate: TokenResponseDelegate, callback: @escaping () -> Void ) {
            callback()
        }
        
        override internal  func retrievePublicKeys(tokenResponseDelegate: TokenResponseDelegate, callback: @escaping () -> Void) {
            callback()
        }
    }
    
    class MockTokenManagerWithRetrievePublicKeysFails: TokenManager {
        var err:Error?
        var response:Response?
        override internal func sendRequest(request:Request, body registrationParamsAsData:Data?, internalCallBack: @escaping BMSCompletionHandler) {
            internalCallBack(response, err)
        }
    }
    
    class MockTokenManagerWithRetrievePublicKeysFailsInvalidJson: TokenManager {
        var err:Error?
        override internal func sendRequest(request:Request, body registrationParamsAsData:Data?, internalCallBack: @escaping BMSCompletionHandler) {
            let data = "{\"access_token\":\"\(AppIDTestConstants.APP_ANON_ACCESS_TOKEN)\",\"id_token\":\"\(AppIDTestConstants.ID_TOKEN)\",\"expires_in\":3600}".data(using: .utf8)
            let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
            internalCallBack(response, err)
        }
    }
    
    class MockTokenManagerWithRetrievePublicKeys: TokenManager {
        var err:Error?
        override internal func sendRequest(request:Request, body registrationParamsAsData:Data?, internalCallBack: @escaping BMSCompletionHandler) {
            let data = AppIDTestConstants.jwk.data(using: .utf8)
            let response = Response(responseData: data, httpResponse: nil, isRedirect: false)
            internalCallBack(response, err)
        }
    }
    
    func getPublicKeys() -> [String : SecKey] {
        
        guard let publicKeyJson = try? Utils.parseJsonStringtoDictionary(AppIDTestConstants.jwk), let keys = publicKeyJson["keys"] as? [[String: Any]] else {
            return [:]
        }
        
        let publicKeys = keys.reduce([String : SecKey]()) { result, key in
            var result = result
            print(key)
            guard let keyKid = key["kid"] as? String,
                let data = try? JSONSerialization.data(withJSONObject: key, options: .prettyPrinted),
                let rsaPublicKey = try? RSAPublicKey(data: data), let publicKey = try? rsaPublicKey.converted(to: SecKey.self) else {
                    return result
            }
            
            result[keyKid] = publicKey
            return result
        }
        return publicKeys
    }
    
    class MockAppId: AppID {
      
    }
}
