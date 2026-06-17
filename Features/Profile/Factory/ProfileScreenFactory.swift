//
//  ProfileScreenFactory.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 17.06.26.
//

import Foundation

protocol ProfileScreenFactoryProtocol {
    func buildProfileViewModel() -> ProfileViewModel
}

final class ProfileScreenFactory: ProfileScreenFactoryProtocol {
    
    private let cloudStorageManager: CloudStorageManagerProtocol
    private let userSessionManager: UserSessionProtocol
    private let userStorageManager: UserStorageManagerProtocol
    private let socialManager: SocialManagerProtocol
    
    init(dependency: DependencyContainer) {
        self.cloudStorageManager = dependency.cloudStorageManager
        self.userSessionManager = dependency.userSessionManager
        self.userStorageManager = dependency.userStorageManager
        self.socialManager = dependency.socialManager
    }
    
    func buildProfileViewModel() -> ProfileViewModel {
        let profileService = ProfileService(dependency: .init(
            cloudStorageManager: cloudStorageManager,
            userSessionManager: userSessionManager,
            userStorageManager: userStorageManager,
            socialManager: socialManager)
        )
        
        return ProfileViewModel(profileService: profileService)
    }
}

extension ProfileScreenFactory {
    struct DependencyContainer {
        let cloudStorageManager: CloudStorageManagerProtocol
        let userSessionManager: UserSessionProtocol
        let userStorageManager: UserStorageManagerProtocol
        let socialManager: SocialManagerProtocol
    }
}
