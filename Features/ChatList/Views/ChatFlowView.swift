//
//  ChatFlowView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 8.06.26.
//

import Foundation
import SwiftUI

struct ChatFlowView: View {
    @ObservedObject private var viewModel: ChatListViewModel
    @Bindable private var coordinator: ChatsCoordinator
    
    init(viewModel: ChatListViewModel, coordinator: ChatsCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.viewModel.onChatSelection = { [weak coordinator] chatId in
            coordinator?.push(with: .chat(id: chatId))
        }
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ChatListView(viewModel: viewModel)
                .ignoresSafeArea(.container, edges: .all)
                .navigationTitle(.chats)
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $viewModel.searchString, placement: .navigationBarDrawer, prompt: "Search")
                .navigationDestination(for: ChatRoutes.self) { route in
                    coordinator.getView(for: route)
                }
        }
    }
}
