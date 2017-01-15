//
//  AuthorizationRequestTests.swift
//  AppID
//
//  Created by Oded Betzalel on 12/01/2017.
//  Copyright © 2017 Oded Betzalel. All rights reserved.
//

import Foundation


import XCTest
import BMSCore
@testable import AppID

class AuthoirzationRequestTest: XCTestCase {
    var request = AppIDRequest(url: "www.test.com", method: HttpMethod.POST)
    override func setUp() {
        request = AppIDRequest(url: "www.test.com", method: HttpMethod.POST)
        super.setUp()
    }
    func testAddHeaders(){
        let headersToBeAdded = ["header1" : "item1" , "header2" : "item2", "header3" : "item3"]
        request.addHeaders(headersToBeAdded)
        XCTAssertEqual(request.headers["header1"], "item1")
        XCTAssertEqual(request.headers["header2"], "item2")
        XCTAssertEqual(request.headers["header3"], "item3")
        let headersToBeAdded2 = ["header4" : "item4" , "header5" : "item5", "header6" : "item6"]
        request.addHeaders(headersToBeAdded2)
        XCTAssertEqual(request.headers["header1"], "item1")
        XCTAssertEqual(request.headers["header2"], "item2")
        XCTAssertEqual(request.headers["header3"], "item3")
        XCTAssertEqual(request.headers["header4"], "item4")
        XCTAssertEqual(request.headers["header5"], "item5")
        XCTAssertEqual(request.headers["header6"], "item6")
    }
}

