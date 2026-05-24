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
    
    private let profileService: ProfileServiceProtocol
    
    init(profileService: ProfileServiceProtocol) {
        self.profileService = profileService
        fetchAvatarPath()
        fetchUsername()
    }
    
    private func fetchUsername() {
        self.username = profileService.username
    }
    
    func fetchAvatarPath() {
        Task {
            do {
                let path = try await profileService.getAvatarPath(width: 300, height: 300)
                self.avatarPath = path
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func signOut() {
        do {
            try profileService.signOut()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func onImagePick(image: Data) {
        Task {
            self.avatarPath = nil
            try await profileService.uploadAvatar(image: image)
            fetchAvatarPath()
        }
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
                "Frozen Location"
            case .blurLocation:
                "Precise Ghosting"
            }
        }
        
        var caption: LocalizedStringResource {
            switch self {
            case .freezeLocation:
                "Stay still on map for everyone while you move around."
            case .blurLocation:
                "Your location is blurred to a 500m radius for strangers."
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
                "GHOST"
            case .defaultMode:
                "DEFAULT"
            }
        }
    }
}
