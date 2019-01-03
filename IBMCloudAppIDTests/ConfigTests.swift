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
@testable import IBMCloudAppID

internal var newRegion = "https://us-south.appid.cloud.ibm.com" //full url with https
internal var oldRegion = ".ng.bluemix.net"
internal var customRegion = ".custom"



public class ConfigTests: XCTestCase {

    
    func testConfig() {
        AppID.sharedInstance = AppID()
        
        // no region and tenant
        let appid = AppID.sharedInstance
        XCTAssertEqual("https://appid-oauth", Config.getServerUrl(appId: appid))
        XCTAssertEqual("appid-oauth", Config.getIssuer(appId: appid))

        // with region and tenant
        appid.initialize(tenantId: "sometenant", region: newRegion)
        XCTAssertEqual( newRegion + "/oauth/v3/sometenant", Config.getServerUrl(appId: appid))

        XCTAssertEqual( newRegion + "/oauth/v3/sometenant/publickeys", Config.getPublicKeyEndpoint(appId: appid))
        XCTAssertEqual( newRegion + "/api/v1/", Config.getAttributesUrl(appId: appid))
        XCTAssertEqual("appid-oauth.ng.bluemix.net", Config.getIssuer(appId: appid))
        
        // with OLD .region and tenant
        appid.initialize(tenantId: "sometenant", region: oldRegion)
        XCTAssertEqual("https://appid-oauth" + oldRegion + "/oauth/v3/sometenant", Config.getServerUrl(appId: appid))
        XCTAssertEqual("https://appid-oauth" + oldRegion + "/oauth/v3/sometenant/publickeys", Config.getPublicKeyEndpoint(appId: appid))
        XCTAssertEqual("https://appid-profiles" + oldRegion + "/api/v1/", Config.getAttributesUrl(appId: appid))
        XCTAssertEqual("appid-oauth" + oldRegion, Config.getIssuer(appId: appid))

        //with custom region
        appid.initialize(tenantId: "sometenant", region: customRegion)
        XCTAssertEqual("https://appid-oauth" + customRegion + "/oauth/v3/sometenant", Config.getServerUrl(appId: appid))
        XCTAssertEqual("https://appid-oauth" + customRegion + "/oauth/v3/sometenant/publickeys", Config.getPublicKeyEndpoint(appId: appid))
        XCTAssertEqual("https://appid-profiles" + customRegion + "/api/v1/", Config.getAttributesUrl(appId: appid))
        XCTAssertEqual("appid-oauth" + customRegion, Config.getIssuer(appId: appid))
    
        // with overrideserverhost
        AppID.overrideServerHost = "somehost/"
        XCTAssertEqual("somehost/sometenant", Config.getServerUrl(appId: appid))
        XCTAssertEqual("somehost/", Config.getIssuer(appId: appid))
        
    }
    
    

}
