//
//  UserStorageError.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 29.04.26.
//

import Foundation

enum UserStorageError: Error {
    case permissionDenied
    case networkError(Error)
    case unknown(Error)
    
    var message: LocalizedStringResource {
        switch self {
        case .permissionDenied:
            LocalizedStringResource.permissionDenied
        case .networkError(let error):
            LocalizedStringResource.networkErrorSendingUserInfo(error.localizedDescription)
        case .unknown(let error):
            "Unknown error occured: \(error.localizedDescription)"
        }
    }
}

extension UserStorageError: Equatable {
    static func ==(lhs: UserStorageError, rhs: UserStorageError) -> Bool {
        switch (lhs, rhs) {
        case (.permissionDenied, .permissionDenied):
            return true
        case (.networkError(let lError), .networkError(let rError)), (.unknown(let lError), .unknown(let rError)):
            return lError.localizedDescription == rError.localizedDescription
        default:
            return false
        }
    }
}
