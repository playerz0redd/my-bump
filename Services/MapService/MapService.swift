//
//  MapService.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 21.04.26.
//

import Foundation
import Combine
import CoreLocation

protocol MapServiceProtocol {
    func observeLocation() -> AnyPublisher<CLLocationCoordinate2D, Never>
    func observeFrindLocation(with id: String) -> AnyPublisher<FriendLocationModel, Never>
}

final class MapService: MapServiceProtocol {
    
    private let locationManager: LocationManagerProtocol
    private let locationSyncManager: LocationSyncManagerProtocol
    private let userSessionManager: UserSessionProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(dependency: DependencyContainer) {
        self.locationManager = dependency.locationManager
        self.locationSyncManager = dependency.locationSyncManager
        self.userSessionManager = dependency.userSessionManager
        
        guard let userId = userSessionManager.userId else { return }
        
        locationManager.locationPublisher
            .throttle(for: .seconds(5), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] coord in
                self?.locationSyncManager.updateLocation(userId: userId, location: coord.coordinate)
            }
            .store(in: &cancellables)
    }
    
    func observeFrindLocation(with id: String) -> AnyPublisher<FriendLocationModel, Never> {
        return locationSyncManager.observeLocation(for: id)
            .map({ FriendLocationModel(from: $0) })
            .eraseToAnyPublisher()
    }
    
    func observeLocation() -> AnyPublisher<CLLocationCoordinate2D, Never> {
        locationManager.requestPermission()
        locationManager.startTracking()
        
        return locationManager.locationPublisher
            .map(\.coordinate)
            .eraseToAnyPublisher()
    }
}

extension MapService {
    struct DependencyContainer {
        let locationManager: LocationManagerProtocol
        let locationSyncManager: LocationSyncManagerProtocol
        let userSessionManager: UserSessionProtocol
    }
}
