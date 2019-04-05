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
        
        XCTAssertEqual(token?.subject, AppIDTestConstants.subject)
        XCTAssertEqual(token?.audience, [AppIDTestConstants.clientId])
        XCTAssertTrue(token?.issuedAt == Date(timeIntervalSince1970: 1552502422 as Double))
        XCTAssertEqual(token?.tenant, AppIDTestConstants.tenantId)
        XCTAssertEqual(token?.authenticationMethods?[0], "google")
        XCTAssertTrue(token!.isExpired)
        XCTAssertFalse(token!.isAnonymous)
        XCTAssertTrue(token?.expiration == Date(timeIntervalSince1970: 1552502424 as Double))

    }


    func testValidIdToken() {
        let token = IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)

        XCTAssertEqual(token?.email, "donlonqwerty@gmail.com")
        XCTAssertNil(token?.gender)
        XCTAssertEqual(token?.locale, "en")
        XCTAssertEqual(token?.name, "Lon Don")
        XCTAssertEqual(token?.raw, AppIDTestConstants.ID_TOKEN)
        XCTAssertNotNil(token?.header)
        XCTAssertNotNil(token?.payload)
        XCTAssertNotNil(token?.signature)
        XCTAssertEqual(token?.issuer, AppIDTestConstants.region + "/oauth/v4/" + AppIDTestConstants.tenantId)

        XCTAssertEqual(token?.subject, AppIDTestConstants.subject)
        XCTAssertEqual(token?.audience, [AppIDTestConstants.clientId])
        XCTAssertTrue(token?.issuedAt == Date(timeIntervalSince1970: 1552502422 as Double))
        XCTAssertEqual(token?.tenant, AppIDTestConstants.tenantId)
        XCTAssertEqual(token?.authenticationMethods?[0], "google")
        XCTAssertTrue(token!.isExpired)
        XCTAssertTrue(token?.expiration == Date(timeIntervalSince1970: 1552502424 as Double))

    }

}
