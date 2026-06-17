//
//  MessagesServiceError.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 18.06.26.
//

import Foundation

enum MessagesServiceError: Error {
    case sendError(MessageManagerError)
    case fetchError(MessageManagerError)
    case fetchUserIdError
    case uploadImagesError(CloudStorageError)
    case unknown(Error)
    
    var message: LocalizedStringResource {
        switch self {
        case .sendError(let error):
            LocalizedStringResource.sendMessageError(error.message)
        case .fetchError(let error):
            LocalizedStringResource.fetchMessagesError(error.message)
        case .fetchUserIdError:
            LocalizedStringResource.fetchUserIdError
        case .uploadImagesError(let error):
            LocalizedStringResource.uploadImagesError(error.message)
        case .unknown(let error):
            LocalizedStringResource.uknownSendingMessageErrorOccured(error.localizedDescription)
        }
    }
}
