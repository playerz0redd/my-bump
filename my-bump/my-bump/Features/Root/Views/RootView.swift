//
//  ContentView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 13.04.26.
//

import SwiftUI

struct RootView: View {
    
    @State private var authViewModel: AuthViewModel = .init(
        dependency: .init(
            authService: AuthService(authManager: FirebaseAuthManager(), userStorageManager: UserStorageManager()),
            validationService: ValidationService()
        )
    )
    @State private var mapviewModel: MapViewModel = .init(mapService: MapService(dependency: .init(locationManager: LocationManager(), locationSyncManager: LocationSyncManager(), userSessionManager: FirebaseAuthManager())), socialService: SocialService(socialManager: SocialManager(), userSessionManager: FirebaseAuthManager(), userStorageManager: UserStorageManager(), cloudStorageManager: CloudinaryManager()))
    
    @State private var managementviewModel: FriendsManagementViewModel = .init(socialService: SocialService(socialManager: SocialManager(), userSessionManager: FirebaseAuthManager(), userStorageManager: UserStorageManager(), cloudStorageManager: CloudinaryManager()))
    
    @State private var profileVm: ProfileViewModel = .init(profileService: ProfileService(dependency: .init(cloudStorageManager: CloudinaryManager(), userSessionManager: FirebaseAuthManager(), userStorageManager: UserStorageManager(), socialManager: SocialManager())))
    
    var body: some View {
        if authViewModel.isSignedIn {
            TabView {
                Tab {
                    MapView(viewModel: mapviewModel)
                }
                Tab {
                    FriendsManagementFlowView(viewModel: managementviewModel)
                }
                Tab {
                    ProfileView(viewModel: profileVm)
                }
            }
//            FriendsManagementFlowView(viewModel: .init(socialService: SocialService(socialManager: SocialManager(), userSessionManager: FirebaseAuthManager())))
        } else {
            AuthFlowView(viewModel: authViewModel)
        }
       // MapView(viewModel: .init(mapService: MapService(dependency: .init(locationManager: LocationManager(), locationSyncManager: LocationSyncManager(), userSessionManager: FirebaseAuthManager()))))
    }
}

