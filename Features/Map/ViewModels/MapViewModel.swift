//
//  MapViewModel.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 21.04.26.
//

import Foundation
import Combine
import Observation
import CoreLocation

@Observable @MainActor
final class MapViewModel {
    
    var myCoordinates: CLLocationCoordinate2D = .init()
    var friendsState: [String: FriendMapState] = [:]
    
    private let mapService: MapServiceProtocol
    private let socialService: SocialServiceProtocol
    private let avatarSize: Int = 50
    private var cancellables: Set<AnyCancellable> = []
    
    init(mapService: MapServiceProtocol, socialService: SocialServiceProtocol) {
        self.mapService = mapService
        self.socialService = socialService
        initializeFriends()
        observeMyLocation()
        observeFriends()
    }
    
    func getUserAvatar(for id: String) -> URL? {
        guard let user = friendsState[id]?.friend, let avatarPath = user.avatarPath else { return nil }
        return socialService.getUserAvatar(forImage: avatarPath, width: avatarSize, height: avatarSize)
    }
    
    func getUsername(for id: String) -> String? {
        guard let user = friendsState[id]?.friend else { return nil }
        return user.name
    }
    
    private func observeFriends() {
        try? socialService.observeUsersByStatus(status: .friends)
            .receive(on: RunLoop.main)
            .sink { [weak self] friends in
                guard let self = self else { return }
                self.friendsState = self.friendsToDict(friends: friends)
            }
            .store(in: &cancellables)
    }
    
    private func observeMyLocation() {
        mapService.observeLocation()
            .receive(on: RunLoop.main)
            .sink { [weak self] coord in
                self?.myCoordinates = coord
            }
            .store(in: &cancellables)
    }
    
    private func initializeFriends() {
        Task {
            let friends = try await socialService.fetchUsersByStatus(status: .friends)
            self.friendsState = friendsToDict(friends: friends)
            observeFriendsLocation()
        }
    }
    
    private func friendsToDict(friends: [FriendModel]) -> [String: FriendMapState] {
        let pairs = friends.compactMap { friend -> (String, FriendMapState)? in
            guard let id = friend.id else { return nil }
            return (id, FriendMapState(friend: friend))
        }
        return Dictionary(uniqueKeysWithValues: pairs)
    }
    
    private func observeFriendsLocation() {
        friendsState.keys.forEach { id in
            mapService.observeFrindLocation(with: id)
                .receive(on: RunLoop.main)
                .sink { [weak self] location in
                    self?.friendsState[location.userId]?.location = location
                }
                .store(in: &cancellables)
        }
    }
}
