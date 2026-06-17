//
//  ProfileService.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 20.05.26.
//

import Foundation

protocol ProfileServiceProtocol {
    var username: String? { get }
    func uploadAvatar(image: Data) async throws(ProfileServiceError)
    func getAvatarPath(width: Int, height: Int) async throws(ProfileServiceError) -> URL?
    func signOut() throws(ProfileServiceError)
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
    
    func signOut() throws(ProfileServiceError) {
        do {
            try userSessionManager.signOut()
        } catch {
            throw .signOutError(error)
        }
    }
    
    func getAvatarPath(width: Int, height: Int) async throws(ProfileServiceError) -> URL? {
        do {
            guard let userId = userSessionManager.userId,
                  let avatarString = try await userStorageManager.getUserAvatarPath(forUserId: userId) else { return nil }
            
            let imageUrl = cloudStorageManager.getUrl(id: avatarString, width: width, height: height)
            return imageUrl
        } catch {
            throw .fetchImagePathError(error)
        }
    }
    
    func uploadAvatar(image: Data) async throws(ProfileServiceError) {
        guard let userId = userSessionManager.userId else { return }
        
        do {
            let imageId = try await cloudStorageManager.uploadImage(image: image)
            try await userStorageManager.addUserAvatar(forUserId: userId, avatarId: imageId)
            try await socialManager.updateAvatarForFriends(userId: userId, newAvatar: imageId)
        } catch {
            throw .uploadImageError
        }
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
