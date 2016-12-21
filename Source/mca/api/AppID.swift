//
//  AppID.swift
//  Pods
//
//  Created by Oded Betzalel on 08/12/2016.
//
//

import Foundation
import SafariServices
import BMSCore
public class AppID {
    
    
    private var loginView:SFSafariViewController?
    private var tokenRequest : ((_ code: String?, _ errMsg:String?) -> Void)?
    
    var authorizationManager:AppIDAuthorizationManager
    var registrationManager:RegistrationManager
    var tokenManager:TokenManager
    var preferences:AuthorizationManagerPreferences
    var tenantId:String?
    var bluemixRegion:String?
    
    
    public static var overrideServerHost: String?
    
    public static var defaultProtocol: String = HTTPS_SCHEME
    public static let HTTP_SCHEME = "http"
    public static let HTTPS_SCHEME = "https"
    
    public static let CONTENT_TYPE = "Content-Type"
    public static let sharedInstance = AppID()
    internal static let logger =  Logger.logger(name: Logger.bmsLoggerPrefix + "AppID")
    
    private init() {
        self.tenantId = BMSClient.sharedInstance.bluemixAppGUID
        self.bluemixRegion = BMSClient.sharedInstance.bluemixRegion
        self.preferences = AuthorizationManagerPreferences()
        
        if preferences.deviceIdentity.get() == nil {
            preferences.deviceIdentity.set(MCADeviceIdentity().jsonData as [String:Any])
        }
        if preferences.appIdentity.get() == nil {
            preferences.appIdentity.set(MCAAppIdentity().jsonData as [String:Any])
        }
        
        authorizationManager = AppIDAuthorizationManager(preferences: preferences)
        registrationManager = RegistrationManager(preferences: preferences)
        tokenManager = TokenManager(preferences: preferences, sessionId: registrationManager.sessionId)
        BMSClient.sharedInstance.authorizationManager = authorizationManager
        
    }
    
    
    public func initialize(tenantId : String, bluemixRegion : String) {
        self.tenantId = tenantId
        self.bluemixRegion = bluemixRegion
    }
    
    internal var serverUrl:String {
        get{
            var url = "";
            if let overrideServerHost = AppID.overrideServerHost {
                url = overrideServerHost
            } else {
                url =  AppID.defaultProtocol
                    + "://"
                    + BMSSecurityConstants.AUTH_SERVER_NAME
                    + bluemixRegion!
                
            }
            return url
        }
        
    }
    
    
    
    public var accessToken:String? {
        get {
            return self.preferences.accessToken.get()
        }
    }
    /**
     - returns: User identity
     */
    public var userIdentity:UserIdentity? {
        get{
            return authorizationManager.userIdentity
        }
    }
    
    public func tokenRequest(code: String?, errMsg:String?) {
        loginView?.dismiss(animated: true, completion: { () -> Void in
        self.tokenRequest?(code, errMsg)
        })
    }
    
    public func login(onTokenCompletion : BMSCompletionHandler?) {
        func showLoginWebView() -> Void {
            if let unwrappedTenant = tenantId {
                let params = [
                    BMSSecurityConstants.JSON_RESPONSE_TYPE_KEY : BMSSecurityConstants.JSON_CODE_KEY,
                    BMSSecurityConstants.client_id_String : unwrappedTenant,
                    BMSSecurityConstants.JSON_REDIRECT_URI_KEY : BMSSecurityConstants.REDIRECT_URI_VALUE,
                    BMSSecurityConstants.JSON_SCOPE_KEY : BMSSecurityConstants.OPEN_ID_VALUE,
                    BMSSecurityConstants.JSON_USE_LOGIN_WIDGET : BMSSecurityConstants.TRUE_VALUE,
                    BMSSecurityConstants.JSON_STATE_KEY : UUID().uuidString
                    
                ]
                let url = AppID.sharedInstance.serverUrl + "/" + BMSSecurityConstants.V3_AUTH_PATH + BMSSecurityConstants.authorizationEndPoint + Utils.getQueryString(params: params)
                
                loginView =  SFSafariViewController(url: URL(string: url )!)
                
                let mainView  = UIApplication.shared.keyWindow?.rootViewController
                tokenRequest = { (code: String?, errMsg:String?) -> Void in
                    guard let unWrappedCode = code else {
                        if (errMsg == nil){
                            onTokenCompletion?(nil, AppIDError.AuthenticationError(msg: "General error"))
                        } else {
                            onTokenCompletion?(nil, AppIDError.AuthenticationError(msg: errMsg))
                        }
                        return
                    }
                    self.tokenManager.invokeTokenRequest(unWrappedCode, tenantId: unwrappedTenant, clientId: self.preferences.clientId.get()!, callback : onTokenCompletion)
                }
        
                DispatchQueue.main.async {
                    mainView?.present(self.loginView!, animated: true, completion: nil)
                };
            } else {
                onTokenCompletion?(nil, AppIDError.AuthenticationError(msg: "Tenant Id is not defined"))
            }
        }
        
        if (preferences.clientId.get() == nil || self.preferences.registrationTenantId.get() != self.tenantId) {
            do {
                try registrationManager.registerDevice(callback: {(response: Response?, error: Error?) in
                    if error == nil && response?.statusCode == 200{ //TODO: maybe android should add it as well
                        self.preferences.registrationTenantId.set(self.tenantId)
                        showLoginWebView()
                    } else {
                        onTokenCompletion?(nil, error)
                    }
                })
            } catch (let err){
                onTokenCompletion?(nil, AppIDError.RegistrationError(msg: err.localizedDescription))
            }
            
        } else {
            showLoginWebView()
        }
    }
    
}
