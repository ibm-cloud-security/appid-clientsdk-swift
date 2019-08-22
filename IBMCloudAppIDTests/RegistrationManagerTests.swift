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


public class RegistrationManagerTests: XCTestCase {

    var oauthManager = OAuthManager(appId: AppID.sharedInstance)

    public override func setUp() {
        AppID.sharedInstance = AppID()
        AppID.sharedInstance.initialize(tenantId: "tenant1", region: "region2")
        oauthManager = OAuthManager(appId: AppID.sharedInstance)
        oauthManager.registrationManager?.clearRegistrationData()
    }

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

    class MockRegistrationManagerWithSendRequest: RegistrationManager {
        var err:Error?
        var response:Response?
        init(oauthManager:OAuthManager, response:Response?, err:Error?) {
            self.err = err
            self.response = response
            super.init(oauthManager:oauthManager)
        }


        override internal func generateKeyPair() throws {
            TestHelpers.clearDictValuesFromKeyChain([AppIDConstants.publicKeyIdentifier : kSecClassKey, AppIDConstants.privateKeyIdentifier : kSecClassKey])
            TestHelpers.savePrivateKeyDataToKeyChain(AppIDTestConstants.privateKeyData, tag: AppIDConstants.privateKeyIdentifier)
            TestHelpers.savePublicKeyDataToKeyChain(AppIDTestConstants.publicKeyData, tag: AppIDConstants.publicKeyIdentifier)
            return
        }

        override internal func sendRequest(request:Request, registrationParamsAsData:Data?, internalCallBack: @escaping BMSCompletionHandler) {

            XCTAssertEqual(request.resourceUrl, Config.getServerUrl(appId: AppID.sharedInstance) + "/clients")
            XCTAssertEqual(request.httpMethod, HttpMethod.POST)
            XCTAssertEqual(request.headers, [Request.contentType : "application/json"])
            XCTAssertEqual(request.timeout, BMSClient.sharedInstance.requestTimeout)
            let expectedString =
            "{\"grant_types\":[\"authorization_code\",\"password\"],\"device_os\":\"iOS\",\"device_os_version\":\"" + UIDevice.current.systemVersion + "\",\"client_type\":\"mobileapp\",\"device_id\":\"" + (UIDevice.current.identifierForVendor?.uuidString)! + "\",\"device_model\":\"iPhone\",\"jwks\":{\"keys\":[{\"n\":\"AOH-nACU3cCopAz6_SzJuDtUyN4nHhnk9yfF9DFiGPctXPbwMXofZvd9WcYQqtw-w3WV_yhui9PrOVfVBhk6CmM=\",\"kty\":\"RSA\",\"e\":\"AQAB\"}]},\"software_version\":\"1.0\",\"token_endpoint_auth_method\":\"client_secret_basic\",\"response_types\":[\"code\"],\"redirect_uris\":[\"oded.dummyAppForKeyChain:\\/\\/mobile\\/callback\"],\"software_id\":\"oded.dummyAppForKeyChain\"}"
            let actualString = String(data: registrationParamsAsData!, encoding: .utf8)
            let actual = try! Utils.parseJsonStringtoDictionary(String(data: registrationParamsAsData!, encoding: .utf8)!)
            let expected = try! Utils.parseJsonStringtoDictionary(expectedString)
            XCTAssertTrue(NSDictionary(dictionary: actual).isEqual(to: expected))
            internalCallBack(response, err)
        }

    }

