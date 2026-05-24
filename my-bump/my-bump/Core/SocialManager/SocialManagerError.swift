//
//  SocialManagerError.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 4.05.26.
//

import Foundation

enum SocialManagerError: Error {
    case fetchError(Error)
    case saveError(Error)
    case deleteError(Error)
    
    var message: LocalizedStringResource {
        switch self {
        case .fetchError(let error):
            .fetchError(error.localizedDescription)
        case .saveError(let error):
            .saveError(error.localizedDescription)
        case .deleteError(let error):
            .deletingError(error.localizedDescription)
        }
    }
}
