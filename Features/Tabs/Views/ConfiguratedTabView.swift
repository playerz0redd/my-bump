//
//  ConfiguratedTabView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 17.06.26.
//

import Foundation
import SwiftUI

struct ConfiguratedTabView: View {
    
    @State private var mapViewModel: MapViewModel
    @State private var profileViewModel: ProfileViewModel
    @StateObject private var chatListViewModel: ChatListViewModel
    @State private var friendsManagementViewModel: FriendsManagementViewModel
    @State private var chatCoordinator: ChatsCoordinator
    
    private let container: AppDependencyContainer
    
    init(container: AppDependencyContainer) {
        self.container = container
        let chatFactory = container.makeChatFactory()
        
        _chatCoordinator = State(wrappedValue: ChatsCoordinator(chatFactory: chatFactory))
        _mapViewModel = State(wrappedValue: container.makeMapFactory().buildMapViewModel())
        _profileViewModel = State(wrappedValue: container.makeProfileFactory().buildProfileViewModel())
        _chatListViewModel = StateObject(wrappedValue: chatFactory.buildChatListViewModel())
        _friendsManagementViewModel = State(
            wrappedValue: container.makeFriendsManagementFactory().buildFriendManagementViewModel()
        )
    }
    
    var body: some View {
        NavigationStack {
            TabView {
                Tab("", systemImage: Assets.map.rawValue) {
                    MapView(viewModel: mapViewModel)
                }
                Tab("", systemImage: Assets.friends.rawValue) {
                    FriendsManagementFlowView(viewModel: friendsManagementViewModel)
                }
                Tab("", systemImage: Assets.chats.rawValue) {
                    ChatFlowView(viewModel: chatListViewModel, coordinator: chatCoordinator)
                }
                Tab("", systemImage: Assets.profile.rawValue) {
                    ProfileView(viewModel: profileViewModel)
                }
            }
        }
    }
}

private extension ConfiguratedTabView {
    enum Assets: String {
        case map = "globe.europe.africa.fill"
        case friends = "person.2.fill"
        case chats = "bubble.left.and.bubble.right.fill"
        case profile = "person.circle.fill"
    }
}
