/*
*     Copyright 2015 IBM Corp.
*     Licensed under the Apache License, Version 2.0 (the "License");
*     you may not use this file except in compliance with the License.
*     You may obtain a copy of the License at
*     http://www.apache.org/licenses/LICENSE-2.0
*     Unless required by applicable law or agreed to in writing, software
*     distributed under the License is distributed on an "AS IS" BASIS,
*     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*     See the License for the specific language governing permissions and
*     limitations under the License.
*/
import Foundation
import BMSCore

/// This class represents the base user identity class, with default methods and keys
#if swift (>=3.0)
public class AppIDUserIdentity : BaseUserIdentity{
    public var json:[String:Any]?
   
    public override init() {
        super.init()
        
    }
    
    public convenience init(map: [String:AnyObject]?) {
        self.init(map: map as [String:Any]?)
        
    }
    
    public override init(map: [String : Any]?) {
        super.init(map: map)
        json = map
    }
    
    
    public var AppIDID: String? {
        get {
            return json?[BaseUserIdentity.Key.ID] as? String
        }
    }
    
    public var AppIDauthorizedBy: String? {
        get {
            return json?[BaseUserIdentity.Key.authorizedBy] as? String
        }
    }
    
    public var AppIDdisplayName: String? {
        get {
            return json?[BaseUserIdentity.Key.displayName] as? String
        }
    }

    
    public var picUrl : String? {
        get {
            return (((json?["attributes"] as? [String:Any])?["picture"] as? [String:Any])?["data"] as? [String:Any])?["url"] as? String
        }
    }
 }
#else
public class MCAUserIdentity : BaseUserIdentity{
    
    public override init() {
        super.init()
    }
    
    public override init(map: [String : AnyObject]?) {
        super.init(map: map)
    }
}
    
#endif

