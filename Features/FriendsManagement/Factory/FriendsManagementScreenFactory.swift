//
//  FriendsManagementScreenFactory.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 17.06.26.
//

import Foundation

protocol FriendsManagementScreenFactoryProtocol {
    func buildFriendManagementViewModel() -> FriendsManagementViewModel 
}

final class FriendsManagementScreenFactory: FriendsManagementScreenFactoryProtocol {
    
    private let socialManager: SocialManagerProtocol
    private let userSessionManager: UserSessionProtocol
    private let userStorageManager: UserStorageManagerProtocol
    private let cloudStorageManager: CloudStorageManagerProtocol
    private let chatManager: ChatManagerProtocol
    
    init(dependency: DependencyContainer) {
        self.socialManager = dependency.socialManager
        self.userSessionManager = dependency.userSessionManager
        self.userStorageManager = dependency.userStorageManager
        self.cloudStorageManager = dependency.cloudStorageManager
        self.chatManager = dependency.chatManager
    }
    
    func buildFriendManagementViewModel() -> FriendsManagementViewModel {
        let chatService = ChatService(dependency: .init(
            chatManager: chatManager,
            userSessionManager: userSessionManager,
            userStorageManager: userStorageManager,
            cloudStorageManager: cloudStorageManager)
        )
        
        let socialService = SocialService(dependency: .init(
            socialManager: socialManager,
            userSessionManager: userSessionManager,
            userStorageManager: userStorageManager,
            cloudStorageManager: cloudStorageManager,
            chatService: chatService)
        )
        
        return FriendsManagementViewModel(socialService: socialService)
    }
}

extension FriendsManagementScreenFactory {
    struct DependencyContainer {
        let socialManager: SocialManagerProtocol
        let userSessionManager: UserSessionProtocol
        let userStorageManager: UserStorageManagerProtocol
        let cloudStorageManager: CloudStorageManagerProtocol
        let chatManager: ChatManagerProtocol
    }
}
