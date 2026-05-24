//
//  AuthViewModel+FieldType.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 28.04.26.
//

import Foundation

extension AuthViewModel {
    
    enum FieldType {
        case name
        case email
        case password
        case confirmPassword
    
        
        var image: String {
            switch self {
            case .name:
                "person"
            case .email:
                "envelope"
            case .password:
                "lock"
            case .confirmPassword:
                "lock"
            }
        }
        
        var title: LocalizedStringResource {
            switch self {
            case .name:
                    .password
            case .email:
                    .emailAddress
            case .password:
                    .password
            case .confirmPassword:
                    .confirmPassword
            }
        }
        
        var placeholder: LocalizedStringResource {
            switch self {
            case .name:
                    .yourFullName
            case .email:
                    .yourEmail
            case .password:
                    .yourPassword
            case .confirmPassword:
                    .confirmYourPassword
            }
        }
        
        var isPassword: Bool {
            switch self {
            case .name:
                false
            case .email:
                false
            case .password:
                true
            case .confirmPassword:
                true
            }
        }
        
    }
}

