//
//  FriendsManagementViewModel.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.05.26.
//

import Foundation
import Observation
import Combine

@MainActor @Observable
final class FriendsManagementViewModel {
    
    var requests: [FriendModel] = []
    var friends: [FriendModel] = []
    var requesting: [FriendModel] = []
    var searchUsers: [FriendModel] = []
    var isShowingFriendActions: Bool = false
    var selectedFriend: FriendModel?
    var isShowingAllFriends = false
    var isShowingAllRequests = false
    var searchBeetwenFriendsText: String = ""
    var socialError: SocialServiceError?
    
    var searchPeopleText: String = "" {
        didSet {
            searchSubject.send(searchPeopleText)
        }
    }
    
    var shouldShowMoreFriends: Bool {
        friends.count > maxVisibleItems
    }
    
    var moreFriendsCount: Int {
        friends.count - maxVisibleItems
    }
    
    var visibleFriends: [FriendModel] {
        var friends = friends
        if !searchBeetwenFriendsText.isEmpty {
            friends = friends.filter({ $0.name.lowercased().contains(searchBeetwenFriendsText.lowercased()) })
        }
        
        return isShowingAllFriends ? friends : Array(friends.prefix(maxVisibleItems))
    }
    
    var visibleRequests: [FriendModel] {
        isShowingAllRequests ? requests : Array(requests.prefix(maxVisibleItems))
    }
    
    private let maxVisibleItems: Int = 5
    private let searchSubject = PassthroughSubject<String, Never>()
    private let socialService: SocialServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(socialService: SocialServiceProtocol) {
        self.socialService = socialService
        updateData()
        setupSubscriptions()
    }
    
    func openFriendActions(friend: FriendModel) {
        self.selectedFriend = friend
        self.isShowingFriendActions = true
    }
    
    func avatarFirstLetter(friend: FriendModel) -> String {
        String(friend.name.prefix(1))
    }
    
    func updateData() {
        fetchFriends()
        fetchRequests()
        fetchRequesting()
    }
    
    func fetchUsersByName() {
        performTask {
            let myId = try self.socialService.getMyId()
            let users = try await self.socialService.fetchUsers(withName: self.searchPeopleText).filter({ $0.id != myId })
            
            let friendsSet: Set<FriendModel> = Set(self.friends)
            let requestsSet: Set<FriendModel> = Set(self.requests)
            let requestingSet: Set<FriendModel> = Set(self.requesting)
            
            self.searchUsers = users.map { FriendModel(
                id: $0.id,
                name: $0.name,
                status: self.getRelation(with: $0.id, friends: friendsSet, requests: requestsSet, requesting: requestingSet),
                timestamp: .now,
                avatarPath: $0.avatarPath
            )}
        }
    }
    
    func acceptInvite(person: FriendModel) {
        guard let personId = person.id else {
            assertionFailure(Assertions.acceptInviteAssetion.assertionString(name: person.name))
            return
        }

        performTask {
            try await self.socialService.changeFriendStatus(userToId: personId, userToName: person.name, userToAvatar: person.avatarPath, newStatus: .friends)
            self.requests.removeAll(where: { $0.id == personId })
            self.friends.append(FriendModel(
                id: personId,
                name: person.name,
                status: .friends,
                timestamp: .now,
                avatarPath: person.avatarPath
            ))
        }
    }
    
    func declineInvite(person: FriendModel) {
        guard let personId = person.id else {
            assertionFailure(Assertions.declineInviteAssertion.assertionString(name: person.name))
            return
        }

        performTask {
            try await self.socialService.removeRelation(userToId: personId)
            self.requests.removeAll(where: { $0.id == personId })
        }
    }
    
    func getAvatarUrl(forImage id: String?) -> URL? {
        guard let id = id else { return nil }
        return socialService.getUserAvatar(forImage: id, width: 100, height: 100)
    }
    
    func addToFriends(person: FriendModel) {
        guard let personId = person.id, let index = self.searchUsers.firstIndex(of: person) else {
            assertionFailure(Assertions.addToFrindsAssertion.assertionString(name: person.name))
            return
        }

        performTask {
            try await self.socialService.changeFriendStatus(userToId: personId, userToName: person.name, userToAvatar: person.avatarPath, newStatus: .requesting)
            self.searchUsers[index].status = .requesting
            self.requesting.append(FriendModel(id: person.id, name: person.name, status: .requesting, timestamp: .now, avatarPath: person.avatarPath))
        }
    }
    
