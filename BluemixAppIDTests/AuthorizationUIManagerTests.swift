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

public class AuthorizationUIManagerTests: XCTestCase {


    class MockTokenManager: TokenManager {
        var exp:XCTestExpectation
        init(oAuthManager: OAuthManager, exp: XCTestExpectation) {
            self.exp = exp
            super.init(oAuthManager: oAuthManager)
        }
        
        override func obtainTokens(code:String, authorizationDelegate:AuthorizationDelegate) {
            self.exp.fulfill()
        }
        
    }
    
    class MockSafariView: safariView {
        
        override func dismiss(animated flag: Bool, completion: (() -> Swift.Void)? = nil) {
            completion!()
        }
        
    }
    

    let oauthManager = OAuthManager(appId: AppID.sharedInstance)
    
    class delegate: AuthorizationDelegate {
        var exp: XCTestExpectation?
        var errMsg: String?
        public init(exp: XCTestExpectation?, errMsg:String?) {
            self.exp = exp
            self.errMsg = errMsg
        }
        
        func onAuthorizationFailure(error: AuthorizationError) {
            XCTAssertEqual(error.description, errMsg)
            self.exp?.fulfill()
        }
        
        func onAuthorizationCanceled() {
           XCTFail()
        }
        
        func onAuthorizationSuccess(accessToken: AccessToken, identityToken: IdentityToken, response:Response?) {
             XCTFail()
        }
        
    }
    
    // happy flow
    func testApplicationHappyFlow() {
        
        let expectation1 = expectation(description: "Obtained tokens")
        oauthManager.tokenManager = MockTokenManager(oAuthManager: oauthManager, exp: expectation1)
        let manager = AuthorizationUIManager(oAuthManager: oauthManager, authorizationDelegate: delegate(exp: nil, errMsg: nil), authorizationUrl: "someurl", redirectUri: "someredirect")
        manager.loginView = MockSafariView(url:URL(string: "http://www.someurl.com")!)
        // happy flow
        XCTAssertTrue(manager.application(UIApplication.shared, open: URL(string:AppIDConstants.REDIRECT_URI_VALUE.lowercased() + "?code=somegrantcode")!, options: [:]))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
        
    }
    
    
    // no code no err
    func testApplicationErr() {
        
        let expectation1 = expectation(description: "Obtained tokens")
        let manager = AuthorizationUIManager(oAuthManager: oauthManager, authorizationDelegate: delegate(exp: expectation1, errMsg: "Failed to extract grant code"), authorizationUrl: "someurl", redirectUri: "someredirect")
        manager.loginView = MockSafariView(url:URL(string: "http://www.someurl.com")!)
        XCTAssertFalse(manager.application(UIApplication.shared, open: URL(string:AppIDConstants.REDIRECT_URI_VALUE.lowercased() + "?nocode=something")!, options: [:]))
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
    }
    
    
    // with err msg
    func testApplicationErr2() {
        
        let expectation1 = expectation(description: "Obtained tokens")
        let manager = AuthorizationUIManager(oAuthManager: oauthManager, authorizationDelegate: delegate(exp: expectation1, errMsg: "Failed to obtain access and identity tokens"), authorizationUrl: "someurl", redirectUri: "someredirect")
        manager.loginView = MockSafariView(url:URL(string: "http://www.someurl.com")!)
        XCTAssertFalse(manager.application(UIApplication.shared, open: URL(string:AppIDConstants.REDIRECT_URI_VALUE.lowercased() + "?code=somecode&error=someerr")!, options: [:]))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }

        
    
        
    }

    
}
