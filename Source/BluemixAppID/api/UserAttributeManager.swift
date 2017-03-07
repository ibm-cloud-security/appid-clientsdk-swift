//
//  UserAttributeManager.swift
//  AppID
//
//  Created by Oded Betzalel on 06/02/2017.
//  Copyright © 2017 Oded Betzalel. All rights reserved.
//

import Foundation

public protocol UserAttributeManager {

    func setAttribute(key: String, value: String, completionHandler: @escaping(Error?, [String:Any]?) -> Void)
    func setAttribute(key: String, value: String, accessTokenString: String, completionHandler: @escaping(Error?, [String:Any]?) -> Void)
    func getAttribute(key: String, completionHandler: @escaping(Error?, [String:Any]?) -> Void)
    func getAttribute(key: String, accessTokenString: String, completionHandler: @escaping(Error?, [String:Any]?) -> Void)
    func getAttributes(completionHandler: @escaping(Error?, [String:Any]?) -> Void)
    func getAttributes(accessTokenString: String, completionHandler: @escaping(Error?, [String:Any]?) -> Void)
    func deleteAttribute(key: String, completionHandler: @escaping(Error?, [String:Any]?) -> Void)
    func deleteAttribute(key: String, accessTokenString: String, completionHandler: @escaping(Error?, [String:Any]?) -> Void)
    
}
