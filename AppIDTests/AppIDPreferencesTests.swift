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

import XCTest

import BMSCore
@testable import AppID

class AppIDPreferencesTests: XCTestCase {
    var preferences:AppIDPreferences = AppIDPreferences()
    var idToken = "123"
    var accessToken = "456"
    var clientId = "id2"
    
    override func setUp() {
        preferences = AppIDPreferences()
        SecItemDelete([ kSecClass as String : kSecClassGenericPassword ] as CFDictionary) //clears tokens from keychain
        super.setUp()
    }
    
    func testClientIdPreference() {
        preferences.clientId.set(clientId)
        XCTAssertEqual(preferences.clientId.get(),clientId)
        preferences.clientId.clear()
        XCTAssertNil(preferences.clientId.get())
    }
    
    func testIdentityPreferences() {
        preferences.appIdentity.set(AppIDAppIdentity().jsonData as [String:Any])
        var appId = preferences.appIdentity.getAsMap()
        XCTAssertEqual(appId?[BaseAppIdentity.Key.ID] as? String, Utils.getApplicationDetails().name)
        XCTAssertEqual(appId?[BaseAppIdentity.Key.version] as? String, Utils.getApplicationDetails().version)
        preferences.deviceIdentity.set(AppIDDeviceIdentity().jsonData as [String:Any])
        var deviceId = preferences.deviceIdentity.getAsMap()
        XCTAssertEqual(deviceId?[BaseDeviceIdentity.Key.ID] as? String, UIDevice.current.identifierForVendor?.uuidString)
        XCTAssertEqual(deviceId?[BaseDeviceIdentity.Key.OS] as? String, UIDevice.current.systemName)
        XCTAssertEqual(deviceId?[BaseDeviceIdentity.Key.OSVersion] as? String, UIDevice.current.systemVersion)
        XCTAssertEqual(deviceId?[BaseDeviceIdentity.Key.model] as? String, UIDevice.current.model)
        preferences.userIdentity.set(["item1" : "one" as AnyObject , "item2" : "two" as AnyObject] as [String:Any])
        
        var userId = preferences.userIdentity.getAsMap()
        XCTAssertEqual(userId?["item1"] as? String, "one")
        XCTAssertEqual(userId?["item2"] as? String, "two")
    }
    
    func testTokenPreferences(){
        preferences = AppIDPreferences()
        preferences.persistencePolicy.set(PersistencePolicy.always, shouldUpdateTokens: true)
        preferences.accessToken.set(accessToken)
        preferences.idToken.set(idToken)
        assertTokens(true)
        preferences.persistencePolicy.set(PersistencePolicy.never, shouldUpdateTokens: true)
        assertTokens(false)
        preferences.persistencePolicy.set(PersistencePolicy.always, shouldUpdateTokens: true)
        assertTokens(true)
        preferences.idToken.clear()
        preferences.accessToken.clear()
        XCTAssertEqual(SecurityUtils.getItemFromKeyChain(preferences.idToken.prefName),nil)
        XCTAssertEqual(SecurityUtils.getItemFromKeyChain(preferences.accessToken.prefName),nil)
        XCTAssertNil(preferences.accessToken.get())
        XCTAssertNil(preferences.idToken.get())
        
    }
    private func assertTokens(_ TokensShouldExistInKeyChain:Bool) {
        XCTAssertEqual(preferences.accessToken.get(),accessToken)
        XCTAssertEqual(preferences.idToken.get(),idToken)
        if TokensShouldExistInKeyChain {
            XCTAssertEqual(SecurityUtils.getItemFromKeyChain(preferences.idToken.prefName),idToken)
            XCTAssertEqual(SecurityUtils.getItemFromKeyChain(preferences.accessToken.prefName),accessToken)
        } else {
            XCTAssertNil(SecurityUtils.getItemFromKeyChain(preferences.idToken.prefName))
            XCTAssertNil(SecurityUtils.getItemFromKeyChain(preferences.accessToken.prefName))
        }
    }
}
