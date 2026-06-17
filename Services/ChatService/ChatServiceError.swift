//
//  ChatServiceError.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.06.26.
//

import Foundation

enum ChatServiceError: Error {
    case fetchChatsError(ChatManagerError)
    case createChatError(ChatManagerError)
    case fetchUserIdError
    
    var message: LocalizedStringResource {
        switch self {
        case .fetchChatsError(let error), .createChatError(let error):
            error.message
        case .fetchUserIdError:
            LocalizedStringResource.couldNotFetchUserId
        }
    }
}
