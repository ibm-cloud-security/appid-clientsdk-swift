//
//  AppIDTests.swift
//  AppID
//
//  Created by Oded Betzalel on 17/01/2017.
//  Copyright © 2017 Oded Betzalel. All rights reserved.
//

import Foundation

import XCTest
import BMSCore
@testable import AppID

class AppIDTests: XCTestCase {
    var appId = AppID.sharedInstance
    let tenantId = "1"
    static var  callbackErr = false;
    static var  callbackResponse = false;
    var pref = AppIDPreferences()
    
    class MockRegistrationManager : RegistrationManager {
        var response:Response? = nil
        var err:Error? = nil
        override func registerDevice(callback :@escaping BMSCompletionHandler) throws {
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
        appId.initialize(tenantId: tenantId, bluemixRegion: BMSClient.Region.usSouth)
        appId.registrationManager = mockRegistrationManager!
        //   appId.tokenManager = mockTokenManager!
        super.setUp();
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
        appId.login(onTokenCompletion: testCallBack)
        mockRegistrationManager?.response = nil
        mockRegistrationManager?.err = AppIDError.registrationError(msg: "REGISTRATION err")
        let testCallBack2 = {(response: Response?, error: Error?) in
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            expectation2.fulfill()
        }
        appId.login(onTokenCompletion: testCallBack2)
        
        //saved client different tenant
        pref.clientId.set("1")
        pref.registrationTenantId.set("2")
        let testCallBack3 = {(response: Response?, error: Error?) in
            XCTAssertEqual(self.mockRegistrationManager?.err?.localizedDescription, error?.localizedDescription)
            XCTAssertNil(response)
            expectation3.fulfill()
        }
        appId.login(onTokenCompletion: testCallBack3)
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
        XCTAssertEqual(appId.accessToken, appId.preferences.accessToken.get())
        XCTAssertEqual(appId.idToken, appId.preferences.idToken.get())
        appId.preferences.accessToken.set(accessToken)
         appId.preferences.idToken.set(idToken)
        XCTAssertEqual(appId.accessToken, appId.preferences.accessToken.get())
        XCTAssertEqual(appId.idToken, appId.preferences.idToken.get())
        XCTAssertEqual(appId.accessToken, accessToken)
        XCTAssertEqual(appId.idToken, idToken)
    }
    
    func testApplication() {
        //happy flow
        let testcode = "testcode"
        appId.loginView = mockLoginView(url: URL(string : "http://www.a.com")!)
        let expectation1 = expectation(description: "Callback1 called")
        appId.tokenRequest = { (code: String?, errMsg:String?) -> Void in
            XCTAssertEqual(code!, testcode)
            XCTAssertNil(errMsg)
            expectation1.fulfill()
        }
        XCTAssertTrue(appId.application(UIApplication.shared, open: URL(string: AppIDConstants.REDIRECT_URI_VALUE + "?code=" + testcode)!, options: [:]))
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
        //no grant code
        let expectation2 = expectation(description: "Callback2 called")
        appId.tokenRequest = { (code: String?, errMsg:String?) -> Void in
            XCTAssertNil(code)
            XCTAssertNotNil(errMsg)
            expectation2.fulfill()
        }
        XCTAssertTrue(appId.application(UIApplication.shared, open: URL(string: AppIDConstants.REDIRECT_URI_VALUE + "?notgrantcode=" + testcode)!, options: [:]))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
        //non happy flow
        XCTAssertFalse(appId.application(UIApplication.shared, open: URL(string: "someurl" + "?notgrantcode=" + testcode)!, options: [:]))
        
    }
    
    
}

