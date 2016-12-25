//
//  AppIDErrors.swift
//  Pods
//
//  Created by Oded Betzalel on 11/12/2016.
//
//

import Foundation

enum AppIDError : Error {
    case authenticationError(msg : String?)
    case registrationError(msg : String?)
    case tokenRequestError(msg : String?)
    case jsonUtilsError(msg: String?)
    case generalError
    
}
