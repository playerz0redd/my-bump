//
//  ChatsCoordinator.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 9.06.26.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class ChatsCoordinator {
    
    var path: NavigationPath = .init() {
        didSet { if path.isEmpty { self.chatViewModel = nil }  }
    }
    
    private let chatFactory: ChatScreenFactoryProtocol
    private var chatViewModel: ChatViewModel?
    
    init(chatFactory: ChatScreenFactoryProtocol) {
        self.chatFactory = chatFactory
    }
    
    func push(with route: ChatRoutes) {
        switch route {
        case .chat(let id):
            chatViewModel = chatFactory.buildChatViewModel(with: id)
            path.append(route)
        }
    }
    
    func pop() {
        path.removeLast()
    }
}

extension ChatsCoordinator {
    @ViewBuilder
    func getView(for route: ChatRoutes) -> some View {
        switch route {
        case .chat:
            if let viewModel = self.chatViewModel {
                ChatView(viewModel: viewModel)
            }
        }
    }
}
