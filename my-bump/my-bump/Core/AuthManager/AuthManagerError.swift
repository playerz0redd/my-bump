//
//  AuthManagerError.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.04.26.
//

import Foundation

enum AuthManagerError: Error {
    case emailIsAlreadyInUse
    case userNotFound
    case missGoogleIdToken
    case userCancelledSignIn
    case invalidEmail(Error)
    case networkError(Error)
    case unknown(Error)
    
    var message: LocalizedStringResource {
        switch self {
        case .emailIsAlreadyInUse:
                .emailIsAlreadyInUse
        case .userNotFound:
                .incorrectEmailOrPassword
        case .invalidEmail(let error):
                .invalidEmail(error.localizedDescription)
        case .networkError(let error):
                .networkError(error.localizedDescription)
        case .unknown(let error):
                .unknownErrorOccured(error.localizedDescription)
        case .missGoogleIdToken:
                .userNotAutheficated
        case .userCancelledSignIn:
                .userCancelledSignInWithGoogle
        }
    }
}

extension AuthManagerError: Equatable {
    static func == (lhs: AuthManagerError, rhs: AuthManagerError) -> Bool {
        switch (lhs, rhs) {
        case (.emailIsAlreadyInUse, .emailIsAlreadyInUse), (.userNotFound, .userNotFound),
            (.missGoogleIdToken, .missGoogleIdToken), (.userCancelledSignIn, .userCancelledSignIn):
            return true
        case (.invalidEmail(let lErr), .invalidEmail(let rErr)),
             (.networkError(let lErr), .networkError(let rErr)),
             (.unknown(let lErr), .unknown(let rErr)):
            return lErr.localizedDescription == rErr.localizedDescription
        default:
            return false
        }
    }
}
