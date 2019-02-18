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
        XCTAssertEqual(token?.issuer, "https://appid-oauth.stage1.eu-gb.bluemix.net")

        XCTAssertEqual(token?.subject,  "c74da57d-e9b9-4867-a80e-0a4476e8b9df")
        XCTAssertEqual(token?.audience, ["e2646605f5b43e44c53c7028bac659f23ffb5e39"])
        XCTAssertTrue(token?.issuedAt == Date(timeIntervalSince1970: 1550455907 as Double))
        XCTAssertEqual(token?.tenant, "bd9fb8c8-e8d7-4671-a7bb-48e2ed5fcb77")
        XCTAssertEqual(token?.authenticationMethods?[0], "cloud_directory")
        XCTAssertTrue(token!.isExpired)
        XCTAssertFalse(token!.isAnonymous)
        XCTAssertTrue(token?.expiration == Date(timeIntervalSince1970: 1550456207 as Double))

    }


    func testValidIdToken() {
        let token = IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)

        XCTAssertNil(token?.email)
        XCTAssertNil(token?.gender)
        XCTAssertNil(token?.locale)
        XCTAssertNil(token?.name)
        XCTAssertEqual(token?.raw, AppIDTestConstants.ID_TOKEN)
        XCTAssertNotNil(token?.header)
        XCTAssertNotNil(token?.payload)
        XCTAssertNotNil(token?.signature)
        XCTAssertEqual(token?.issuer, "https://appid-oauth.stage1.eu-gb.bluemix.net")

        XCTAssertNil(token?.subject)
        XCTAssertEqual(token?.audience, ["e2646605f5b43e44c53c7028bac659f23ffb5e39"])
        XCTAssertTrue(token?.issuedAt == Date(timeIntervalSince1970: 1550456270 as Double))
        XCTAssertEqual(token?.tenant, "bd9fb8c8-e8d7-4671-a7bb-48e2ed5fcb77")
        XCTAssertEqual(token?.authenticationMethods?[0], "facebook")
        XCTAssertTrue(token!.isExpired)
        XCTAssertTrue(token?.expiration == Date(timeIntervalSince1970: 1550456570 as Double))

    }

}
