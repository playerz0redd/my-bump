//
//  AuthError.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.04.26.
//

import Foundation

enum AuthServiceError: Error {
    
    case loginError(AuthManagerError)
    case signOutError(AuthManagerError)
    case registerError(AuthManagerError)
    case changePasswordError(AuthManagerError)
    case saveProfileError(UserStorageError)
    case unknown(Error)

    var message: LocalizedStringResource {
        switch self {
        case .loginError(let authManagerError):
            authManagerError.message
        case .signOutError(let authManagerError):
            authManagerError.message
        case .registerError(let authManagerError):
            authManagerError.message
        case .changePasswordError(let authManagerError):
            authManagerError.message
        case .saveProfileError(let error):
            error.message
        case .unknown(let error):
            .errorOccured(error.localizedDescription)
        }
    }
}

extension AuthServiceError: Equatable {
    static func ==(lhs: AuthServiceError, rhs: AuthServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.unknown(let lError), .unknown(let rError)):
            return lError.localizedDescription == rError.localizedDescription
        default:
            return lhs.message == rhs.message
        }
    }
}
