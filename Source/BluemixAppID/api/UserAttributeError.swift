//
//  UserAttributeError.swift
//  AppID
//
//  Created by Oded Betzalel on 06/02/2017.
//  Copyright © 2017 Oded Betzalel. All rights reserved.
//

import Foundation

public enum UserAttributeError: Error {
    case userAttributeFailure(String)
    
    var description: String {
        switch self {
        case .userAttributeFailure(let msg) :
            return msg
        }
    }
}