    // send request returns error
    func testRegisterOAuthClient1() {

        let expectation1 = expectation(description: "got to callback")
        let callback = {(error: Error?) in
            XCTAssertEqual((error as? AppIDError)?.description, "Failed to register OAuth client")
            XCTAssertNil(self.oauthManager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).get(), "")
            XCTAssertNil(self.oauthManager.registrationManager?.preferenceManager.getStringPreference(name: AppIDConstants.tenantPrefName).get(), "tenant1")

            expectation1.fulfill()
        }
        let err = AppIDError.registrationError(msg: "Failed to register OAuth client")
        let regManager =  MockRegistrationManagerWithSendRequest(oauthManager:OAuthManager(appId: AppID.sharedInstance), response: nil, err: err)
        regManager.registerOAuthClient(callback: callback)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
    }


    // happy flow
    func testRegisterOAuthClient2() {

        let expectation1 = expectation(description: "got to callback")

        let callback = {(error: Error?) in
            XCTAssertNil(error)
            XCTAssertNotNil(self.oauthManager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).get())
            // failed because of difference in order
//            XCTAssertEqual(self.oauthManager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).get(), try? Utils.JSONStringify(["key1": "val1", "key2": "val2"] as AnyObject))
            XCTAssertEqual(self.oauthManager.registrationManager?.preferenceManager.getStringPreference(name: AppIDConstants.tenantPrefName).get(), "tenant1")

            expectation1.fulfill()
        }


        let response:Response = Response(responseData: try! Utils.JSONStringify(["key1": "val1", "key2": "val2"] as AnyObject).data(using: .utf8), httpResponse: HTTPURLResponse(url: URL(string: "ADS")!, statusCode: 200, httpVersion: nil, headerFields: nil), isRedirect: false)

        let regManager =  MockRegistrationManagerWithSendRequest(oauthManager:oauthManager, response: response, err: nil)
        regManager.registerOAuthClient(callback: callback)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }


    }



    // send request returns unsuccessful response
    func testRegisterOAuthClient3() {

        let expectation1 = expectation(description: "got to callback")
        let callback = {(error: Error?) in
            XCTAssertEqual((error as? AppIDError)?.description, "Could not register client")
            XCTAssertNil(self.oauthManager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).get(), "")
            XCTAssertNil(self.oauthManager.registrationManager?.preferenceManager.getStringPreference(name: AppIDConstants.tenantPrefName).get(), "tenant1")

            expectation1.fulfill()
        }

         let response:Response = Response(responseData: "some text".data(using: .utf8), httpResponse: HTTPURLResponse(url: URL(string: "ADS")!, statusCode: 401, httpVersion: nil, headerFields: nil), isRedirect: false)

        let regManager =  MockRegistrationManagerWithSendRequest(oauthManager:OAuthManager(appId: AppID.sharedInstance), response: response, err: nil)
        regManager.registerOAuthClient(callback: callback)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
    }


    // no error and no response
    func testRegisterOAuthClient4() {

        let expectation1 = expectation(description: "got to callback")
        let callback = {(error: Error?) in
            XCTAssertEqual((error as? AppIDError)?.description, "Could not register client")
            XCTAssertNil(self.oauthManager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).get(), "")
            XCTAssertNil(self.oauthManager.registrationManager?.preferenceManager.getStringPreference(name: AppIDConstants.tenantPrefName).get(), "tenant1")

            expectation1.fulfill()
        }

        let regManager =  MockRegistrationManagerWithSendRequest(oauthManager:OAuthManager(appId: AppID.sharedInstance), response: nil, err: nil)
        regManager.registerOAuthClient(callback: callback)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
    }


    // no response text
    func testRegisterOAuthClient5() {

        let expectation1 = expectation(description: "got to callback")
        let callback = {(error: Error?) in
            XCTAssertEqual((error as? AppIDError)?.description, "Could not register client")
            XCTAssertNil(self.oauthManager.registrationManager?.preferenceManager.getJSONPreference(name: AppIDConstants.registrationDataPref).get(), "")
            XCTAssertNil(self.oauthManager.registrationManager?.preferenceManager.getStringPreference(name: AppIDConstants.tenantPrefName).get(), "tenant1")

            expectation1.fulfill()
        }

        let response:Response = Response(responseData: nil, httpResponse: HTTPURLResponse(url: URL(string: "ADS")!, statusCode: 401, httpVersion: nil, headerFields: nil), isRedirect: false)

        let regManager =  MockRegistrationManagerWithSendRequest(oauthManager:OAuthManager(appId: AppID.sharedInstance), response: response, err: nil)
        regManager.registerOAuthClient(callback: callback)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("err: \(error)")
            }
        }
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
        AppID.sharedInstance.initialize(tenantId: "sometenant", region: "region")
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
