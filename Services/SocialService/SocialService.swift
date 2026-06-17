//
//  SocialService.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 30.04.26.
//

import Foundation
import Combine

protocol SocialServiceProtocol {
    func fetchUsers(with name: String) async throws(SocialServiceError) -> [UserModel]
    func changeFriendStatus(
        userToId: String,
        userToName: String,
        userToAvatar: String?, 
        newStatus: FriendStatus
    ) async throws(SocialServiceError)
    
    func fetchUsersByStatus(status: FriendStatus) async throws(SocialServiceError) -> [FriendModel]
    func removeRelation(userToId: String) async throws(SocialServiceError)
    func getMyId() throws(SocialServiceError) -> String
    func observeUsersByStatus(status: FriendStatus) throws(SocialServiceError) -> AnyPublisher<[FriendModel], Never>
    func getUserAvatar(forImage id: String, width: Int, height: Int) -> URL?
}

final class SocialService: SocialServiceProtocol {
    
    private let socialManager: SocialManagerProtocol
    private let userSessionManager: UserSessionProtocol
    private let userStorageManager: UserStorageManagerProtocol
    private let cloudStorageManager: CloudStorageManagerProtocol
    private let chatService: ChatServiceProtocol
    
    init(dependency: DependencyContainer) {
        self.socialManager = dependency.socialManager
        self.userSessionManager = dependency.userSessionManager
        self.userStorageManager = dependency.userStorageManager
        self.cloudStorageManager = dependency.cloudStorageManager
        self.chatService = dependency.chatService
    }
    
    func getUserAvatar(forImage id: String, width: Int, height: Int) -> URL? {
        cloudStorageManager.getUrl(id: id, width: width, height: height)
    }
    
    func getMyId() throws(SocialServiceError) -> String {
        guard let id = userSessionManager.userId else { throw .fetchUserDataError }
        return id
    }
    
    func fetchUsers(with name: String) async throws(SocialServiceError) -> [UserModel] {
        do {
            let users = try await socialManager.findUsers(with: name)
            return users.map({ UserModel(from: $0) })
        } catch let error {
            throw .fetchUsersError(error)
        }
    }
    
    func observeUsersByStatus(status: FriendStatus) throws(SocialServiceError) -> AnyPublisher<[FriendModel], Never> {
        guard let myId = userSessionManager.userId else { throw .fetchUserDataError }
        return socialManager.observeUsersWithStatus(id: myId).map { friends in
            friends.compactMap({ $0.status == status ? FriendModel(from: $0) : nil })
        }
        .eraseToAnyPublisher()
    }
    
    func fetchUsersByStatus(status: FriendStatus) async throws(SocialServiceError) -> [FriendModel] {
        guard let myId = userSessionManager.userId else { throw .fetchUserDataError }
        do {
            return try await socialManager.fetchUsersByStatus(id: myId, status: status).map({ FriendModel(from: $0) })
        } catch let error {
            throw .fetchUsersError(error)
        }
    }
    
    func changeFriendStatus(
        userToId: String,
        userToName: String,
        userToAvatar: String?,
        newStatus: FriendStatus
    ) async throws(SocialServiceError) {
        guard let id = userSessionManager.userId, let name = userSessionManager.username else { throw .fetchUserDataError }
        do {
            let userFromAvatar: String? = try await userStorageManager.getUserAvatarPath(forUserId: id)
            let dto = ChangeFriendStatusDTO(
                userFrom: .init(
                    id: id,
                    name: name,
                    avatar: userFromAvatar),
                userTo: .init(
                    id: userToId,
                    name: userToName,
                    avatar: userToAvatar)
            )
            try await socialManager.changeFriendStatus(dto: dto, newStatus: newStatus)
            if newStatus == .friends {
                try await chatService.createChat(userWith: userToId)
            }
        } catch let error as SocialManagerError {
            throw .fetchUsersError(error)
        } catch _ as UserStorageError {
            throw .fetchUserDataError
        } catch {
            
        }
    }
    
    func removeRelation(userToId: String) async throws(SocialServiceError) {
        guard let id = userSessionManager.userId else { throw .fetchUserDataError }
        do {
            try await socialManager.removeRelation(userFromId: id, userToId: userToId)
        } catch let error {
            throw .deleteRelationError(error)
        }
    }
}

extension SocialService {
    struct DependencyContainer {
        let socialManager: SocialManagerProtocol
        let userSessionManager: UserSessionProtocol
        let userStorageManager: UserStorageManagerProtocol
        let cloudStorageManager: CloudStorageManagerProtocol
        let chatService: ChatServiceProtocol
    }
}
