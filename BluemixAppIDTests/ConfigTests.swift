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

public class ConfigTests: XCTestCase {

    func testGetServerUrl() {
        AppID.sharedInstance = AppID()
        // no region and tenant
        let appid = AppID.sharedInstance
        XCTAssertEqual("https://appid-oauth", Config.getServerUrl(appId: appid))

        // with region and tenant
        appid.initialize(tenantId: "sometenant", bluemixRegion: ".region")
        XCTAssertEqual("https://appid-oauth.region/oauth/v3/sometenant", Config.getServerUrl(appId: appid))
        
        XCTAssertEqual("https://appid-oauth.region/oauth/v3/sometenant/publickeys", Config.getPublicKeyEndpoint(appId: appid))
        
        XCTAssertEqual("appid-oauth.region", Config.getIssuer(appId: appid))
        
        // with overrideserverhost
        AppID.overrideServerHost = "somehost/"
        XCTAssertEqual("somehost/sometenant", Config.getServerUrl(appId: appid))
        
    }
    
}
