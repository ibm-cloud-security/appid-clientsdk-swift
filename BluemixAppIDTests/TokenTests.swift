//
//  AbstractTokenTests.swift
//  AppID
//
//  Created by Oded Betzalel on 13/02/2017.
//  Copyright © 2017 Oded Betzalel. All rights reserved.
//

import Foundation

import XCTest
import BMSCore
@testable import BluemixAppID
class TokenTests: XCTestCase {



    func testValidAccessToken() {
        let token = AccessTokenImpl(with: AppIDTestConstants.ACCESS_TOKEN)
        XCTAssertNotNil(token)
        XCTAssertEqual(token?.scope, "appid_default appid_readprofile appid_readuserattr appid_writeuserattr")
        XCTAssertEqual(token?.raw, AppIDTestConstants.ACCESS_TOKEN)
        XCTAssertNotNil(token?.header)
        XCTAssertNotNil(token?.payload)
        XCTAssertNotNil(token?.signature)
        XCTAssertEqual(token?.issuer, "mobileclientaccess.stage1.ng.bluemix.net")

        XCTAssertNil(token?.subject)
        XCTAssertEqual(token?.audience, "26cb012eb327c612d90a6819163b6bcbd4849cbb")
        XCTAssertTrue(token?.issuedAt == Date(timeIntervalSince1970: 1487081278 as Double))
        XCTAssertEqual(token?.tenant, "4dba9430-54e6-4cf2-a516-6f73feb702bb")
        XCTAssertEqual(token?.authenticationMethods?[0], nil)
        XCTAssertTrue(token!.isExpired)
        XCTAssertTrue(token?.expiration == Date(timeIntervalSince1970: 1487084878 as Double))

    }


    func testValidIdToken() {
        let token = IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)

        XCTAssertEqual(token?.email, "donlonqwerty@gmail.com")
        XCTAssertEqual(token?.gender, "male")
        XCTAssertEqual(token?.locale, "en_US")
        XCTAssertEqual(token?.name, "Don Lon")
        XCTAssertEqual(token?.picture, "https://scontent.xx.fbcdn.net/v/t1.0-1/p50x50/13501551_286407838378892_1785766211766730697_n.jpg?oh=242bc2fb505609b442874fde3e9865a9&oe=5907B1BC")
        XCTAssertEqual(token?.identities?.count,0)
        XCTAssertEqual(token?.raw, AppIDTestConstants.ID_TOKEN)
        XCTAssertNotNil(token?.header)
        XCTAssertNotNil(token?.payload)
        XCTAssertNotNil(token?.signature)
        XCTAssertEqual(token?.issuer, "mobileclientaccess.stage1.ng.bluemix.net")
        
        XCTAssertNil(token?.subject)
        XCTAssertEqual(token?.audience, "26cb012eb327c612d90a6819163b6bcbd4849cbb")
        XCTAssertTrue(token?.issuedAt == Date(timeIntervalSince1970: 1487081278 as Double))
        XCTAssertEqual(token?.tenant, "4dba9430-54e6-4cf2-a516-6f73feb702bb")
        XCTAssertEqual(token?.authenticationMethods?[0], nil)
        XCTAssertTrue(token!.isExpired)
        XCTAssertTrue(token?.expiration == Date(timeIntervalSince1970: 1487084878 as Double))
        
    }
    
}
