//
//  AppDependencyContainer.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 17.06.26.
//

import Foundation

final class AppDependencyContainer {
    private lazy var authManager: AuthManagerProtocol = FirebaseAuthManager()
    private lazy var chatManager: ChatManagerProtocol = ChatManager()
    private lazy var cloudStorageManager: CloudStorageManagerProtocol = CloudinaryManager()
    private lazy var locationManager: LocationManagerProtocol = LocationManager()
    private lazy var locationSyncManager: LocationSyncManagerProtocol = LocationSyncManager()
    private lazy var socialManager: SocialManagerProtocol = SocialManager()
    private lazy var userStorageManager: UserStorageManagerProtocol = UserStorageManager()
    private lazy var userSessionManager: UserSessionProtocol = FirebaseAuthManager()
}

extension AppDependencyContainer {
    func makeProfileFactory() -> ProfileScreenFactoryProtocol {
        ProfileScreenFactory(dependency: .init(
            cloudStorageManager: cloudStorageManager,
            userSessionManager: userSessionManager,
            userStorageManager: userStorageManager,
            socialManager: socialManager)
        )
    }
}

extension AppDependencyContainer {
    func makeMapFactory() -> MapScreenFactoryProtocol {
        MapScreenFactory(dependency: .init(
            locationManager: locationManager,
            locationSyncManager: locationSyncManager,
            userSessionManager: userSessionManager,
            socialManager: socialManager,
            userStorageManager: userStorageManager,
            cloudStorageManager: cloudStorageManager,
            chatManager: chatManager)
        )
    }
}

extension AppDependencyContainer {
    func makeFriendsManagementFactory() -> FriendsManagementScreenFactoryProtocol {
        FriendsManagementScreenFactory(dependency: .init(
            socialManager: socialManager,
            userSessionManager: userSessionManager,
            userStorageManager: userStorageManager,
            cloudStorageManager: cloudStorageManager,
            chatManager: chatManager)
        )
    }
}

extension AppDependencyContainer {
    func makeChatFactory() -> ChatScreenFactoryProtocol {
        ChatScreenFactory(dependency: .init(
            userSessionManager: userSessionManager,
            cloudStorageManager: cloudStorageManager,
            chatsManager: chatManager,
            userStorageManager: userStorageManager)
        )
    }
}

extension AppDependencyContainer {
    func makeAuthFactory() -> AuthScreenFactoryProtocol {
        AuthScreenFactory(authManager: authManager, userStorageManager: userStorageManager)
    }
}
