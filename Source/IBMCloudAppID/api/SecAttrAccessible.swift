/* *     Copyright 2016, 2017, 2018 IBM Corp.
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

public enum SecAttrAccessible: RawRepresentable {

    case alwaysAccessible               // kSecAttrAccessibleAlways
    case alwaysAccessibleDeviceOnly     // kSecAttrAccessibleAlwaysThisDeviceOnly
    case afterFristUnlock               // kSecAttrAccessibleAfterFirstUnlock
    case afterFirstUnlockDeviceOnly     // kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    case whenUnlocked                   // kSecAttrAccessibleWhenUnlocked
    case whenUnlockedDeviceOnly         // kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    case passcodeSet                    // kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly

    public init?(rawValue: CFString) {
        switch rawValue {
        case kSecAttrAccessibleAlways: self = .alwaysAccessible
        case kSecAttrAccessibleAlwaysThisDeviceOnly: self = .alwaysAccessibleDeviceOnly
        case kSecAttrAccessibleAfterFirstUnlock: self = .afterFristUnlock
        case kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly: self = .afterFirstUnlockDeviceOnly
        case kSecAttrAccessibleWhenUnlocked: self = .whenUnlocked
        case kSecAttrAccessibleWhenUnlockedThisDeviceOnly: self = .whenUnlockedDeviceOnly
        case kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly: self = .passcodeSet
        default: self = .afterFristUnlock
        }
    }

    public var rawValue: CFString {
        switch self {
        case .alwaysAccessible: return kSecAttrAccessibleAlways
        case .alwaysAccessibleDeviceOnly: return kSecAttrAccessibleAlwaysThisDeviceOnly
        case .afterFristUnlock: return kSecAttrAccessibleAfterFirstUnlock
        case .afterFirstUnlockDeviceOnly: return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenUnlocked: return kSecAttrAccessibleWhenUnlocked
        case .whenUnlockedDeviceOnly: return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .passcodeSet: return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
    }
}
