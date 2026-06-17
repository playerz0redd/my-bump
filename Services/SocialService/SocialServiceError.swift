//
//  SocialServiceError.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 4.05.26.
//

import Foundation

enum SocialServiceError: Error {
    case fetchUserDataError
    case fetchUsersError(SocialManagerError)
    case deleteRelationError(SocialManagerError)
    
    var message: LocalizedStringResource {
        switch self {
        case .fetchUserDataError:
            .couldNotFetchUserDataPleaseTryAgain
        case .fetchUsersError(let socialManagerError):
            socialManagerError.message
        case .deleteRelationError(let socialManagerError):
            socialManagerError.message
        }
    }
}
