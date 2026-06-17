//
//  MapScreenFactory.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 17.06.26.
//

import Foundation

protocol MapScreenFactoryProtocol {
    func buildMapViewModel() -> MapViewModel
}

final class MapScreenFactory: MapScreenFactoryProtocol {
    
    private let locationManager: LocationManagerProtocol
    private let locationSyncManager: LocationSyncManagerProtocol
    private let userSessionManager: UserSessionProtocol
    private let socialManager: SocialManagerProtocol
    private let userStorageManager: UserStorageManagerProtocol
    private let cloudStorageManager: CloudStorageManagerProtocol
    private let chatManager: ChatManagerProtocol
    
    init(dependency: DependencyContainer) {
        self.locationManager = dependency.locationManager
        self.locationSyncManager = dependency.locationSyncManager
        self.userSessionManager = dependency.userSessionManager
        self.socialManager = dependency.socialManager
        self.userStorageManager = dependency.userStorageManager
        self.cloudStorageManager = dependency.cloudStorageManager
        self.chatManager = dependency.chatManager
    }
    
    func buildMapViewModel() -> MapViewModel {
        let mapService = MapService(dependency: .init(
            locationManager: locationManager,
            locationSyncManager: locationSyncManager,
            userSessionManager: userSessionManager)
        )
        
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
        
        return MapViewModel(mapService: mapService, socialService: socialService)
    }
}

extension MapScreenFactory {
    struct DependencyContainer {
        let locationManager: LocationManagerProtocol
        let locationSyncManager: LocationSyncManagerProtocol
        let userSessionManager: UserSessionProtocol
        let socialManager: SocialManagerProtocol
        let userStorageManager: UserStorageManagerProtocol
        let cloudStorageManager: CloudStorageManagerProtocol
        let chatManager: ChatManagerProtocol
    }
}