    func buttonAction(action: FriendActions, friend: FriendModel) {
        switch action {
        case .viewProfile:
            break
        case .ghostMode:
            break
        case .removeFriend:
            removeFriend(friend: friend)
        }
    }
    
    private func setupSubscriptions() {
        observeSearchField()
        observeFriends()
        observeResponses()
        observeRequesting()
    }
    
    private func observeSearchField() {
        searchSubject
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchUsersByName()
            }
            .store(in: &cancellables)
    }
    
    private func observeFriends() {
        do {
            try socialService.observeUsersByStatus(status: .friends)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] friends in
                    self?.friends = friends
                }
                .store(in: &cancellables)
        } catch {
            self.socialError = error
        }
    }
    
    private func observeRequesting() {
        do {
            try socialService.observeUsersByStatus(status: .requesting)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] requests in
                    self?.requesting = requests
                }
                .store(in: &cancellables)
        } catch {
            self.socialError = error
        }
    }
    
    private func observeResponses() {
        do {
            try socialService.observeUsersByStatus(status: .responsing)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] responses in
                    self?.requests = responses
                }
                .store(in: &cancellables)
        } catch {
            self.socialError = error
        }
    }
    
    private func performTask(action: @escaping @MainActor () async throws -> Void) {
        Task {
            do {
                try await action()
            } catch let error as SocialServiceError {
                socialError = error
            }
        }
    }
    
    private func getRelation(
        with id: String?,
        friends: Set<FriendModel>,
        requests: Set<FriendModel>,
        requesting: Set<FriendModel>
    ) -> FriendStatus {
        guard let id = id else { return .unknown }
        
        if friends.contains(where: { $0.id == id}) {
            return .friends
        }
        if requests.contains(where: { $0.id == id}) {
            return .responsing
        }
        if requesting.contains(where: { $0.id == id}) {
            return .requesting
        }
        return .unknown
    }
    
    private func fetchRequesting() {
        performTask {
            self.requesting = try await self.socialService.fetchUsersByStatus(status: .requesting)
        }
    }
    
    private func removeFriend(friend: FriendModel) {
        guard let friendId = friend.id else {
            assertionFailure(Assertions.removeFriendAssertion.assertionString(name: friend.name))
            return
        }

        performTask {
            try await self.socialService.removeRelation(userToId: friendId)
            self.friends.removeAll(where: { $0 == friend })
            self.isShowingFriendActions = false
        }
    }
    
    private func fetchFriends() {
        performTask {
            self.friends = try await self.socialService.fetchUsersByStatus(status: .friends)
        }
    }
    
    private func fetchRequests() {
        performTask {
            self.requests = try await self.socialService.fetchUsersByStatus(status: .responsing)
        }
    }
}

private extension FriendsManagementViewModel {
    enum Assertions: String {
        case acceptInviteAssetion = "Attempted to accept an invite for a user with a missing or nil id:"
        case declineInviteAssertion = "Attempted to decline an invite for a user with a missing or nil id:"
        case addToFrindsAssertion = "Attempted to send an invite for a user with a missing or nil id:"
        case removeFriendAssertion = "Attempted to remove relation for a user with a missing or nil id:"
        
        func assertionString(name: String) -> String {
            self.rawValue + name
        }
    }
}

extension FriendsManagementViewModel {
    enum FriendActions: CaseIterable {
        case viewProfile
        case ghostMode
        case removeFriend
        
        var title: LocalizedStringResource {
            switch self {
            case .viewProfile:
                LocalizedStringResource.viewProfile
            case .ghostMode:
                LocalizedStringResource.ghostMode
            case .removeFriend:
                LocalizedStringResource.removeFriend
            }
        }
        
        var icon: String {
            switch self {
            case .viewProfile:
                "person"
            case .ghostMode:
                "eye.slash"
            case .removeFriend:
                "person.badge.minus"
            }
        }
    }
}
