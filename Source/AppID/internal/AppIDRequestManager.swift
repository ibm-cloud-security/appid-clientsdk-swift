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
import BMSAnalyticsAPI

    
    // MARK: - AppIDRequestManager (Swift 3)
    
    public class AppIDRequestManager {
        
        //MARK constants
        //MARK vars (private)
        
        var requestPath : String?
        var requestOptions : RequestOptions?
        
        
        public static var overrideServerHost: String?
        
        private static let logger = Logger.logger(name: BMSSecurityConstants.AppIDRequestManagerLoggerName)
        
        internal var defaultCompletionHandler : BMSCompletionHandler
        
        internal init(completionHandler: BMSCompletionHandler?) {
            
            if let handler = completionHandler {
                defaultCompletionHandler = handler
            } else {
                defaultCompletionHandler = {(response: Response?, error: Error?) in
                    AppIDRequestManager.logger.debug(message: "ResponseListener is not specified. Defaulting to empty listener.")
                }
                
            }
            
            AppIDRequestManager.logger.debug(message: "AppIDRequestManager is initialized.")
        }
        
        internal func send(_ path:String , options:RequestOptions) throws {
            var rootUrl:String = ""
            var computedPath:String = path
            
            if path.hasPrefix(AppID.HTTP_SCHEME) && path.characters.index(of: ":") != nil {
                let url = URL(string: path)
                if let pathTemp = url?.path {
                    rootUrl = (path as NSString).replacingOccurrences(of: pathTemp, with: "")
                    computedPath = pathTemp
                }
                else {
                    rootUrl = ""
                }
            }
            try sendInternal(rootUrl, path: computedPath, options: options)
            
        }
        
        
        internal func sendInternal(_ rootUrl:String, path:String, options:RequestOptions?) throws {
            self.requestOptions = options != nil ? options : RequestOptions()
            
            requestPath = Utils.concatenateUrls(rootUrl, path: path)
            
            let request = AppIDRequest(url:requestPath!, method:self.requestOptions!.requestMethod)
            
            request.timeout = requestOptions!.timeout != 0 ? requestOptions!.timeout : BMSClient.sharedInstance.requestTimeout
            
            
            if let unwrappedHeaders = options?.headers {
                request.addHeaders(unwrappedHeaders)
            }
            
            
            if let method = options?.requestMethod, method == HttpMethod.GET{
                request.queryParameters = options?.parameters
                request.send(defaultCompletionHandler)
            } else if let params = options?.parameters, params.count > 0  {
                request.sendWithCompletionHandler(params, callback: defaultCompletionHandler)
            } else if let json = options?.json {
                request.sendJson(json: json, callback: defaultCompletionHandler)
            }
        }
        
        internal func resendRequest() throws {
            try send(requestPath!, options: requestOptions!)
        }
        
    }
    
