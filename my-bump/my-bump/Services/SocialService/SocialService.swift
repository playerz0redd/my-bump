//
//  SocialService.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 30.04.26.
//

import Foundation
import Combine

protocol SocialServiceProtocol {
    func fetchUsers(withName name: String) async throws(SocialServiceError) -> [UserModel]
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
    
    init(socialManager: SocialManagerProtocol, userSessionManager: UserSessionProtocol, userStorageManager: UserStorageManagerProtocol, cloudStorageManager: CloudStorageManagerProtocol) {
        self.socialManager = socialManager
        self.userSessionManager = userSessionManager
        self.userStorageManager = userStorageManager
        self.cloudStorageManager = cloudStorageManager
    }
    
    func getUserAvatar(forImage id: String, width: Int, height: Int) -> URL? {
        cloudStorageManager.getUrl(id: id, width: width, height: height)
    }
    
    func getMyId() throws(SocialServiceError) -> String {
        guard let id = userSessionManager.userId else { throw .fetchUserDataError }
        return id
    }
    
    func fetchUsers(withName name: String) async throws(SocialServiceError) -> [UserModel] {
        do {
            let users = try await socialManager.findUsers(withName: name)
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
        } catch let error as SocialManagerError {
            throw .fetchUsersError(error)
        } catch let error as UserStorageError {
            throw .fetchUserDataError
        } catch let error {
            
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
