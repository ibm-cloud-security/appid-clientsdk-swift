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

public class UserProfileTests: XCTestCase {

    static let bearerHeader = ["Authorization": "Bearer" + AppIDTestConstants.ACCESS_TOKEN]

    static let expectedAttributesPathWithKey = "/api/v1/attributes/key"
    static let expectedAttributesPath = "/api/v1/attributes"
    static let expectedProfilePath = "/tenant/userinfo"

    class MockUserProfileManger : UserProfileManagerImpl {
        var data : Data? = nil
        var response : URLResponse? = nil
        var error : Error? = nil
        var token : String? = nil
        var idTokenSubject: String? = nil

        var expectMethod = "GET"
        var expectedPath = expectedAttributesPath

        override func send(request : URLRequest, handler : @escaping (Data?, URLResponse?, Error?) -> Void) {
            // make sure the token is put on the request:
            if let token = token {
                XCTAssert(("Bearer " + token) == request.value(forHTTPHeaderField: "Authorization"))
            }

            XCTAssert(expectMethod == request.httpMethod)
            XCTAssert(request.url?.path.hasSuffix(expectedPath) == true)
            handler(data, response, error)
        }

        override func getLatestAccessToken() -> String? {
            return token
        }

        override func getLatestIdentityTokenSubject() -> String? {
            return idTokenSubject
        }

    }

    class MyDelegate {

        var failed = false
        var passed = false
        var failureDesc : String? = nil

        func onSuccess(result: [String: Any]) {
            XCTAssert(result["key"] != nil)
            let actualValue = result["key"]!
            let actualValueString = String(describing: actualValue)
            XCTAssert(actualValueString == "value")
            passed = true
        }

        func onFailure(error: Error) {
            failed = true
        }

        func reset() {
            failed = false
            passed = false
        }

    }

    override public func setUp() {
        AppID.sharedInstance.initialize(tenantId: "tenant", region: AppID.regionUSSouth)
    }

