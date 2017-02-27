//
//  UserAttributeTests.swift
//  BluemixAppID
//
//  Created by Moty Drimer on 23/02/2017.
//  Copyright © 2017 Oded Betzalel. All rights reserved.
//

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
            if (token != nil) {
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
    
    class MyDelegate : UserAttributeDelegate {
        
        var failed = false;
        var passed = false;
        
        func onSuccess(result: [String:Any]) {
            XCTAssert(result["key"] != nil)
            let actualValue = result["key"]!
            var actualValueString = String(describing: actualValue)
            XCTAssert(actualValueString == "value")
            passed = true
        }
        func onFailure(error: UserAttributeError) {
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
        userAttributeManager.getAttributes(delegate: delegate)
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
        userAttributeManager.getAttributes(accessTokenString: "token", delegate: delegate)
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
        userAttributeManager.getAttribute(key : "key", delegate: delegate)
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
        userAttributeManager.getAttribute(key : "key", accessTokenString: "token", delegate: delegate)
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
        userAttributeManager.setAttribute(key : "key", value : "value", delegate: delegate)
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
        userAttributeManager.setAttribute(key : "key", value : "value", accessTokenString: "token", delegate: delegate)
        if delegate.failed || !delegate.passed {
            XCTFail()
        }
        delegate.reset()
        
        
    }
    
    
}
