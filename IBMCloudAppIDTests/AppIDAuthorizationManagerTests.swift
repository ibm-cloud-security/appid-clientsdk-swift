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
@testable import IBMCloudAppID

public class AppIDAuthorizationManagerTests: XCTestCase {

    static var appid:AppID? = nil
    static var manager:AppIDAuthorizationManager? = nil

    override public func setUp() {
        super.setUp()
        AppID.sharedInstance.initialize(tenantId: "123", region: "123")
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
    class MockAuthorizationManager: IBMCloudAppID.AuthorizationManager {
        static var res = "cancel"

        var shouldCallObtainTokensRefreshToken = false
        var obtainTokensRefreshTokenCalled = false

        override func launchAuthorizationUI(accessTokenString: String? = nil, authorizationDelegate:AuthorizationDelegate) {
            if MockAuthorizationManager.res == "success" {
                authorizationDelegate.onAuthorizationSuccess(
                    accessToken:AccessTokenImpl(with: AppIDTestConstants.ACCESS_TOKEN)!,
                    identityToken : IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)!,
                    refreshToken: nil,
                    response: AppIDAuthorizationManagerTests.expectedResponse)
            } else if MockAuthorizationManager.res == "failure" {
                authorizationDelegate.onAuthorizationFailure(error: AuthorizationError.authorizationFailure("someerr"))
            } else {
                authorizationDelegate.onAuthorizationCanceled()
            }

        }

        override func signinWithRefreshToken(refreshTokenString: String?, tokenResponseDelegate: TokenResponseDelegate) {
            obtainTokensRefreshTokenCalled = true
            if !shouldCallObtainTokensRefreshToken {
                XCTFail("Unexpected call to obtainTokensRefreshToken")
            }
        }

        func verify() {
            if shouldCallObtainTokensRefreshToken && !obtainTokensRefreshTokenCalled {
                XCTFail("Should have called obtainTokensRefreshToken, but the function wasn't called")
            }
        }

    }


    public func testObtainAuthorizationCanceled() {

        MockAuthorizationManager.res = "cancel"
        AppIDAuthorizationManagerTests.manager?.oAuthManager.authorizationManager = MockAuthorizationManager(oAuthManager: (AppIDAuthorizationManagerTests.manager?.oAuthManager)!)
        let callback:BMSCompletionHandler = {(response:Response?, error:Error?) in
            XCTAssertNil(response)
            XCTAssertEqual((error as? AuthorizationError)?.description, "Authorization canceled")
        }
        AppIDAuthorizationManagerTests.manager?.obtainAuthorization(completionHandler: callback)

    }

    public func testObtainAuthorizationSuccess() {
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

    public func testObtainAuthorizationWithRefreshTokenSuccess() {
        MockAuthorizationManager.res = "failure"

        AppIDAuthorizationManagerTests.manager?.oAuthManager.authorizationManager = MockAuthorizationManager(oAuthManager: (AppIDAuthorizationManagerTests.manager?.oAuthManager)!)

        let tokenManager = TestHelpers.MockTokenManager(
            oAuthManager: AppIDAuthorizationManagerTests.manager!.oAuthManager)

        AppIDAuthorizationManagerTests.manager?.oAuthManager.tokenManager = tokenManager
        tokenManager.latestRefreshToken = RefreshTokenImpl(with: "ststs")
        tokenManager.shouldCallObtainWithRefresh = true
        let callback:BMSCompletionHandler = {(response:Response?, error:Error?) in
            XCTAssertNotNil(response)
            XCTAssertNil(error)
        }
        AppIDAuthorizationManagerTests.manager?.obtainAuthorization(completionHandler: callback)
        tokenManager.verify()
    }

    public func testObtainAuthorizationSuccessAfterRefreshFails() {
        MockAuthorizationManager.res = "success"
        AppIDAuthorizationManagerTests.manager?.oAuthManager.authorizationManager = MockAuthorizationManager(oAuthManager: (AppIDAuthorizationManagerTests.manager?.oAuthManager)!)
        let tokenManager = TestHelpers.MockTokenManager(
            oAuthManager: AppIDAuthorizationManagerTests.manager!.oAuthManager)
        AppIDAuthorizationManagerTests.manager?.oAuthManager.tokenManager = tokenManager
        tokenManager.shouldCallObtainWithRefresh = true
        tokenManager.obtainWithRefreshShouldFail = true
        tokenManager.latestRefreshToken = RefreshTokenImpl(with: "ststs")

        let callback:BMSCompletionHandler = {(response:Response?, error:Error?) in
            XCTAssertNotNil(response)
            XCTAssertEqual(AppIDAuthorizationManagerTests.expectedResponse.statusCode, response?.statusCode)
            XCTAssertEqual(AppIDAuthorizationManagerTests.expectedResponse.responseText, response?.responseText)
            XCTAssertEqual(AppIDAuthorizationManagerTests.expectedResponse.responseData, response?.responseData)
            XCTAssertNil(error)
        }
        AppIDAuthorizationManagerTests.manager?.obtainAuthorization(completionHandler: callback)
        tokenManager.verify()
    }


    public func testObtainAuthorizationFailure() {

        MockAuthorizationManager.res = "failure"
        AppIDAuthorizationManagerTests.manager?.oAuthManager.authorizationManager = MockAuthorizationManager(oAuthManager: (AppIDAuthorizationManagerTests.manager?.oAuthManager)!)
        let callback:BMSCompletionHandler = {(response:Response?, error:Error?) in
            XCTAssertNil(response)
            XCTAssertEqual((error as? AuthorizationError)?.description, "someerr")
        }
        AppIDAuthorizationManagerTests.manager?.obtainAuthorization(completionHandler: callback)

    }

    public func testObtainAuthorizationFailsAfterRefreshFails() {
        MockAuthorizationManager.res = "failure"
        AppIDAuthorizationManagerTests.manager?.oAuthManager.authorizationManager = MockAuthorizationManager(oAuthManager: (AppIDAuthorizationManagerTests.manager?.oAuthManager)!)
        let tokenManager = TestHelpers.MockTokenManager(
            oAuthManager: AppIDAuthorizationManagerTests.manager!.oAuthManager)
        AppIDAuthorizationManagerTests.manager?.oAuthManager.tokenManager = tokenManager
        tokenManager.shouldCallObtainWithRefresh = true
        tokenManager.obtainWithRefreshShouldFail = true
        tokenManager.latestRefreshToken = RefreshTokenImpl(with: "ststs")
        let callback:BMSCompletionHandler = {(response:Response?, error:Error?) in
            XCTAssertNil(response)
            XCTAssertEqual((error as? AuthorizationError)?.description, "someerr")
        }
        AppIDAuthorizationManagerTests.manager?.obtainAuthorization(completionHandler: callback)
        tokenManager.verify()
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
