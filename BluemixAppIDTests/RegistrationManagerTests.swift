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


public class RegistrationManagerTests: XCTestCase {
    
    
    func testClearRegistrationData() {
        let manager = RegistrationManager(oauthManager:OAuthManager(appId: AppID.sharedInstance))
        manager.preferenceManager.getStringPreference(name: AppIDConstants.tenantPrefName).set("sometenant")
        manager.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "some client id"] as [String:Any])
        XCTAssertNotNil( manager.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).get())
        XCTAssertNotNil( manager.preferenceManager.getStringPreference(name: AppIDConstants.tenantPrefName).get())
        manager.clearRegistrationData()
        XCTAssertNil( manager.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).get())
        XCTAssertNil( manager.preferenceManager.getStringPreference(name: AppIDConstants.tenantPrefName).get())

        
        
    }
    
    func testEnsureRegistered() {
        class MockRegistrationManager: RegistrationManager {
            var success:Bool
            init(oauthManager:OAuthManager, success:Bool) {
                self.success = success
                super.init(oauthManager:oauthManager)
            }
            override internal func registerOAuthClient(callback :@escaping (Error?) -> Void) {
                if success == true {
                    callback(nil)
                } else {
                    callback(AppIDError.registrationError(msg: "Failed to register OAuth client"))
                }
            }
        }
        // registration success
        MockRegistrationManager(oauthManager:OAuthManager(appId: AppID.sharedInstance), success: true).ensureRegistered(callback: {(error: Error?) -> Void in
            XCTAssertNil(error)
        })
        AppID.sharedInstance.initialize(tenantId: "sometenant", bluemixRegion: "region")
        // registraiton failure
        MockRegistrationManager(oauthManager:OAuthManager(appId: AppID.sharedInstance), success: false).ensureRegistered(callback: {(error: Error?) -> Void in
            XCTAssertNotNil(error)
        })
        
        // already registered
        var regManager =  MockRegistrationManager(oauthManager:OAuthManager(appId: AppID.sharedInstance), success: false)
        regManager.preferenceManager.getStringPreference(name: AppIDConstants.tenantPrefName).set("sometenant")
        regManager.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "some client id"] as [String:Any])
        regManager.ensureRegistered(callback: {(error: Error?) -> Void in
            XCTAssertNil(error)
        })
        
        // already registered - different tenant
        regManager =  MockRegistrationManager(oauthManager:OAuthManager(appId: AppID.sharedInstance), success: false)
        regManager.preferenceManager.getStringPreference(name: AppIDConstants.tenantPrefName).set("someothertenant")
        regManager.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).set([AppIDConstants.client_id_String : "some client id"] as [String:Any])
        regManager.ensureRegistered(callback: {(error: Error?) -> Void in
            XCTAssertNotNil(error)
        })
        
    }
}
