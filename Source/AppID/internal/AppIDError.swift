//
//  AppIDErrors.swift
//  Pods
//
//  Created by Oded Betzalel on 11/12/2016.
//
//

import Foundation

enum AppIDError : Error {
    case AuthenticationError(msg : String?)
    case RegistrationError(msg : String?)
    case TokenRequestError(msg : String?)
    
}
