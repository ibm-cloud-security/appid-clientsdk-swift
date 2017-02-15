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
import BMSCore
@testable import BluemixAppID

public class Helpers {
    
    public static func savePublicKeyDataToKeyChain(_ key:Data,tag:String) {
        let publicKeyAttr : [NSString:AnyObject] = [
            kSecValueData: key as AnyObject,
            kSecClass : kSecClassKey,
            kSecAttrApplicationTag: tag as AnyObject,
            kSecAttrKeyType : kSecAttrKeyTypeRSA,
            kSecAttrKeyClass : kSecAttrKeyClassPublic
            
        ]
        SecItemAdd(publicKeyAttr as CFDictionary, nil)
    }
    
    public static func savePrivateKeyDataToKeyChain(_ key:Data,tag:String) {
        let publicKeyAttr : [NSString:AnyObject] = [
            kSecValueData: key as AnyObject,
            kSecClass : kSecClassKey,
            kSecAttrApplicationTag: tag as AnyObject,
            kSecAttrKeyType : kSecAttrKeyTypeRSA,
            kSecAttrKeyClass : kSecAttrKeyClassPrivate
            
        ]
        SecItemAdd(publicKeyAttr as CFDictionary, nil)
    }
    
    public static func clearDictValuesFromKeyChain(_ dict : [String : NSString])  {
        for (tag, kSecClassName) in dict {
            if kSecClassName == kSecClassKey {
                _ = SecurityUtils.deleteKeyFromKeyChain(tag)
            } else if kSecClassName == kSecClassGenericPassword {
                _ = SecurityUtils.removeItemFromKeyChain(tag)
            }
        }
    }



}
