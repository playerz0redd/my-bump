//
//  ChatManagerError.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.06.26.
//

import Foundation

enum ChatManagerError: Error {
    case fetchError(Error)
    case createError(Error)
    
    var message: LocalizedStringResource {
        switch self {
        case .fetchError(let error):
            LocalizedStringResource.fetchChatsError(error.localizedDescription)
        case .createError(let error):
            LocalizedStringResource.createChatError(error.localizedDescription)
        }
    }
}
