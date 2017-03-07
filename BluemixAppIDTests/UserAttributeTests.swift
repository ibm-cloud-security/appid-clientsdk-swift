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

public class UserAttributeTests: XCTestCase {

    class MockUserAttributeManger : UserAttributeManagerImpl {
        var data : Data? = nil
        var response : URLResponse? = nil
        var error : Error? = nil
        var token : String? = nil

        var expectMethod = "GET"

        override func send(request : URLRequest, handler : @escaping (Data?, URLResponse?, Error?) -> Void) {
            // make sure the token is put on the request:
            if token != nil {
                let unWrappedToken = token!
                XCTAssert(("Bearer "+unWrappedToken) == request.value(forHTTPHeaderField: "Authorization"))
            }

            XCTAssert(expectMethod == request.httpMethod)
            handler(data, response, error)
        }

        override func getLatestToken() -> String? {
            return token
        }

    }

    class MyDelegate {

        var failed = false
        var passed = false
        var failureDesc : String? = nil

        func onSuccess(result: [String:Any]) {
            XCTAssert(result["key"] != nil)
            let actualValue = result["key"]!
            var actualValueString = String(describing: actualValue)
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

    func testGetAllAttributes () {
        var delegate = MyDelegate()
        var userAttributeManager = MockUserAttributeManger(appId: AppID.sharedInstance)
        var resp = HTTPURLResponse(url: URL(string: "http://someurl.com")!, statusCode: 200, httpVersion: "1.1", headerFields: [:])
        userAttributeManager.response = resp
        userAttributeManager.data = "{\"key\" : \"value\"}".data(using: .utf8)
        userAttributeManager.expectMethod = "GET"
        userAttributeManager.getAttributes { (err, res) in
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
        var delegate = MyDelegate()
        var userAttributeManager = MockUserAttributeManger(appId: AppID.sharedInstance)
        var resp = HTTPURLResponse(url: URL(string: "http://someurl.com")!, statusCode: 200, httpVersion: "1.1", headerFields: [:])
        userAttributeManager.response = resp
        userAttributeManager.data = "{\"key\" : \"value\"}".data(using: .utf8)
        userAttributeManager.token = "token"
        userAttributeManager.expectMethod = "GET"
        userAttributeManager.getAttributes(accessTokenString: "token") { (err, res) in
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
        var delegate = MyDelegate()
        var userAttributeManager = MockUserAttributeManger(appId: AppID.sharedInstance)
        var resp = HTTPURLResponse(url: URL(string: "http://someurl.com")!, statusCode: 200, httpVersion: "1.1", headerFields: [:])
        userAttributeManager.response = resp
        userAttributeManager.data = "{\"key\" : \"value\"}".data(using: .utf8)
        userAttributeManager.expectMethod = "GET"
        userAttributeManager.getAttribute(key: "key") { (err, res) in
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
        var delegate = MyDelegate()
        var userAttributeManager = MockUserAttributeManger(appId: AppID.sharedInstance)
        var resp = HTTPURLResponse(url: URL(string: "http://someurl.com")!, statusCode: 200, httpVersion: "1.1", headerFields: [:])
        userAttributeManager.response = resp
        userAttributeManager.data = "{\"key\" : \"value\"}".data(using: .utf8)
        userAttributeManager.token = "token"
        userAttributeManager.expectMethod = "GET"
        userAttributeManager.getAttribute(key: "key", accessTokenString: "token") { (err, res) in
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
        var delegate = MyDelegate()
        var userAttributeManager = MockUserAttributeManger(appId: AppID.sharedInstance)
        var resp = HTTPURLResponse(url: URL(string: "http://someurl.com")!, statusCode: 200, httpVersion: "1.1", headerFields: [:])
        userAttributeManager.response = resp
        userAttributeManager.data = "{\"key\" : \"value\"}".data(using: .utf8)
        userAttributeManager.expectMethod = "PUT"
        userAttributeManager.setAttribute(key: "key", value: "value") { (err, res) in
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
        var delegate = MyDelegate()
        var userAttributeManager = MockUserAttributeManger(appId: AppID.sharedInstance)
        var resp = HTTPURLResponse(url: URL(string: "http://someurl.com")!, statusCode: 200, httpVersion: "1.1", headerFields: [:])
        userAttributeManager.response = resp
        userAttributeManager.data = "{\"key\" : \"value\"}".data(using: .utf8)
        userAttributeManager.token = "token"
        userAttributeManager.expectMethod = "PUT"
        userAttributeManager.setAttribute(key: "key", value: "value", accessTokenString: "token") { (err, res) in
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

    func testFailure () {
        var delegate = MyDelegate()
        var userAttributeManager = MockUserAttributeManger(appId: AppID.sharedInstance)
        var resp = HTTPURLResponse(url: URL(string: "http://someurl.com")!, statusCode: 404, httpVersion: "1.1", headerFields: [:])
        userAttributeManager.response = resp
        userAttributeManager.data = "{\"error\" : \"NOT_FOUND\"}".data(using: .utf8)
        userAttributeManager.token = "token"
        userAttributeManager.expectMethod = "PUT"
        userAttributeManager.setAttribute(key: "key", value: "value", accessTokenString: "token") { (err, res) in
            if err == nil {
                delegate.onSuccess(result: res!)
            } else {
                delegate.onFailure(error: err!)
            }
        }
        XCTAssert(delegate.failed)
        delegate.reset()


    }


}
