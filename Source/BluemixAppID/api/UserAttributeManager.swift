//
//  UserAttributeManager.swift
//  AppID
//
//  Created by Oded Betzalel on 06/02/2017.
//  Copyright © 2017 Oded Betzalel. All rights reserved.
//

import Foundation

public protocol UserAttributeManager {

    func setAttribute(key: String, value: String, delegate: UserAttributeDelegate)
    func setAttribute(key: String, value: String, accessToken: AccessToken, delegate: UserAttributeDelegate)
    func getAttribute(key: String, delegate: UserAttributeDelegate)
    func getAttribute(key: String, accessToken: AccessToken, delegate: UserAttributeDelegate)
    func getAttributes(delegate: UserAttributeDelegate)
    func getAttributes(accessToken: AccessToken, delegate: UserAttributeDelegate)
    func deleteAttribute(key: String, delegate: UserAttributeDelegate)
    func deleteAttribute(key: String, accessToken: AccessToken, delegate: UserAttributeDelegate)
    
}
