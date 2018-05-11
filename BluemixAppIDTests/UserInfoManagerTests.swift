/* *     Copyright 2016, 2018 IBM Corp.
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

public class UserInfoManagerTests: XCTestCase {
    
    static let expectedUrl = Config.getServerUrl(appId: AppID.sharedInstance) + "/" + AppIDConstants.userInfoEndPoint
    static let bearerHeader = ["Authorization":"Bearer" + AppIDTestConstants.ACCESS_TOKEN];
    
    class MockUserManger : UserInfoManager {
        var data: Data? = nil
        var response: URLResponse? = nil
        var error: Error? = nil
        var token: String? = nil
        var idTokenSubject: String? = nil
        var expectMethod = "GET"
        
        override func send(request: URLRequest, handler: @escaping (Data?, URLResponse?, Error?) -> Void) {

            if let token = token {
                XCTAssert(("Bearer "+token) == request.value(forHTTPHeaderField: "Authorization"))
            }
            
            XCTAssert(request.url?.absoluteString == expectedUrl)
            XCTAssert(expectMethod == request.httpMethod)
            handler(data, response, error)
        }
        
        override func getLatestAccessToken() -> String? {
            return token
        }
        
        override func getLatestIdentityTokenSubject() -> String? {
            return idTokenSubject
        }
        
    }
    
    var userManager: MockUserManger!
    
    override public func setUp() {
        AppID.sharedInstance.initialize(tenantId: "tenant1", bluemixRegion: AppID.REGION_US_SOUTH)
        userManager = MockUserManger(appId: AppID.sharedInstance)
    }
    
    func testUserInfoSuccessFlow () {
        let resp = HTTPURLResponse(url: URL(string: UserInfoManagerTests.expectedUrl)!, statusCode: 200, httpVersion: "1.1", headerFields: UserInfoManagerTests.bearerHeader)
        userManager.response = resp
        userManager.token = AppIDConstants.APPID_ACCESS_TOKEN
        userManager.data = "{\"sub\" : \"123\"}".data(using: .utf8)
        userManager.idTokenSubject = "123"
        
        func happyFlowHandler(err: Swift.Error?, res: [String: Any]?) {
            guard err == nil, let res = res else {
                return XCTFail()
            }
            XCTAssert((res as! [String: String]) == ["sub": "123"])
        }
        
        userManager.getUserInfo(completion: happyFlowHandler)
        userManager.getUserInfo(accessToken: AppIDConstants.APPID_ACCESS_TOKEN, idToken: nil, completion: happyFlowHandler)
        userManager.getUserInfo(accessToken: AppIDConstants.APPID_ACCESS_TOKEN,
                                idToken: AppIDTestConstants.ID_TOKEN_WITH_SUBJECT,
                                completion: happyFlowHandler)
    }
    
    func testMissingAccessToken () {
        errorHandler(expectedError: .missingAccessToken)
    }
    
    func testUnauthorized () {
        let resp = HTTPURLResponse(url: URL(string: UserInfoManagerTests.expectedUrl)!, statusCode: 401, httpVersion: "1.1", headerFields: UserInfoManagerTests.bearerHeader)
        userManager.response = resp
        userManager.token = "Bad token"
        userManager.idTokenSubject = "123"
        errorHandler(expectedError: .unauthorized)
    }
    
    func testUserNotFound () {
        let resp = HTTPURLResponse(url: URL(string: UserInfoManagerTests.expectedUrl)!, statusCode: 404, httpVersion: "1.1", headerFields: UserInfoManagerTests.bearerHeader)
        userManager.response = resp
        userManager.token = AppIDConstants.APPID_ACCESS_TOKEN
        userManager.idTokenSubject = "123"
        errorHandler(expectedError: .notFound)
    }
    
    func testUnexpectedResponseCode () {
        let resp = HTTPURLResponse(url: URL(string: UserInfoManagerTests.expectedUrl)!, statusCode: 500, httpVersion: "1.1", headerFields: UserInfoManagerTests.bearerHeader)
        userManager.response = resp
        userManager.token = "Bad token"
        userManager.idTokenSubject = "123"
        errorHandler(expectedError: .general("Unexpected"))
    }
    
    func testTokenSubstitutionAttack () {
        let resp = HTTPURLResponse(url: URL(string: UserInfoManagerTests.expectedUrl)!, statusCode: 200, httpVersion: "1.1", headerFields: UserInfoManagerTests.bearerHeader)
        userManager.response = resp
        userManager.data = "{\"sub\" : \"1234\"}".data(using: .utf8)
        userManager.token = AppIDConstants.APPID_ACCESS_TOKEN
        userManager.idTokenSubject = "123"
        errorHandler(expectedError: .responseValidationError)
    }
    
    func testUnexpectedError () {
        userManager.error = NSError(domain: "Unexpected", code: 1, userInfo: nil)
        userManager.data = "{\"sub\" : \"1234\"}".data(using: .utf8)
        userManager.token = AppIDConstants.APPID_ACCESS_TOKEN
        userManager.idTokenSubject = "123"
        errorHandler(expectedError: .general("Unexpected"))
    }
    
    func testNoData () {
        let resp = HTTPURLResponse(url: URL(string: UserInfoManagerTests.expectedUrl)!, statusCode: 200, httpVersion: "1.1", headerFields: UserInfoManagerTests.bearerHeader)
        userManager.response = resp
        userManager.token = AppIDConstants.APPID_ACCESS_TOKEN
        userManager.idTokenSubject = "123"
        errorHandler(expectedError: .general("Unexpected"))
    }
    
    func testNoResponse () {
        userManager.data = "{\"sub\" : \"1234\"}".data(using: .utf8)
        userManager.token = AppIDConstants.APPID_ACCESS_TOKEN
        userManager.idTokenSubject = "123"
        errorHandler(expectedError: .general("Unexpected"))
    }
    
    func testMalformedJsonData () {
        let resp = HTTPURLResponse(url: URL(string: UserInfoManagerTests.expectedUrl)!, statusCode: 200, httpVersion: "1.1", headerFields: UserInfoManagerTests.bearerHeader)
        userManager.response = resp
        userManager.data = "\"sub\" : \"1234\"}".data(using: .utf8)
        userManager.token = AppIDConstants.APPID_ACCESS_TOKEN
        userManager.idTokenSubject = "123"
        errorHandler(expectedError: .general("Unexpected"))
    }
    
    func testMalformedIdentityToken () {
        userManager.getUserInfo(accessToken: "", idToken: "bad token") { (err, resp) in
            guard let err = err as? UserInfoManagerError else {
                return XCTFail()
            }
            XCTAssert(err.description == UserInfoManagerError.missingOrMalformedIdToken.description)
        }
    }
    
    func testValidIdentityToken () {
        userManager.getUserInfo(accessToken: "", idToken: "") { (err, resp) in
            guard let err = err as? UserInfoManagerError else {
                return XCTFail()
            }
            XCTAssert(err.description == UserInfoManagerError.missingOrMalformedIdToken.description)
        }
    }
    
    func errorHandler(expectedError: UserInfoManagerError) {
        userManager.getUserInfo { (err, res) in
            guard let error = err as? UserInfoManagerError else {
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
