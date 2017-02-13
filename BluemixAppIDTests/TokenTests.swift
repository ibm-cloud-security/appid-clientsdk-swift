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
        XCTAssertEqual(token?.scope, "default")
        XCTAssertEqual(token?.raw, AppIDTestConstants.ACCESS_TOKEN)
        XCTAssertNotNil(token?.header)
        XCTAssertNotNil(token?.payload)
        XCTAssertNotNil(token?.signature)
        XCTAssertEqual(token?.issuer, "imf-authserver.stage1-dev.ng.bluemix.net")

        XCTAssertNil(token?.subject)
        XCTAssertEqual(token?.audience, "741efc868b9a3f37b1cea5b1a50d50f74182dfb4")
        XCTAssertTrue(token?.issuedAt == Date(timeIntervalSince1970: 1485546831000 as! Double))
        XCTAssertEqual(token?.tenant, "66f79ab9-a54e-4fa2-ad3c-406df494d018")
        XCTAssertEqual(token?.authBy, "facebook")
        XCTAssertTrue(token!.isExpired)
        XCTAssertTrue(token?.issuedAt == Date(timeIntervalSince1970: 1485550431000 as! Double))

    }
    
    
    func testValidIdToken() {
        let token = IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)
        
        XCTAssertNil(token?.email, "")
        XCTAssertEqual(token?.gender, "male")
        XCTAssertEqual(token?.locale, "ko_KR")
        XCTAssertEqual(token?.name, "Don Lon")
        XCTAssertEqual(token?.picture, "https://scontent.xx.fbcdn.net/v/t1.0-1/p50x50/13501551_286407838378892_1785766211766730697_n.jpg?oh=242bc2fb505609b442874fde3e9865a9&oe=5907B1BC")
        XCTAssertEqual(token?.identities?.count,0)
        XCTAssertEqual(token?.raw, AppIDTestConstants.ID_TOKEN)
        XCTAssertNotNil(token?.header)
        XCTAssertNotNil(token?.payload)
        XCTAssertNotNil(token?.signature)
        XCTAssertEqual(token?.issuer, "imf-authserver.stage1-dev.ng.bluemix.net")
        
        XCTAssertNil(token?.subject)
        XCTAssertEqual(token?.audience, "741efc868b9a3f37b1cea5b1a50d50f74182dfb4")
        XCTAssertTrue(token?.issuedAt == Date(timeIntervalSince1970: 1485546831000 as! Double))
        XCTAssertEqual(token?.tenant, "66f79ab9-a54e-4fa2-ad3c-406df494d018")
        XCTAssertEqual(token?.authBy, "facebook")
        XCTAssertTrue(token!.isExpired)
        XCTAssertTrue(token?.issuedAt == Date(timeIntervalSince1970: 1485550431000 as! Double))
        
    }
}
