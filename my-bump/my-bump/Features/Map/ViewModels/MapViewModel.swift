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
    var friends: [String: FriendModel] = [:]
    var friendsLocations: [String: FriendLocationModel] = [:]
    
    private let mapService: MapServiceProtocol
    private let socialService: SocialServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(mapService: MapServiceProtocol, socialService: SocialServiceProtocol) {
        self.mapService = mapService
        self.socialService = socialService
        initializeFriends()
        observeMyLocation()
        observeFriends()
    }
    
    func getUserAvatar(forUserId id: String) -> URL? {
        guard let user = friends[id], let avatarPath = user.avatarPath else { return nil }
        return socialService.getUserAvatar(forImage: avatarPath, width: 50, height: 50)
    }
    
    func getUsername(forUserId id: String) -> String? {
        guard let user = friends[id] else { return nil }
        return user.name
    }
    
    private func observeFriends() {
        try? socialService.observeUsersByStatus(status: .friends)
            .receive(on: RunLoop.main)
            .sink { [weak self] friends in
                guard let self = self else { return }
                self.friends = self.friendsToDict(friends: friends)
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
            self.friends = friendsToDict(friends: friends)
            observeFriendsLocation()
        }
    }
    
    private func friendsToDict(friends: [FriendModel]) -> [String: FriendModel] {
        var friendsDictionary: [String: FriendModel] = [:]
        
        friends.forEach { friend in
            guard let id = friend.id else { return }
            friendsDictionary[id] = friend
        }
        return friendsDictionary
    }
    
    private func observeFriendsLocation() {
        friends.keys.forEach { id in
            mapService.observeFrindLocation(withId: id)
                .receive(on: RunLoop.main)
                .sink { [weak self] location in
                    self?.friendsLocations[location.userId] = location
                }
                .store(in: &cancellables)
        }
    }
}
