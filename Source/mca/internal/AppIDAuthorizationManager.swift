//
//  AppIDAuthorizationManager.swift
//  Pods
//
//  Created by Oded Betzalel on 08/12/2016.
//
//

import Foundation
import BMSCore

internal class AppIDAuthorizationManager : AuthorizationManager{
    public func obtainAuthorization(completionHandler callback: BMSCompletionHandler?) {
    AppID.sharedInstance.login(onTokenCompletion: callback)
    }
    
    public func clearAuthorizationData() {
        return
    }
    
    
    /// Default scheme to use (default is https)
    public static var defaultProtocol: String = HTTPS_SCHEME
    public static let HTTP_SCHEME = "http"
    public static let HTTPS_SCHEME = "https"
    
    public static let CONTENT_TYPE = "Content-Type"
    
    private static let logger =  Logger.logger(name: Logger.bmsLoggerPrefix + "MCAAuthorizationManager")
    
    internal var preferences:AuthorizationManagerPreferences!
    
    //lock constant
    private var lockQueue = DispatchQueue(label: "MCAAuthorizationManagerQueue", attributes: DispatchQueue.Attributes.concurrent)
    
   
    
    
    // Specifies the bluemix region of the MCA service instance
    public private(set) var bluemixRegion: String?
    
    // Specifies the tenant id of the MCA service instance
    public private(set) var tenantId: String?
    
    /**
     - returns: The singelton instance
     */
    
    /**
     The intializer for the `MCAAuthorizationManager` class.
     
     - parameter tenantId:           The tenant id of the MCA service instance
     - parameter bluemixRegion:      The region where your MCA service instance is hosted. Use one of the `BMSClient.REGION` constants.
     */
    public  init(preferences:AuthorizationManagerPreferences) {
        self.preferences = preferences
    }
    
    /**
     - returns: The locally stored authorization header or nil if the value does not exist.
     */
    public var cachedAuthorizationHeader:String? {
        get{
            var returnedValue:String? = nil
            lockQueue.sync(flags: .barrier, execute: {
                if let accessToken = self.preferences.accessToken.get(), let idToken = self.preferences.idToken.get() {
                    returnedValue = "\(BMSSecurityConstants.BEARER) \(accessToken) \(idToken)"
                }
            })
            return returnedValue
        }
    }
    
    /**
     - returns: User identity
     */
    public var userIdentity:UserIdentity? {
        get{
            let userIdentityJson = preferences.userIdentity.getAsMap()
            return MCAUserIdentity(map: userIdentityJson)
        }
    }
    
    /**
     - returns: Device identity
     */
    public var deviceIdentity:DeviceIdentity {
        get{
            let deviceIdentityJson = preferences.deviceIdentity.getAsMap()
            return MCADeviceIdentity(map: deviceIdentityJson)
        }
    }
    
    /**
     - returns: Application identity
     */
    public var appIdentity:AppIdentity {
        get{
            let appIdentityJson = preferences.appIdentity.getAsMap()
            return MCAAppIdentity(map: appIdentityJson)
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
    
    
    public func isAuthorizationRequired(for httpResponse: Response) -> Bool {
        if let header = httpResponse.headers![caseInsensitive : BMSSecurityConstants.WWW_AUTHENTICATE_HEADER], let authHeader : String = header as? String {
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
    
    
    public func isAuthorizationRequired(for statusCode: Int, httpResponseAuthorizationHeader responseAuthorizationHeader: String) -> Bool {
        
        if (statusCode == 401 || statusCode == 403) &&
            responseAuthorizationHeader.lowercased().contains(BMSSecurityConstants.BEARER.lowercased()) &&
            responseAuthorizationHeader.lowercased().contains(BMSSecurityConstants.AUTH_REALM.lowercased()) {
            return true
        }
        
        return false
    }
    
    
    /**
     Adds the cached authorization header to the given URL connection object.
     If the cached authorization header is equal to nil then this operation has no effect.
     - Parameter request - The request to add the header to.
     */
    
    public func addCachedAuthorizationHeader(_ request: NSMutableURLRequest) {
        addAuthorizationHeader(request, header: cachedAuthorizationHeader)
    }
    
    private func addAuthorizationHeader(_ request: NSMutableURLRequest, header:String?) {
        guard let unWrappedHeader = header else {
            return
        }
        request.setValue(unWrappedHeader, forHTTPHeaderField: BMSSecurityConstants.AUTHORIZATION_HEADER)
    }
    
    
    public func authorizationPersistencePolicy() -> PersistencePolicy {
        return preferences.persistencePolicy.get()
    }

}
