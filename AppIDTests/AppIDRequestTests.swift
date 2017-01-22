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
@testable import AppID

class AppIDRequestTest: XCTestCase {
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

