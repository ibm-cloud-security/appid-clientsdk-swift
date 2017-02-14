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

public class AppIDAuthorizationManagerTests: XCTestCase {
    
    static var appid:AppID? = nil
    static var manager:AppIDAuthorizationManager? = nil
    
    override public func setUp() {
        super.setUp()
        AppID.sharedInstance.initialize(tenantId: "123", bluemixRegion: "123")
        AppIDAuthorizationManagerTests.appid = AppID.sharedInstance
        AppIDAuthorizationManagerTests.manager = AppIDAuthorizationManager(appid: AppIDAuthorizationManagerTests.appid!)
    }
    
    public func testIsAuthorizationRequired () {
        
        // 401 status, Www-Authenticate header exist, but invalid value
        XCTAssertFalse((AppIDAuthorizationManagerTests.manager?.isAuthorizationRequired(for: 401, httpResponseAuthorizationHeader: "Dummy"))!)
        
        // 401 status, Www-Authenticate header exists, Bearer exists, but not appid scope
        XCTAssertFalse((AppIDAuthorizationManagerTests.manager?.isAuthorizationRequired(for: 401, httpResponseAuthorizationHeader: "Bearer Dummy"))!)
        
        // 401 with bearer and correct scope
        XCTAssertTrue((AppIDAuthorizationManagerTests.manager?.isAuthorizationRequired(for: 401, httpResponseAuthorizationHeader: "Bearer scope=\"appid_default\""))!)
        
        // Check with http response
        
        let response = HTTPURLResponse(url: URL(string: "ADS")!, statusCode: 401, httpVersion: nil, headerFields: [AppIDConstants.WWW_AUTHENTICATE_HEADER : "Bearer scope=\"appid_default\""])
        XCTAssertTrue((AppIDAuthorizationManagerTests.manager?.isAuthorizationRequired(for: Response(responseData: nil, httpResponse: response, isRedirect: false)))!)
    }
    
    static var expectedResponse:Response = Response(responseData: nil, httpResponse: HTTPURLResponse(url: URL(string: "ADS")!, statusCode: 401, httpVersion: nil, headerFields: [AppIDConstants.WWW_AUTHENTICATE_HEADER : "Bearer scope=\"appid_default\""]), isRedirect: false)
    class MockAuthorizationManager: BluemixAppID.AuthorizationManager {
        static var res = "cancel"
        override func launchAuthorizationUI(authorizationDelegate:AuthorizationDelegate) {
            if MockAuthorizationManager.res == "success" {
                authorizationDelegate.onAuthorizationSuccess(accessToken:AccessTokenImpl(with: AppIDTestConstants.ACCESS_TOKEN)!, identityToken : IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)!, response: AppIDAuthorizationManagerTests.expectedResponse)
            } else if MockAuthorizationManager.res == "failure" {
                authorizationDelegate.onAuthorizationFailure(error: AuthorizationError.authorizationFailure("someerr"))
            } else {
                authorizationDelegate.onAuthorizationCanceled()
            }
        }
    }

    
    public func testObtainAuthorization1() {
        
        MockAuthorizationManager.res = "cancel"
        AppIDAuthorizationManagerTests.manager?.oAuthManager.authorizationManager = MockAuthorizationManager(oAuthManager: (AppIDAuthorizationManagerTests.manager?.oAuthManager)!)
        let callback:BMSCompletionHandler = {(response:Response?, error:Error?) in
            XCTAssertNil(response)
            XCTAssertNotNil(error as? AuthorizationError) // TODO: test it better
        }
        AppIDAuthorizationManagerTests.manager?.obtainAuthorization(completionHandler: callback)
        
    }

    public func testObtainAuthorization2() {
        MockAuthorizationManager.res = "success"
        
        
        AppIDAuthorizationManagerTests.manager?.oAuthManager.authorizationManager = MockAuthorizationManager(oAuthManager: (AppIDAuthorizationManagerTests.manager?.oAuthManager)!)
        let callback:BMSCompletionHandler = {(response:Response?, error:Error?) in
            XCTAssertNotNil(response)
            XCTAssertEqual(AppIDAuthorizationManagerTests.expectedResponse.statusCode, response?.statusCode)
            XCTAssertEqual(AppIDAuthorizationManagerTests.expectedResponse.responseText, response?.responseText)
            XCTAssertEqual(AppIDAuthorizationManagerTests.expectedResponse.responseData, response?.responseData)
            XCTAssertNil(error)
        }
        AppIDAuthorizationManagerTests.manager?.obtainAuthorization(completionHandler: callback)
        
    }

    public func testObtainAuthorization3() {
        
        MockAuthorizationManager.res = "failure"
        AppIDAuthorizationManagerTests.manager?.oAuthManager.authorizationManager = MockAuthorizationManager(oAuthManager: (AppIDAuthorizationManagerTests.manager?.oAuthManager)!)
        let callback:BMSCompletionHandler = {(response:Response?, error:Error?) in
            XCTAssertNil(response)
            XCTAssertNotNil(error as? AuthorizationError) // TODO: test it better
        }
        AppIDAuthorizationManagerTests.manager?.obtainAuthorization(completionHandler: callback)
        
    }

    public func testGetCachedAuthorizationHeader () {
        class AppIDAuthorizationManagerMock: AppIDAuthorizationManager {
            var aToken:AccessToken?
            var iToken:IdentityToken?
            init(accessToken:AccessToken?, idToken:IdentityToken?) {
                self.aToken = accessToken
                self.iToken = idToken
                super.init(appid: AppIDAuthorizationManagerTests.appid!)
            }
            
            public override var accessToken: AccessToken? {
                get {
                    return aToken
                }
            }
            
            public override var identityToken: IdentityToken? {
                get {
                    return iToken
                }
            }
        }
        let accessToken = AccessTokenImpl(with: AppIDTestConstants.ACCESS_TOKEN)
        let idToken = IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)
        XCTAssertNil(AppIDAuthorizationManagerMock(accessToken: nil,idToken: nil).cachedAuthorizationHeader)
        XCTAssertNil(AppIDAuthorizationManagerMock(accessToken: accessToken,idToken: nil).cachedAuthorizationHeader)
        XCTAssertNil(AppIDAuthorizationManagerMock(accessToken: nil,idToken: idToken).cachedAuthorizationHeader)
        XCTAssertEqual((AppIDAuthorizationManagerMock(accessToken: accessToken,idToken: idToken).cachedAuthorizationHeader), "Bearer " + accessToken!.raw + " " + idToken!.raw)
        
        
        
    }
}
