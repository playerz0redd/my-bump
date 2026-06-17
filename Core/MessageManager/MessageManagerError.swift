//
//  MessageManagerError.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.06.26.
//

import Foundation

enum MessageManagerError: Error {
    case fetchError(Error)
    case uploadError(Error)
    
    var message: LocalizedStringResource {
        switch self {
        case .fetchError(let error):
            "Fetch error: \(error.localizedDescription)"
        case .uploadError(let error):
            LocalizedStringResource.uploadError(error.localizedDescription)
        }
    }
}
