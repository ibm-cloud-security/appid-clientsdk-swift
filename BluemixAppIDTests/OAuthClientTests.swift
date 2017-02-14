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

public class OAuthClientTests: XCTestCase {

    func testOAuthClient() {
        let idToken = IdentityTokenImpl(with: AppIDTestConstants.ID_TOKEN)
        let client = OAuthClientImpl(with: idToken!)
       
        XCTAssertEqual(client?.type, "mobileapp")
         XCTAssertEqual(client?.name, "testAppDisplayName")
         XCTAssertEqual(client?.softwareId, "testApp")
         XCTAssertEqual(client?.softwareVersion, "1.0")
        XCTAssertEqual(client?.deviceId, "9600E01E-E5F1-4FDD-B9C9-D24C418DA947")
        XCTAssertEqual(client?.deviceModel, "iPhone")
        XCTAssertEqual(client?.deviceOS, "iPhone OS")
        client?.oauthClient?["type"] = [:]
        XCTAssertNil(client?.type)
        client?.oauthClient?["name"] = [:]
        XCTAssertNil(client?.name)
        client?.oauthClient?["software_id"] = [:]
        XCTAssertNil(client?.softwareId)
        client?.oauthClient?["software_version"] = [:]
        XCTAssertNil(client?.softwareVersion)
        client?.oauthClient?["device_id"] = [:]
        XCTAssertNil(client?.deviceId)
        client?.oauthClient?["device_model"] = [:]
        XCTAssertNil(client?.deviceModel)
        client?.oauthClient?["device_os"] = [:]
        XCTAssertNil(client?.deviceOS)
        
    }

}
