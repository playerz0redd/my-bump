//
//  CloudStorageError.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.06.26.
//

import Foundation

enum CloudStorageError: Error {
    case apiError(Error)
    case unknownError
    
    var message: LocalizedStringResource {
        switch self {
        case .apiError(let error):
            LocalizedStringResource.apiErrorOccured(error.localizedDescription)
        case .unknownError:
            LocalizedStringResource.unknownError
        }
    }
}
