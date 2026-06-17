//
//  ValidationError.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 14.04.26.
//

import Foundation


protocol ValidationErrorProtocol: Error {
    var message: LocalizedStringResource { get }
}

enum ValidationError {
    
    enum NameError: Equatable, ValidationErrorProtocol {
        case tooShort
        case tooLong
        case empty
        
        var message: LocalizedStringResource {
            switch self {
            case .tooShort:
                    .nameIsTooShort
            case .tooLong:
                    .nameIsTooLong
            case .empty:
                    .nameIsEmpty
            }
        }
    }
    
    enum EmailError: Equatable, ValidationErrorProtocol {
        case invalidFormat
        case empty
        case tooLong
        
        var message: LocalizedStringResource {
            switch self {
            case .invalidFormat:
                    .emailHasInvalidFormat
            case .empty:
                    .emailIsEmpty
            case .tooLong:
                    .emailIsTooLong
            }
            
        }
    }
    
    enum PasswordError: Equatable, ValidationErrorProtocol {
        case passwordMismatch
        case tooShort
        case tooLong
        case empty
        
        var message: LocalizedStringResource {
            switch self {
            case .passwordMismatch:
                    .passwordsAreNotEqual
            case .tooShort:
                    .passwordIsTooShort
            case .tooLong:
                    .passwordIsTooLong
            case .empty:
                    .passwordIsEmpty
            }
        }
    }
}
