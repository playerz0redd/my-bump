//
//  ProfileServiceError.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.06.26.
//

import Foundation

enum ProfileServiceError: Error {
    case uploadImageError
    case fetchImagePathError(UserStorageError)
    case signOutError(AuthManagerError)
}
