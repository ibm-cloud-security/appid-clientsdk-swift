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
class UtilsTest: XCTestCase {
    
    
    func testJSONStringify() {
        
        let dict:[String:Any] = ["first":true,"second":3, "third" : ["item1","item2",["item3","item4"],"item5"]]
        let json = try? Utils.JSONStringify(dict as AnyObject)
        
        let jsonStringOption1 = "{\"first\":true,\"second\":3,\"third\":[\"item1\",\"item2\",[\"item3\",\"item4\"],\"item5\"]}"
        let jsonStringOption2 = "{\"first\":true,\"third\":[\"item1\",\"item2\",[\"item3\",\"item4\"],\"item5\"],\"second\":3}"
        let jsonStringOption3 = "{\"third\":[\"item1\",\"item2\",[\"item3\",\"item4\"],\"item5\"],\"first\":true,\"second\":3}"
        let jsonStringOption4 = "{\"second\":3,\"third\":[\"item1\",\"item2\",[\"item3\",\"item4\"],\"item5\"],\"first\":true}"
        let jsonStringOption5 = "{\"second\":3,\"first\":true,\"third\":[\"item1\",\"item2\",[\"item3\",\"item4\"],\"item5\"]}"
        let jsonStringOption6 = "{\"third\":[\"item1\",\"item2\",[\"item3\",\"item4\"],\"item5\"],\"second\":3,\"first\":true}"
        let cond = (jsonStringOption1 == json || jsonStringOption2 == json || jsonStringOption3 == json || jsonStringOption4 == json || jsonStringOption5 == json || jsonStringOption6 == json)
        XCTAssertTrue(cond)
    }
    
    func testParseJsonStringtoDictionary() {
        let jsonString = "{\"first\":true,\"second\":3,\"third\":[\"item1\",\"item2\",[\"item3\",\"item4\"],\"item5\"]}"
        
        //        var json = try! JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions()) as! [AnyObject]
        let returnedDict:[String:Any]? = try? Utils.parseJsonStringtoDictionary(jsonString)
        XCTAssertNotNil(returnedDict)
        XCTAssertEqual(returnedDict!["first"] as? Bool, true)
        XCTAssertEqual(returnedDict!["second"] as? Int, 3)
        
        XCTAssertEqual((returnedDict!["third"] as? [AnyObject])?[0] as? String, "item1")
        XCTAssertEqual((returnedDict!["third"] as? [AnyObject])?[1] as? String, "item2")
        XCTAssertEqual(((returnedDict!["third"] as? [AnyObject])?[2] as? [String])!, ["item3","item4"])
        XCTAssertEqual((returnedDict!["third"] as? [AnyObject])?[3] as? String, "item5")
        
        
    }
    
    private func stringToBase64Data(_ str:String) -> Data {
        let utf8str = str.data(using: String.Encoding.utf8)
        let base64EncodedStr = utf8str?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        return Data(base64Encoded: base64EncodedStr!, options: NSData.Base64DecodingOptions(rawValue: 0))!
    }
    
    func testGetApplicationDetails() {
        let appInfo = Utils.getApplicationDetails()
        XCTAssertNotNil(appInfo.name)
        XCTAssertNotNil(appInfo.version)
    }
    
//    func testGetDeviceDictionary() {
//        let deviceIdentity = AppIDDeviceIdentity()
//        let appIdentity = AppIDAppIdentity()
//        var dictionary = Utils.getDeviceDictionary()
//        XCTAssertEqual(dictionary[AppIDConstants.JSON_DEVICE_ID_KEY] as? String, deviceIdentity.ID)
//        XCTAssertEqual(dictionary[AppIDConstants.JSON_MODEL_KEY] as? String, deviceIdentity.model)
//        XCTAssertEqual(dictionary[AppIDConstants.JSON_OS_KEY] as? String, deviceIdentity.OS)
//        XCTAssertEqual(dictionary[AppIDConstants.JSON_APPLICATION_ID_KEY] as? String, appIdentity.ID)
//        XCTAssertEqual(dictionary[AppIDConstants.JSON_APPLICATION_VERSION_KEY] as? String, appIdentity.version)
//        XCTAssertEqual(dictionary[AppIDConstants.JSON_ENVIRONMENT_KEY] as? String, AppIDConstants.JSON_IOS_ENVIRONMENT_VALUE)
//    }
    func testDecodeBase64WithString(){
        let str = "VGhpcyBpcyBhIFV0aWxzIHVuaXRUZXN0IHR+c/Q="
        let strSafe = "VGhpcyBpcyBhIFV0aWxzIHVuaXRUZXN0IHR-c_Q="
        guard let data = Utils.decodeBase64WithString(str, isSafeUrl: false) else {
            XCTFail("failed to decode a base64 string")
            return
        }
        XCTAssertEqual(Utils.base64StringFromData(data, isSafeUrl: false),str)
        XCTAssertEqual(Utils.base64StringFromData(data, isSafeUrl: true),strSafe)
    }
    
}
