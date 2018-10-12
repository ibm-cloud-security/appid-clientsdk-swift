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
class SecurityUtilsTest: XCTestCase {

    var itemLabel = "itemLabel"
    var itemData = "testItemString"
    var keySize = 512
    var publicKeyTag = AppIDConstants.publicKeyIdentifier
    var privateKeyTag = AppIDConstants.privateKeyIdentifier

    override func setUp() {
        super.setUp()
        TestHelpers.clearDictValuesFromKeyChain([publicKeyTag : kSecClassKey, privateKeyTag : kSecClassKey])
        TestHelpers.savePublicKeyDataToKeyChain(AppIDTestConstants.publicKeyData, tag: publicKeyTag)
        TestHelpers.savePrivateKeyDataToKeyChain(AppIDTestConstants.privateKeyData, tag: privateKeyTag)
    }

    func testSecAttrAccessible() {
        AppID.secAttrAccess = .accessibleAlways
        XCTAssertEqual(AppID.secAttrAccess.rawValue, kSecAttrAccessibleAlways)
    }

    func testGenerateKeyPairAttrsPrivate() {
        let keyPair = SecurityUtils.generateKeyPairAttrs(keySize, publicTag: publicKeyTag, privateTag: privateKeyTag)
        let privateAttrs = keyPair["private"] as! [NSString: AnyObject] // tailor:disable
        let accessibility = privateAttrs[kSecAttrAccessible]
        XCTAssertEqual(accessibility as! CFString, AppID.secAttrAccess.rawValue) // tailor:disable
    }

    func testGenerateKeyPairAttrsPublic() {
        let keyPair = SecurityUtils.generateKeyPairAttrs(keySize, publicTag: publicKeyTag, privateTag: privateKeyTag)
        let publicAttrs = keyPair["public"] as! [NSString: AnyObject] // tailor:disable
        let accessibility = publicAttrs[kSecAttrAccessible]
        XCTAssertEqual(accessibility as! CFString, AppID.secAttrAccess.rawValue) // tailor:disable
    }

    func testGenerateKeyPairAttrs() {
        let keyPair = SecurityUtils.generateKeyPairAttrs(keySize, publicTag: publicKeyTag, privateTag: privateKeyTag)
        XCTAssertEqual(keyPair[kSecAttrAccessible] as! CFString, AppID.secAttrAccess.rawValue) // tailor:disable
    }

    func testKeyPairGeneration() {
        TestHelpers.clearDictValuesFromKeyChain([publicKeyTag : kSecClassKey, privateKeyTag : kSecClassKey])
        XCTAssertNotNil(try? SecurityUtils.generateKeyPair(keySize, publicTag: publicKeyTag, privateTag: privateKeyTag))
    }

    func testSaveItemToKeyChain() {
        _ = SecurityUtils.saveItemToKeyChain(itemData, label: itemLabel)
        XCTAssertEqual(SecurityUtils.getItemFromKeyChain(itemLabel), itemData)
        _ = SecurityUtils.removeItemFromKeyChain(itemLabel)
        XCTAssertNil(SecurityUtils.getItemFromKeyChain(itemLabel))
    }


    func testGetJwksHeader() {
        // happy flow
        var jwks:[String:Any]? = try? SecurityUtils.getJWKSHeader()
        XCTAssertNotNil(jwks)
        XCTAssertEqual(jwks?["e"] as? String, "AQAB")
        XCTAssertEqual(jwks?["kty"] as? String, "RSA")
        XCTAssertEqual(jwks?["n"] as? String, "AOH-nACU3cCopAz6_SzJuDtUyN4nHhnk9yfF9DFiGPctXPbwMXofZvd9WcYQqtw-w3WV_yhui9PrOVfVBhk6CmM=")

        // no public key
        TestHelpers.clearDictValuesFromKeyChain([AppIDConstants.publicKeyIdentifier : kSecClassKey])
        do {
            jwks = try SecurityUtils.getJWKSHeader()
            XCTFail()
        } catch let e {
            XCTAssertEqual((e as? AppIDError)?.description, "General Error")
        }
    }

    func testSignString() {

        // happy flow
        let signature = try? SecurityUtils.signString("somepayload", keyIds: (publicKeyTag, privateKeyTag), keySize: keySize)
        XCTAssertEqual(signature, "ODT3jvWINoDIYrdMPMB-n548VKXnVT7wAg378q3vV4b20gkZq66DOPrkM9JmyOsVcrKO7FWCa0VaLu418rkC3w==")
    }
}
