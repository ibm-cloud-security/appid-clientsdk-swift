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
    //TODO: how should someone access a protected resource
	private(set) var tenantId: String?
	private(set) var bluemixRegion: String?

	internal var loginView:safariView?
    internal var tokenRequest : ((_ code: String?, _ errMsg:String?) -> Void)?

    private(set) var oauthManager:OAuthManager?
    private(set) var loginWidget:LoginWidgetImpl?
    //TODO: user attr manager - do we need it
    public static var overrideServerHost: String?
    //TODO: make this singleton correct
    public static let sharedInstance = AppID()
    internal static let logger =  Logger.logger(name: AppIDConstants.AppIDLoggerName)
    
    private init() {}
    
    
    public func initialize(tenantId : String, bluemixRegion : String) -> AppID {
        self.tenantId = tenantId
        self.bluemixRegion = bluemixRegion
		self.oauthManager = OAuthManager(appId: self)
        self.loginWidget = LoginWidgetImpl(oauthManager: self.oauthManager!)
        return self
    }
	
    
    
    //TODO: what should these two functions do?
    public func loginAnonymously(authorizationDelegate:AuthorizationDelegate) {
        self.loginAnonymously(accessToken: nil, authorizationDelegate: authorizationDelegate)
    }
    
    public func loginAnonymously(accessToken:String?, authorizationDelegate:AuthorizationDelegate) {
        
    }
    
	public func application(_ application: UIApplication, open url: URL, options :[UIApplicationOpenURLOptionsKey : Any]) -> Bool {
            return (self.oauthManager?.authorizationManager?.application(application, open: url, options: options))!
    }
    
    
       
}
