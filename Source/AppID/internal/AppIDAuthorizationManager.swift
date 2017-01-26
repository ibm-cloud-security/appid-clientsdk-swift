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

internal class AppIDAuthorizationManager : AuthorizationManager {
    public func obtainAuthorization(completionHandler callback: BMSCompletionHandler?) {
    AppID.sharedInstance.login(onTokenCompletion: callback)
    }
    
    public func clearAuthorizationData() {
        return
    }
    
    
    /// Default scheme to use (default is https)
    public static let CONTENT_TYPE = "Content-Type"
    
    private static let logger =  Logger.logger(name: Logger.bmsLoggerPrefix + "AppIDAuthorizationManager")
    
    internal var preferences:AppIDPreferences!
    
    //lock constant
    private var lockQueue = DispatchQueue(label: "AppIDAuthorizationManagerQueue", attributes: DispatchQueue.Attributes.concurrent)
    
   
    
    
    // Specifies the bluemix region of the MCA service instance
    internal private(set) var bluemixRegion: String?
    
    // Specifies the tenant id of the MCA service instance
    internal private(set) var tenantId: String?
    
    /**
     - returns: The singelton instance
     */
    
    /**
     The intializer for the `MCAAuthorizationManager` class.
     
     - parameter tenantId:           The tenant id of the MCA service instance
     - parameter bluemixRegion:      The region where your MCA service instance is hosted. Use one of the `BMSClient.REGION` constants.
     */
    internal  init(preferences:AppIDPreferences) {
        self.preferences = preferences
    }
    
    /**
     - returns: The locally stored authorization header or nil if the value does not exist.
     */
    internal var cachedAuthorizationHeader:String? {
        get{
            var returnedValue:String? = nil
            lockQueue.sync(flags: .barrier, execute: {
                if let accessToken = self.preferences.accessToken.get(), let idToken = self.preferences.idToken.get() {
                    returnedValue = "\(AppIDConstants.BEARER) \(accessToken) \(idToken)"
                }
            })
            return returnedValue
        }
    }
    
    /**
     - returns: User identity
     */
    internal var userIdentity:UserIdentity? {
        get{
//            let userIdentityJson = preferences.userIdentity.getAsMap()
            return BaseUserIdentity()
        }
    }
    
    /**
     - returns: Device identity
     */
    internal var deviceIdentity:DeviceIdentity {
        get{
//            let deviceIdentityJson = preferences.deviceIdentity.getAsMap()
            return BaseDeviceIdentity()
        }
    }
    
    /**
     - returns: Application identity
     */
    internal var appIdentity:AppIdentity {
        get{
//            let appIdentityJson = preferences.appIdentity.getAsMap()
            return BaseAppIdentity()
        }
    }
    
    private init() {
        }
    
    /**
     A response is an OAuth error response only if,
     1. it's status is 401 or 403.
     2. The value of the "WWW-Authenticate" header contains 'Bearer'.
     
     - Parameter httpResponse - Response to check the authorization conditions for.
     
     - returns: True if the response satisfies both conditions
     */
    
    
    internal func isAuthorizationRequired(for httpResponse: Response) -> Bool {
        if let header = httpResponse.headers![caseInsensitive : AppIDConstants.WWW_AUTHENTICATE_HEADER], let authHeader : String = header as? String {
            guard let statusCode = httpResponse.statusCode else {
                return false
            }
            return isAuthorizationRequired(for: statusCode, httpResponseAuthorizationHeader: authHeader)
        }
        
        return false
    }
    
    /**
     Check if the params came from response that requires authorization
     
     - Parameter statusCode - Status code of the response
     - Parameter responseAuthorizationHeader - Response header
     
     - returns: True if status is 401 or 403 and The value of the header contains 'Bearer'
     */
    
    
    internal func isAuthorizationRequired(for statusCode: Int, httpResponseAuthorizationHeader responseAuthorizationHeader: String) -> Bool {
        
        if (statusCode == 401 || statusCode == 403) &&
            responseAuthorizationHeader.lowercased().contains(AppIDConstants.BEARER.lowercased()) &&
            responseAuthorizationHeader.lowercased().contains(AppIDConstants.AUTH_REALM.lowercased()) {
            return true
        }
        
        return false
    }
    
    
    /**
     Adds the cached authorization header to the given URL connection object.
     If the cached authorization header is equal to nil then this operation has no effect.
     - Parameter request - The request to add the header to.
     */
    
    internal func addCachedAuthorizationHeader(_ request: NSMutableURLRequest) {
        addAuthorizationHeader(request, header: cachedAuthorizationHeader)
    }
    
    private func addAuthorizationHeader(_ request: NSMutableURLRequest, header:String?) {
        guard let unWrappedHeader = header else {
            return
        }
        request.setValue(unWrappedHeader, forHTTPHeaderField: AppIDConstants.AUTHORIZATION_HEADER)
    }
    
    
    internal func authorizationPersistencePolicy() -> PersistencePolicy {
        return preferences.persistencePolicy.get()
    }

}
