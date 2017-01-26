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
    
	public var tenantId: String?
	public var bluemixRegion: String?

	internal var loginView:safariView?
    internal var tokenRequest : ((_ code: String?, _ errMsg:String?) -> Void)?
    
    internal var authorizationManager:AppIDAuthorizationManager?
    internal var registrationManager:RegistrationManager?
    internal var tokenManager:TokenManager?
    internal var preferences:AppIDPreferences?
	
    public static var overrideServerHost: String?
    
    public static let sharedInstance = AppID()
    internal static let logger =  Logger.logger(name: AppIDConstants.AppIDLoggerName)
    
    private init() {}
    
    
    public func initialize(tenantId : String, bluemixRegion : String) {
        self.tenantId = tenantId
        self.bluemixRegion = bluemixRegion
		
		//        if preferences.deviceIdentity.get() == nil {
		//            preferences.deviceIdentity.set(AppIDDeviceIdentity().jsonData as [String:Any])
		//        }
		//        if preferences.appIdentity.get() == nil {
		//            preferences.appIdentity.set(AppIDAppIdentity().jsonData as [String:Any])
		//        }
		
		self.preferences = AppIDPreferences()
		self.authorizationManager = AppIDAuthorizationManager(preferences: preferences!)
		self.registrationManager = RegistrationManager(preferences: preferences!)
		self.tokenManager = TokenManager(preferences: preferences!)
    }
	
    internal var serverUrl:String {
		var url = "";
		if let overrideServerHost = AppID.overrideServerHost {
			url = overrideServerHost
		} else {
			url =  "https://"
				+ AppIDConstants.AUTH_SERVER_NAME
				+ bluemixRegion!
			
		}
		return url
    }
	
	public func application(_ application: UIApplication, open url: URL, options :[UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        func tokenRequest(code: String?, errMsg:String?) {
            loginView?.dismiss(animated: true, completion: { () -> Void in
                self.tokenRequest?(code, errMsg)
            })
        }
        
        let urlString = url.absoluteString
        if urlString.lowercased().hasPrefix(AppIDConstants.REDIRECT_URI_VALUE.lowercased()) == true {
            //gets the query, then sepertes it to params, then filters the one the is "code" then takes its value
            let code = url.query?.components(separatedBy: "&").filter({(item) in item.hasPrefix(AppIDConstants.JSON_CODE_KEY)}).first?.components(separatedBy: "=")[1]
            if(code == nil){
                tokenRequest(code: code, errMsg: "Failed to extract grant code")
            } else {
                tokenRequest(code: code, errMsg: nil)
            }
            return true
        }
        return false
    }
    
    
    public func login(onTokenCompletion : BMSCompletionHandler?) {
        func showLoginWebView() -> Void {
            if let unwrappedTenant = tenantId, let clientId = preferences!.clientId.get() {
                let params = [
                    AppIDConstants.JSON_RESPONSE_TYPE_KEY : AppIDConstants.JSON_CODE_KEY,
                    AppIDConstants.client_id_String : clientId,
                    AppIDConstants.JSON_REDIRECT_URI_KEY : AppIDConstants.REDIRECT_URI_VALUE,
                    AppIDConstants.JSON_SCOPE_KEY : AppIDConstants.OPEN_ID_VALUE,
                    AppIDConstants.JSON_USE_LOGIN_WIDGET : AppIDConstants.TRUE_VALUE,
                    AppIDConstants.JSON_STATE_KEY : UUID().uuidString
                    
                ]
                let url = AppID.sharedInstance.serverUrl + "/" + AppIDConstants.V3_AUTH_PATH + unwrappedTenant + "/" + AppIDConstants.authorizationEndPoint + Utils.getQueryString(params: params)
                
                loginView =  safariView(url: URL(string: url )!)
                loginView?.setCallback(callback: onTokenCompletion)
                let mainView  = UIApplication.shared.keyWindow?.rootViewController
                tokenRequest = { (code: String?, errMsg:String?) -> Void in
                    guard let unWrappedCode = code else {
                        if (errMsg == nil){
                            onTokenCompletion?(nil, AppIDError.authenticationError(msg: "General error"))
                        } else {
                            onTokenCompletion?(nil, AppIDError.authenticationError(msg: errMsg))
                        }
                        return
                    }
                    self.tokenManager!.invokeTokenRequest(unWrappedCode, callback : onTokenCompletion)
                }
                
                DispatchQueue.main.async {
                    mainView?.present(self.loginView!, animated: true, completion: nil)
                };
            } else {
                onTokenCompletion?(nil, AppIDError.authenticationError(msg: "Failed to authorize client"))
            }
        }
        
        if (preferences!.clientId.get() == nil || self.preferences!.registrationTenantId.get() != self.tenantId) {
            do {
                try registrationManager!.registerDevice(callback: {(response: Response?, error: Error?) in
                    if error == nil && response?.statusCode == 200 {
                        self.preferences!.registrationTenantId.set(self.tenantId)
                        showLoginWebView()
                    } else {
                        onTokenCompletion?(nil, error == nil ? AppIDError.registrationError(msg: "Could not register device") : error)
                    }
                })
            } catch (let err){
                onTokenCompletion?(nil, AppIDError.registrationError(msg: err.localizedDescription))
            }
            
        } else {
            showLoginWebView()
        }
    }
    
}
