//
//  AppIDSecurityUtilsTests.swift
//  AppID
//
//  Created by Oded Betzalel on 12/01/2017.
//  Copyright © 2017 Oded Betzalel. All rights reserved.
//

import Foundation
import XCTest
import BMSCore
@testable import AppID
class SecurityUtilsTest: XCTestCase {
    var keySize = 512
    var publicKeyTag = "publicKeyTag"
    var privateKeyTag = "privateKeyTag"
    
    var publicKeyData:Data = Data(base64Encoded: "MEgCQQDh/pwAlN3AqKQM+v0sybg7VMjeJx4Z5PcnxfQxYhj3LVz28DF6H2b3fVnGEKrcPsN1lf8obovT6zlX1QYZOgpjAgMBAAE=", options: NSData.Base64DecodingOptions(rawValue:0))!
    var privateKeyData:Data = Data(base64Encoded: "MIIBOgIBAAJBAOH+nACU3cCopAz6/SzJuDtUyN4nHhnk9yfF9DFiGPctXPbwMXofZvd9WcYQqtw+w3WV/yhui9PrOVfVBhk6CmMCAwEAAQJAJ4H8QbnEnoacz0wdcHP/ShgDWZrbD0nQz1oy22M73BHidwDvy1rIeM6PgkK1tyHNWrqyo1kAnp7DuNVmfGbJ0QIhAc3gVBJCrVbiO23OasUuYTN2y2KrZ2DUcjLp5ZOID1/LAiB9Qo1mx3yz4HT4wJvddb9AqSTlmSrrdXcNGNhWFRT8yQIhAbepkD3lrL2lEy8+q9JRiQOFVKvzP7Aj6yVeE0Sx4virAiAk2ITbrOajyuzdl1rCBDbkAF1YJHwZkw4YDizk9YKc8QIhAV0VZFoZidVBTsoi7xeufS0GSDqPxskq7gJGY70p4dco", options: NSData.Base64DecodingOptions(rawValue:0))!
        var jws = "eyJhbGciOiJSUzI1NiIsImpwayI6eyJhbGciOiJSU0EiLCJtb2QiOiJBT0grbkFDVTNjQ29wQXo2XC9Tekp1RHRVeU40bkhobms5eWZGOURGaUdQY3RYUGJ3TVhvZlp2ZDlXY1lRcXR3K3czV1ZcL3lodWk5UHJPVmZWQmhrNkNtTT0iLCJleHAiOiJBUUFCIn19.eyJjb2RlIjoiNTBzcWthZER6bTl6TjdFTEpDWXR1bnlLb3Raa1Y3SEJKdFBMSHJmZzAzY2Qtbk5JOEhnU1VicnpoNmJpa2ZLYl9MeVUwQU54UGkyWDA4OUNqV0syT3RDR3djRHJ2RjNlcEM5WFFHMXlwTlVMZHo4c2dWZWVmYkxob2JsZ2ltZ2JwN3M1X0dLSllWWmVGZ2JpbnFlWWhmMXpudEZOdHA0dVhsNmVaX1h1aTMwZ2VwTEEyT2pUcUhnM1VadV9xRVk0In0=.FqJBhAX1-4auIchN6Gk_1laA4zCS_Fpy1tRwa6Oeklv2ungnnSKL2VRuzRIwzAjyAhfyOSnlsOqL5r7K-RhF-Q=="
    var certificateLabel = "certificateLabel"
    var itemLabel = "itemLabel"
    var itemData = "testItemString"
    var grantCode = "50sqkadDzm9zN7ELJCYtunyKotZkV7HBJtPLHrfg03cd-nNI8HgSUbrzh6bikfKb_LyU0ANxPi2X089CjWK2OtCGwcDrvF3epC9XQG1ypNULdz8sgVeefbLhoblgimgbp7s5_GKJYVZeFgbinqeYhf1zntFNtp4uXl6eZ_Xui30gepLA2OjTqHg3UZu_qEY4"
    override func setUp() {
        super.setUp()
        SecurityUtils.clearDictValuesFromKeyChain([certificateLabel : kSecClassCertificate, publicKeyTag : kSecClassKey, privateKeyTag : kSecClassKey])
        savePublicKeyDataToKeyChain(publicKeyData, tag: publicKeyTag)
        savePrivateKeyDataToKeyChain(privateKeyData, tag: privateKeyTag)
    }
    
    
    func testKeyPairGeneration() {
        SecurityUtils.clearDictValuesFromKeyChain([publicKeyTag : kSecClassKey, privateKeyTag : kSecClassKey])
        XCTAssertNotNil(try? SecurityUtils.generateKeyPair(keySize, publicTag: publicKeyTag, privateTag: privateKeyTag))
    }
    
    
    func testSaveItemToKeyChain(){
        SecurityUtils.saveItemToKeyChain(itemData, label: itemLabel)
        XCTAssertEqual(SecurityUtils.getItemFromKeyChain(itemLabel), itemData)
        SecurityUtils.removeItemFromKeyChain(itemLabel)
        XCTAssertNil(SecurityUtils.getItemFromKeyChain(itemLabel))
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private func savePublicKeyDataToKeyChain(_ key:Data,tag:String) {
        let publicKeyAttr : [NSString:AnyObject] = [
            kSecValueData: key as AnyObject,
            kSecClass : kSecClassKey,
            kSecAttrApplicationTag: tag as AnyObject,
            kSecAttrKeyType : kSecAttrKeyTypeRSA,
            kSecAttrKeyClass : kSecAttrKeyClassPublic
            
        ]
        SecItemAdd(publicKeyAttr as CFDictionary, nil)
    }
    
    private func savePrivateKeyDataToKeyChain(_ key:Data,tag:String) {
        let publicKeyAttr : [NSString:AnyObject] = [
            kSecValueData: key as AnyObject,
            kSecClass : kSecClassKey,
            kSecAttrApplicationTag: tag as AnyObject,
            kSecAttrKeyType : kSecAttrKeyTypeRSA,
            kSecAttrKeyClass : kSecAttrKeyClassPrivate
            
        ]
        SecItemAdd(publicKeyAttr as CFDictionary, nil)
    }
    
}
