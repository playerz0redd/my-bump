//
//  ChatFactory.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.06.26.
//

import Foundation

protocol ChatScreenFactoryProtocol {
    func buildChatViewModel(with id: String) -> ChatViewModel
    func buildChatListViewModel() -> ChatListViewModel
}

final class ChatScreenFactory: ChatScreenFactoryProtocol {
    
    private let userSessionManager: UserSessionProtocol
    private let cloudStorageManager: CloudStorageManagerProtocol
    private let chatManager: ChatManagerProtocol
    private let userStorageManager: UserStorageManagerProtocol
    
    init(dependency: DependencyContainer) {
        self.userSessionManager = dependency.userSessionManager
        self.cloudStorageManager = dependency.cloudStorageManager
        self.userStorageManager = dependency.userStorageManager
        self.chatManager = dependency.chatsManager
    }
    
    func buildChatListViewModel() -> ChatListViewModel {
        let chatsService = ChatService(dependency: .init(
            chatManager: chatManager,
            userSessionManager: userSessionManager,
            userStorageManager: userStorageManager,
            cloudStorageManager: cloudStorageManager)
        )
        let modelMapper = ChatModelMapper(
            userStorageManager: userStorageManager,
            userSessionManager: userSessionManager,
            cloudStorageManager: cloudStorageManager
        )
        
        return ChatListViewModel(chatsService: chatsService, chatsMapper: modelMapper)
    }
    
    func buildChatViewModel(with id: String) -> ChatViewModel {
        let messagesMapper = MessagesModelMapper(
            cloudStorageManager: cloudStorageManager,
            userSessionManager: userSessionManager
        )
        
        let messageServiceDependency = MessagesService.DependencyContainer(
            messageManager: MessageManager(),
            cloudStorageManager: cloudStorageManager,
            userSessionManager: userSessionManager
        )
        
        let messageService = MessagesService(chatId: id, dependency: messageServiceDependency)
        return ChatViewModel(dependency: .init(
            messagesMapper: messagesMapper,
            messagesService: messageService)
        )
    }
}

extension ChatScreenFactory {
    struct DependencyContainer {
        let userSessionManager: UserSessionProtocol
        let cloudStorageManager: CloudStorageManagerProtocol
        let chatsManager: ChatManagerProtocol
        let userStorageManager: UserStorageManagerProtocol
    }
}
