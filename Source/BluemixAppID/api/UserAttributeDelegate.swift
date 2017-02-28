//
//  File.swift
//  AppID
//
//  Created by Oded Betzalel on 06/02/2017.
//  Copyright © 2017 Oded Betzalel. All rights reserved.
//

import Foundation


public protocol UserAttributeDelegate {

    func onSuccess(result: [String:Any])
    func onFailure(error: UserAttributeError)
}
