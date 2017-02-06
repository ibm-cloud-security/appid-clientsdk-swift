//
//  UserAttributeManager.swift
//  AppID
//
//  Created by Oded Betzalel on 06/02/2017.
//  Copyright © 2017 Oded Betzalel. All rights reserved.
//

import Foundation

public protocol UserAttributeManager {
    
    func setAttribute(var1: String, var2: String, var3: UserAttributeDelegate)
    func setAttribute(var1: String, var2: String, var3: AccessTokenImpl, var4: UserAttributeDelegate)
    func getAttribute(var1: String, var2: UserAttributeDelegate)
    func getAttribute(var1: String, var2: AccessTokenImpl, var3: UserAttributeDelegate)
    func deleteAttribute(var1: String, var2: UserAttributeDelegate)
    func deleteAttribute(var1: String, var2: AccessTokenImpl, var3: UserAttributeDelegate)
    
}
