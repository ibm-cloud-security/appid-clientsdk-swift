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
public class AuthorizationHeaderHelperTests: XCTestCase {


    func testIsAuthorizationRequired() {
        var headers:[String: Any] = [:]
        headers["Dummy"] = ["Dummy"]
        
        // Non-401 status
        XCTAssertFalse(AuthorizationHeaderHelper.isAuthorizationRequired(statusCode: 200, header: nil))
        
        // 401 status, but Www-Authenticate header is null
        XCTAssertFalse(AuthorizationHeaderHelper.isAuthorizationRequired(statusCode: 401, header: nil))
        
        // 401 status, Www-Authenticate header exist, but invalid value
        XCTAssertFalse(AuthorizationHeaderHelper.isAuthorizationRequired(statusCode: 401, header: "Dummy"))
        
        // 401 status, Www-Authenticate header exists, Bearer exists, but not appid scope
        XCTAssertFalse(AuthorizationHeaderHelper.isAuthorizationRequired(statusCode: 401, header: "Bearer Dummy"))

        // 401 with bearer and correct scope
         XCTAssertTrue(AuthorizationHeaderHelper.isAuthorizationRequired(statusCode: 401, header: "Bearer scope=\"appid_default\""))
        
        // Check with http response
        
        let response = HTTPURLResponse(url: URL(string: "ADS")!, statusCode: 401, httpVersion: nil, headerFields: [AppIDConstants.WWW_AUTHENTICATE_HEADER : "Bearer scope=\"appid_default\""])
        XCTAssertTrue(AuthorizationHeaderHelper.isAuthorizationRequired(for: Response(responseData: nil, httpResponse: response, isRedirect: false)))
    }
    
}
