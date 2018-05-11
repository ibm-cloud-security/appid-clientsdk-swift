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
import SafariServices
import BMSCore

public class AppID {

	private(set) var tenantId: String?
	private(set) var bluemixRegion: String?
    private(set) var oauthManager: OAuthManager?
    private(set) var userInfoManager: UserInfoManager?
    public var loginWidget: LoginWidgetImpl?
    public var userAttributeManager:UserAttributeManagerImpl?
    
    public static var overrideServerHost: String?
    public static var overrideAttributesHost: String?
    public static var sharedInstance = AppID()
    internal static let logger =  Logger.logger(name: AppIDConstants.AppIDLoggerName)
    
    static public let REGION_US_SOUTH = ".ng.bluemix.net"
    static public let REGION_UK = ".eu-gb.bluemix.net"
    static public let REGION_SYDNEY = ".au-syd.bluemix.net"
    static public let REGION_GERMANY = ".eu-de.bluemix.net"
    
    internal init() {}
    
    /**
        Intializes the App ID instance
        @param tenantId The tenant Id.
        @param bluemixRegion The bluemix region.
    */
    public func initialize(tenantId: String, bluemixRegion: String) {
        self.tenantId = tenantId
        self.bluemixRegion = bluemixRegion
		self.oauthManager = OAuthManager(appId: self)
        self.userInfoManager = UserInfoManager(appId: self)
        self.loginWidget = LoginWidgetImpl(oauthManager: self.oauthManager!)
        self.userAttributeManager = UserAttributeManagerImpl(appId: self)
    }

    public func setPreferredLocale(_ locale: Locale) {
        self.oauthManager?.setPreferredLocale(locale)
    }
    
    public func signinAnonymously(accessTokenString:String? = nil, allowCreateNewAnonymousUsers: Bool = true, authorizationDelegate:AuthorizationDelegate) {
        oauthManager?.authorizationManager?.loginAnonymously(accessTokenString: accessTokenString, allowCreateNewAnonymousUsers: allowCreateNewAnonymousUsers, authorizationDelegate: authorizationDelegate)
    }

    public func signinWithResourceOwnerPassword(_ accessTokenString:String? = nil, username: String, password: String, tokenResponseDelegate:TokenResponseDelegate) {
        oauthManager?.authorizationManager?.signinWithResourceOwnerPassword(accessTokenString: accessTokenString, username: username, password: password, tokenResponseDelegate: tokenResponseDelegate)
    }

   /**
     Obtain new access and identity tokens using a refresh token.
     
     Note that the identity itself (user name/details) will not be refreshed by this operation, 
     it will remain the same identity but in a new token (new expiration time)
    */
    public func signinWithRefreshToken(refreshTokenString:String? = nil, tokenResponseDelegate:TokenResponseDelegate) {
        oauthManager?.authorizationManager?.signinWithRefreshToken(
            refreshTokenString: refreshTokenString,
            tokenResponseDelegate: tokenResponseDelegate)
    }
    
    @available(*, deprecated: 3.0, renamed: "signinAnonymously")
    public func loginAnonymously(accessTokenString:String? = nil, allowCreateNewAnonymousUsers: Bool = true, authorizationDelegate:AuthorizationDelegate) {
        self.signinAnonymously(accessTokenString: accessTokenString, allowCreateNewAnonymousUsers: allowCreateNewAnonymousUsers, authorizationDelegate: authorizationDelegate)
    }
    
    @available(*, deprecated: 3.0, renamed: "signinWithResourceOwnerPassword")
    public func obtainTokensWithROP(_ accessTokenString:String? = nil, username: String, password: String, tokenResponseDelegate:TokenResponseDelegate) {
        self.signinWithResourceOwnerPassword(accessTokenString, username: username,
                                             password: password, tokenResponseDelegate: tokenResponseDelegate)
    }

    
    
	public func application(_ application: UIApplication, open url: URL, options :[UIApplicationOpenURLOptionsKey: Any]) -> Bool {
            return (self.oauthManager?.authorizationManager?.application(application, open: url, options: options))!
    }
    
    ///
    /// Retrieves UserInfo using the stored access and identity tokens
    ///
    /// - Parameter completion: The error, json profile response handler
    ///
    public func getUserInfo(completion: @escaping (Error?, [String: Any]?) -> Void) {
        userInfoManager?.getUserInfo(completion: completion)
    }
    
    ///
    /// Retrieves UserInfo using the provided access and identity tokens
    ///
    /// - Parameter accessTokenString: the access token to use for authorization
    /// - Parameter identityTokenString: the identity token to use for response validation
    /// - Parameter completion: the (error, json profile) response handler
    ///
    public func getUserInfo(accessTokenString: String, identityTokenString: String, completion: @escaping (Error?, [String: Any]?) -> Void) {
        userInfoManager?.getUserInfo(accessToken: accessTokenString, idToken: identityTokenString, completion: completion)
    }
}
