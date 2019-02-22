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
@testable import IBMCloudAppID
class TokenTests: XCTestCase {



    func testValidAccessToken() {
        let token = AccessTokenImpl(with: AppIDTestConstants.ACCESS_TOKEN)
        XCTAssertNotNil(token)
        XCTAssertEqual(token?.scope, "openid appid_default appid_readprofile appid_readuserattr appid_writeuserattr appid_authenticated")
        XCTAssertEqual(token?.raw, AppIDTestConstants.ACCESS_TOKEN)
        XCTAssertNotNil(token?.header)
        XCTAssertNotNil(token?.payload)
        XCTAssertNotNil(token?.signature)
        XCTAssertEqual(token?.issuer, AppIDTestConstants.region + "/oauth/v4/" + AppIDTestConstants.tenantId)
        
        XCTAssertEqual(token?.subject,  "f4bb7733-6e4e-4a53-9a4a-8c5d2cee06ea")
        XCTAssertEqual(token?.audience, [AppIDTestConstants.clientId])
        XCTAssertTrue(token?.issuedAt == Date(timeIntervalSince1970: 1550869474 as Double))
        XCTAssertEqual(token?.tenant, AppIDTestConstants.tenantId)
        XCTAssertEqual(token?.authenticationMethods?[0], "cloud_directory")
        XCTAssertTrue(token!.isExpired)
        XCTAssertFalse(token!.isAnonymous)
        XCTAssertTrue(token?.expiration == Date(timeIntervalSince1970: 1550873074 as Double))

    }


    func testValidIdToken() {
        let token = IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)

        XCTAssertEqual(token?.email, "testuser@ibm.com")
        XCTAssertNil(token?.gender)
        XCTAssertNil(token?.locale)
        XCTAssertEqual(token?.name, "testuser")
        XCTAssertEqual(token?.raw, AppIDTestConstants.ID_TOKEN)
        XCTAssertNotNil(token?.header)
        XCTAssertNotNil(token?.payload)
        XCTAssertNotNil(token?.signature)
        XCTAssertEqual(token?.issuer, AppIDTestConstants.region + "/oauth/v4/" + AppIDTestConstants.tenantId)

        XCTAssertEqual(token?.subject,  "f4bb7733-6e4e-4a53-9a4a-8c5d2cee06ea")
        XCTAssertEqual(token?.audience, [AppIDTestConstants.clientId])
        XCTAssertTrue(token?.issuedAt == Date(timeIntervalSince1970: 1550869474 as Double))
        XCTAssertEqual(token?.tenant, AppIDTestConstants.tenantId)
        XCTAssertEqual(token?.authenticationMethods?[0], "cloud_directory")
        XCTAssertTrue(token!.isExpired)
        XCTAssertTrue(token?.expiration == Date(timeIntervalSince1970: 1550873074 as Double))

    }

}
