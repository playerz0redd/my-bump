//
//  ProfileService.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 20.05.26.
//

import Foundation

protocol ProfileServiceProtocol {
    func uploadAvatar(image: Data) async throws
    func getAvatarPath(width: Int, height: Int) async throws -> URL?
    var username: String? { get }
    func signOut() throws 
}

final class ProfileService: ProfileServiceProtocol {
    
    var username: String? {
        userSessionManager.username
    }
    
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
    
    func signOut() throws {
        try userSessionManager.signOut()
    }
    
    func getAvatarPath(width: Int, height: Int) async throws -> URL? {
        guard let userId = userSessionManager.userId,
              let avatarString = try await userStorageManager.getUserAvatarPath(forUserId: userId) else { return nil }
        
        let imageUrl = cloudStorageManager.getUrl(id: avatarString, width: width, height: height)
        return imageUrl
    }
    
    func uploadAvatar(image: Data) async throws {
        guard let userId = userSessionManager.userId else { return }
        
        let imageId = try await cloudStorageManager.uploadImage(image: image)
        try await userStorageManager.addUserAvatar(forUserId: userId, avatarId: imageId)
        try await socialManager.updateAvatarForFriends(userId: userId, newAvatar: imageId)
    }
}

extension ProfileService {
    struct DependencyContainer {
        let cloudStorageManager: CloudStorageManagerProtocol
        let userSessionManager: UserSessionProtocol
        let userStorageManager: UserStorageManagerProtocol
        let socialManager: SocialManagerProtocol
    }
}
