//
//  ProfileViewModel.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 20.05.26.
//

import Foundation
import Observation

@Observable @MainActor
final class ProfileViewModel {
    
    var avatarPath: URL?
    var username: String?
    var privacyStatus: PrivacyStatus = .defaultMode
    var isFreezeActive: Bool = false
    var isBlurActive: Bool = false
    var profileError: ProfileServiceError?
    
    private let profileService: ProfileServiceProtocol
    private let avatarSize: Int = 300
    
    init(profileService: ProfileServiceProtocol) {
        self.profileService = profileService
        fetchAvatarPath()
        fetchUsername()
    }
    
    func fetchAvatarPath() {
        Task {
            do {
                let path = try await profileService.getAvatarPath(width: avatarSize, height: avatarSize)
                self.avatarPath = path
            } catch let error as ProfileServiceError {
                self.profileError = error
            }
        }
    }
    
    func signOut() {
        do {
            try profileService.signOut()
        } catch {
            self.profileError = error
        }
    }
    
    func onImagePick(image: Data) {
        Task {
            self.avatarPath = nil
            try await profileService.uploadAvatar(image: image)
            fetchAvatarPath()
        }
    }
    
    private func fetchUsername() {
        self.username = profileService.username
    }
}

extension ProfileViewModel {
    enum SwitchButton {
        case freezeLocation
        case blurLocation
        
        var icon: String {
            switch self {
            case .freezeLocation:
                "snowflake"
            case .blurLocation:
                "target"
            }
        }
        
        var title: LocalizedStringResource {
            switch self {
            case .freezeLocation:
                LocalizedStringResource.frozenLocation
            case .blurLocation:
                LocalizedStringResource.preciseGhosting
            }
        }
        
        var caption: LocalizedStringResource {
            switch self {
            case .freezeLocation:
                LocalizedStringResource.stayStillOnMapForEveryoneWhileYouMoveAround
            case .blurLocation:
                LocalizedStringResource.yourLocationIsBlurredToA500MRadiusForStrangers
            }
        }
    }
}

extension ProfileViewModel {
    enum PrivacyStatus {
        case ghostMode
        case defaultMode
        
        var title: LocalizedStringResource {
            switch self {
            case .ghostMode:
                LocalizedStringResource.ghost
            case .defaultMode:
                LocalizedStringResource.`default`
            }
        }
    }
}

