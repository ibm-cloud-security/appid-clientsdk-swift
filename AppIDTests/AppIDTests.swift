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
@testable import AppID

class AppIDTests: XCTestCase {
    static var appId = AppID.sharedInstance
    static let tenantId = "1"
    static let clientId = "2"
    static var  callbackErr = false;
    static var  callbackResponse = false;
    var pref = AppIDPreferences()
    
    static let defaultCallBack : BMSCompletionHandler = {(response: Response?, error: Error?) in
        
    }
    
    
    class MockRegistrationManager : RegistrationManager {
        var response:Response? = nil
        var err:Error? = nil
        override func registerDevice(callback :@escaping BMSCompletionHandler) throws {
            if (response != nil) {
                AppIDTests.appId.preferences.clientId.set(AppIDTests.clientId)
            }
            callback(response,err)
        }
    }
    var mockRegistrationManager:MockRegistrationManager?
    
    class MockTokenManager : TokenManager {
        var response:Response? = nil
        var err:Error? = nil
        override func invokeTokenRequest(_ grantCode: String, callback: BMSCompletionHandler?) {
            callback?(response,err)
        }
    }
    
    // var mockTokenManager:MockTokenManager?
    
    override func setUp() {
        mockRegistrationManager = MockRegistrationManager(preferences: pref)
        AppIDTests.appId.initialize(tenantId: AppIDTests.tenantId, bluemixRegion: BMSClient.Region.usSouth)
        AppIDTests.appId.registrationManager = mockRegistrationManager!
        AppIDTests.appId.preferences.clientId.set(nil)
        //   appId.tokenManager = mockTokenManager!
        super.setUp();
    }
    
    func testLoginRegisterSuccess() {
        let defaultCallBack:BMSCompletionHandler = {(response: Response?, error: Error?) in
            }
        let params = [
            AppIDConstants.JSON_RESPONSE_TYPE_KEY : AppIDConstants.JSON_CODE_KEY,
            AppIDConstants.client_id_String : AppIDTests.clientId,
            AppIDConstants.JSON_REDIRECT_URI_KEY : AppIDConstants.REDIRECT_URI_VALUE,
            AppIDConstants.JSON_SCOPE_KEY : AppIDConstants.OPEN_ID_VALUE,
            AppIDConstants.JSON_USE_LOGIN_WIDGET : AppIDConstants.TRUE_VALUE,
            ]
        
        let url = AppID.sharedInstance.serverUrl + "/" + AppIDConstants.V3_AUTH_PATH + AppIDTests.tenantId + "/" + AppIDConstants.authorizationEndPoint + Utils.getQueryString(params: params)
        
        
        let response = HTTPURLResponse(url: URL(string : "SOMEurl")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        mockRegistrationManager?.response = Response(responseData: nil, httpResponse: response, isRedirect: false)
        mockRegistrationManager?.err = nil
        
        AppIDTests.appId.login(onTokenCompletion: defaultCallBack)
        
        
        var viewUrl = AppIDTests.appId.loginView!.url!.absoluteString
        let firstPart = viewUrl.components(separatedBy: "state=")[0]
        var secondPart = ""
        let comp = viewUrl.components(separatedBy:  "state=")[1].components(separatedBy: "&")
        for i in 1...comp.count - 1 {
            
            secondPart += comp[i] + (i == comp.count - 1 ? "" : "&")
        }
        viewUrl = firstPart + secondPart
        XCTAssertEqual(viewUrl , url)
        XCTAssertEqual(AppIDTests.appId.preferences.registrationTenantId.get(), AppIDTests.tenantId)
        XCTAssertNotNil(AppIDTests.appId.tokenRequest)
        XCTAssertNotNil(AppIDTests.appId.loginView?.callback)
    }
    
    
    
    
    func testLoginRegisterFailed() {
        
        //no saved client id tests
        var callbackCalled = 0
        mockRegistrationManager?.response = nil
        mockRegistrationManager?.err = nil
        let expectation1 = expectation(description: "Callback1 called")
        let expectation2 = expectation(description: "Callback2 called")
        let expectation3 = expectation(description: "Callback3 called")
        let testCallBack = {(response: Response?, error: Error?) in
            callbackCalled += 1
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            expectation1.fulfill()
        }
        AppIDTests.appId.login(onTokenCompletion: testCallBack)
        mockRegistrationManager?.response = nil
        mockRegistrationManager?.err = AppIDError.registrationError(msg: "REGISTRATION err")
        let testCallBack2 = {(response: Response?, error: Error?) in
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            expectation2.fulfill()
        }
        AppIDTests.appId.login(onTokenCompletion: testCallBack2)
        
        //saved client different tenant
        pref.clientId.set("1")
        pref.registrationTenantId.set("2")
        let testCallBack3 = {(response: Response?, error: Error?) in
            XCTAssertEqual(self.mockRegistrationManager?.err?.localizedDescription, error?.localizedDescription)
            XCTAssertNil(response)
            expectation3.fulfill()
        }
        AppIDTests.appId.login(onTokenCompletion: testCallBack3)
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
    }
    
    class mockLoginView : safariView {
        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            completion?()
        }
    }
    
    func testTokens() {
        let accessToken = "thisIsAccessToken"
        let idToken = "thisIsAccessToken"
        XCTAssertEqual(AppIDTests.appId.accessToken, AppIDTests.appId.preferences.accessToken.get())
        XCTAssertEqual(AppIDTests.appId.idToken, AppIDTests.appId.preferences.idToken.get())
        AppIDTests.appId.preferences.accessToken.set(accessToken)
        AppIDTests.appId.preferences.idToken.set(idToken)
        XCTAssertEqual(AppIDTests.appId.accessToken, AppIDTests.appId.preferences.accessToken.get())
        XCTAssertEqual(AppIDTests.appId.idToken, AppIDTests.appId.preferences.idToken.get())
        XCTAssertEqual(AppIDTests.appId.accessToken, accessToken)
        XCTAssertEqual(AppIDTests.appId.idToken, idToken)
    }
    
    func testApplication() {
        //happy flow
        let testcode = "testcode"
        AppIDTests.appId.loginView = mockLoginView(url: URL(string : "http://www.a.com")!)
        let expectation1 = expectation(description: "Callback1 called")
        AppIDTests.appId.tokenRequest = { (code: String?, errMsg:String?) -> Void in
            XCTAssertEqual(code!, testcode)
            XCTAssertNil(errMsg)
            expectation1.fulfill()
        }
        XCTAssertTrue(AppIDTests.appId.application(UIApplication.shared, open: URL(string: AppIDConstants.REDIRECT_URI_VALUE + "?code=" + testcode)!, options: [:]))
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
        //no grant code
        let expectation2 = expectation(description: "Callback2 called")
        AppIDTests.appId.tokenRequest = { (code: String?, errMsg:String?) -> Void in
            XCTAssertNil(code)
            XCTAssertNotNil(errMsg)
            expectation2.fulfill()
        }
        XCTAssertTrue(AppIDTests.appId.application(UIApplication.shared, open: URL(string: AppIDConstants.REDIRECT_URI_VALUE + "?notgrantcode=" + testcode)!, options: [:]))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
        //non happy flow
        XCTAssertFalse(AppIDTests.appId.application(UIApplication.shared, open: URL(string: "someurl" + "?notgrantcode=" + testcode)!, options: [:]))
        
    }
    
    
}

