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


internal class Config {
    private static var serverUrlPrefix = "https://mobileclientaccess"
 
    internal static func getServerUrl(appId:AppID) -> String{
        //TODO: remove this !
    var serverUrl = Config.serverUrlPrefix + appId.bluemixRegion! + "/oauth/v3/"
        if let overrideServerHost = AppID.overrideServerHost {
        serverUrl = overrideServerHost
    }
    
    serverUrl = serverUrl + appId.tenantId!
    return serverUrl
    }
}