    func testGetAllAttributes () {
        let delegate = MyDelegate()
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: "http://someurl.com")!, statusCode: 200, httpVersion: "1.1", headerFields: [:])
        userProfileManager.response = resp
        userProfileManager.data = "{\"key\" : \"value\"}".data(using: .utf8)
        userProfileManager.token = "token"
        userProfileManager.expectMethod = "GET"
        userProfileManager.getAttributes { (err, res) in
            if err == nil {
                delegate.onSuccess(result: res!)
            } else {
                delegate.onFailure(error: err!)
            }
        }
        if delegate.failed || !delegate.passed {
            XCTFail()
        }
        delegate.reset()


    }

    func testGetAllAttributesWithToken () {
        let delegate = MyDelegate()
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: "http://someurl.com")!, statusCode: 200, httpVersion: "1.1", headerFields: [:])
        userProfileManager.response = resp
        userProfileManager.data = "{\"key\" : \"value\"}".data(using: .utf8)
        userProfileManager.token = "token"
        userProfileManager.expectMethod = "GET"
        userProfileManager.getAttributes(accessTokenString: "token") { (err, res) in
            if err == nil {
                delegate.onSuccess(result: res!)
            } else {
                delegate.onFailure(error: err!)
            }
        }
        if delegate.failed || !delegate.passed {
            XCTFail()
        }
        delegate.reset()

    }


    func testGetAttribute () {
        let delegate = MyDelegate()
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: "http://someurl.com")!, statusCode: 200, httpVersion: "1.1", headerFields: [:])
        userProfileManager.response = resp
        userProfileManager.data = "{\"key\" : \"value\"}".data(using: .utf8)
        userProfileManager.token = "token"
        userProfileManager.expectMethod = "GET"
        userProfileManager.expectedPath = UserProfileTests.expectedAttributesPathWithKey
        userProfileManager.getAttribute(key: "key") { (err, res) in
            if err == nil {
                delegate.onSuccess(result: res!)
            } else {
                delegate.onFailure(error: err!)
            }
        }
        if delegate.failed || !delegate.passed {
            XCTFail()
        }
        delegate.reset()


    }

    func testGetAttributeWithToken () {
        let delegate = MyDelegate()
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: "http://someurl.com")!, statusCode: 200, httpVersion: "1.1", headerFields: [:])
        userProfileManager.response = resp
        userProfileManager.data = "{\"key\" : \"value\"}".data(using: .utf8)
        userProfileManager.token = "token"
        userProfileManager.expectMethod = "GET"
        userProfileManager.expectedPath = UserProfileTests.expectedAttributesPathWithKey
        userProfileManager.getAttribute(key: "key", accessTokenString: "token") { (err, res) in
            if err == nil {
                delegate.onSuccess(result: res!)
            } else {
                delegate.onFailure(error: err!)
            }
        }
        if delegate.failed || !delegate.passed {
            XCTFail()
        }
        delegate.reset()


    }


    func testSetAttribute () {
        let delegate = MyDelegate()
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: "http://someurl.com")!, statusCode: 200, httpVersion: "1.1", headerFields: [:])
        userProfileManager.response = resp
        userProfileManager.data = "{\"key\" : \"value\"}".data(using: .utf8)
        userProfileManager.token = "token"
        userProfileManager.expectMethod = "PUT"
        userProfileManager.expectedPath = UserProfileTests.expectedAttributesPathWithKey
        userProfileManager.setAttribute(key: "key", value: "value") { (err, res) in
            if err == nil {
                delegate.onSuccess(result: res!)
            } else {
                delegate.onFailure(error: err!)
            }
        }
        if delegate.failed || !delegate.passed {
            XCTFail()
        }
        delegate.reset()


    }

    func testSetAttributeWithToken () {
        let delegate = MyDelegate()
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: "http://someurl.com")!, statusCode: 200, httpVersion: "1.1", headerFields: [:])
        userProfileManager.response = resp
        userProfileManager.data = "{\"key\" : \"value\"}".data(using: .utf8)
        userProfileManager.token = "token"
        userProfileManager.expectMethod = "PUT"
        userProfileManager.expectedPath = UserProfileTests.expectedAttributesPathWithKey
        userProfileManager.setAttribute(key: "key", value: "value", accessTokenString: "token") { (err, res) in
            if err == nil {
                delegate.onSuccess(result: res!)
            } else {
                delegate.onFailure(error: err!)
            }
        }

        if delegate.failed || !delegate.passed {
            XCTFail()
        }
        delegate.reset()


    }

    func testDeleteAttributeWithToken () {
        let delegate = MyDelegate()
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: "http://someurl.com")!, statusCode: 204, httpVersion: "1.1", headerFields: [:])
        userProfileManager.response = resp
        userProfileManager.data = "".data(using: .utf8)
        userProfileManager.token = "token"
        userProfileManager.expectMethod = "DELETE"
        userProfileManager.expectedPath = UserProfileTests.expectedAttributesPathWithKey
        userProfileManager.deleteAttribute(key: "key", accessTokenString: "token") { (err, res) in
            guard err == nil else {
                return delegate.onFailure(error: err!)
            }
            XCTAssertEqual(res!.count, 0)
            delegate.passed = true
        }

        if delegate.failed || !delegate.passed {
            XCTFail()
        }
        delegate.reset()


    }

    func testFailure () {
        let delegate = MyDelegate()
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: "http://someurl.com")!, statusCode: 404, httpVersion: "1.1", headerFields: [:])
        userProfileManager.response = resp
        userProfileManager.data = "{\"error\" : \"NOT_FOUND\"}".data(using: .utf8)
        userProfileManager.token = "token"
        userProfileManager.expectMethod = "PUT"
        userProfileManager.expectedPath = UserProfileTests.expectedAttributesPathWithKey
        userProfileManager.setAttribute(key: "key", value: "value", accessTokenString: "token") { (err, res) in
            if err == nil {
                delegate.onSuccess(result: res!)
            } else {
                delegate.onFailure(error: err!)
            }
        }
        XCTAssert(delegate.failed)
        delegate.reset()


    }

    func testUserInfoSuccessFlow () {
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: UserProfileTests.expectedProfilePath)!, statusCode: 200, httpVersion: "1.1", headerFields: UserProfileTests.bearerHeader)
        userProfileManager.response = resp
        userProfileManager.expectedPath = UserProfileTests.expectedProfilePath
        userProfileManager.token = AppIDConstants.APPID_ACCESS_TOKEN
        userProfileManager.data = "{\"sub\" : \"123\"}".data(using: .utf8)
        userProfileManager.idTokenSubject = "123"

        func happyFlowHandler(err: Swift.Error?, res: [String: Any]?) {
            guard err == nil, let res = res else {
                return XCTFail()
            }
            guard let dict = res as? [String: String] else {
                return XCTFail()
            }
            XCTAssert(dict == ["sub": "123"])
        }

        userProfileManager.getUserInfo(completionHandler: happyFlowHandler)
        userProfileManager.getUserInfo(accessTokenString: AppIDConstants.APPID_ACCESS_TOKEN,
                                       identityTokenString: nil,
                                       completionHandler: happyFlowHandler)
        userProfileManager.getUserInfo(accessTokenString: AppIDConstants.APPID_ACCESS_TOKEN,
                                       identityTokenString: AppIDTestConstants.ID_TOKEN_WITH_SUBJECT,
                                       completionHandler: happyFlowHandler)
    }

    func testMissingAccessToken () {
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        userProfileErrorHandler(manager: userProfileManager, expectedError: .missingAccessToken)
    }

    func testUnauthorized () {
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: UserProfileTests.expectedProfilePath)!, statusCode: 401, httpVersion: "1.1", headerFields: UserProfileTests.bearerHeader)
        userProfileManager.response = resp
        userProfileManager.token = "Bad token"
        userProfileManager.idTokenSubject = "123"
        userProfileManager.expectedPath = UserProfileTests.expectedProfilePath
        userProfileErrorHandler(manager: userProfileManager, expectedError: .unauthorized)
    }

    func testUserNotFound () {
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: UserProfileTests.expectedProfilePath)!, statusCode: 404, httpVersion: "1.1", headerFields: UserProfileTests.bearerHeader)
        userProfileManager.response = resp
        userProfileManager.token = AppIDConstants.APPID_ACCESS_TOKEN
        userProfileManager.idTokenSubject = "123"
        userProfileManager.expectedPath = UserProfileTests.expectedProfilePath
        userProfileErrorHandler(manager: userProfileManager, expectedError: .notFound)
    }

    func testUnexpectedResponseCode () {
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: UserProfileTests.expectedProfilePath)!, statusCode: 500, httpVersion: "1.1", headerFields: UserProfileTests.bearerHeader)
        userProfileManager.response = resp
        userProfileManager.token = "Bad token"
        userProfileManager.idTokenSubject = "123"
        userProfileManager.expectedPath = UserProfileTests.expectedProfilePath
        userProfileErrorHandler(manager: userProfileManager, expectedError: .general("Unexpected"))
    }

    func testTokenSubstitutionAttack () {
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: UserProfileTests.expectedProfilePath)!, statusCode: 200, httpVersion: "1.1", headerFields: UserProfileTests.bearerHeader)
        userProfileManager.response = resp
        userProfileManager.data = "{\"sub\" : \"1234\"}".data(using: .utf8)
        userProfileManager.token = AppIDConstants.APPID_ACCESS_TOKEN
        userProfileManager.idTokenSubject = "123"
        userProfileManager.expectedPath = UserProfileTests.expectedProfilePath
        userProfileErrorHandler(manager: userProfileManager, expectedError: .responseValidationError)
    }

    func testUnexpectedError () {
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        userProfileManager.error = NSError(domain: "Unexpected", code: 1, userInfo: nil)
        userProfileManager.data = "{\"sub\" : \"1234\"}".data(using: .utf8)
        userProfileManager.token = AppIDConstants.APPID_ACCESS_TOKEN
        userProfileManager.idTokenSubject = "123"
        userProfileManager.expectedPath = UserProfileTests.expectedProfilePath
        userProfileErrorHandler(manager: userProfileManager, expectedError: .general("Unexpected"))
    }

    func testNoData () {
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: UserProfileTests.expectedProfilePath)!, statusCode: 200, httpVersion: "1.1", headerFields: UserProfileTests.bearerHeader)
        userProfileManager.response = resp
        userProfileManager.token = AppIDConstants.APPID_ACCESS_TOKEN
        userProfileManager.idTokenSubject = "123"
        userProfileManager.expectedPath = UserProfileTests.expectedProfilePath
        userProfileErrorHandler(manager: userProfileManager, expectedError: .general("Failed to parse server response - no response text"))
    }

    func testNoResponse () {
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        userProfileManager.data = "{\"sub\" : \"1234\"}".data(using: .utf8)
        userProfileManager.token = AppIDConstants.APPID_ACCESS_TOKEN
        userProfileManager.idTokenSubject = "123"
        userProfileManager.expectedPath = UserProfileTests.expectedProfilePath
        userProfileErrorHandler(manager: userProfileManager, expectedError: .general("Did not receive a response"))
    }

    func testMalformedJsonData () {
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: UserProfileTests.expectedProfilePath)!, statusCode: 200, httpVersion: "1.1", headerFields: UserProfileTests.bearerHeader)
        userProfileManager.response = resp
        userProfileManager.data = "\"sub\" : \"1234\"}".data(using: .utf8)
        userProfileManager.token = AppIDConstants.APPID_ACCESS_TOKEN
        userProfileManager.idTokenSubject = "123"
        userProfileManager.expectedPath = UserProfileTests.expectedProfilePath
        userProfileErrorHandler(manager: userProfileManager, expectedError: .bodyParsingError)
    }

    func testInvalidUserInfoResponse () {
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: UserProfileTests.expectedProfilePath)!, statusCode: 200, httpVersion: "1.1", headerFields: UserProfileTests.bearerHeader)
        userProfileManager.response = resp
        userProfileManager.data = "{\"nosub\" : \"1234\"}".data(using: .utf8)
        userProfileManager.token = AppIDConstants.APPID_ACCESS_TOKEN
        userProfileManager.idTokenSubject = "123"
        userProfileManager.expectedPath = UserProfileTests.expectedProfilePath
        userProfileErrorHandler(manager: userProfileManager, expectedError: .invalidUserInfoResponse)
    }

    func testMalformedIdentityToken () {
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        userProfileManager.getUserInfo(accessTokenString: "", identityTokenString: "bad token") { (err, resp) in
            guard let err = err as? UserProfileError else {
                return XCTFail()
            }
            XCTAssert(err.description == UserProfileError.missingOrMalformedIdToken.description)
        }
    }

    func testIdentityTokenWithoutSubject () {
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        let resp = HTTPURLResponse(url: URL(string: UserProfileTests.expectedProfilePath)!, statusCode: 200, httpVersion: "1.1", headerFields: UserProfileTests.bearerHeader)
        userProfileManager.response = resp
        userProfileManager.data = "{\"sub\" : \"1234\"}".data(using: .utf8)
        userProfileManager.expectedPath = UserProfileTests.expectedProfilePath
        userProfileManager.getUserInfo(accessTokenString: AppIDTestConstants.ACCESS_TOKEN,
                                        identityTokenString: AppIDTestConstants.ID_TOKEN) { (err, res) in
            if err != nil {
                return XCTFail()
            }

            guard let dict = res as? [String: String] else {
                return XCTFail()
            }
            XCTAssert(dict == ["sub": "1234"])
        }
    }

    func testMalformedUserProvidedIdToken () {
        let userProfileManager = MockUserProfileManger(appId: AppID.sharedInstance)
        userProfileManager.getUserInfo(accessTokenString: "", identityTokenString: "") { (err, resp) in
            guard let err = err as? UserProfileError else {
                return XCTFail()
            }
            XCTAssert(err.description == UserProfileError.missingOrMalformedIdToken.description)
        }
    }

    func userProfileErrorHandler(manager: UserProfileManager, expectedError: UserProfileError) {
        manager.getUserInfo { (err, res) in
            guard let error = err as? UserProfileError else {
                return XCTFail()
            }

            switch (expectedError, error) {
            case (.general(_), .general(_)): return
            default:
                XCTAssert(error.description == expectedError.description)
            }
        }
    }

}
